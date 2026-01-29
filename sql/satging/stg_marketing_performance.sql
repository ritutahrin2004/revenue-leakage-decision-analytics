DROP TABLE IF EXISTS grocery_growth_analytics.stg_marketing_performance;

CREATE TABLE grocery_growth_analytics.stg_marketing_performance AS
WITH cleaned AS (
    SELECT
        campaign_id,
        order_date AS raw_date,
        campaign_name,
        channel,
        impressions,
        clicks,
        conversions,
        spend,
        revenue_generated,
        roas
    FROM grocery_growth_analytics.blinkit_marketing_performance
    WHERE COALESCE(order_date, '') NOT IN ('', 'date')
),
typed AS (
    SELECT
        campaign_id,
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
        END AS campaign_date,

        NULLIF(campaign_name, '') AS campaign_name,
        NULLIF(channel, '') AS channel,

        NULLIF(regexp_replace(impressions, '[^0-9\.\-]', '', 'g'), '')::numeric AS impressions,
        NULLIF(regexp_replace(clicks, '[^0-9\.\-]', '', 'g'), '')::numeric AS clicks,
        NULLIF(regexp_replace(conversions, '[^0-9\.\-]', '', 'g'), '')::numeric AS conversions,
        NULLIF(regexp_replace(spend, '[^0-9\.\-]', '', 'g'), '')::numeric AS spend,

        -- raw column name is 'evenue_generated'
        NULLIF(regexp_replace(revenue_generated, '[^0-9\.\-]', '', 'g'), '')::numeric AS revenue_generated,

        NULLIF(regexp_replace(roas, '[^0-9\.\-]', '', 'g'), '')::numeric AS roas
    FROM cleaned
)
SELECT
    campaign_id,
    campaign_date,
    campaign_name,
    channel,
    impressions,
    clicks,
    conversions,
    spend,
    revenue_generated,
    roas
FROM typed
WHERE campaign_date IS NOT NULL;
