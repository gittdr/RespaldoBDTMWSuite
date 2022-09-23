SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.order_schedule    Script Date: 6/1/99 11:55:06 AM ******/
create procedure [dbo].[order_schedule] @userid char(20)

as

declare
	@rowcounter			integer,
	@rows_affected		integer,
	@rows_affected2		integer,
	@current_row			integer,
	@batch_id 				integer,
	@rowcount 			integer,
	@order					integer,
	@dispatch_date  		datetime,
	@schedule_date		datetime,
	@drv					char(8),				
	@trc					char(8),				
	@trl					char(13),		
	@car					char(8),		
	@err_icon				char(1),
	@err_number			integer,
	@err_type				char(6),
	@err_message			varchar(255),
	@view_id 				char(6),
	@allow_dup			char(3),
	@temp					varchar(20)



create table #tmp1scroll
(view_id		integer,
process_ind	integer		null,
override_ind	char(1)		null,
fromdate		datetime	null,
todate			datetime	null,
weekendind	char(1)		null,
holidayind		char(1)		null,
schedule_date datetime	null)

insert into #tmp1scroll
select scv_id,
	scp_processind,
	scp_overrideind,
	scp_fromdate,
	scp_todate,
	scp_weekendind,
	scp_holidayind,
	null
from scheduleparms

update #tmp1scroll
set schedule_date = Convert(datetime,Convert(char,getdate(),101))
where process_ind = 1 and
	override_ind = 'N'

update #tmp1scroll
set schedule_date = dateadd(day,1,Convert(datetime,Convert(char,getdate(),101)))
where process_ind = 2 and
	override_ind = 'N'

update #tmp1scroll  
set schedule_date = fromdate  
where override_ind = 'Y' and  
	Convert(datetime,Convert(char,getdate(),101)) between fromdate and todate


select @rows_affected = 1

