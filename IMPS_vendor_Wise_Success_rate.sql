with imps_monthly as (
    select
        date_trunc(cast(pir.date_created as date), month) as month,
        pir.vendor_id,
        -- successful transactions
        count(distinct case 
            when pir.status = 'SUCCESS' 
             and pir.paynimo_msg <> 'Copied Transaction' 
            then pir.loan_application_id_ref 
        end) as success,
        -- total attempts
        count(distinct pir.loan_application_id_ref) as attempts
    from mv-dw-wi.lending.paynimo_imps_request pir
    left join mv-dw-wi.lending.loan_application la
      on la.id = pir.loan_application_id_ref
     and la.product_type = 1
    where cast(pir.date_created as date) >= date '2025-06-01'   -- Start of June
      and cast(pir.date_created as date) <= current_date        
    group by 1, 2
)
select
    month,
    vendor_id,
    attempts,
    success,
    safe_divide(success, attempts) as success_rate
from imps_monthly
order by month, vendor_id;
