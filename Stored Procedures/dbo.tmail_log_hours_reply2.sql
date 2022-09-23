SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Log Hours Recording **************************
** Used for inserting log hours as sent by driver 
** Created:		Dan Klein
**			11/11/97
***************************************************/

CREATE PROCEDURE [dbo].[tmail_log_hours_reply2] 
	@driver_id varchar(8),
	@date datetime,
	@onduty int,
	@sleeper int,
	@driving int,
	@miles int,
	@errmess varchar(128) OUT,
	@Rule_Reset_Indicator varchar(1) /* jgf 1/9/04 {21232} */

AS

DECLARE @datedif int,
	@sT_1 varchar(200) 	--Translation String

SELECT @errmess = ''

SELECT @datedif = DATEDIFF ( dy, @date, getdate())
IF @datedif < 0 OR @datedif > 7 
  BEGIN
	SELECT @sT_1 = 'Log date too early or late.  Must be within the last 7 days'
--	EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	SELECT @errmess = @sT_1
	SELECT @errmess
	RETURN
  END

select @date = convert(datetime,convert(varchar(8), @date, 112),112) -- jgf 11/18/04 {24533}

IF NOT EXISTS ( SELECT mpp_id FROM manpowerprofile WHERE mpp_id = @driver_id )
  BEGIN
	SELECT @sT_1 = 'Driver ID: ~1 is not on file.'
	EXEC dbo.tmail_sprint @sT_1 out, @driver_id, '', '', '', '', '', '', '', '' , ''
--	EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	SELECT @errmess = @sT_1
	SELECT @errmess
	RETURN
  END

IF @sleeper/4. + @onduty/4. + @driving/4. > 24
  BEGIN
	SELECT @sT_1 = 'Log hours would exceed 24 hours for a day.'
--	EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	SELECT @errmess = @sT_1
	SELECT @errmess
	RETURN
  END

if isnull(@Rule_Reset_Indicator, '') = ''
	BEGIN
	Select @Rule_Reset_Indicator = (select Rule_Reset_Indc 
									From log_driverlogs (NOLOCK)
									WHERE 	log_driverlogs.mpp_id = @driver_id
									AND	log_driverlogs.log_date = @date)
	if isnull(@Rule_Reset_Indicator, '') = ''
		Select @Rule_Reset_Indicator = 'N'
	END

IF EXISTS (SELECT * 
	FROM log_driverlogs (NOLOCK)
	WHERE 	log_driverlogs.mpp_id = @driver_id
	  AND	log_driverlogs.log_date = @date)
	/* update 'em*/
	UPDATE log_driverlogs SET
		driving_hrs = @driving/4., 
		sleeper_berth_hrs = @sleeper/4.,
		off_duty_hrs = (24 - ( @driving/4. + @sleeper/4. + @onduty/4. )),
		total_miles = @miles,
		on_duty_hrs = @onduty/4.,
		rule_reset_indc = @Rule_Reset_Indicator  /* jgf 1/9/04 {21232} */
	WHERE 	log_driverlogs.mpp_id = @driver_id
	  AND	log_driverlogs.log_date = @date

ELSE
	/* insert 'em */
	INSERT INTO log_driverlogs
		(driving_hrs, 
		sleeper_berth_hrs, 
		off_duty_hrs, 
		log_date, 
		mpp_id, 
		total_miles,
		on_duty_hrs,
		rule_reset_indc )
	VALUES
		(@driving/4.,
		@sleeper/4.,
		(24 - ( @driving/4. + @sleeper/4. + @onduty/4. )),
		@date,
		@driver_id,
		@miles,
		@onduty/4.,
		@Rule_Reset_Indicator )  /* jgf 1/9/04 {21232} */

SELECT @errmess

GO
GRANT EXECUTE ON  [dbo].[tmail_log_hours_reply2] TO [public]
GO
