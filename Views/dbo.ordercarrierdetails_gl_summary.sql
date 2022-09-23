SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[ordercarrierdetails_gl_summary]
as
select oc_id, glnum, account_type, 
sum(amount) as amount, 
sum(debit_amount) as debit_amount, 
sum(credit_amount) as credit_amount
from ordercarrierdetails_gl
group by oc_id, glnum, account_type
GO
GRANT DELETE ON  [dbo].[ordercarrierdetails_gl_summary] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercarrierdetails_gl_summary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercarrierdetails_gl_summary] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercarrierdetails_gl_summary] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercarrierdetails_gl_summary] TO [public]
GO
