SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.sch_transactions    Script Date: 6/1/99 11:55:07 AM ******/
create procedure [dbo].[sch_transactions] 
	@batch			char(1),
	@schedule_date	datetime,
	@view_id			integer,
	@company			varchar(12),
	@subcompany			varchar(8),
	@revtype1			varchar(40),
	@revtype2			varchar(40),
	@revtype3			varchar(40),
	@revtype4			varchar(40)

as
/* jude 1/15/97 */
declare @no_of_copies integer

select @no_of_copies = 1
/* jude 1/15/97 */

SELECT @schedule_date schedule_date,
	@view_id view_id, 
	oh.ord_revtype1, 	
	oh.ord_subcompany, 	
	oh.ord_company, 	
	oh.ord_hdrnumber, 	
	oh.ord_number, 	
	sc.mpp_id, 	
	sc.trc_number, 	
	sc.trl_id, 	
	sc.car_id , 
	dateadd(day,sc.sch_dispatch, @schedule_date) dispatch_date , 
	oh.ord_revtype2, 
	oh.ord_revtype3, 
	oh.ord_revtype4,
	'RevType1' revtype1, 
	'RevType2' revtype2, 
	'RevType3' revtype3, 
	'RevType4' revtype4,  
	sc.sch_multisch,  
	sc.sch_timeofday,
	@no_of_copies no_of_copies
into #temp1  
FROM orderheader oh,
	schedule_table sc 
WHERE ((oh.ord_company = @company) or (@company = 'UNKNOWN')) and
	(oh.ord_subcompany = @subcompany) and
	(@revtype1 LIKE "%"+oh.ord_revtype1+"%" or @revtype1 = 'UNK') and
	(@revtype2 LIKE "%"+oh.ord_revtype2+"%"  or @revtype2 = 'UNK') and
	(@revtype3 LIKE  "%"+oh.ord_revtype3+"%" or @revtype3 = 'UNK') and
	(@revtype4 LIKE  "%"+oh.ord_revtype4+"%" or @revtype4 = 'UNK') and
	(oh.ord_hdrnumber = sc.ord_hdrnumber) and
	(oh.ord_status = 'MST') and 
	((datepart(weekday, @schedule_date) = sc.sch_dow) or (sc.sch_specificdate = @schedule_date))


update #temp1
set schedule_date = dateadd(hh,datepart(hh,sch_timeofday),schedule_date)
where sch_timeofday is not null

update #temp1
set schedule_date = dateadd(mi,datepart(mi,sch_timeofday),schedule_date)
where sch_timeofday is not null

update #temp1
set dispatch_date = dateadd(hh,datepart(hh,sch_timeofday),dispatch_date)
where sch_timeofday is not null

update #temp1
set dispatch_date = dateadd(mi,datepart(mi,sch_timeofday),dispatch_date)
where sch_timeofday is not null

if @batch = 'N'
	select * from #temp1
else
	select * from #temp1

return

GO
GRANT EXECUTE ON  [dbo].[sch_transactions] TO [public]
GO
