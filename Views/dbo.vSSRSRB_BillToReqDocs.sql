SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 100 * from vSSRSRB_BillToReqDocs


CREATE            view [dbo].[vSSRSRB_BillToReqDocs]

as

/**
 *
 * NAME:
 * dbo.vSSRSRB_BillToReqDocs
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/
 
 
SELECT   
case  [App] when 'I' then 'Invoicing'
     when  'B' then 'Both'
	 when  'S' then 'Settlements'
	 else 'NA'
	 End As 'Required for Application',
	 *
	 from

(
		  Select
		  bd.cmp_id as 'Company ID',
		  (select cmp_name from company where cmp_id = bd.cmp_id) as 'Company Name',
		  --added by mreed 12/14/2012.
		 (select top 1 tpr_id from Thirdpartyrelationship where bd.cmp_id = tprel_tablekey and tprel_table = 'company.billto' and tpr_type = 'Tpr1')  as [Agent],
		 (select top 1 tpr_id from Thirdpartyrelationship where bd.cmp_id = tprel_tablekey and tprel_table = 'company.billto' and tpr_type = 'Tpr2')  as [SalesPerson],
		  --end add
		  bd.bdt_doctype as 'Document Type',
		  (select top 1 name from labelfile where abbr = bd.bdt_doctype and labeldefinition = 'paperwork') as 'Document Name',
		  bd.bdt_inv_required as 'Required for Invoicing',
		  bd.bdt_required_for_application 'App'
		 From BillDoctypes bd  (nolock)
		 )
		 as tempdoc

GO
GRANT DELETE ON  [dbo].[vSSRSRB_BillToReqDocs] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_BillToReqDocs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_BillToReqDocs] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_BillToReqDocs] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_BillToReqDocs] TO [public]
GO
