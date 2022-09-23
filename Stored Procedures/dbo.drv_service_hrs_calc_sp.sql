SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[drv_service_hrs_calc_sp] 
	@lgh	as integer,
	@drv	as varchar(13)
		
as

/*
*	Created for PTS 57896 for customer to track the time the Drvier spent, by leg, on certain tasks.
*	
*		Customer calculates two values for the leg
*			1) hours loading/unloading
*			2) Drive Hours.
*/	

declare @ldhrs		decimal(10,2),
	@drvhrs			decimal(10,2),
	@totdrvhrs		decimal(10,2),
	@curseq			integer,
	@totmiles		integer,
	@MPH			integer,
	@lastdepart		datetime,
	@depart			datetime,
	@DrvHrsThreshold	integer
	
-- Build a list of all the stops on the Leg for the driver
Declare @drvstops Table (
	seq					integer		identity,
	stp_number			integer,
	stp_arrivaldate		datetime,
	stp_departuredate	datetime,
	stp_lgh_mileage		integer)
	
insert into @drvstops
select s.stp_number,
	s.stp_arrivaldate,
	s.stp_departuredate,
	isNull(s.stp_lgh_mileage,0)
from stops s join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
where s.lgh_number = @lgh
	and (e.evt_driver1 = @drv OR e.evt_driver2 = @drv)
order by stp_mfh_sequence


-- Find the MPH value to use for the calculations.
select @MPH = isNull(gi_integer1,55),
	@DrvHrsThreshold = ISNULL(gi_integer2, 120)
from generalinfo where gi_name = 'DrivingHoursMPHvalue'

-- Need to total the two values for all the stops on the leg. Must loop through all the stops on the leg for the driver
--	and total the values.
select @curseq = 0
select @ldhrs = 0
select @drvhrs  = 0
select @totdrvhrs = 0

select @curseq = MIN(seq) from @drvstops where seq > @curseq

While @curseq > 0 
	begin
		select @depart = stp_departuredate,
			@totmiles = isNull(@totmiles,0) + isNull(stp_lgh_mileage,0),
			@drvhrs = DATEDIFF(MINUTE,@lastdepart, stp_arrivaldate),
			@ldhrs = @ldhrs + isNull(DATEDIFF(minute, stp_arrivaldate, stp_departuredate),0)
		from @drvstops
		where seq = @curseq
		
		if @curseq = 1 
			select @drvhrs = 0
		
		select @totdrvhrs = isNull(@totdrvhrs,0) + isNull(@drvhrs,0)
		Select @lastdepart = @depart		

		select @curseq = MIN(isNull(seq,0)) from @drvstops where seq > @curseq
		
	end
	
--Determine which 'rule' to use for the Driving Hours.
if @totdrvhrs > @DrvHrsThreshold 
	Select @totdrvhrs = Round((@totmiles / @MPH),2)
else
	-- Convert to Hours from minutes
	Select @totdrvhrs = Round(@totdrvhrs / 60,2)
	
-- Convert to Hours from minutes
select @ldhrs = Round((@ldhrs / 60),2)

-- Update the table with the calculated values.
if exists (select 1 from legheader_driver_hours where lgh_number = @lgh and mpp_id = @drv)
	update legheader_driver_hours
	set ldh_drv_hours = @totdrvhrs,
		ldh_drv_ld_unld_hrs = @ldhrs
	where legheader_driver_hours.lgh_number = @lgh
		and mpp_id = @drv
		AND (ldh_drv_hours <> @totdrvhrs OR ldh_drv_ld_unld_hrs <> @ldhrs)
else
	insert into legheader_driver_hours (lgh_number, mpp_id, ldh_drv_hours, ldh_drv_ld_unld_hrs)
	values ( @lgh,@drv,@totdrvhrs,@ldhrs)
		
GO
GRANT EXECUTE ON  [dbo].[drv_service_hrs_calc_sp] TO [public]
GO
