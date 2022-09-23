SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROC [dbo].[ResNow_UpdateOrderStatus]
	(
		@PriorCycleTime datetime = '19500101'
	)
					
AS


	insert into ResNow_OrderStatusChanges (ord_hdrnumber,lgh_number,mov_number,updated_by,updated_dt,PriorStatus,NextStatus)
	select ord_hdrnumber
	,lgh_number
	,mov_number
	,updated_by
	,updated_dt
	,PriorStatus = SUBSTRING(SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),CHARINDEX('->',SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),1)-4,3)
	,NextStatus = SUBSTRING(SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),CHARINDEX('->',SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),1)+3,3)
	from expedite_audit EA (NOLOCK)
	where updated_dt >= @PriorCycleTime
	AND join_to_table_name = 'orderheader'
	AND update_note like '%Status%'
	AND NOT Exists
		(
			select ord_hdrnumber
			from ResNow_OrderStatusChanges ROSC (NOLOCK)
			where ROSC.ord_hdrnumber = EA.ord_hdrnumber
			AND ROSC.updated_dt = EA.updated_dt
		)




	--exec ResNow_UpdateOrderStatus @PriorCycleTime = @LastCycleTime
	
GO
GRANT EXECUTE ON  [dbo].[ResNow_UpdateOrderStatus] TO [public]
GO
