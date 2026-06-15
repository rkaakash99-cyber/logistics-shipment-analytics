# ── Imports ──────────────────────────────────────────────
from sqlalchemy import create_engine
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns

# ── Connect & load data ──────────────────────────────────
engine = create_engine(
    "mysql+pymysql://",
    connect_args={
        "host"    : "localhost",
        "user"    : "root",
        "password": "****",  
        "database": "logistics_db"
    }
)

query = """
SELECT
    s.shipment_id,
    ca.carrier_name,
    s.shipment_date,
    s.expected_delivery,
    s.actual_delivery,
    s.delivery_status,
    s.destination_city,
    s.freight_cost,
    p.category,
    si.total_price
FROM shipments s
JOIN customers      c  ON s.customer_id  = c.customer_id
JOIN warehouses     w  ON s.warehouse_id = w.warehouse_id
JOIN carriers       ca ON s.carrier_id   = ca.carrier_id
JOIN shipment_items si ON s.shipment_id  = si.shipment_id
JOIN products       p  ON si.product_id  = p.product_id
"""

with engine.connect() as conn:
    df = pd.read_sql(query, conn)

# ── Clean & prepare ──────────────────────────────────────
df['shipment_date']     = pd.to_datetime(df['shipment_date'])
df['expected_delivery'] = pd.to_datetime(df['expected_delivery'])
df['actual_delivery']   = pd.to_datetime(df['actual_delivery'])
df['shipment_month']    = df['shipment_date'].dt.to_period('M').astype(str)
df['is_delayed']        = df['delivery_status'] == 'Delayed'

# ── Global style ─────────────────────────────────────────
sns.set_theme(style="whitegrid", palette="muted")
plt.rcParams.update({
    "figure.dpi"      : 120,
    "axes.titlesize"  : 13,
    "axes.titleweight": "bold",
    "axes.labelsize"  : 11,
    "xtick.labelsize" : 10,
    "ytick.labelsize" : 10,
})

# ════════════════════════════════════════════════════════
# CHART 1 — Monthly Shipment Volume (Line Chart)
# Business question: Is our shipment volume growing month on month?
# ════════════════════════════════════════════════════════
monthly = (df.groupby('shipment_month')['shipment_id']
             .nunique()
             .reset_index()
             .rename(columns={'shipment_id': 'shipments'}))

fig, ax = plt.subplots(figsize=(8, 4))
ax.plot(monthly['shipment_month'], monthly['shipments'],
        marker='o', linewidth=2.5, color='#2196F3', markersize=7)

for i, row in monthly.iterrows():
    ax.annotate(str(row['shipments']),
                xy=(i, row['shipments']),
                xytext=(0, 10), textcoords='offset points',
                ha='center', fontsize=10, color='#2196F3', fontweight='bold')

ax.set_title("Monthly Shipment Volume")
ax.set_xlabel("Month")
ax.set_ylabel("Number of Shipments")
ax.yaxis.set_major_locator(mticker.MaxNLocator(integer=True))
plt.xticks(rotation=15)
plt.tight_layout()
plt.savefig("chart1_monthly_volume.png", dpi=150)
plt.show()
print("Chart 1 saved.")

# ════════════════════════════════════════════════════════
# CHART 2 — Revenue by Product Category (Bar Chart)
# Business question: Which product category generates the most revenue?
# ════════════════════════════════════════════════════════
cat_rev = (df.groupby('category')['total_price']
             .sum()
             .reset_index()
             .rename(columns={'total_price': 'revenue'})
             .sort_values('revenue', ascending=False))

fig, ax = plt.subplots(figsize=(8, 4))
bars = ax.bar(cat_rev['category'], cat_rev['revenue'],
              color=sns.color_palette("Blues_d", len(cat_rev)))

for bar in bars:
    ax.text(bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 200,
            f"₹{bar.get_height():,.0f}",
            ha='center', va='bottom', fontsize=9, fontweight='bold')

ax.set_title("Revenue by Product Category")
ax.set_xlabel("Category")
ax.set_ylabel("Total Revenue (₹)")
ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"₹{x:,.0f}"))
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig("chart2_revenue_category.png", dpi=150)
plt.show()
print("Chart 2 saved.")

