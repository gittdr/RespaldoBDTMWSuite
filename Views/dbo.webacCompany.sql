SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[webacCompany] as
select cmp_id,cmp_name,cmp_billto,cmp_shipper,cmp_consingee as cmp_consignee,cmp_active,cmp_id+' | '+cmp_name+' | '+ isnull(cmp_altid, '') as cmp_lookup 
from company (nolock)
GO
GRANT DELETE ON  [dbo].[webacCompany] TO [public]
GO
GRANT INSERT ON  [dbo].[webacCompany] TO [public]
GO
GRANT SELECT ON  [dbo].[webacCompany] TO [public]
GO
GRANT UPDATE ON  [dbo].[webacCompany] TO [public]
GO
