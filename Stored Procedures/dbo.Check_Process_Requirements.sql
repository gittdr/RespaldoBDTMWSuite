SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[Check_Process_Requirements] @mov_number int,
	@flag int output
as

if exists (select * from stops, orderheader, Process_Requirements
	where 	stops.mov_number = @mov_number and
		stops.ord_hdrnumber = orderheader.ord_hdrnumber and
		orderheader.ord_billto = Process_Requirements.prq_billto)
	select @flag = 1
else 
	select @flag = 0
GO
GRANT EXECUTE ON  [dbo].[Check_Process_Requirements] TO [public]
GO
