SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[CarrierHubNotApprovedPayView] AS
select lgh_number [Leg Number], d.ord_hdrnumber [Order], asgn_id [Carrier], asgn_type [AssignType],
	d.pyd_number [Pay Detail Number],
	ISNULL(d.pyt_itemcode,'') [Item Code],
	ISNULL(t.pyt_description,'') [Pay Type],
	ISNULL(d.pyd_description,'') [Description], 
	d.pyd_quantity [Quantity],
	d.pyd_rate [Rate],
	d.pyd_amount [Amount], 
	ISNULL(l.name,'') [Status], 
	ISNULL(d.pyd_ref_invoice,'') [Carrier Invoice], 
	d.pyd_ref_invoicedate [Invoice Date], 
	d.pyd_transdate [Trans Date],
	d.pyd_updatedby [Updated By],
	d.pyd_updatedon [Updated On],
	d.pyd_createdon [Created On],
	d.pyd_createdby [Created By],
	ISNULL(d.pyd_remarks,'') [Remark]
from paydetail as d
	join paytype as t on t.pyt_itemcode = d.pyt_itemcode
	join labelfile as l on l.abbr = d.pyd_status and labeldefinition ='PayStatus'
where d.pyd_status in ('HLD')
GO
GRANT SELECT ON  [dbo].[CarrierHubNotApprovedPayView] TO [public]
GO
