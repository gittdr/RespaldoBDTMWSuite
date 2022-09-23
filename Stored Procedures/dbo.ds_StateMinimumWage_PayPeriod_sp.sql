SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWage_PayPeriod_sp]
( @mpp_terminated CHAR(1)
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWage_PayPeriod_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to list Pay Periods with Previous Month Payroll Begin and End Dates
*
* RETURNS:
*
* NOTHING:
*
* 08/16/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   DECLARE @Month_Begin_WeekDay  INT
   DECLARE @Month_End_WeekDay    INT
   DECLARE @LookBack_Months      INT
   DECLARE @LookBack_Months_Term INT

   SELECT @Month_Begin_WeekDay = IsNull(gi_integer1,2)
        , @Month_End_WeekDay   = IsNull(gi_integer2,7)
        , @LookBack_Months     = IsNull(gi_integer3,1)
     FROM generalinfo
    WHERE gi_name = 'STL_StateMinimumWage'

   SELECT @LookBack_Months = @LookBack_Months * -1

   SELECT @LookBack_Months_Term = @LookBack_Months + 1
   IF @LookBack_Months_Term > 0
      SELECT @LookBack_Months_Term = 0


   IF IsNull(@mpp_terminated,'N') <> 'Y'
      SELECT @mpp_terminated = 'N'

   IF @mpp_terminated = 'Y'
      SELECT d.psd_id                                                                                                AS psd_id
           , d.psd_date                                                                                              AS Current_Pay_Period
           , dbo.fn_get_payroll_beginend(DATEADD(MONTH,@LookBack_Months_Term,d.psd_date), 'B', @Month_Begin_WeekDay) AS Process_Month_Begin_Date
           , dbo.fn_get_payroll_beginend(DATEADD(MONTH,0,d.psd_date), 'E', @Month_End_WeekDay)                       AS Process_Month_End_Date
        FROM payschedulesheader h
        JOIN payschedulesdetail d ON h.psh_id = d.psh_id
       WHERE d.psd_date IS NOT NULL
         AND h.psh_status <> 'CLS'
         AND d.psd_status <> 'CLS'
      ORDER BY d.psd_date DESC
   ELSE
      SELECT d.psd_id                                                                                                AS psd_id
           , d.psd_date                                                                                              AS Current_Pay_Period
           , dbo.fn_get_payroll_beginend(DATEADD(MONTH,@LookBack_Months,d.psd_date), 'B', @Month_Begin_WeekDay)      AS Process_Month_Begin_Date
           , dbo.fn_get_payroll_beginend(DATEADD(MONTH,@LookBack_Months,d.psd_date), 'E', @Month_End_WeekDay)        AS Process_Month_End_Date
        FROM payschedulesheader h
        JOIN payschedulesdetail d ON h.psh_id = d.psh_id
       WHERE d.psd_date IS NOT NULL
         AND h.psh_status <> 'CLS'
         AND d.psd_status <> 'CLS'
         AND d.psd_date >= dbo.fn_get_FirstFullWeek_BeginEnd(d.psd_date, 'B', @Month_Begin_WeekDay, @Month_End_WeekDay)
         AND d.psd_date <= dbo.fn_get_FirstFullWeek_BeginEnd(d.psd_date, 'E', @Month_Begin_WeekDay, @Month_End_WeekDay)
      ORDER BY d.psd_date DESC

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWage_PayPeriod_sp] TO [public]
GO
