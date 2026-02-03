-- Baseline: Weekly net revenue
SELECT
  DATE_TRUNC('week', order_ts)::date AS week_start,
  COUNT(DISTINCT order_id) AS orders,
  SUM(order_total) AS net_revenue
FROM grocery_growth_analytics.stg_orders
WHERE order_ts IS NOT NULL
  AND order_total IS NOT NULL
GROUP BY 1
ORDER BY 1;
