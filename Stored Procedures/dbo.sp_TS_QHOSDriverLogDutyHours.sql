SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TS_QHOSDriverLogDutyHours]
( @mpp_id                        VARCHAR(8)
, @applicable_pay_period_begin   DATETIME
, @applicable_pay_period_end     DATETIME
)
AS

/*
*
*
* NAME:
* dbo.sp_TS_QHOSDriverLogDutyHours
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return Get QHOS Driver Duty Hours for a given Date Range
*
* RETURNS:
* DECIMAL(10,4)
*
* NOTHING:
*
* 08/14/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN
   DECLARE @ldc_RetVal DECIMAL(10,4)

   SELECT @ldc_RetVal = SUM(duration)
     FROM dbo.QHOSDriverLogExportData
    WHERE DriverID = @mpp_id
      AND LocalStartTime >= @applicable_pay_period_begin
      AND LocalStartTime <= @applicable_pay_period_end
      AND Activity in (2,3,4,5)
   IF @ldc_RetVal IS NULL OR @ldc_RetVal <= 0
      SELECT @ldc_RetVal = 0
   ELSE
      SELECT @ldc_RetVal = @ldc_RetVal / 60

   RETURN @ldc_RetVal

END
GO
GRANT EXECUTE ON  [dbo].[sp_TS_QHOSDriverLogDutyHours] TO [public]
GO
