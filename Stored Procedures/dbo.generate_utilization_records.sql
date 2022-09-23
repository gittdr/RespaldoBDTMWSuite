SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[generate_utilization_records] @mov_number integer
as
begin
	declare @temp as integer
end

--declare @curr_leg int
--declare @trc varchar(8)
--declare @sofpta_id int
--declare @curr_leg_status varchar(6)
--declare @tmwuser varchar (255)
--declare @prev_leg int, @asgn_number int
--declare @max_util_enddate datetime
--declare @SoftPTATime int

--exec gettmwuser @tmwuser output
--select @SoftPTATime = isnull(gi_integer1,240)
--  from generalinfo
-- where gi_name = 'SoftPTATime'

----handle current trip records
--select @curr_leg = MIN(lgh_number) 
--  from legheader 
-- where mov_number = @mov_number

-- while @curr_leg is not null
-- begin
--	 select @trc = lgh_tractor,
--			@curr_leg_status = lgh_outstatus 
--	   from legheader 
--	  where lgh_number = @curr_leg
--	 if @trc = 'UNKNOWN'
--		return
		
--	--get previous leg for later use
--	select @prev_leg = lgh_number 
--	  from assetassignment 
--	 where asgn_type = 'TRC' 
--	   and asgn_id = @trc 
--	   and lgh_number <> @curr_leg 
--	   and asgn_status = 'CMP' 
--	   and asgn_date = (select MAX(asgn_date) 
--						  from assetassignment 
--						 where asgn_type = 'TRC' 
--						   and asgn_id = @trc 
--						   and lgh_number <> @curr_leg 
--						   and asgn_status = 'CMP' 
--						   and asgn_date <= (select lgh_startdate 
--											   from legheader 
--											  where lgh_number = @curr_leg))

--	--insert soft legpta when trip is planned with a tractor
--	if @curr_leg_status = 'CMP' and not exists (select * from legpta where lgh_number = @curr_leg)
--	begin
--		insert into legpta(lgh_number, pta_type, util_code, pta_date, trc_number, update_date, update_user)
--		--select @curr_leg, 'S', 'UNK', dateadd(mi,@SoftPTATime,stp.stp_schdtlatest), @trc, getdate(), @tmwuser
--		select @curr_leg, 'S', 'UNK', dbo.GetSoftPTADate_fn(lgh.lgh_number, @SoftPTATime), @trc, getdate(), @tmwuser
--		  from legheader lgh
--		  --join stops stp on stp.stp_number = lgh.stp_number_end
--		 where lgh.lgh_number = @curr_leg
--	end
--	--if soft exists update it
--	else if @curr_leg_status = 'CMP' and exists (select * from legpta where lgh_number = @curr_leg and legpta.pta_type = 'S' or legpta.pta_type = 'RE')
--	begin
--		select @sofpta_id = lpa_id from legpta where lgh_number = @curr_leg and legpta.pta_type = 'S' and legpta.pta_type = 'RE'
--		update legpta
--		   --set pta_date = dateadd(m,@SoftPTATime,s.stp_schdtlatest)
--		   set pta_date = dbo.GetSoftPTADate_fn(lgh.lgh_number, @SoftPTATime)
--		  from legheader lgh
--		 where legpta.lpa_id = @sofpta_id
--		   and lgh.lgh_number = @curr_leg
--		--create the NL utilization record
		
--		insert into utilization(lpa_id, trc_number, lgh_number, trc_status, util_code, util_start_date, util_end_date, update_date)
--			select lpa_id, @trc, @curr_leg, NULL, 'NL', lgh_enddate, pta_date, GETDATE()
--			  from legpta
--			  join legheader on legheader.lgh_number = legpta.lgh_number
--			 where legpta.lgh_number = @curr_leg
		
--	end
--	--handle hard PTA records
--	else if @curr_leg_status = 'CMP' and exists (select * from legpta where lgh_number = @curr_leg and legpta.pta_type = 'H' and legpta.pta_type <> 'RE')
--	begin
--		if not exists(select * from utilization util where util.lgh_number = @curr_leg)
--		begin
--			--create hard PTA util date
--			insert into utilization(lpa_id, trc_number, lgh_number, trc_status, util_code, util_start_date, util_end_date, update_date)
--			select lpa_id, @trc, @curr_leg, NULL, util_code, lgh_enddate, pta_date, GETDATE()
--			  from legpta
--			  join legheader on legheader.lgh_number = legpta.lgh_number
--			 where legpta.lgh_number = @curr_leg
--		end
--		--update it if it's already there
--		update utilization 
--		   set util_end_date = pta_date
--		  from legpta
--		 where legpta.lgh_number = utilization.lgh_number
--		   and utilization.lgh_number = @curr_leg

--		--create a NL record if needed for current trip
--		select @max_util_enddate = MAX(util_end_date) from utilization where lgh_number = @curr_leg
--		if @max_util_enddate < GETDATE()
--			insert into utilization (lpa_id, lgh_number, trc_number, util_code, util_start_date, util_end_date, update_date)
--			select 0, @curr_leg, @trc, 'NL', @max_util_enddate, NULL, GETDATE()
--			  from legheader where lgh_number = @curr_leg
--	end
--	else if @curr_leg_status = 'STD'
--	begin
--	    --create a NL record for the previous load if needed
--		select @max_util_enddate = MAX(isnull(util_end_date,'12/31/2049 00:00:00')) from utilization where lgh_number = @prev_leg
--		if @max_util_enddate = '12/31/2049 00:00:00'
--			select @max_util_enddate = NULL
--		if (select util_code from utilization where lgh_number = @prev_leg and util_end_date = @max_util_enddate) <> 'NL'
--		begin
--			insert into utilization (lpa_id, lgh_number, trc_number, util_code, util_start_date, util_end_date, update_date)
--				select 0, @prev_leg, @trc, 'NL', @max_util_enddate, NULL, GETDATE()
--				  from legheader where lgh_number = @prev_leg
--		end
		
--		declare @prevleg_maxstartdate datetime
--		--create a NL from the end of the last trip if the last trip had no hard PTA
--		if not exists (select * from utilization where lgh_number = @prev_leg)
--		begin
--			insert into utilization (lpa_id, lgh_number, trc_number, util_code, util_start_date, util_end_date, update_date)
--			select lpa_id, @prev_leg, @trc, 'NL', pta_date, l.lgh_startdate, GETDATE()
--			  from legpta
--			  join legheader l on l.lgh_number = @curr_leg
--			 where legpta.pta_type = 'S'
--			   and legpta.lgh_number = @prev_leg
--		end
--		--fill any gap with NL util record from previous trip to current trip
--		select @prevleg_maxstartdate = MAX(util_start_date) from utilization where lgh_number = @prev_leg
--		update utilization
--		   set util_end_date = currleg.lgh_startdate
--		  from legheader prevlgh
--		  join legheader currleg on currleg.lgh_number = @curr_leg 
--		 where prevlgh.lgh_number = @prev_leg
--		   and utilization.lgh_number = @prev_leg
--		   and utilization.util_start_date = @prevleg_maxstartdate
--	end
--	select @curr_leg = MIN(lgh_number) 
--	  from legheader 
--	 where mov_number = @mov_number
--	   and lgh_number > @curr_leg

--end
GO
