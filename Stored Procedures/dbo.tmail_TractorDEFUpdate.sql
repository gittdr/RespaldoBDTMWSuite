SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_TractorDEFUpdate] (@TruckID varchar(10), 
					@Numerator varchar(4),
					@Denominator varchar(4)
					)
AS 

/**
 * 
 * NAME:
 * dbo.tmail_TractorDEFUpdate
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Updates the tractorprofile table.
 *  - Gallons of DEF fuel in tank
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
 * 002 - @Numerator  varchar(4), input, null
 * 003 - @Denominator  varchar(4), input, null
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 09/16/2012.01 – PTS62505 - LB - Created to update the DEF level for tractor.
 *
 **/


DECLARE @TankCapacity int,
	@TankGallons int,
	@iNumerator float,
	@iDenominator float,
	@v_ErrString varchar(500),
	@TankFraction float

SET NOCOUNT ON

SET @v_ErrString = ''

--Validate entries.
IF NOT EXISTS(SELECT trc_driver 
			FROM tractorprofile (NOLOCK)
			WHERE trc_number = @TruckID)
  BEGIN
	RAISERROR('Truck number not known.  Make sure truck exists in TMWSuite.', 16,1)
	RETURN -1
  END

IF ISNUMERIC(@Numerator) = 1
BEGIN
	SET @iNumerator = CONVERT(float,@Numerator)
END
ELSE
BEGIN
	RAISERROR('Invalid Numerator for DEF Level.', 16,1)
	RETURN -1
END

IF ISNUMERIC(@Denominator) = 1
BEGIN
	SET @iDenominator = CONVERT(float,@Denominator)
	IF ISNULL(@iDenominator,0) = 0
	BEGIN
		Set @iDenominator = 8
	END
END
ELSE
BEGIN
	Set @iDenominator = 8
END
	
-- Update the amount of DEF in the tank 
	SET @TankGallons = 0
	
	SET @TankGallons = @iNumerator
	
	IF @TankGallons > 0
		UPDATE tractorprofile
		SET trc_DEFLevel = @TankGallons
		WHERE trc_number = @TruckID
  
	select @TankGallons
GO
GRANT EXECUTE ON  [dbo].[tmail_TractorDEFUpdate] TO [public]
GO
