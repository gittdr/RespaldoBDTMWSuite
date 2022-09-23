SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[stp_cvtToSysTZ]
	@stp_number int,
	@stp_arrivaldate datetime out,
	@stp_departuredate datetime out,
	@stp_activitystart_dt datetime out,
	@stp_activityend_dt datetime out,
	@stp_ETA datetime out,
	@stp_ETD datetime out,
	@stp_tzHours int out,
	@stp_tzMins int out,
	@stp_tzDstCode int out
AS

/* REVISION HISTORY:
 * 08/23/2005.01 – PTS29481 - Tim Adam – Don't return nulls for time zone arguments.
*/

SET NOCOUNT ON 

DECLARE 
	@cty_gmtdelta float,
	@cty_dstapplies char(1),
	@stp_city int,
	@sys_MakeTZAdjusts char(1),
	@sys_tzHours int,
	@sys_tzMins int,
	@sys_tzDstCode int,
	@tmp_time datetime

IF isnull(@stp_number,0) = 0 RETURN

SELECT @sys_MakeTZAdjusts = UPPER(ISNULL(gi_string1, 'N'))
FROM generalinfo (NOLOCK)
WHERE gi_name = 'MakeTZAdjustments'

SELECT 
	@stp_arrivaldate = stp_arrivaldate,
	@stp_departuredate = stp_departuredate,
	@stp_activitystart_dt = stp_activitystart_dt,
	@stp_activityend_dt = stp_activityend_dt,
	@stp_ETA = stp_ETA,
	@stp_ETD = stp_ETD,
	@stp_city = stp_city
	FROM stops WHERE stp_number = @stp_number

SELECT 
	@stp_tzHours = 0,
	@stp_tzMins = 0,
	@stp_tzDstCode = -1

IF @sys_MakeTZAdjusts = 'Y'
  	BEGIN
	
	SELECT @sys_tzHours = ISNULL(CONVERT(int, gi_string1), -15)
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysTZ'

	SELECT @sys_TZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysTZMins'

	SELECT @sys_tzDstCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no DST
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysDSTCode'

	SELECT 
		@cty_gmtdelta = cty_gmtdelta, 
		@cty_dstapplies = cty_dstapplies 
	FROM city (NOLOCK)
	WHERE cty_code = @stp_city
	
	SELECT @cty_gmtdelta = isnull(@cty_gmtdelta,999),
		@cty_dstapplies = upper(isnull(@cty_dstapplies,'Y'))

	IF @cty_gmtdelta <> 999
		begin
		IF @cty_dstapplies = 'Y' 
			SELECT @stp_tzDstCode = 0
		else
			SELECT @stp_tzDstCode = -1
		SELECT @stp_tzHours = convert(int,@cty_gmtdelta)
		SELECT @stp_tzMins = (@cty_gmtdelta - @stp_tzHours) * 60
		exec dbo.ChangeTZ_7 @stp_arrivaldate, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_arrivaldate = @tmp_time
		exec dbo.ChangeTZ_7 @stp_departuredate, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_departuredate = @tmp_time
		exec dbo.ChangeTZ_7 @stp_activitystart_dt, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_activitystart_dt = @tmp_time
		exec dbo.ChangeTZ_7 @stp_activityend_dt, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_activityend_dt = @tmp_time
		exec dbo.ChangeTZ_7 @stp_ETA, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_ETA = @tmp_time
		exec dbo.ChangeTZ_7 @stp_ETD, @stp_tzHours, @stp_tzMins, @stp_tzDstCode, @sys_tzHours, @sys_tzMins, @sys_tzDstCode, @tmp_time out
		SELECT @stp_ETD = @tmp_time
		end		
	
	END
GO
GRANT EXECUTE ON  [dbo].[stp_cvtToSysTZ] TO [public]
GO
