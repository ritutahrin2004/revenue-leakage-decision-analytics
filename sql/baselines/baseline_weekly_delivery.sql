-- Baseline: Weekly delivery performance (late rate + p95 delay)
SELECT
  DATE_TRUNC('week', o.order_ts)::date AS week_start,
  COUNT(DISTINCT o.order_id) AS orders,
  AVG(CASE WHEN d.delay_minutes > 0 THEN 1 ELSE 0 END)::numeric(10,4) AS pct_late,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY d.delay_minutes) AS p95_delay_minutes,
  AVG(d.delay_minutes) AS avg_delay_minutes
FROM grocery_growth_analytics.stg_orders o
JOIN grocery_growth_analytics.stg_delivery_performance d
  ON d.order_id = o.order_id
WHERE o.order_ts IS NOT NULL
  AND d.delay_minutes IS NOT NULL
GROUP BY 1
ORDER BY 1;
