SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tmail_enh_log_hours_reply    Script Date: 12/29/98 8:32:52 AM ******/
/* Log Hours Recording **************************
** Used for inserting log hours as sent by driver 
** Created:		Dan Klein
**			11/11/97
** Added 'Enhanced' 	Todd DiGiacinto
**	features	10/21/98
***************************************************/


/* Note on Enhanced features: msgdate/time being too early must be
	checked by the calling routine as is 24 hour total. */

CREATE PROCEDURE [dbo].[tmail_enh_log_hours_reply2] 
	@driver_id varchar(8),
	@ssn varchar(20),
	@tractor varchar(13), 
	@date datetime,
	@onduty int,
	@sleeper int,
	@driving int,
	@miles int,
	@Rule_Reset_Indicator varchar(1)
AS

SET NOCOUNT ON 

DECLARE @datedif int,
	@errmess varchar(128),
	@WorkDriver_id varchar(8),
	@RetVal int,
	@sT_1 varchar(200) --Translation string

IF ISNULL(@ssn,'') > ''
	BEGIN
	SELECT @WorkDriver_id = mpp_id
	FROM manpowerprofile (NOLOCK)
	WHERE mpp_ssn = @ssn 
	IF ISNULL(@WorkDriver_id , '' ) = ''
		BEGIN
		SELECT @sT_1 = '{TMWERR:1031}Unknown SSN: %s'
--		EXEC dbo.tm_t_sp @sT_1 out, 1, ''
		RAISERROR (@sT_1, 16, -1, @ssn)
		RETURN 1
		END
	END
ELSE
	BEGIN
	IF ISNULL(@driver_id,'') > ''
		BEGIN
		SELECT @WorkDriver_id = mpp_id 
		FROM manpowerprofile (NOLOCK)
		WHERE mpp_id = @driver_id 
		IF ISNULL(@WorkDriver_id , '' ) = ''
			BEGIN
			SELECT @sT_1 = '{TMWERR:1034}Unknown DriverID: %s'
--			EXEC dbo.tm_t_sp @sT_1 out, 1, ''
			RAISERROR (@sT_1, 16, -1, @driver_id )
			RETURN 1
			END
		END
	ELSE
		BEGIN
		IF ISNULL(@tractor, '') > ''

			BEGIN
			EXEC dbo.tmail_drv_for_trc @tractor, @WorkDriver_id out
			IF ISNULL(@WorkDriver_id , '' ) = ''
				BEGIN
				SELECT @sT_1 = '{TMWERR:1034}Unknown Driver for Tractor: %s'
--				EXEC dbo.tm_t_sp @sT_1 out, 1, ''
				RAISERROR (@sT_1, 16, -1, @tractor)
				RETURN 1
				END
			IF NOT EXISTS (SELECT mpp_id 
								FROM manpowerprofile (NOLOCK)
								WHERE mpp_id = @WorkDriver_id  )	
				BEGIN
				SELECT @sT_1 = '{TMWERR:1034}Bad Driver (%s) for Tractor: %s'
--				EXEC dbo.tm_t_sp @sT_1 out, 1, ''
				RAISERROR (@sT_1, 16, -1, @WorkDriver_id, @tractor)
				RETURN 1
				END
			END
		END
	END

IF ISNULL(@tractor, '') > ''
	EXEC @RetVal = dbo.tmail_chk_trc_drv @tractor , @WorkDriver_id
IF @RetVal <> 0
	BEGIN
	IF ISNULL(@SSN, '')>''
		BEGIN
		SELECT @sT_1 = '{TMWERR:1034}SSN %s not on truck %s'
--		EXEC dbo.tm_t_sp @sT_1 out, 1, ''
		RAISERROR (@sT_1,16,-1, @SSN, @tractor)
		END
	RETURN @RetVal
	END

select @date = convert(datetime,convert(varchar(8), @date, 112),112)  -- jgf 11/18/04 {24533}

if isnull(@Rule_Reset_Indicator, '') = ''
	BEGIN
	Select @Rule_Reset_Indicator = Rule_Reset_Indc
	From log_driverlogs (NOLOCK)
	WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
	  AND	log_driverlogs.log_date = @date
	if isnull(@Rule_Reset_Indicator, '') = ''
		Select @Rule_Reset_Indicator = 'N'
	END

IF EXISTS (Select * 
		From log_driverlogs (NOLOCK)
		WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
			AND	log_driverlogs.log_date = @date)
	Update log_driverlogs Set
		driving_hrs  = @driving/4.,
		sleeper_berth_hrs = @sleeper/4.,
		off_duty_hrs = (24 - ( @driving/4. + @sleeper/4. + @onduty/4. )),
		total_miles = @miles,
		on_duty_hrs = @onduty/4.,
		rule_reset_indc = @Rule_Reset_Indicator
		WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
		  AND	log_driverlogs.log_date = @date

ELSE
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
		@WorkDriver_id,
		@miles,
		@onduty/4.,
		@Rule_Reset_Indicator )

GO
GRANT EXECUTE ON  [dbo].[tmail_enh_log_hours_reply2] TO [public]
GO
