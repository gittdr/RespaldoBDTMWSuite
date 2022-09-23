SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE proc [dbo].[accident_hours_sp] (@ps_drv_id varchar(12), @pdc_accidentdate datetime)
as
/**
 *
 * NAME:
 * dbo.dbo.accident_hours_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure sums up driving hours and off duty hours
 * between the date of an accident and the last 10 off duty hours
 *
**************************************************************************

Sample call


exec accident_hours_sp 'BOBBY', '2011-03-28'


**************************************************************************
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * Sum Driving Hours, Sum Off Duty Hours
 *
 * PARAMETERS:
 * 001 - @@ps_drv_id varchar(8) - Driver ID
 * 002 - @@pdc_accidentdate datetime - Date of the accident
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 04/06/2011.01 - PTS53214 - vjh create proc
 * 04/19/2011.01 - PTS56712 - vjh make compatible with SQL server 2005
 **/

BEGIN

declare @sumdrvhours float, @sumodhours float, @sleeper_berth_hrs float, @off_duty_hrs float, @driving_hrs float, @on_duty_hrs float
declare @dayindex int
declare @rule_reset_indc char(1)

select @dayindex = 0
select @sumdrvhours = 0
select @sumodhours = 0

while 1=1
begin
	select
	@sleeper_berth_hrs = sleeper_berth_hrs,
	@off_duty_hrs = off_duty_hrs,
	@driving_hrs = driving_hrs,
	@on_duty_hrs = on_duty_hrs,
	@rule_reset_indc = rule_reset_indc
	from log_driverlogs
	where mpp_id = @ps_drv_id
	and log_date = DATEADD(DAY,@dayindex,@pdc_accidentdate)
	
	--debugging code
	--select @sleeper_berth_hrs, @off_duty_hrs, @driving_hrs, @on_duty_hrs, @rule_reset_indc, @dayindex
	
	If @off_duty_hrs is null begin
		--missing entry, return -1
		select @sumdrvhours = -1, @sumodhours = -1
		break
	end
		
	--if the day of the accident is a reset, no hours
	If @rule_reset_indc = 'Y' and @dayindex = 0 break
	
	--if the day of the acident has 10 off duty hours, no hours
	If @off_duty_hrs >= 10 and @dayindex = 0 break
	
	--if we encounter a day with 10 off duty or a reset, do not include hours from it
	If @off_duty_hrs >= 10 or @rule_reset_indc = 'Y' break
	
	select @sumdrvhours = @sumdrvhours + @driving_hrs
	select @sumodhours = @sumodhours + @on_duty_hrs
	
	select @dayindex = @dayindex - 1
	if @dayindex < -10 break
	
end

select @sumdrvhours as DrvHours, @sumodhours as ODHours
	
END
GO
GRANT EXECUTE ON  [dbo].[accident_hours_sp] TO [public]
GO
