SELECT DISTINCT actual_time
FROM grocery_growth_analytics.blinkit_delivery_performance
WHERE actual_time IS NOT NULL
  AND actual_time NOT IN ('actual_time', '')
LIMIT 50;

DROP TABLE IF EXISTS grocery_growth_analytics.stg_delivery_performance;

CREATE TABLE grocery_growth_analytics.stg_delivery_performance AS
WITH cleaned AS (
    SELECT
        order_id,
        delivery_partner_id,
        promised_time,
        actual_time,
        delivery_time_minutes,
        distance_km,
        delivery_status,
        reasons_if_delayed
    FROM grocery_growth_analytics.blinkit_delivery_performance
    WHERE COALESCE(promised_time, '') NOT IN ('', 'promised_time')
      AND COALESCE(actual_time, '') NOT IN ('', 'actual_time')
),
typed AS (
    SELECT
        order_id,
        delivery_partner_id,

        CASE
            WHEN promised_time ~ '^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?$'
                THEN promised_time::timestamp
            ELSE NULL
        END AS promised_ts,

        CASE
            WHEN actual_time ~ '^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?$'
                THEN actual_time::timestamp
            ELSE NULL
        END AS actual_ts,

        NULLIF(regexp_replace(delivery_time_minutes, '[^0-9\.\-]', '', 'g'), '')::numeric AS delivery_time_minutes,
        NULLIF(regexp_replace(distance_km, '[^0-9\.\-]', '', 'g'), '')::numeric AS distance_km,

        NULLIF(delivery_status, '') AS delivery_status,
        NULLIF(reasons_if_delayed, '') AS reasons_if_delayed
    FROM cleaned
)
SELECT
    order_id,
    delivery_partner_id,
    promised_ts,
    actual_ts,
    delivery_time_minutes,
    distance_km,
    delivery_status,
    reasons_if_delayed,
    CASE
        WHEN promised_ts IS NOT NULL AND actual_ts IS NOT NULL
            THEN EXTRACT(EPOCH FROM (actual_ts - promised_ts)) / 60.0
        ELSE NULL
    END AS delay_minutes
FROM typed
WHERE order_id IS NOT NULL;
