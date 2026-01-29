DROP TABLE IF EXISTS grocery_growth_analytics.stg_order_items;

CREATE TABLE grocery_growth_analytics.stg_order_items AS
WITH ranked AS (
    SELECT
        order_id,
        product_id,
        NULLIF(regexp_replace(quantity, '[^0-9\.\-]', '', 'g'), '')::numeric AS quantity,
        NULLIF(regexp_replace(unit_price, '[^0-9\.\-]', '', 'g'), '')::numeric AS unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, product_id
            ORDER BY quantity DESC NULLS LAST
        ) AS rn
    FROM grocery_growth_analytics.blinkit_order_items
)
SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_revenue
FROM ranked
WHERE rn = 1;
