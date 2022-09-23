SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[revenueallocation_summary]
as
select ivh_number, ral_glnum, ral_distribution_type, 
case when (ral_distribution_type='Taxes') then cht_itemcode else '' end as tax_code,
sum(ral_amount) as ral_amount, 
sum(ral_debit_amount) as ral_debit_amount, 
sum(ral_credit_amount) as ral_credit_amount,
sum(ral_inv_debit_amount) as ral_inv_debit_amount,
sum(ral_inv_credit_amount) as ral_inv_credit_amount,
sum(ral_system_debit_amount) as ral_system_debit_amount,
sum(ral_system_credit_amount) as ral_system_credit_amount
from revenueallocation
group by ivh_number, ral_glnum, ral_distribution_type, case when (ral_distribution_type='Taxes') then cht_itemcode else '' end
GO
GRANT DELETE ON  [dbo].[revenueallocation_summary] TO [public]
GO
GRANT INSERT ON  [dbo].[revenueallocation_summary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[revenueallocation_summary] TO [public]
GO
GRANT SELECT ON  [dbo].[revenueallocation_summary] TO [public]
GO
GRANT UPDATE ON  [dbo].[revenueallocation_summary] TO [public]
GO
