SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_ProcessIntTrUpd_sp] (
@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for ProcessInteractiveTripUpdates GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/


BEGIN
DECLARE @lgh_number INT
	,@new_lgh_outstatus VARCHAR(6)
	,@old_lgh_outstatus VARCHAR(6)
	,@driver VARCHAR(8)
	,@old_driver VARCHAR(8)
	,@driver2 VARCHAR(8)
	,@old_driver2 VARCHAR(8)
	,@tractor VARCHAR(8)
	,@old_tractor VARCHAR(8)
	,@trailer VARCHAR(13)
	,@old_trailer VARCHAR(13)
	,@new_lgh_carrier VARCHAR(8)
	,@old_lgh_carrier VARCHAR(8)
	,@ProcessInteractiveTripUpdatesLEFTgi_string1 VARCHAR(30)
	,@ProcessInteractiveTripUpdatesgi_string2 VARCHAR(30)
	,@ProcessInteractiveTripUpdatesgi_string3 VARCHAR(30)

SELECT TOP 1 @ProcessInteractiveTripUpdatesLEFTgi_string1 = LEFT(COALESCE(gi.gi_string1, 'N'), 1)
	,@ProcessInteractiveTripUpdatesgi_string2 = LEFT(COALESCE(gi.gi_string2, 'N'), 1)
	,@ProcessInteractiveTripUpdatesgi_string3 = LEFT(COALESCE(gi.gi_string3, 'N'), 1)
FROM generalinfo gi
WHERE gi.gi_name = 'ProcessInteractiveTripUpdates'


  DECLARE TripCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT 
    i.lgh_outstatus
  , d.lgh_outstatus
  , i.lgh_driver1
  , d.lgh_driver1
  , i.lgh_driver2
  , d.lgh_driver2
  , i.lgh_tractor
  , d.lgh_tractor
  , i.lgh_primary_trailer
  , d.lgh_primary_trailer
  , i.lgh_carrier
  , d.lgh_carrier
	, i.lgh_number
  FROM 
    @inserted i
      INNER JOIN 
    @deleted d ON i.lgh_number = d.lgh_number;

  OPEN TripCursor
  FETCH NEXT FROM TripCursor INTO 
    @new_lgh_outstatus 
  , @old_lgh_outstatus 
  , @driver 
  , @old_driver 
  , @driver2 
  , @old_driver2 
  , @tractor 
  , @old_tractor 
  , @trailer 
  , @old_trailer 
  , @new_lgh_carrier 
  , @old_lgh_carrier 
	, @lgh_number


  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Driver Processing
	IF @ProcessInteractiveTripUpdatesLEFTgi_string1 = 'Y'
    BEGIN
      IF (@old_lgh_outstatus <> @new_lgh_outstatus)
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'DRV', @driver, @lgh_number, 'TRIP';
        EXEC Interactive_Fuel_Update_sp 'DRV', @driver2, @lgh_number, 'TRIP';
      END;

      IF ((@driver <> 'UNKNOWN') AND (@driver <> @old_driver))
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'DRV', @driver, @lgh_number, 'TRIP';
      END;

      IF (@old_driver <> 'UNKNOWN') AND (@old_driver <> @driver)    
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'DRV', @old_driver, @lgh_number, 'TRIP';
      END;

      IF (@driver2 <> 'UNKNOWN') AND (@driver2 <> @old_driver2)  
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'DRV', @driver2, @lgh_number, 'TRIP';
      END;

      IF (@old_driver2 <> 'UNKNOWN') AND (@old_driver2 <> @driver2)
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'DRV', @old_driver2, @lgh_number, 'TRIP';
      END;
    END;

    -- Tractor Processing
	IF @ProcessInteractiveTripUpdatesgi_string2 = 'Y'
    BEGIN
      IF (@old_lgh_outstatus <> @new_lgh_outstatus)
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRC', @tractor, @lgh_number, 'TRIP';
      END;

      IF ((@tractor <> 'UNKNOWN') AND (@tractor <> @old_tractor))
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRC', @tractor, @lgh_number, 'TRIP';
      END;

      IF (@old_tractor <> 'UNKNOWN') AND (@old_tractor <> @tractor)    
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRC', @old_tractor, @lgh_number, 'TRIP';
      END;
    END;

    -- Trailer Processing
	IF @ProcessInteractiveTripUpdatesgi_string3 = 'Y'
    BEGIN
      IF (@old_lgh_outstatus <> @new_lgh_outstatus)
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRL', @trailer, @lgh_number, 'TRIP';
      END;

      IF ((@trailer <> 'UNKNOWN') AND (@trailer <> @old_trailer))
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRL', @trailer, @lgh_number, 'TRIP';
      END;

      IF (@old_trailer <> 'UNKNOWN') AND (@old_trailer <> @trailer)    
      BEGIN
        EXEC Interactive_Fuel_Update_sp 'TRL', @old_trailer, @lgh_number, 'TRIP';
      END;
    END;
  
    FETCH NEXT FROM TripCursor INTO 
      @new_lgh_outstatus 
    , @old_lgh_outstatus 
    , @driver 
    , @old_driver 
    , @driver2 
    , @old_driver2 
    , @tractor 
    , @old_tractor 
    , @trailer 
    , @old_trailer 
    , @new_lgh_carrier 
    , @old_lgh_carrier 
		, @lgh_number
  END;

  CLOSE TripCursor
  DEALLOCATE TripCursor

END;
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_ProcessIntTrUpd_sp] TO [public]
GO
