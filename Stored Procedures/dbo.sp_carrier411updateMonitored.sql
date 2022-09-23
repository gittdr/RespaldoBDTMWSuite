SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411updateMonitored]
( @docket            CHAR(8)
, @car_411_monitored CHAR(1)
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411updateMonitored
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to update car_411_monitored in table carrier
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @docket            CHAR(8)
 * @car_411_monitored CHAR(1)
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/04/11
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @duplicates  CHAR(1)

   SELECT @duplicates = gi_string1
     FROM generalinfo
    WHERE gi_name = 'Carrier411Audit'
   SELECT @duplicates = IsNull(@duplicates,'N')

   IF @car_411_monitored <> 'E'
   BEGIN
      --Remove flag
      UPDATE carrier
         SET car_411_monitored = 'N'
       WHERE car_iccnum = @docket

      --Set Monitor flag
      IF @duplicates = 'Y'
         UPDATE carrier
            SET car_411_monitored = @car_411_monitored
          WHERE car_iccnum = @docket
      ELSE
         UPDATE carrier
            SET car_411_monitored = @car_411_monitored
          WHERE car_iccnum = @docket
            AND 1 = (SELECT COUNT(1)
                       FROM carrier
                      WHERE car_iccnum = @docket
                    )
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411updateMonitored] TO [public]
GO
