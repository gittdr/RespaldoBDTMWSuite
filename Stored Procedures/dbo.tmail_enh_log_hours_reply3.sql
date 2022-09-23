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
** 06/01/2010 - VMS - Added precision and scale values to the declaration of decimal variables
**                    to prevent rounding to nearest whole decimal 
**					  (Ex 12.28 was rounded to 12.00 without the precision and scale settings)
** 06/04/2010 - VMS - Modified to handle situation when total hours calculated ends up with 
**                    a value of 24.01 due to rounding.  Adjustment will be made to get back
**                    to a total of 24.0.
**
** 09/25/2015 - JJN - Modified to not insert a NULL value into LOG.
**
** Flags
**  1 = Append Hours - Flag processed in code
**  2 = Do not round up t0 24 hours when using real numbers - Flag processed in code
**  4 = Keep Vendor Hours
***************************************************/


/* Note on Enhanced features: msgdate/time being too early must be
	checked by the calling routine as is 24 hour total. */

CREATE PROCEDURE [dbo].[tmail_enh_log_hours_reply3] 
	@driver_id varchar(8),
	@ssn varchar(20),
	@tractor varchar(13), 
	@date datetime,
	@sOnDuty varchar(12),
	@sSleeper varchar(12),
	@sDriving varchar(12),
	@sMiles varchar(12),
	@Rule_Reset_Indicator varchar(1),
	@sFlags varchar(12)
AS

DECLARE @datedif int,
	@errmess varchar(128),
	@WorkDriver_id varchar(8),
	@RetVal int,
	@sT_1 varchar(200), --Translation string
    @lFlags int,
	@iOnDuty int,
	@iSleeper int,
	@iDriving int,
	@iMiles int,
	@decOnDuty decimal(12,2),
	@decSleeper decimal(12,2),
	@decDriving decimal(12,2),
	@decCalcdOffDuty decimal(12,2),
	@decNewOnDuty decimal(12,2),
	@decNewSleeper decimal(12,2),
	@decNewDriving decimal(12,2),
	@decTimeDiff decimal(12,2),
	@decMiles decimal

SET @lFlags = convert(int, @sFlags)

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
			IF NOT EXISTS ( SELECT mpp_id 
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
	Select @Rule_Reset_Indicator = Rule_Reset_Indc From log_driverlogs
	WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
	  AND	log_driverlogs.log_date = @date
	if isnull(@Rule_Reset_Indicator, '') = ''
		Select @Rule_Reset_Indicator = 'N'
	END

IF @lFlags & 4 = 4
	BEGIN

		SET @decOnDuty = @sOnDuty
		SET @decSleeper = @sSleeper
		SET @decDriving = @sDriving
		SET @decMiles = convert(decimal, @sMiles)

		------------------------------------------------------------------------------
		-- Code to handle adjusting for rounding error pushing total hours to 24.01
		------------------------------------------------------------------------------
		SET @decCalcdOffDuty = (24 - ( @decDriving + @decSleeper + @decOnduty ))

		IF @decCalcdOffDuty < 0.0
			BEGIN
				SET @decTimeDiff = @decCalcdOffDuty

				IF (@decSleeper > abs(@decTimeDiff))
						BEGIN 
							SET @decNewSleeper = @decSleeper + @decTimeDiff
							SET @decSleeper = @decNewSleeper
						END
				ELSE
					IF @decOnDuty > abs(@decTimeDiff)
						BEGIN
							SET @decNewOnDuty = @decOnDuty + @decTimeDiff
							SET @decOnDuty = @decNewOnDuty
						END
					ELSE
						IF @decDriving > abs(@decTimeDiff)
							BEGIN
								SET @decNewDriving = @decDriving + @decTimeDiff
								SET @decDriving = @decNewDriving
							END

				SET @decCalcdOffDuty = 0.0

			END
		------------------------------------------------------------------------------

		IF EXISTS (Select * From log_driverlogs
		WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
		  AND	log_driverlogs.log_date = @date)
			Update log_driverlogs Set
				driving_hrs  = @decDriving,
				sleeper_berth_hrs = @decSleeper,
				-- off_duty_hrs = (24 - ( @decDriving + @decSleeper + @decOnduty )),
				off_duty_hrs = @decCalcdOffDuty,
				total_miles = @decmiles,
				on_duty_hrs = @decOnDuty,
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
				rule_reset_indc,
				[log] )
			VALUES
				(@decDriving,
				@decSleeper,
				(24 - ( @decDriving + @decSleeper + @decOnduty )),
				@date,
				@WorkDriver_id,
				@decmiles,
				@decOnduty,
				@Rule_Reset_Indicator,
				'' )
	END
Else
	BEGIN

		SET @iOnDuty = convert(int, @sOnDuty)
		SET @iSleeper = convert(int, @sSleeper)
		SET @iDriving = convert(int, @sDriving)
		SET @iMiles = convert(int, @sMiles)

		IF EXISTS (Select * 
					From log_driverlogs (NOLOCK)
		WHERE 	log_driverlogs.mpp_id = @WorkDriver_id
		  AND	log_driverlogs.log_date = @date)
			Update log_driverlogs Set
				driving_hrs  = @iDriving/4.,
				sleeper_berth_hrs = @iSleeper/4.,
				off_duty_hrs = (24 - ( @iDriving/4. + @iSleeper/4. + @iOnduty/4. )),
				total_miles = @iMiles,
				on_duty_hrs = @iOnduty/4.,
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
				rule_reset_indc,
				[log] )
			VALUES
				(@iDriving/4.,
				@iSleeper/4.,
				(24 - ( @iDriving/4. + @iSleeper/4. + @iOnduty/4. )),
				@date,
				@WorkDriver_id,
				@iMiles,
				@iOnduty/4.,
				@Rule_Reset_Indicator,
				'' )
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_enh_log_hours_reply3] TO [public]
GO
