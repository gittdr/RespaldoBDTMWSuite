SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*******************************************************************************************************************************************************
 ** NAME: car_expstatus
 **
 ** Parameters: 
 **    @carid VARCHAR(8) - Carrier ID for which status should be set.
 **    @debug INTEGER    - Optional defaults to 0, when zero updates are performed, when anything else select statement with changes instead of update.
 **
 ** General Info Settings
 **    ExpTimeBuffer 
 **        Number of minutes (+ or -) that are added to the current time when looking for active expirations
 **    UseMaxCarrierExpirationCode
 **        When Set to Y priority for open expirations is as follows:
 **          1.  Termination Expiration (labelfile code = 20) 
 **          2.  If more than termination expiration, select the one with greatest completion date.
 **          2.  No termination expiration then expiration with greatest labelfile code (>20)
 **          3.  If more than one with greatest labelfile code, select the one with greatest completion date.
 **
 **        When set to N piority for expirations is as follows:
 **          1.  Termination Expiration (labelfile code = 20)
 **          2.  If more than termination expiration, select the one with greatest completion date.
 **          3.  Expiration with greatest completion date if more than 1 one with same completion date the one with greatest code.
 **          4.  If more than one with greatest completion date, select the one with greatest code.
 **
 ** Revisions History:
 **   INT-106017 - RJE 03/31/2017 - Rewrote procedure for performance
 **
 *******************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[car_expstatus]
(
  @carid VARCHAR(8),
  @debug INTEGER = 0
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @ExpTimeBuffer                INTEGER,
        @UseMaxCarrierExpirationCode  CHAR(1),
        @comparedate                  DATETIME,
        @expdate                      DATETIME,
        @expstat                      VARCHAR(6)

-- Get out now if no carrier 
IF COALESCE(@carid, 'UNKNOWN') = 'UNKNOWN' RETURN

-- Get all general info settings here (1 query)
SELECT  @ExpTimeBuffer = CASE WHEN gi_name = 'ExpTimeBuffer' THEN COALESCE(gi_integer1, 0) ELSE @ExpTimeBuffer END,
        @UseMaxCarrierExpirationCode = CASE WHEN gi_name = 'UseMaxCarrierExpirationCode' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @UseMaxCarrierExpirationCode END
  FROM  generalinfo
 WHERE  gi_name IN ('ExpTimeBuffer', 'UseMaxCarrierExpirationCode')

SELECT  @comparedate = DATEADD(MINUTE, COALESCE(@ExpTimeBuffer, 0), GETDATE()),
        @UseMaxCarrierExpirationCode = COALESCE(@UseMaxCarrierExpirationCode, 'N')

-- Get active expiration priority given to those with code 20
SELECT TOP 1
        @expdate = e.exp_expirationdate,
        @expstat = ls.abbr
  FROM  expiration e
          INNER JOIN labelfile lc ON lc.abbr = e.exp_code AND lc.labeldefinition = 'CarExp'
          LEFT OUTER JOIN labelfile ls ON ls.code = lc.code AND ls.labeldefinition = 'CarStatus'
 WHERE  e.exp_idtype = 'CAR'
	 AND  e.exp_id = @carid
	 AND  e.exp_completed = 'N' 
   AND  lc.code >= 20 
   AND  e.exp_expirationdate <= @comparedate 
ORDER BY CASE WHEN lc.code = 20 THEN 999999 WHEN @UseMaxCarrierExpirationCode = 'Y' THEN lc.code ELSE 0 END DESC, e.exp_compldate DESC, lc.code DESC

IF @debug = 0
-- Update carrier only if needed
  UPDATE  carrier
     SET  car_status = COALESCE(@expstat, 'ACT'),
          car_terminationdt = @expdate
   WHERE  car_id = @carid
     AND  (COALESCE(car_status, '-98765') <> COALESCE(@expstat, 'ACT')
      OR   COALESCE(car_terminationdt, CONVERT(DATETIME, 0)) <> COALESCE(@expdate, CONVERT(DATETIME, 0)))
ELSE
  SELECT  @carid car_id,
          COALESCE(@expstat, 'ACT') car_status,
          @expdate car_terminationdt
GO
GRANT EXECUTE ON  [dbo].[car_expstatus] TO [public]
GO
