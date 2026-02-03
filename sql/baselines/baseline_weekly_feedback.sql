-- Baseline: Weekly customer feedback (negative sentiment + rating)
SELECT
  DATE_TRUNC('week', feedback_ts)::date AS week_start,
  COUNT(*) AS feedback_count,
  AVG(CASE WHEN LOWER(sentiment) IN ('negative','neg') THEN 1 ELSE 0 END)::numeric(10,4) AS pct_negative,
  AVG(rating) AS avg_rating
FROM grocery_growth_analytics.stg_customer_feedback
WHERE feedback_ts IS NOT NULL
GROUP BY 1
ORDER BY 1;

