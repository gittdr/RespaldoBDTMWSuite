SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROC [dbo].[dwUpdateOrderStatus]
	(
		@Datasource varchar(32)
		,@PriorCycleTime datetime = '19500101'
		,@ThisCycleTime datetime = NULL
	)
					
AS

--set @Datasource = 'JB'
--set @PriorCycleTime = '19500101'
--set @ThisCycleTime = '20130904 07:05:24.444'

If @ThisCycleTime is NULL 
	Set @ThisCycleTime = GETDATE()

-- Part 1: update the order status changes since last cycle
--insert into dwOrderStatusChanges (Datasource,ord_hdrnumber,updated_by,updated_dt,PriorStatus,NextStatus,DateAdded)
select @Datasource
,ord_hdrnumber
,updated_by
,updated_dt
,PriorStatus = SUBSTRING(SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),CHARINDEX('->',SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),1)-4,3)
,NextStatus = SUBSTRING(SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),CHARINDEX('->',SUBSTRING(update_note,CHARINDEX('Status',update_note,1),20),1)+3,3)
,DateAdded = @ThisCycleTime
from expedite_audit EA with (NOLOCK)
where updated_dt >= @PriorCycleTime
AND EXISTS
	(
		select ord_hdrnumber
		from orderheader OH with (NOLOCK)
		where EA.ord_hdrnumber = OH.ord_hdrnumber
	)
AND join_to_table_name = 'orderheader'
AND update_note like '%Status%'
--AND NOT Exists
--	(
--		select ord_hdrnumber
--		from dwOrderStatusChanges ROSC with (NOLOCK)
--		where ROSC.ord_hdrnumber = EA.ord_hdrnumber
--		AND ROSC.updated_dt = EA.updated_dt
--	)

GO
GRANT EXECUTE ON  [dbo].[dwUpdateOrderStatus] TO [public]
GO
