SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--PTS 46118 JJF 20090717
CREATE PROCEDURE [dbo].[d_ticket_order_entry_master] (
	@mst_ord_hdrnumber	int
)

AS
	
	SELECT 
			toem.ord_hdrnumber,
			toem.toem_plan_status,
			toem.toem_update_reason,
			toem.toem_comments
	FROM	ticket_order_entry_master toem
	WHERE	toem.ord_hdrnumber = @mst_ord_hdrnumber
GO
GRANT EXECUTE ON  [dbo].[d_ticket_order_entry_master] TO [public]
GO
