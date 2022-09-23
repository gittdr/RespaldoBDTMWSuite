SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[legheaderbrokered_gl_summary]
as
select lgh_number, gl_type, glnum, account_type, 
sum(ordercarrierdetails_gl.amount) as amount, 
sum(debit_amount) as debit_amount, 
sum(credit_amount) as credit_amount
from ordercarrierdetails_gl 
join ordercarrier on ordercarrier.id = ordercarrierdetails_gl.oc_id
group by lgh_number, gl_type, glnum, account_type
GO
GRANT DELETE ON  [dbo].[legheaderbrokered_gl_summary] TO [public]
GO
GRANT INSERT ON  [dbo].[legheaderbrokered_gl_summary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheaderbrokered_gl_summary] TO [public]
GO
GRANT SELECT ON  [dbo].[legheaderbrokered_gl_summary] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheaderbrokered_gl_summary] TO [public]
GO
