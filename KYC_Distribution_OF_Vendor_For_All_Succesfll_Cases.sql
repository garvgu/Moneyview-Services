WITH OKYC AS (
    SELECT
        DATE_TRUNC(date_created, MONTH) AS month,
        COUNT(*) AS attempts,
        COUNTIF(status = 'COMPLETED') AS success
    FROM mv-dw-wi.lending.okyc_info
    WHERE CAST(date_created AS DATE) >= DATE '2025-06-01'
      AND CAST(date_created AS DATE) <= CURRENT_DATE
      
    GROUP BY month
),

-- Digilocker
digilocker AS (
    SELECT
        DATE_TRUNC(date_created, MONTH) AS month,
        COUNT(*) AS attempts,
        COUNTIF(status = 'COMPLETED') AS success
    FROM mv-dw-wi.lending.digio_kyc
    WHERE CAST(date_created AS DATE) >= DATE '2025-06-01'
      AND CAST(date_created AS DATE) <= CURRENT_DATE
    GROUP BY month
),

-- Combine and add totals
combined AS (
    SELECT month, 'OKYC' AS vendor, attempts, success FROM OKYC
    UNION ALL
    SELECT month, 'Digilocker' AS vendor, attempts, success FROM digilocker
)

SELECT
    month,
    vendor,
    attempts,
    success,
    ROUND(success*10/ NULLIF(attempts,0),2) AS success_rate
FROM combined
ORDER BY month, vendor;
