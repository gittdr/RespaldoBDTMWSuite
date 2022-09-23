SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWageLog_s_sp]
( @processed_pay_period          DATETIME
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWageLog_s_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to insert rows into stateminimumwagelog_hdr and stateminimumwagelog_dtl
*
* RETURNS:
*
* NOTHING:
*
* 08/15/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   DECLARE @smwlh_id INT

   --Data Validation
   IF @processed_pay_period IS NULL
   BEGIN
      RAISERROR('A Processing Period is required',16,1)
      RETURN
   END

   SELECT @smwlh_id = smwlh_id
     FROM stateminimumwagelog_hdr
    WHERE processed_pay_period = @processed_pay_period

   SELECT smwlh_id
        , processed_pay_period
        , applicable_pay_period_begin
        , applicable_pay_period_end
        , smwld_id
        , mpp_id
        , applicable_taxable_pay
        , applicable_duty_hours
        , smw_id
        , adjusted_amount
     FROM (
            SELECT h.smwlh_id
                 , h.processed_pay_period
                 , h.applicable_pay_period_begin
                 , h.applicable_pay_period_end
                 , d.smwld_id
                 , d.mpp_id
                 , d.applicable_taxable_pay
                 , d.applicable_duty_hours
                 , d.smw_id
                 , (SELECT SUM(pyd_amount) FROM dbo.paydetail p WHERE p.pyd_smwld_id = d.smwld_id ) AS adjusted_amount
                 , (SELECT COUNT(1) FROM dbo.paydetail p WHERE p.pyd_smwld_id = d.smwld_id AND p.pyh_number <= 0) AS unposted_adjustment
              FROM stateminimumwagelog_hdr h
            INNER JOIN stateminimumwagelog_dtl d ON h.smwlh_id = d.smwlh_id
             WHERE h.smwlh_id = @smwlh_id
          ) q
     WHERE q.unposted_adjustment > 0

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWageLog_s_sp] TO [public]
GO
