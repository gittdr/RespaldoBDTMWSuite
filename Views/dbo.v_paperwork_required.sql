SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_paperwork_required] (
cmp_id
,doc_type 
,doc_name 
,charge_code
,charge_desc
,require_type
,isrequired
,invoice_attach
,application_code
,freight_event 
,attach_bc
,attach_misc
)
as
--Paperwork required by billto company
select cmp_id
, bdt_doctype 
, l.name 
, '[ALL]'
, '[ALL]' 
, 'C' 
, isnull(bdt_inv_required, 'N')
, isnull(bdt_inv_attach, 'N')
, isnull(bdt_required_for_application, 'B')
, isnull(bdt_required_for_fgt_event, 'B') 
, isnull(bdt_inv_attachBC, 'N')
, isnull(bdt_inv_attachMisc, 'N')
from BillDoctypes d 
left outer join labelfile l on l.abbr = d.bdt_doctype and l.labeldefinition = 'Paperwork' and IsNULL(l.retired,'N') <> 'Y' 

UNION

--Paperwork required for charge code, all companies
select '[ALL]'
,cpw_paperwork
,l.name
,cht_itemcode
,cht_description
,cht_paperwork_requiretype
,UPPER(isnull(cpw_inv_required,'N'))
,UPPER(isnull(cpw_inv_attach,'N'))
,'I'  --charge types are required for invoicing only
,'B'
,'N'
,'N'
from chargetype c
join chargetypepaperwork cpw on cpw.cht_number = c.cht_number
join labelfile l on l.abbr = cpw.cpw_paperwork and l.labeldefinition = 'Paperwork' and IsNULL(l.retired,'N') <> 'Y' 
where cht_paperwork_requiretype = 'A'

UNION

--Paperwork required for charge code for specific companies
select cmp.cmp_id
,cpw_paperwork
,l.name
,cht_itemcode
,cht_description
,cht_paperwork_requiretype
,UPPER(isnull(cpw_inv_required,'N'))
,UPPER(isnull(cpw_inv_attach,'N'))
,'I' --charge types are required for invoicing only
,'B'
,'N'
,'N'
from chargetype c
join chargetypepaperwork cpw on cpw.cht_number = c.cht_number
join chargetypepaperworkcmp cmp on cmp.cht_number = cpw.cht_number
join labelfile l on l.abbr = cpw.cpw_paperwork and l.labeldefinition = 'Paperwork' and IsNULL(l.retired,'N') <> 'Y' 
where cht_paperwork_requiretype = 'O'

UNION

--Paperwork required for charge code excluding certain companies
select cmp.cmp_id
,cpw_paperwork
,l.name
,cht_itemcode
,cht_description
,cht_paperwork_requiretype
,UPPER(isnull(cpw_inv_required,'N'))
,UPPER(isnull(cpw_inv_attach,'N'))
,'I' --charge types are required for invoicing only
,'B'
,'N'
,'N'
from chargetype c
join chargetypepaperwork cpw on cpw.cht_number = c.cht_number
join chargetypepaperworkcmp cmpw on cmpw.cht_number = c.cht_number
join labelfile l on l.abbr = cpw.cpw_paperwork and l.labeldefinition = 'Paperwork' and IsNULL(l.retired,'N') <> 'Y' 
join company cmp on cmpw.cmp_id <> cmp.cmp_id and cmp.cmp_active = 'Y' and cmp_billto = 'Y'
where cht_paperwork_requiretype = 'E'

GO
GRANT SELECT ON  [dbo].[v_paperwork_required] TO [public]
GO
