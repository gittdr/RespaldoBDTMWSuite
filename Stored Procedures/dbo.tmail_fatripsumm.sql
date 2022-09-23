SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_fatripsumm]	@lghnum varchar(10),
					@actmiles varchar(10),
					@actfuel varchar(10),
					@drv1hours varchar(10),
					@drv1id varchar(10),
					@drv2hours varchar(10),
					@drv2id varchar(10)
AS


/* 09/04/01 TD: Update PS leg header with trip summary data */

SET NOCOUNT ON 

	
DECLARE @lgh int
DECLARE @RealDrv1Hrs money, @RealDrv2Hrs money

if isnumeric(@lghnum) = 1 --May be a FleetAdvisor Generate Route, (FA:#)
	BEGIN
		SELECT @lgh = CONVERT(int, @lghnum)
		
		IF (SELECT lgh_driver1 
			FROM legheader (NOLOCK) 
			WHERE lgh_number = @lgh) = @drv1id
			
			SELECT @RealDrv1Hrs = CONVERT(money, @drv1hours)
		ELSE IF (SELECT lgh_driver2 
					FROM legheader (NOLOCK) 
					WHERE lgh_number = @lgh) = @drv1id
			SELECT @RealDrv2Hrs = CONVERT(money, @drv1Hours)
		ELSE
			RAISERROR ('Unrecognized Driver 1:%s', 16, 1, @drv1id)

		IF ISNULL(@drv2id, '') <> ''
			BEGIN
			IF (SELECT lgh_driver1 
					FROM legheader (NOLOCK)
					WHERE lgh_number = @lgh) = @drv2id
				SELECT @RealDrv1Hrs = CONVERT(money, @drv2hours)
			ELSE IF (SELECT lgh_driver2 
						FROM legheader (NOLOCK)
						WHERE lgh_number = @lgh) = @drv2id
				SELECT @RealDrv2Hrs = CONVERT(money, @drv2Hours)
			ELSE
				RAISERROR ('Unrecognized Driver 2:%s', 16, 1, @drv2id)
			END

		UPDATE legheader 
		SET 	lgh_actualmiles = CONVERT(money, @actmiles), 
			lgh_fuelburned = CONVERT(money, @actfuel), 
			lgh_triphours = @RealDrv1Hrs, 
			lgh_triphours2 = @RealDrv2Hrs 
		WHERE lgh_number = @lgh

		-- Set the lgh_updatedby fields
		EXEC dbo.tmail_lghUpdatedBy @lgh
	END

SELECT @lghnum LghNum, @actmiles ActMiles, @actfuel ActFuel, @drv1hours Hours1, @drv1id Drv1, @drv2hours Hours2, @drv2id Drv2

GO
GRANT EXECUTE ON  [dbo].[tmail_fatripsumm] TO [public]
GO
