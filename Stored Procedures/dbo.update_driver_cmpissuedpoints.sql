SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[update_driver_cmpissuedpoints] @mpp_id		VARCHAR(8)
AS
DECLARE @from_date					DATETIME,			
		@to_date					DATETIME,
		@historical_points			INT,
		@points						INT,
		@tot_points					INT
	
SET @to_date = GETDATE()
SET @from_date = DATEADD(year, -3, @to_date)
		
SELECT @historical_points = SUM(acd_cmpissuedpoints)
  FROM accident
 WHERE srp_id = 0 AND
       acd_driver1 = @mpp_id AND
       acd_accidenttype2 <> 'UNK' AND
       acd_historicaldate BETWEEN @from_date AND @to_date
IF @historical_points IS NULL
   SET @historical_points = 0

SELECT @points = SUM(acd_cmpissuedpoints)
  FROM accident JOIN safetyreport ON accident.srp_id = safetyreport.srp_id AND
                                     safetyreport.srp_eventdate BETWEEN @from_date AND @to_date
 WHERE accident.srp_id > 0 AND
       accident.acd_accidenttype2 <> 'UNK' AND
     ((accident.acd_driveratwheel = 1 AND accident.acd_driver1 = @mpp_id) OR
      (accident.acd_driveratwheel = 2 AND accident.acd_driver2 = @mpp_id))
IF @points IS NULL
   SET @points = 0

SET @tot_points = @historical_points + @points

UPDATE manpowerprofile
   SET mpp_cmpissuedpoints = @tot_points
 WHERE mpp_id = @mpp_id     

GO
GRANT EXECUTE ON  [dbo].[update_driver_cmpissuedpoints] TO [public]
GO
