SELECT DISTINCT order_date
FROM grocery_growth_analytics.blinkit_orders
WHERE order_date IS NOT NULL
  AND order_date !~ '^\d{4}-\d{2}-\d{2}';


DROP TABLE IF EXISTS grocery_growth_analytics.stg_orders;

CREATE TABLE grocery_growth_analytics.stg_orders AS
WITH cleaned AS (
    SELECT
        order_id,
        customer_id,
        store_id,
        order_date,
        order_total,
        payment_method,
        delivery_partner_id,
        promised_delivery_time,
        actual_delivery_time,
        delivery_status
    FROM grocery_growth_analytics.blinkit_orders
    WHERE order_date ~ '^\d{4}-\d{2}-\d{2}'
),
ranked AS (
    SELECT
        order_id,
        customer_id,
        store_id,
        order_date::timestamp AS order_ts,
        NULLIF(regexp_replace(order_total, '[^0-9\.\-]', '', 'g'), '')::numeric AS order_total,
        payment_method,
        delivery_partner_id,
        NULLIF(promised_delivery_time, '')::timestamp AS promised_ts,
        NULLIF(actual_delivery_time, '')::timestamp AS actual_ts,
        delivery_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_date::timestamp DESC
        ) AS rn
    FROM cleaned
)
SELECT
    order_id,
    customer_id,
    store_id,
    order_ts,
    order_ts::date AS order_date,
    order_total,
    payment_method,
    delivery_partner_id,
    promised_ts,
    actual_ts,
    delivery_status
FROM ranked
WHERE rn = 1;
