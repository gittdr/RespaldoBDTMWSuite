SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdTrc3] (@TruckID varchar(10), 
				   @Driver1 varchar(30), 
				   @Driver2 varchar(30) = NULL,
				   @TankFraction real,
				   @Gallons int,
				   @p_Odometer varchar(20))
AS 

/**
 * 
 * NAME:
 * dbo.tmail_UpdTrc3
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Updates the tractorprofile table.
 *  - Tractor/driver relationship
 *  - Gallons of fuel in tank (will use @Gallons if both @Gallons and @TankFraction are passed)
 *  - Odometer reading (only updates if new value is greater than current)
 *
 * RETURNS:
 *  none.
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @TruckID  varchar(10), input, null
 *       the tractor we are updating in tractorprofile
 * 002 - @Driver1  varchar(30), input, null
 * 003 - @Driver2  varchar(30), input, null
 * 004 - @TankFraction real, input, null
 * 		   What fraction of the tank has fuel (eg 0.25)
 * 005 - @Gallons int, input, null
 *		   How many gallons of fuel are in the tank (eg 200 gal)
 * 006 - @p_Odometer varchar(20)
 *		   Odometer reading.  A varchar because some mc vendors will send
 *		   alpha chars for MCT's that don't support auto-odometer functionality (eg NOT ENABLED).
 *                 Also allows a real number (eg 123456.7); will be rounded to integer.
 * 
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 01/22/2006.01 – PTS29907 - MIZ - Created to add new @p_Odometer parameter.
 * 03/09/2006.01 - PTS30109 - TSA - Allow real number for @p_Odometer and round to integer.
 * 09/17/2013	 - PTS60292 - HMA - Add error message when Driver 1 or Driver 2 are invalid
 * 09/23/2013	 - PTS72308 - APC - Display error message when Driver 1 or Driver 2 are provided (not blank) and do not exist in manpowerprofile
 **/


DECLARE @TankCapacity int,
	@TankGallons int,
	@v_Odometer int,
	@v_ErrString varchar(500),
	@v_mpp_id_temp varchar(8)

SET NOCOUNT ON

SET @Gallons = ISNULL(@Gallons, 0) 
SET @TankFraction = ISNULL(@TankFraction, 0) 
SET @v_ErrString = ''

IF ISNUMERIC (@p_Odometer) > 0
	SET @v_Odometer = CONVERT(int, ROUND(@p_Odometer,0))
ELSE
	SET @v_Odometer = 0

--Validate entries.
IF NOT EXISTS(SELECT trc_driver 
			FROM tractorprofile (NOLOCK)
			WHERE trc_number = @TruckID)
  BEGIN
	RAISERROR('Truck number not known.  Make sure truck exists in TMWSuite.', 16,1)
	RETURN -1
  END

IF NOT EXISTS(SELECT mpp_id 
				FROM manpowerprofile (NOLOCK)
				WHERE mpp_id = @Driver1) BEGIN
	SELECT @Driver1 = (CASE WHEN ISNULL(@Driver1,'') = '' THEN null ELSE 'UNKNOWN' END)
	IF @Driver1 IS NOT NULL BEGIN																			--72308
		SET @v_ErrString = 'Driver1 ID not known. Make sure Driver1 exists in TMWSuite. ';					--60292
	END
END

IF NOT EXISTS(SELECT mpp_id FROM manpowerprofile WHERE mpp_id = @Driver2) BEGIN
	SELECT @Driver2 = (CASE WHEN ISNULL(@Driver2,'') = '' THEN null ELSE 'UNKNOWN' END)
	IF @Driver2 IS NOT NULL BEGIN																			--72308
		SET @v_ErrString = @v_ErrString + 'Driver2 ID not known. Make sure Driver2 exists in TMWSuite. '; 	--60292
	END
END

