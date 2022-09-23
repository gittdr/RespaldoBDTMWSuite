SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--PTS 46118 JJF 20090717
CREATE PROCEDURE [dbo].[d_ticket_order_entry_master_audit] (
	@mst_ord_hdrnumber	int
)

AS
	
		SELECT 
				toema.ord_hdrnumber,
				isnull(lbl_plnstat.name, toema.toema_plan_status) as toema_plan_status_name,
				toema.toema_updateby,
				toema.toema_updatedate,
				isnull(lbl_reason.name, toema.toema_update_reason) as toema_update_reason_name,
				toema.toema_comments
		FROM	ticket_order_entry_master_audit toema
				LEFT OUTER JOIN labelfile lbl_plnstat on lbl_plnstat.abbr = toema.toema_plan_status
														and lbl_plnstat.labeldefinition = 'PlanMasterStatus'
				LEFT OUTER JOIN labelfile lbl_reason on  lbl_reason.abbr = toema.toema_update_reason
														and lbl_reason.labeldefinition = 'PlanMasterStatReason'
		WHERE	toema.ord_hdrnumber = @mst_ord_hdrnumber

	UNION

		SELECT 
				oh.ord_hdrnumber,
				isnull(lbl_plnstat.name, 'Pending') as toema_plan_status_name,
				oh.ord_bookedby,
				oh.ord_bookdate,
				'',
				'Order initially booked'
		FROM	orderheader oh
				LEFT OUTER JOIN labelfile lbl_plnstat on lbl_plnstat.abbr = 'PND'
														and lbl_plnstat.labeldefinition = 'PlanMasterStatus'
		WHERE	oh.ord_hdrnumber = @mst_ord_hdrnumber
	
	
	
GO
GRANT EXECUTE ON  [dbo].[d_ticket_order_entry_master_audit] TO [public]
GO
