-- Analysis: Customer impact by delay bucket (rating + negative sentiment)
SELECT
  CASE
    WHEN d.delay_minutes <= 0 THEN 'On-time'
    WHEN d.delay_minutes <= 10 THEN 'Late: 0-10m'
    WHEN d.delay_minutes <= 30 THEN 'Late: 10-30m'
    WHEN d.delay_minutes <= 60 THEN 'Late: 30-60m'
    ELSE 'Late: 60m+'
  END AS delay_bucket,
  COUNT(*) AS orders,
  AVG(f.rating) AS avg_rating,
  AVG(CASE WHEN LOWER(f.sentiment) IN ('negative','neg') THEN 1 ELSE 0 END)::numeric(10,4) AS pct_negative
FROM grocery_growth_analytics.stg_delivery_performance d
LEFT JOIN grocery_growth_analytics.stg_customer_feedback f
  ON f.order_id = d.order_id
WHERE d.delay_minutes IS NOT NULL
GROUP BY 1
ORDER BY 1;