-- If no input parms were set besides the tractor, raise driver error.
IF (ISNULL(@Driver1, '') = '' 
	AND ISNULL(@Driver2, '') = ''	
	AND @Gallons = 0 
	AND @TankFraction = 0 
	AND @v_Odometer = 0)
  BEGIN
	RAISERROR('No data was provided to update the tractorprofile', 16,1)
	RETURN -1
  END
	
-- Update the driver relationship(s)
/********************************
  @Driver1/@Driver2 
	null - leave alone (driver left blank on form)
	UNKNOWN - change driver assignment for this tractor to UNKNOWN
	mpp_id - change driver assignment for this tractor to mpp_id and remove mpp_id from any other tractor
*********************************/
IF (ISNULL(@Driver1,'') <> '')  -- If it'a null, we're supposed to leave it alone.
  BEGIN
	IF @Driver1 = 'UNKNOWN'
		-- Get the current trc_driver so we can remove the reference to this tractor in manpowerprofile
		--  NOTE: the manpowerprofile update has to occur after the tractorprofile update because
		--			of manpowerprofile triggers.
		SELECT @v_mpp_id_temp = ISNULL(trc_driver,'UNKNOWN')
		FROM tractorprofile (NOLOCK)
		WHERE trc_number = @TruckId

	-- Put mpp_id/UNKNOWN on this trc_driver
	UPDATE tractorprofile SET trc_driver = @Driver1 WHERE trc_number = @TruckID AND ISNULL(trc_driver,'') <> @Driver1

	IF (@Driver1 <> 'UNKNOWN')
	  BEGIN
		-- Remove @Driver1 from any other tractor
		UPDATE tractorprofile SET trc_driver = 'UNKNOWN' WHERE trc_number <> @TruckID AND trc_driver = @Driver1	
		-- Remove @Driver1 from any trc_driver2 association (can only be in one place at a time)
		UPDATE tractorprofile SET trc_driver2 = 'UNKNOWN' WHERE trc_driver2 = @Driver1	

		-- Set the tractor for this driver in manpowerprofile
		UPDATE manpowerprofile SET mpp_tractornumber = @TruckID WHERE mpp_id = @Driver1
	  END
	ELSE
		-- @Driver1 = UNKNOWN: If there was a trc_driver (found above in @v_mpp_id_temp) set any 
		--  manpowerprofile.mpp_tractornumber = UNKNOWN for the driver in @v_mpp_id_temp
		IF @v_mpp_id_temp <> 'UNKNOWN'
			UPDATE manpowerprofile
			SET mpp_tractornumber = 'UNKNOWN'
			FROM manpowerprofile (NOLOCK)
			WHERE mpp_id = @v_mpp_id_temp
				AND mpp_tractornumber <> 'UNKNOWN'
  END

IF (ISNULL(@Driver2,'') <> '')
  BEGIN
	IF @Driver2 = 'UNKNOWN'
		-- Get the current trc_driver2 so we can remove the reference to this tractor in manpowerprofile
		--  NOTE: the manpowerprofile update has to occur after the tractorprofile update because
		--			of manpowerprofile triggers.
		SELECT @v_mpp_id_temp = ISNULL(trc_driver2,'UNKNOWN')
		FROM tractorprofile (NOLOCK)
		WHERE trc_number = @TruckId

	-- Put mpp_id/UNKNOWN on this trc_driver2
	UPDATE tractorprofile SET trc_driver2 = @Driver2 WHERE trc_number = @TruckID AND trc_driver2 <> @Driver2

	IF (@Driver2 <> 'UNKNOWN')
	  BEGIN
		-- Remove @Driver2 from any other trc_driver2 association (besides this tractor)
		UPDATE tractorprofile SET trc_driver2 = 'UNKNOWN' WHERE trc_number <> @TruckID AND trc_driver2 = @Driver2	
		-- Remove @Driver2 from any trc_driver association (can only be in one place at a time)
		UPDATE tractorprofile SET trc_driver = 'UNKNOWN' WHERE trc_driver = @Driver2	

		-- Set the tractor for this driver in manpowerprofile
		UPDATE manpowerprofile SET mpp_tractornumber = @TruckID WHERE mpp_id = @Driver2
	  END
	ELSE
		-- @Driver2 = UNKNOWN: If there was a trc_driver2 (found above in @v_mpp_id_temp) set any 
		--  manpowerprofile.mpp_tractornumber = UNKNOWN for the driver in @v_mpp_id_temp
		IF @v_mpp_id_temp <> 'UNKNOWN'
			UPDATE manpowerprofile
			SET mpp_tractornumber = 'UNKNOWN'
			FROM manpowerprofile (NOLOCK)
			WHERE mpp_id = @v_mpp_id_temp
				AND mpp_tractornumber <> 'UNKNOWN'
  END