while @rows_affected > 0 
	BEGIN

	select @rows_affected =( select count(*) from #tmp1scroll
			where weekendind  = 'N' and
				override_ind = 'N' and
				Upper(datename(weekday,schedule_date)) in ('SATURDAY','SUNDAY'))

	update #tmp1scroll 
	set schedule_date = dateadd(day,1,schedule_date)  
	where weekendind  = 'N' and
		override_ind = 'N' and
		Upper(datename(weekday,schedule_date)) in ('SATURDAY','SUNDAY')

	select @rows_affected2 = (select count(*) from #tmp1scroll
			where holidayind  = 'N' and
				override_ind = 'N' and
				exists ( select holiday
						from holidays
						where #tmp1scroll.schedule_date = holidays.holiday))

	update #tmp1scroll
	set schedule_date = dateadd(day,1,schedule_date)  
	where holidayind  = 'N' and
		override_ind = 'N' and
		exists ( select holiday
				from holidays
				where #tmp1scroll.schedule_date = holidays.holiday)

	if @rows_affected2 > @rows_affected
		Begin
		select @rows_affected = @rows_affected2
		End

	END

SELECT temp1.schedule_date,
	sc.sch_number,
	temp1.view_id, 
	oh.ord_revtype1, 	
	oh.ord_subcompany, 	
	oh.ord_company, 	
	oh.ord_hdrnumber, 	
	oh.ord_number, 	
	sc.mpp_id, 	
	sc.trc_number, 	
	sc.trl_id, 	
	sc.car_id , 
	dateadd(day,sc.sch_dispatch, temp1.schedule_date) dispatch_date , 
	oh.ord_revtype2, 
	oh.ord_revtype3, 
	oh.ord_revtype4,
	'RevType1' revtype1,
	'RevType2' revtype2,
	'RevType3' revtype3,
	'RevType4' revtype4,
	sc.sch_multisch,   
	sc.sch_timeofday,
	0 counter into #temp2  
FROM orderheader oh,
	schedule_table sc,
	#tmp1scroll temp1,
	scheduleviews sv
WHERE temp1.schedule_date is not null and
	(temp1.view_id = sv.scv_id) and
	((oh.ord_company = sv.ord_company) or (sv.ord_company = 'UNKNOWN')) and
	(oh.ord_subcompany =sv.ord_subcompany) and
	(sv.ord_revtype1 LIKE "%"+oh.ord_revtype1+"%" or sv.ord_revtype1 = 'UNK') and
	(sv.ord_revtype2 LIKE "%"+oh.ord_revtype2+"%" or sv.ord_revtype2 = 'UNK') and
	(sv.ord_revtype3 LIKE "%"+oh.ord_revtype3+"%" or sv.ord_revtype3 = 'UNK') and
	(sv.ord_revtype4 LIKE "%"+oh.ord_revtype4+"%" or sv.ord_revtype4 = 'UNK') and
	(oh.ord_hdrnumber = sc.ord_hdrnumber) and
	(oh.ord_status = 'MST') and 
	((datepart(weekday,  temp1.schedule_date) = sc.sch_dow) or (sc.sch_specificdate =  temp1.schedule_date))

select (datepart(weekday,schedule_date)), schedule_date from #tmp1scroll
select * from #temp2

update #temp2
set schedule_date = dateadd(hh,datepart(hh,sch_timeofday),schedule_date)
where sch_timeofday is not null

update #temp2
set schedule_date = dateadd(mi,datepart(mi,sch_timeofday),schedule_date)
where sch_timeofday is not null

update #temp2
set dispatch_date = dateadd(hh,datepart(hh,sch_timeofday),dispatch_date)
where sch_timeofday is not null

update #temp2
set dispatch_date = dateadd(mi,datepart(mi,sch_timeofday),dispatch_date)
where sch_timeofday is not null

/* remove any records that have already been scheduled for the schedule date */

delete from #temp2
where exists (select scv_id from scheduleviews
				where scheduleviews.scv_id = #temp2.view_id and
					#temp2.schedule_date between scv_lastfromdate and scv_lasttodate)


/* Get the batch number and process the transactions */

exec @batch_id = getsystemnumber 'BATCHQ',''

select @rowcount = 1

Set ROWCOUNT 1

update #temp2 set counter = @rowcount

while @@rowcount > 0
	
	Begin
	select @rowcount = @rowcount + 1

	update #temp2 
		set counter = @rowcount
		where counter = 0

	End

Set ROWCOUNT 0


/* loop through #temp2 and process each row individually */

	select @current_row = 0
	
	WHILE (select count(*) from #temp2 where counter > @current_row) > 0
		
		BEGIN
		Select @current_row = min(counter) from #temp2 where counter > @current_row	

		Select @order = ord_hdrnumber,
			@dispatch_date = dispatch_date,
			@schedule_date = schedule_date,
			@drv = mpp_id, 
			@trc = trc_number,	
			@trl = trl_id,
			@car = car_id,
			@view_id = convert(char(6),view_id),
			@allow_dup = sch_multisch  
		from #temp2
		where counter = @current_row

		exec copy_order @order,@dispatch_date,@schedule_date,@drv,@trc,@trl,@car,@userid,@batch_id,@view_id,@allow_dup   
 
		END

/* Log any Errors or other conditions that warrant notification*/
	
	/* Log no schedules generated */
	IF (select count(*) from #temp2 ) =  0 
		BEGIN
		select @err_message = 'No schedules generated by Batch Scheduling Process on '+Convert(varchar(12),getdate(),101),
			@err_icon = 'E',
			@err_number = 200

		insert into tts_errorlog (
			err_batch,
			err_user_id,
			err_icon,
			err_message,
			err_date,
			err_item_number,
			err_number,
			err_type)
		values(
			@batch_id,
			@userid,
			@err_icon,
			@err_message,
			getdate(),
			"0",
			@err_number,
			@err_type)
		END
	
	/* Log master orders w/no schedules */

	select distinct(ord_hdrnumber), ord_number into #temp3
	from orderheader
	where ord_status = 'MST' and
		not exists (select ord_hdrnumber from schedule_table
						where schedule_table.ord_hdrnumber = orderheader.ord_hdrnumber)
	order by ord_hdrnumber

	select @current_row = 0
	WHILE (select count(*) from #temp3 where ord_hdrnumber > @current_row) > 0
	
		BEGIN

		Select @current_row = min(ord_hdrnumber) from #temp3 where ord_hdrnumber > @current_row	

		select @err_message = 'No schedules defined in Batch Scheduling Process for order: '+Convert(varchar(12),ord_number),
			@err_icon = 'I',
			@err_number = 201
		from #temp3
		where ord_hdrnumber = @current_row

		insert into tts_errorlog (
			err_batch,
			err_user_id,
			err_icon,
			err_message,
			err_date,
			err_item_number,
			err_number,
			err_type)
		values(
			@batch_id,
			@userid,
			@err_icon,
			@err_message,
			getdate(),
			"0",
			@err_number,
			@err_type)
		END

/* Set the lastfrom and lastto dates for each view */

	update scheduleviews 
	set scv_lastfromdate = (select max(#temp2.schedule_date) from #temp2 where #temp2.view_id = scheduleviews.scv_id),
		scv_lasttodate = (select max(#temp2.schedule_date) from #temp2 where #temp2.view_id = scheduleviews.scv_id)
	
/* Reset the override indicatiors and specific dates */

	Update scheduleparms
	set scp_overrideind = 'N'
	where scp_overrideind = 'Y'

select *, @batch_id from #temp2
return

GO
GRANT EXECUTE ON  [dbo].[order_schedule] TO [public]
GO
