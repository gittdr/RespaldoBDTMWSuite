SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AccumulateLifeTimeMileage]
AS

DECLARE @on   VARCHAR(10) 

-- get settings for the module
SELECT @on = UPPER(RTRIM(ISNULL(gi_string1, 'OFF'))) 
  FROM generalinfo 
 WHERE gi_name = 'UnitDistance'

-- if feature off, then exit
IF @on = 'OFF'
   RETURN

-- create temp unit legs table
CREATE TABLE #unitlegs  
     (unittype  VARCHAR(6), 
      unitid    VARCHAR(13), 
      lghnumber INT, 
      mileage   DECIMAL(12, 1))

-- create temp unit mileage table
CREATE TABLE #unitmiles 
     (unittype     VARCHAR(6), 
      unitid       VARCHAR(13), 
      totalmileage DECIMAL(12, 1))

-- get a list of all new units and leg headers to update
INSERT INTO #unitlegs (unittype, unitid, lghnumber, mileage) 
     SELECT udl_unittype, udl_unitid, udl_lgh_number, ISNULL(udl_distance, 0) 
       FROM UnitDistancebyLeg 
      WHERE udl_stlstatus = 1 
        AND ISNULL(udl_verified, 0) = 0

-- sum the mileage
INSERT INTO #unitmiles (unittype, unitid, totalmileage) 
     SELECT unittype, unitid, SUM(mileage) 
       FROM #unitlegs 
   GROUP BY unittype, unitid

-- update the lifetime mileage field on the tractorprofile
UPDATE tractorprofile 
   SET trc_lifetimemileage = ISNULL(trc_lifetimemileage, 0) + totalmileage 
  FROM #unitmiles 
 WHERE unittype = 'TRC' 
   AND #unitmiles.unitid = trc_number 

-- update the lifetime mileage field on the tractorprofile
UPDATE trailerprofile  
   SET trl_lifetimemileage = ISNULL(trl_lifetimemileage, 0) + totalmileage 
  FROM #unitmiles 
 WHERE unittype = 'TRL' 
   AND #unitmiles.unitid = trl_id 

-- mark the entries in the UnitDistancebyLeg table as verified
UPDATE UnitDistancebyLeg 
   SET udl_verified = 1 
  FROM #unitlegs 
 WHERE udl_unittype = #unitlegs.unittype 
   AND udl_unitid = #unitlegs.unitid 
   AND udl_lgh_number = #unitlegs.lghnumber 

-- drop temp table
DROP TABLE #unitmiles
DROP TABLE #unitlegs

GO
GRANT EXECUTE ON  [dbo].[AccumulateLifeTimeMileage] TO [public]
GO
