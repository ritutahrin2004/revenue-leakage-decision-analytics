-- Analysis: Revenue share associated with late deliveries (ops leakage proxy)
SELECT
  DATE_TRUNC('week', o.order_ts)::date AS week_start,
  SUM(o.order_total) AS total_revenue,
  SUM(CASE WHEN d.delay_minutes > 0 THEN o.order_total ELSE 0 END) AS late_order_revenue,
  CASE
    WHEN SUM(o.order_total) > 0
      THEN SUM(CASE WHEN d.delay_minutes > 0 THEN o.order_total ELSE 0 END) / SUM(o.order_total)
  END AS share_revenue_late
FROM grocery_growth_analytics.stg_orders o
JOIN grocery_growth_analytics.stg_delivery_performance d
  ON d.order_id = o.order_id
WHERE o.order_ts IS NOT NULL
  AND o.order_total IS NOT NULL
  AND d.delay_minutes IS NOT NULL
GROUP BY 1
ORDER BY 1;


