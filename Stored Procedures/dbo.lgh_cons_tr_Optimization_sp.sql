SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_Optimization_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for UT_LHG_OPTIMIZATION GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/

BEGIN

DECLARE @powerIds TABLE (powerId VARCHAR(25));

 IF EXISTS(SELECT  
              *
            FROM  
              @inserted i
                INNER JOIN 
              @deleted d ON d.lgh_number = i.lgh_number
            WHERE  
              ISNULL(i.lgh_tractor, '') <> ISNULL(d.lgh_tractor, '') 
                OR
              ISNULL(i.lgh_driver1, '') <> ISNULL(d.lgh_driver1, '') 
                OR
              ISNULL(i.lgh_driver2, '') <> ISNULL(d.lgh_driver2, '') 
                OR
              ISNULL(i.lgh_carrier, '') <> ISNULL(d.lgh_carrier, ''))
  BEGIN
    UPDATE
      dbo.tractorprofile
    SET  
      trc_optimizationdate = GETDATE()
    FROM  
      @inserted i
     WHERE  
       tractorprofile.trc_number = i.lgh_tractor
         AND  
       i.lgh_tractor <> 'UNKNOWN';

    UPDATE
      dbo.tractorprofile
    SET  
      trc_optimizationdate = GETDATE()
    FROM  
      @deleted d
    WHERE  
      tractorprofile.trc_number = d.lgh_tractor
        AND  
      d.lgh_tractor <> 'UNKNOWN';

    UPDATE  
      dbo.legheader
    SET  
      lgh_optimizationdate = GETDATE()
    FROM  
      @inserted i
    WHERE  
      legheader.lgh_number = i.lgh_number;
    
    IF EXISTS(SELECT  
                * 
              FROM  
                @inserted i
                  INNER JOIN 
                @deleted d ON d.lgh_number = i.lgh_number
              WHERE  
                d.lgh_tractor = 'UNKNOWN'
                  AND  
                d.lgh_carrier <> 'UNKNOWN'
                  AND  
                d.lgh_carrier <> i.lgh_carrier)
    BEGIN
    
      INSERT @powerIds
      SELECT  
        d.lgh_carrier + '|' + CAST(d.lgh_number AS VARCHAR(20))
      FROM  
        @inserted i
          INNER JOIN 
        @deleted d ON d.lgh_number = i.lgh_number
      WHERE
        d.lgh_tractor = 'UNKNOWN'
          AND
        d.lgh_carrier <> 'UNKNOWN'
          AND
        d.lgh_carrier <> i.lgh_carrier;

      DELETE  
        opt_eta_pta_stop_state
      WHERE  
        truck_id IN (SELECT powerId FROM @powerIds);

      DELETE  
        opt_eta_pta_load_state
      WHERE  
        truck_id IN (SELECT powerId FROM @powerIds);

      DELETE  
        opt_eta_pta_hos_segments
      WHERE  
        truck_id IN (SELECT powerId FROM @powerIds);

      DELETE  
        opt_eta_pta_power_state
      WHERE  
        power_id IN (SELECT powerId FROM @powerIds);
    END;
  END;
END 
      

GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_Optimization_sp] TO [public]
GO