# ════════════════════════════════════════════════════════
# CHART 3 — Delivery Status Breakdown (Pie Chart)
# Business question: What percentage of shipments are on time vs delayed?
# ════════════════════════════════════════════════════════
status_counts = df.groupby('delivery_status')['shipment_id'].nunique()

colors = {'Delivered': '#4CAF50', 'Delayed': '#F44336', 'In Transit': '#FF9800'}
pie_colors = [colors.get(s, '#90A4AE') for s in status_counts.index]

fig, ax = plt.subplots(figsize=(6, 6))
wedges, texts, autotexts = ax.pie(
    status_counts,
    labels=status_counts.index,
    autopct='%1.1f%%',
    colors=pie_colors,
    startangle=140,
    pctdistance=0.75,
    wedgeprops=dict(edgecolor='white', linewidth=2)
)
for t in autotexts:
    t.set_fontsize(11)
    t.set_fontweight('bold')

ax.set_title("Delivery Status Breakdown")
plt.tight_layout()
plt.savefig("chart3_delivery_status.png", dpi=150)
plt.show()
print("Chart 3 saved.")

# ════════════════════════════════════════════════════════
# CHART 4 — Carrier Delay Rate (Grouped Bar Chart)
# Business question: Which carrier has the worst on-time performance?
# ════════════════════════════════════════════════════════
carrier_perf = df.groupby('carrier_name').agg(
    total = ('shipment_id', 'nunique'),
    delayed = ('is_delayed', 'sum')
).reset_index()
carrier_perf['on_time']    = carrier_perf['total'] - carrier_perf['delayed']
carrier_perf['delay_pct']  = (carrier_perf['delayed'] / carrier_perf['total'] * 100).round(1)
carrier_perf = carrier_perf.sort_values('delay_pct', ascending=False)

x = range(len(carrier_perf))
width = 0.35

fig, ax = plt.subplots(figsize=(8, 4))
b1 = ax.bar([i - width/2 for i in x], carrier_perf['on_time'],
            width, label='On Time', color='#4CAF50')
b2 = ax.bar([i + width/2 for i in x], carrier_perf['delayed'],
            width, label='Delayed', color='#F44336')

for bar in list(b1) + list(b2):
    ax.text(bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 0.05,
            str(int(bar.get_height())),
            ha='center', va='bottom', fontsize=9)

ax.set_title("Carrier Performance — On Time vs Delayed")
ax.set_xlabel("Carrier")
ax.set_ylabel("Number of Shipments")
ax.set_xticks(list(x))
ax.set_xticklabels(carrier_perf['carrier_name'], rotation=10)
ax.yaxis.set_major_locator(mticker.MaxNLocator(integer=True))
ax.legend()
plt.tight_layout()
plt.savefig("chart4_carrier_performance.png", dpi=150)
plt.show()
print("Chart 4 saved.")

# ════════════════════════════════════════════════════════
# CHART 5 — Freight Cost by Destination City (Horizontal Bar)
# Business question: Which cities cost the most to ship to?
# ════════════════════════════════════════════════════════
city_freight = (df.groupby('destination_city')['freight_cost']
                  .sum()
                  .reset_index()
                  .rename(columns={'freight_cost': 'total_freight'})
                  .sort_values('total_freight'))

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.barh(city_freight['destination_city'], city_freight['total_freight'],
               color=sns.color_palette("Oranges_d", len(city_freight)))

for bar in bars:
    ax.text(bar.get_width() + 50,
            bar.get_y() + bar.get_height() / 2,
            f"₹{bar.get_width():,.0f}",
            va='center', fontsize=9, fontweight='bold')

ax.set_title("Total Freight Cost by Destination City")
ax.set_xlabel("Total Freight Cost (₹)")
ax.set_ylabel("City")
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"₹{x:,.0f}"))
plt.tight_layout()
plt.savefig("chart5_freight_by_city.png", dpi=150)
plt.show()
print("Chart 5 saved.")

print("\nAll 5 charts saved successfully!")