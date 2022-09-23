SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[Update_UnitDistancebyLeg] (@startdate DATETIME)
AS

DECLARE @type VARCHAR(10), 
        @on   VARCHAR(10), 
        @id   INT

-- get settings for the module
SELECT @type = UPPER(RTRIM(ISNULL(gi_string2, 'DI'))), 
       @on = UPPER(RTRIM(ISNULL(gi_string1, 'OFF'))) 
  FROM generalinfo 
 WHERE gi_name = 'UnitDistance'

-- if feature off, then exit
IF @on = 'OFF'
   RETURN

-- create temp table
CREATE TABLE #legheader 
     (id           INT IDENTITY(1, 1) NOT NULL,
      unittype     VARCHAR(6)    NULL, 
      unitid       VARCHAR(13)   NULL, 
      lgh_number   INT           NULL, 
      startdate    DATETIME      NULL, 
      startmileage DECIMAL(8, 1) NULL, 
      endmileage   DECIMAL(8, 1) NULL, 
      totalmileage DECIMAL(9, 1) NULL, 
      settled      VARCHAR(3)    NULL)

-- insert assets and information into the temp table
INSERT INTO #legheader (unittype, unitid, lgh_number, startdate, settled) 
     SELECT asgn_type, asgn_id, lgh_number, asgn_date, pyd_status 
       FROM assetassignment 
      WHERE asgn_type IN ('TRC', 'TRL') 
        AND asgn_id <> 'UNKNOWN' 
        AND asgn_date >= @startdate 

-- remove old data, just incase an asset was removed from the legheader
DELETE FROM UnitDistancebyLeg 
      WHERE udl_lgh_number IN (SELECT DISTINCT lgh_number FROM #legheader) 
        AND udl_verified <> 1

-- remove verified records from the #legheader table
DELETE FROM #legheader 
      WHERE lgh_number IN (SELECT DISTINCT udl_lgh_number FROM UnitDistancebyLeg WHERE udl_start_date >= @startdate) 

-- mark all records with paid status when one settlement is prepared
UPDATE #legheader 
   SET settled = '1' 
 WHERE lgh_number IN (SELECT DISTINCT lgh_number 
                        FROM assetassignment 
                       WHERE lgh_number in (SELECT lgh_number 
                                              FROM #legheader) 
                         AND pyd_status = 'PPD')
UPDATE #legheader 
   SET settled = '0'
 WHERE settled <> '1'

-- update the mileage fields
IF @type = 'HUB'
   -- HUB mileage from evt_hubmiles
   BEGIN
      -- tractor 
      UPDATE #legheader 
         SET startmileage = (SELECT MIN(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_tractor = #legheader.unitid), 
             endmileage = (SELECT MAX(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_tractor = #legheader.unitid)
       WHERE unittype = 'TRC'
      
      -- trailer 1
      UPDATE #legheader 
         SET startmileage = (SELECT MIN(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer1 = #legheader.unitid), 
             endmileage = (SELECT MAX(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer1 = #legheader.unitid)
       WHERE unittype = 'TRL' 
      
      -- trailer 2
      UPDATE #legheader 
         SET startmileage = (SELECT MIN(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer2 = #legheader.unitid), 
             endmileage = (SELECT MAX(ISNULL(evt_hubmiles, 0)) 
                               FROM stops, event  
                              WHERE  stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer2 = #legheader.unitid)
       WHERE unittype = 'TRL' 
         AND (startmileage IS NULL OR startmileage = 0)
      
      -- convert hub mileage to a total mileage
      UPDATE #legheader 
         SET totalmileage = endmileage - startmileage 
   END                             
ELSE
   -- DI mileage from stp_lgh_mileage field
   BEGIN
      -- tractor 
      UPDATE #legheader 
         SET totalmileage = (SELECT SUM(ISNULL(stp_lgh_mileage, 0)) 
                               FROM stops 
                              WHERE stops.lgh_number = #legheader.lgh_number)
       WHERE unittype = 'TRC'
      
      -- trailer 1
      UPDATE #legheader 
         SET totalmileage = (SELECT SUM(ISNULL(stp_lgh_mileage, 0)) 
                               FROM stops, event  
                              WHERE stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer1 = #legheader.unitid)
       WHERE unittype = 'TRL' 
      
      -- trailer 2
      UPDATE #legheader 
         SET totalmileage = (SELECT SUM(ISNULL(stp_lgh_mileage, 0)) 
                               FROM stops, event  
                              WHERE stops.lgh_number = #legheader.lgh_number 
                                AND stops.stp_number = event.stp_number 
                                AND event.evt_trailer2 = #legheader.unitid)
       WHERE unittype = 'TRL' 
         AND (totalmileage IS NULL OR totalmileage = 0)

   END                             

SELECT @id = MIN(id) 
  FROM #legheader 
WHILE @id > 0
BEGIN 
     -- insert values into UnitDistancebyLeg table
/* kluge to fix PK constront error for duplicate assetassignment recs per leg
     caused when there are multiple trailers on a leg */
     INSERT INTO UnitDistancebyLeg (udl_unittype, udl_unitid, udl_lgh_number, udl_distance, 
                                    udl_start_date, udl_last_updated, udl_last_updatedby, udl_stlstatus, udl_verified)
          SELECT unittype, unitid, lgh_number, ISNULL(totalmileage, 0), 
                 startdate, GetDate(), User, CONVERT(TINYINT, settled), 0
            FROM (Select distinct unittype,unitid,lgh_number,totalmileage = Max(isNull(totalmileage,0)),
                 startdate = Max(startdate),settled =max(settled) From #legheader  WHERE id = @ID
                 Group by unittype, unitid, lgh_number) DLEG
 /*         FROM #legheader
            WHERE id = @id
*/
     
     SELECT @id = MIN(id) 
       FROM #legheader 
      WHERE id > @id
END

-- drop temp table
DROP TABLE #legheader

GO
GRANT EXECUTE ON  [dbo].[Update_UnitDistancebyLeg] TO [public]
GO
