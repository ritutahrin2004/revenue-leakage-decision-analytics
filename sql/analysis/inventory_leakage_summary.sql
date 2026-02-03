-- Analysis: Inventory risk share summary (avg/min/max across weeks)
WITH weekly_stress AS (
  SELECT
    product_id,
    DATE_TRUNC('week', inventory_date)::date AS week_start,
    SUM(
      CASE
        WHEN COALESCE(stock_received,0) - COALESCE(damaged_stock,0) <= 0 THEN 1
        ELSE 0
      END
    ) AS stressed_days
  FROM grocery_growth_analytics.stg_inventory
  WHERE inventory_date IS NOT NULL
  GROUP BY 1,2
),
weekly_product_revenue AS (
  SELECT
    oi.product_id,
    DATE_TRUNC('week', o.order_ts)::date AS week_start,
    SUM(oi.quantity * oi.unit_price) AS product_revenue
  FROM grocery_growth_analytics.stg_order_items oi
  JOIN grocery_growth_analytics.stg_orders o
    ON oi.order_id = o.order_id
  WHERE o.order_ts IS NOT NULL
  GROUP BY 1,2
),
weekly_inventory_risk AS (
  SELECT
    w.week_start,
    CASE
      WHEN SUM(w.product_revenue) > 0
        THEN SUM(CASE WHEN s.stressed_days >= 3 THEN w.product_revenue ELSE 0 END) / SUM(w.product_revenue)
    END AS share_revenue_inventory_risk
  FROM weekly_product_revenue w
  LEFT JOIN weekly_stress s
    ON w.product_id = s.product_id
   AND w.week_start = s.week_start
  GROUP BY 1
)
SELECT
  AVG(share_revenue_inventory_risk) AS avg_share_revenue_inventory_risk,
  MIN(share_revenue_inventory_risk) AS min_share_revenue_inventory_risk,
  MAX(share_revenue_inventory_risk) AS max_share_revenue_inventory_risk
FROM weekly_inventory_risk;
