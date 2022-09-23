SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateMIVDBorderCrossingCalculationsDelay]
			@Delay INT -- in minutes

AS

/**
 * 
 * NAME:
 * dbo.[sp_UpdateMIVDBorderCrossingCalculationsDelay]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * iterates through tblMIVDBorderCrossingCalculations,
 * Sets column CompletedDelayAfterActualizedLastStop_BeforeMeatInspection
 * to 'Y' if period of delay has transpired
 *
 * RETURNS:
 *	Nothing
 * 
 * Change Log: 
 * 08/05/2014 - PTS80063 - APC - create proc
 **/
 
DECLARE @ckc_updatedon DATETIME,
		@lgh_number int;
 
 -- Iterate over all records of tblMIVDBorderCrossingCalculations
SET @lgh_number = 0;
 
WHILE (1 = 1) 
BEGIN  
  -- Get record with lowest legheader#, greater than the last queried @lgh_number
	SELECT TOP 1 
		@ckc_updatedon = ckc_updatedon,
		@lgh_number = lgh_number
		--@ckc_latseconds = ckc_latseconds,
		--@ckc_longseconds = ckc_longseconds,
		--@border_latseconds = border_stop_latseconds,
		--@border_longseconds = border_stop_longseconds,
		--@prev_airmiles = last_airmiles_calculated,
		--@DriverID = DriverID,
		--@last_checkcall_processed = ckc_number
	FROM tblMIVDBorderCrossingCalculations m (NOLOCK)
	WHERE 
		m.lgh_number > @lgh_number 
		AND ISNULL(m.CompletedDelayAfterActualizedLastStop_BeforeMeatInspection,'N') <> 'Y'
	ORDER BY lgh_number
	
	-- exit loop if no rows returned in query
	IF @@ROWCOUNT = 0 
	BEGIN
		BREAK;
	END
	
	-- if checkcall
	IF DATEDIFF(mi, @ckc_updatedon, CURRENT_TIMESTAMP) >= @Delay 
	BEGIN
		UPDATE tblMIVDBorderCrossingCalculations 
			SET CompletedDelayAfterActualizedLastStop_BeforeMeatInspection = 'Y'
		WHERE
			lgh_number = @lgh_number	
	END
END

GO
GRANT EXECUTE ON  [dbo].[sp_UpdateMIVDBorderCrossingCalculationsDelay] TO [public]
GO
