WITH emandate_data AS (
    SELECT
        DATE_TRUNC(DATE(e.date_created), MONTH) AS month,
        e.registration_instrument AS actual_instrument,
        COUNT(DISTINCT e.id) AS Attempt_Count,
        COUNT(DISTINCT CASE 
                          WHEN er.mandate_status IN ('registration_success','payment_success','refunded')
                          THEN er.loan_application_id_ref 
                       END) AS App_Success
    FROM mv-dw-wi.lending.emandate_attempt e
    LEFT JOIN mv-dw-wi.lending.emandate_registered er
        ON e.id = er.id
    WHERE DATE(e.date_created) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
      AND e.registration_instrument IS NOT NULL                -- remove empty/null
      AND e.registration_instrument NOT IN ('OTHERS','physical','(empty)')   -- remove "others" and "physical nach"
    GROUP BY 1, 2
)

SELECT
    actual_instrument,
    month,
    Attempt_Count,
    App_Success,
    SAFE_DIVIDE(App_Success, Attempt_Count) * 100 AS Success_Percent
FROM emandate_data
ORDER BY actual_instrument, month;
