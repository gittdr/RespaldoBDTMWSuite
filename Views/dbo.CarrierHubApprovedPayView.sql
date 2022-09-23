SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[CarrierHubApprovedPayView] AS
select lgh_number [Leg Number], d.ord_hdrnumber [Order], d.asgn_id [Carrier], d.asgn_type [AssignType],
	d.pyd_number [Pay Detail Number],
	ISNULL(d.pyt_itemcode,'') [Item Code],
	ISNULL(t.pyt_description,'') [Pay Type],
	ISNULL(d.pyd_description,'') [Description], 
	d.pyd_quantity [Quantity],
	d.pyd_rate [Rate],
	d.pyd_amount [Amount], 
	ISNULL(l.name,'') [Status], 
	ISNULL(d.pyd_carinvnum,'') [Carrier Invoice], 
	d.pyd_carinvdate [Invoice Date], 
	d.pyd_transdate [Trans Date],
	d.pyd_updatedby [Updated By],
	d.pyd_updatedon [Updated On],
	d.pyd_createdon [Created On],
	d.pyd_createdby [Created By],
	ISNULL(d.pyd_remarks,'') [Remark]
from paydetail as d
	join paytype as t on t.pyt_itemcode = d.pyt_itemcode
	left outer join payheader as h on h.pyh_pyhnumber = d.pyh_number
	join labelfile as l on l.abbr = isnull(h.pyh_paystatus, d.pyd_status) and labeldefinition ='PayStatus'
where  d.pyd_status not in ('HLD')

GO
GRANT SELECT ON  [dbo].[CarrierHubApprovedPayView] TO [public]
GO
