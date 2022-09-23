SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[copy_schedule_sp] (@old_ord_hdrnumber int, @new_ord_hdrnumber int, @first_run datetime, @expires datetime) AS 
declare @sch_number integer
declare @loop_sch_number integer
declare @mst_sch_number integer
declare @mov_number integer
declare @lgh_number integer
declare @new_dow integer
declare @sch_dow integer
declare @run_date datetime

-- We need a new master schedule number for these.
EXECUTE @mst_sch_number = getsystemnumber 'MSTSCH', ''

select @mov_number = mov_number from orderheader where ord_hdrnumber = @new_ord_hdrnumber
select top 1 @lgh_number = lgh_number from stops where ord_hdrnumber = @new_ord_hdrnumber

select @new_dow = datepart(dw, @first_run) 

-- Insert these in a loop so we have a new system number for each.
select @loop_sch_number = min(sch_number) from schedule_table where ord_hdrnumber = @old_ord_hdrnumber

WHILE @loop_sch_number is not NULL
BEGIN
	EXECUTE @sch_number = getsystemnumber 'SCHEDULE', ''

	select @sch_dow = datepart(dw, sch_timeofday) from schedule_table WHERE @loop_sch_number = sch_number
	
	if @sch_dow < @new_dow
		select @sch_dow = @sch_dow + 7

	select @run_date = dateadd(dd,  @sch_dow - @new_dow, @first_run)

	INSERT INTO [schedule_table] ([sch_number], [sch_description], [ord_hdrnumber], [sch_dow], 
	 	[sch_dispatch], [sch_specificdate], [mpp_id], [trc_number], [trl_id], [car_id], [sch_multisch], [sch_timeofday],
	 	[mov_number], [sch_scope], [sch_copies], [sch_copy_assetassignments], [sch_copy_dates], [sch_copy_rates], 
	 	[sch_copy_accessorials], [sch_copy_notes], [sch_copy_delinstructions], [sch_copy_paydetails], [sch_copy_orderref], 
	 	[sch_copy_otherref], [sch_copy_frequency], [sch_expires_on], [sch_minutestoadd], [sch_lastrundate], 
	 	[sch_skip_holidays], [sch_skip_weekends], [sch_firstrundate], [sch_hourstoadd], [sch_timestorun], [sch_copy_loadreqs], 
	 	[sch_weeks], [lgh_number], [sch_masterid], [sch_rotationweek], [mr_name], [lgh_type1], [lgh_type2], [lgh_comment], 
	 	[sch_copy_lghtypes], [sch_copy_extrainfo], [sch_copy_permitrequirements], [sch_copy_donotinvoice], [sch_copy_donotsettle], 
	 	[lgh_type3], [lgh_type4], [sch_started], [sch_completed], [sch_user], [sch_runschedule])
	 SELECT @sch_number [sch_number], [sch_description], @new_ord_hdrnumber [ord_hdrnumber], [sch_dow], 
	 	[sch_dispatch], [sch_specificdate], [mpp_id], [trc_number], [trl_id], [car_id], [sch_multisch], @run_date,
	 	@mov_number, [sch_scope], [sch_copies], [sch_copy_assetassignments], [sch_copy_dates], [sch_copy_rates], 
	 	[sch_copy_accessorials], [sch_copy_notes], [sch_copy_delinstructions], [sch_copy_paydetails], [sch_copy_orderref], 
	 	[sch_copy_otherref], [sch_copy_frequency], @expires, [sch_minutestoadd], [sch_lastrundate], 
	 	[sch_skip_holidays], [sch_skip_weekends], [sch_firstrundate], [sch_hourstoadd], [sch_timestorun], [sch_copy_loadreqs], 
	 	[sch_weeks], @lgh_number, @mst_sch_number, [sch_rotationweek], [mr_name], [lgh_type1], [lgh_type2], [lgh_comment], 
	 	[sch_copy_lghtypes], [sch_copy_extrainfo], [sch_copy_permitrequirements], [sch_copy_donotinvoice], [sch_copy_donotsettle], 
	 	[lgh_type3], [lgh_type4], [sch_started], [sch_completed], [sch_user], [sch_runschedule]
		FROM [schedule_table] WHERE @loop_sch_number = sch_number
	
	select @loop_sch_number = min(sch_number) from schedule_table where ORD_hdrnumber = @old_ord_hdrnumber and sch_number > @loop_sch_number

end

-- Expire the old schedules
update schedule_table set sch_expires_on = dateadd(day, -1, @first_run) where ord_hdrnumber = @old_ord_hdrnumber

-- Set expirations on the new and old master orders
-- Set the old order header to expire the day before the new one takes effect.
update orderheader set ord_route_exp_date = dateadd(day, -1, @first_run) where ord_hdrnumber = @old_ord_hdrnumber
-- Put the new one in effect.
update orderheader set ord_route_effc_date = @first_run, ord_route_exp_date = @expires where ord_hdrnumber = @new_ord_hdrnumber

GO
GRANT EXECUTE ON  [dbo].[copy_schedule_sp] TO [public]
GO
