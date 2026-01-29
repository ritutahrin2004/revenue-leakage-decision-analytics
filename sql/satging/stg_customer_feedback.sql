SELECT DISTINCT feedback_date
FROM grocery_growth_analytics.blinkit_customer_feedback
WHERE feedback_date IS NOT NULL
  AND feedback_date NOT IN ('', 'feedback_date')
LIMIT 50;

DROP TABLE IF EXISTS grocery_growth_analytics.stg_customer_feedback;

CREATE TABLE grocery_growth_analytics.stg_customer_feedback AS
WITH cleaned AS (
    SELECT
        feedback_id,
        order_id,
        customer_id,
        rating,
        feedback_text,
        feedback_category,
        sentiment,
        feedback_date
    FROM grocery_growth_analytics.blinkit_customer_feedback
    WHERE COALESCE(feedback_date, '') NOT IN ('', 'feedback_date')
),
typed AS (
    SELECT
        feedback_id,
        order_id,
        customer_id,
        NULLIF(regexp_replace(rating, '[^0-9\.\-]', '', 'g'), '')::numeric AS rating,
        NULLIF(feedback_text, '') AS feedback_text,
        NULLIF(feedback_category, '') AS feedback_category,
        NULLIF(sentiment, '') AS sentiment,

        CASE
            WHEN feedback_date ~ '^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?$'
                THEN feedback_date::timestamp
            ELSE NULL
        END AS feedback_ts
    FROM cleaned
)
SELECT
    feedback_id,
    order_id,
    customer_id,
    rating,
    feedback_text,
    feedback_category,
    sentiment,
    feedback_ts,
    feedback_ts::date AS feedback_date
FROM typed
WHERE feedback_id IS NOT NULL;
