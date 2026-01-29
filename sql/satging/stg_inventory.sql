DROP TABLE IF EXISTS grocery_growth_analytics.stg_inventory;

CREATE TABLE grocery_growth_analytics.stg_inventory AS
WITH unioned AS (
    SELECT
        product_id,
        Order_date AS raw_date,
        stock_received,
        damaged_stock,
        'blinkit_inventory' AS source_table
    FROM grocery_growth_analytics.blinkit_inventory

    UNION ALL

    SELECT
        product_id,
        Order_date AS raw_date,
        stock_received,
        damaged_stock,
        'blinkit_inventoryNew' AS source_table
    FROM grocery_growth_analytics."blinkit_inventory_new"
),
cleaned AS (
    SELECT
        product_id,
        raw_date,
        NULLIF(regexp_replace(stock_received, '[^0-9\.\-]', '', 'g'), '')::numeric AS stock_received,
        NULLIF(regexp_replace(damaged_stock, '[^0-9\.\-]', '', 'g'), '')::numeric AS damaged_stock,
        source_table
    FROM unioned
    WHERE COALESCE(raw_date, '') NOT IN ('', 'date', 'Order_date')
),
typed AS (
    SELECT
        product_id,
        source_table,
        CASE
            WHEN raw_date ~ '^\d{4}-\d{2}-\d{2}$'
                THEN raw_date::date
            WHEN raw_date ~ '^\d{4}/\d{2}/\d{2}$'
                THEN to_date(raw_date, 'YYYY/MM/DD')
            WHEN raw_date ~ '^\d{2}-\d{2}-\d{4}$'
                THEN to_date(raw_date, 'DD-MM-YYYY')
            WHEN raw_date ~ '^\d{2}/\d{2}/\d{4}$'
                THEN to_date(raw_date, 'DD/MM/YYYY')
            ELSE NULL
        END AS inventory_date,
        stock_received,
        damaged_stock
    FROM cleaned
)
SELECT
    product_id,
    inventory_date,
    stock_received,
    damaged_stock,
    source_table
FROM typed
WHERE inventory_date IS NOT NULL;
