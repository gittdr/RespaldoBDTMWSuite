SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_EvaluateBorderCrossingAirMiles] 

AS

/**
 * 
 * NAME:
 * dbo.[sp_EvaluateBorderCrossingAirMiles]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * iterates through tblMIVDBorderCrossingCalculations,
 * calculates airmiles between checkcall and border coordinate
 * copies record to notification table if distance has increased,
 * otherwise saves calculation to tblMIVDBorderCrossingCalculations
 *
 * RETURNS:
 *	Nothing
 * 
 * Change Log: 
 * 01/28/2014	 - PTS63658 - APC - Create proc
 *
 **/

DECLARE @lgh_number INT,
		@ckc_latseconds INT,
		@ckc_longseconds INT,
		@border_latseconds INT,
		@border_longseconds INT,
		@prev_airmiles FLOAT,
		@airmiles FLOAT,
		@DriverID VARCHAR(13),
		@last_checkcall_processed INT
		
SET @lgh_number = 0;

-- Iterate over all records of tblMIVDBorderCrossingCalculations
WHILE (1 = 1) 
BEGIN  

  -- Get next customerId
	SELECT TOP 1 
		@lgh_number = lgh_number,
		@ckc_latseconds = ckc_latseconds,
		@ckc_longseconds = ckc_longseconds,
		@border_latseconds = border_stop_latseconds,
		@border_longseconds = border_stop_longseconds,
		@prev_airmiles = last_airmiles_calculated,
		@DriverID = DriverID,
		@last_checkcall_processed = ckc_number
	FROM tblMIVDBorderCrossingCalculations (NOLOCK)
	WHERE lgh_number > @lgh_number 
	ORDER BY lgh_number

	IF @@ROWCOUNT = 0 BEGIN
		BREAK;
	END
	
	SET @airmiles = ROUND(dbo.fnc_AirMilesBetweenLatLongSeconds(@ckc_latseconds, @border_latseconds, @ckc_longseconds, @border_longseconds), 2)
	IF ROUND(@airmiles, 0) = ROUND(@prev_airmiles, 0)
		PRINT 'airmiles havent changed' --do nothing
	ELSE 
		IF ISNULL(@prev_airmiles, 0) = 0 OR @airmiles < @prev_airmiles BEGIN
		PRINT 'UPDATE dbo.tblMIVDBorderCrossingCalculations'
			UPDATE dbo.tblMIVDBorderCrossingCalculations 
			SET last_airmiles_calculated = @airmiles
			WHERE lgh_number = @lgh_number
		END 
	ELSE BEGIN
	PRINT 'INSERT INTO dbo.tblMIVDNotifications'
		INSERT INTO dbo.tblMIVDNotifications
		        ( lgh_Number ,
		          DriverID ,
		          last_checkcall_processed ,
		          last_airmiles_calculated
		        )
		VALUES  ( @lgh_number,
		          @DriverID,
		          @last_checkcall_processed,
		          @prev_airmiles
		        )
		DELETE FROM dbo.tblMIVDBorderCrossingCalculations 
		WHERE lgh_number = @lgh_number
	END
END    

GO
GRANT EXECUTE ON  [dbo].[sp_EvaluateBorderCrossingAirMiles] TO [public]
GO
