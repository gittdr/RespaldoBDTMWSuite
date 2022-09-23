SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROC [dbo].[dwUpdateOrderTouchCount]
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

-- Part 2: update the order touch count for orders involved in this cycle
create table #TempOrderList (ord_hdrnumber int)

insert into #TempOrderList (ord_hdrnumber)
select distinct ord_hdrnumber
from expedite_audit EA with (NOLOCK)
where updated_dt >= @PriorCycleTime
AND EXISTS
	(
		select ord_hdrnumber
		from orderheader OH with (NOLOCK)
		where EA.ord_hdrnumber = OH.ord_hdrnumber
	)

select @Datasource
,ord_hdrnumber
,TouchCount = count(ord_hdrnumber)
,DateUpdated = @ThisCycleTime
from expedite_audit EA with (NOLOCK)
where Exists 
	(
		select ord_hdrnumber
		from #TempOrderList
		where EA.ord_hdrnumber = #TempOrderList.ord_hdrnumber
	)
group by ord_hdrnumber

drop table #TempOrderList

GO
GRANT EXECUTE ON  [dbo].[dwUpdateOrderTouchCount] TO [public]
GO
