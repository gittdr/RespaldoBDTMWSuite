SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[lgh_cons_tr_updatecarcomm_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for UpdateCarrierCommitments GI setttings that are used in	ut_legheader_consolidated.
********************************************************************************************************************/

BEGIN
DECLARE @lgh_number INT
	,@new_lgh_startdate DATETIME
	,@old_lgh_startdate DATETIME
	,@new_lgh_carrier VARCHAR(8)
	,@old_lgh_carrier VARCHAR(8)
	,@new_recommended_car_id VARCHAR(8)
	,@old_recommended_car_id VARCHAR(8)

  DECLARE FOREACHLEG CURSOR FAST_FORWARD FOR
	SELECT 
    i.lgh_number
  , i.lgh_startdate
  , d.lgh_startdate
  , i.lgh_carrier
  , d.lgh_carrier
  , i.lgh_recommended_car_id
  , d.lgh_recommended_car_id
  FROM 
    @inserted i 
      INNER JOIN 
    @deleted d ON i.lgh_number = d.lgh_number
  WHERE 
    i.lgh_startdate <> d.lgh_startdate 
      OR  
    i.lgh_carrier <> d.lgh_carrier 
      OR 
    i.lgh_recommended_car_id <> d.lgh_recommended_car_id
  
  OPEN FOREACHLEG

  FETCH NEXT FROM FOREACHLEG INTO @lgh_number, @new_lgh_startdate, @old_lgh_startdate, @new_lgh_carrier, @old_lgh_carrier, @new_recommended_car_id, @old_recommended_car_id

  WHILE @@FETCH_STATUS = 0
  BEGIN

    IF @new_lgh_carrier <> @old_lgh_carrier 
         AND 
       @new_lgh_startdate <> @old_lgh_startdate
    BEGIN
      IF @old_lgh_carrier <> 'UNKNOWN'
      BEGIN
        EXEC core_updatecarriercommitments @lgh_number, @old_lgh_startdate, @old_lgh_carrier, 'DEC', 'UNKNOWN', @old_lgh_startdate;
      END;

      IF @new_lgh_carrier <> 'UNKNOWN'
      BEGIN
        EXEC core_updatecarriercommitments @lgh_number, @new_lgh_startdate, @new_lgh_carrier, 'INC', @new_recommended_car_id, @old_lgh_startdate;
      END;
    END;

    IF @new_lgh_carrier <> @old_lgh_carrier 
         AND 
       @old_lgh_carrier = @new_lgh_carrier 
         AND 
       @old_lgh_carrier <> 'UNKNOWN'
    BEGIN
      EXEC core_updatecarriercommitments @lgh_number, @old_lgh_startdate, @old_lgh_carrier, 'DEC', 'UNKNOWN', @old_lgh_startdate;
      EXEC core_updatecarriercommitments @lgh_number, @new_lgh_startdate, @old_lgh_carrier, 'INC', 'UNKNOWN', @old_lgh_startdate;
    END;

    IF @old_lgh_startdate = @new_lgh_startdate AND @old_lgh_carrier <> @new_lgh_carrier
    BEGIN
      IF @old_lgh_carrier <> 'UNKNOWN'
      BEGIN
        EXEC core_updatecarriercommitments @lgh_number, @old_lgh_startdate, @old_lgh_carrier, 'DEC', 'UNKNOWN', @old_lgh_startdate;
      END;

      IF @new_lgh_carrier <> 'UNKNOWN'
      BEGIN
        EXEC core_updatecarriercommitments @lgh_number, @new_lgh_startdate, @new_lgh_carrier, 'INC', @new_recommended_car_id, @old_lgh_startdate;
      END;
    END;

    IF @new_lgh_carrier = 'UNKNOWN'
    BEGIN
      IF @old_lgh_startdate <> @new_lgh_startdate AND @old_recommended_car_id <> @new_recommended_car_id
      BEGIN
        IF @old_recommended_car_id <> 'UNKNOWN'
        BEGIN
          EXEC core_updatecarrierrecommendation @lgh_number, @old_lgh_startdate, @old_recommended_car_id, 'DEC';
        END;
        
        IF @new_recommended_car_id <> 'UNKNOWN'
        BEGIN
          EXEC core_updatecarrierrecommendation @lgh_number, @new_lgh_startdate, @new_recommended_car_id, 'INC';
        END;              
      END;

      IF @old_lgh_startdate <> @new_lgh_startdate AND @old_recommended_car_id = @new_recommended_car_id and @old_recommended_car_id <> 'UNKNOWN'
      BEGIN
        EXEC core_updatecarrierrecommendation @lgh_number, @old_lgh_startdate, @old_recommended_car_id, 'DEC';
        EXEC core_updatecarrierrecommendation @lgh_number, @new_lgh_startdate, @old_recommended_car_id, 'INC';
      END;

      IF @old_lgh_startdate = @new_lgh_startdate AND @old_recommended_car_id <> @new_recommended_car_id AND @new_recommended_car_id IS NOT NULL
      BEGIN
        IF @old_recommended_car_id <> 'UNKNOWN'
        BEGIN
          EXEC core_updatecarrierrecommendation @lgh_number, @old_lgh_startdate, @old_recommended_car_id, 'DEC';
        END;
              
        IF @new_recommended_car_id <> 'UNKNOWN'
        BEGIN
          EXEC core_updatecarrierrecommendation @lgh_number, @new_lgh_startdate, @new_recommended_car_id, 'INC';
        END;
      END;
    END;

    FETCH NEXT FROM FOREACHLEG INTO @lgh_number, @new_lgh_startdate, @old_lgh_startdate, @new_lgh_carrier, @old_lgh_carrier, @new_recommended_car_id, @old_recommended_car_id
  END;
  CLOSE FOREACHLEG;
  DEALLOCATE FOREACHLEG
END;

GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_updatecarcomm_sp] TO [public]
GO
