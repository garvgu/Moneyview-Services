WITH emandate_data AS (
    SELECT
        DATE_TRUNC(DATE(e.date_created), MONTH) AS month,
                                   -- vendor field
        e.instrument_type AS instrument,      -- instrument type
        COUNT(DISTINCT e.id) AS attempts,
        COUNT(DISTINCT CASE 
                          WHEN er.mandate_status IN ('registration_success','payment_success','refunded')
                          THEN er.loan_application_id_ref 
                       END) AS success
    FROM mv-dw-wi.lending.emandate_attempt e
    LEFT JOIN mv-dw-wi.lending.emandate_registered er
        ON e.id = er.id
    WHERE DATE(e.date_created) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
  AND e.registration_instrument IS NOT NULL
  AND e.registration_instrument NOT IN ('OTHERS','physical','','(empty)')
  group by 1,2
)

SELECT
    month,
    
    instrument,
    attempts,
    success,
    SAFE_DIVIDE(success, attempts) * 100 AS success_rate
FROM emandate_data
ORDER BY month, instrument;
