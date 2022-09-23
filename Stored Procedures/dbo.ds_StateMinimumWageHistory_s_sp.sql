SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWageHistory_s_sp]
( @processed_pay_period_from  DATETIME    
, @processed_pay_period_to    DATETIME    
, @mpp_id                     VARCHAR(8)  
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWageHistory_s_sp
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
* 08/21/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   --Data Validation
   IF @processed_pay_period_from IS NULL
      SELECT @processed_pay_period_from = Convert(DateTime,'1950-01-01 00:00:00')
   IF @processed_pay_period_to IS NULL
      SELECT @processed_pay_period_to = Convert(DateTime,'2049-12-31 23:59:59')
   IF @mpp_id IS NULL OR @mpp_id = ''
      SELECT @mpp_id = 'UNK'

   IF @processed_pay_period_to < @processed_pay_period_from
   BEGIN
      RAISERROR('<To Date> must be greater or equal to <From Date>',16,1)
      RETURN
   END

   SELECT h.smwlh_id
        , h.processed_pay_period
        , h.applicable_pay_period_begin
        , h.applicable_pay_period_end
        , d.smwld_id
        , d.mpp_id
        , d.applicable_taxable_pay
        , d.applicable_duty_hours
        , d.smw_id
        , (SELECT SUM(pyd_amount) FROM dbo.paydetail WHERE pyd_smwld_id = d.smwld_id) AS adjusted_amount
     FROM stateminimumwagelog_hdr h
   INNER JOIN stateminimumwagelog_dtl d ON h.smwlh_id = d.smwlh_id
    WHERE h.processed_pay_period >= @processed_pay_period_from
      AND h.processed_pay_period <= @processed_pay_period_to
      AND d.mpp_id IN (@mpp_id,'UNK','UNKNOWN')

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWageHistory_s_sp] TO [public]
GO
