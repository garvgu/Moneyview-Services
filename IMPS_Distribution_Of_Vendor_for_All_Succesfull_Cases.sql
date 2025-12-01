with imps_monthly as (
    select
        date_trunc(cast(pir.date_created as date), month) as month,
        pir.vendor_id,
        count(distinct case 
            when pir.status = 'SUCCESS' 
             and pir.paynimo_msg <> 'Copied Transaction' 
            then pir.loan_application_id_ref 
        end) as success
    from mv-dw-wi.lending.paynimo_imps_request pir
    left join mv-dw-wi.lending.loan_application la
      on la.id = pir.loan_application_id_ref
     and la.product_type = 1
    where cast(pir.date_created as date) >= date '2025-06-01'   -- Start of June
      and cast(pir.date_created as date) <= current_date        -- Till today
    group by 1, 2
),
with_totals as (
    select
        month,
        vendor_id,
        success,
        sum(success) over (partition by month) as month_total
    from imps_monthly
)
select
    month,
    vendor_id,
    success,
    month_total,
    round(success * 100.0 / month_total, 2) as vendor_share_pct
from with_totals
order by month, vendor_id;