--** Remove manpowerprofile.mpp_tractornumber assignments if possible **
-- If both drivers were set to a valid mpp_id, then remove that tractor from any other driver besides these two.
IF (ISNULL(@Driver1,'UNKNOWN') <> 'UNKNOWN' AND ISNULL(@Driver2,'UNKNOWN') <> 'UNKNOWN')
	-- Remove this tractor from any other driver in manpowerprofile
	UPDATE manpowerprofile SET mpp_tractornumber = 'UNKNOWN' WHERE (mpp_id <> @Driver1 AND mpp_id <> @Driver2) AND mpp_tractornumber = @TruckID 
ELSE
	-- We have a valid @Driver1 and we want to set trc_driver2 to UNKNOWN, 
	--  so we can blank out other drivers associated with this tractor besides @Driver1
	IF (ISNULL(@Driver1,'UNKNOWN') <> 'UNKNOWN' AND @Driver2 = 'UNKNOWN')  
		UPDATE manpowerprofile SET mpp_tractornumber = 'UNKNOWN' WHERE (mpp_id <> @Driver1) AND mpp_tractornumber = @TruckID 	
	ELSE
		-- We have a valid @Driver2 and we want to set trc_driver to UNKNOWN, 
		--  so we can blank out other drivers associated with this tractor besides @Driver2
		IF (@Driver1 = 'UNKNOWN' AND ISNULL(@Driver2,'UNKNOWN') <> 'UNKNOWN')
			UPDATE manpowerprofile SET mpp_tractornumber = 'UNKNOWN' WHERE (mpp_id <> @Driver2) AND mpp_tractornumber = @TruckID 	

-- Update the amount of fuel in the tank if supplied
IF (@Gallons > 0 OR @TankFraction > 0)
  BEGIN
	SET @TankGallons = 0
	SET @TankCapacity = 0

	IF @Gallons = 0 		 -- Use tankfraction not gallons
	  BEGIN
		SELECT @TankCapacity = ISNULL(trc_tank_capacity, 0)  
		FROM tractorprofile
		WHERE trc_number = @TruckID
		
		IF @TankCapacity = 0
		  BEGIN
			SET @v_ErrString = @v_ErrString + 'The tractor''s tank capacity was not set in tractorprofile. The number of gallons in it''s tank could not be updated. '
			SET @TankGallons = 0
		  END
		ELSE	
			SET @TankGallons = @TankCapacity * @TankFraction
	  END
	ELSE
		SET @TankGallons = @Gallons

	IF @TankGallons > 0
		UPDATE tractorprofile
		SET trc_gal_in_tank = @TankGallons
		WHERE trc_number = @TruckID
  END

IF (@v_Odometer > 0)
	-- Update the tractorprofile hubometer field only if the new value is larger.
	UPDATE tractorprofile
	SET trc_currenthub = @v_Odometer
	WHERE trc_number = @TruckID
		AND @v_Odometer > ISNULL(trc_currenthub, 0)

-- If there was an error, raise it.
IF (@v_ErrString <> '')
  BEGIN
	RAISERROR(@v_ErrString, 16,1)
	RETURN -1
  END
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdTrc3] TO [public]
GO
