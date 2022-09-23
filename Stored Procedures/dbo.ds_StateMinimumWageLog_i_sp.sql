SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWageLog_i_sp]
( @smwlh_id                      INT
, @processed_pay_period          DATETIME
, @applicable_pay_period_begin   DATETIME
, @applicable_pay_period_end     DATETIME
, @smwld_id                      INT
, @mpp_id                        VARCHAR(8)
, @applicable_taxable_pay        MONEY
, @applicable_duty_hours         DECIMAL(10,4)
, @smw_id                        INT
, @adjusted_amount               MONEY
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWageLog_i_sp
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

   DECLARE @pyd_number        INT
   DECLARE @pyt_itemcode      VARCHAR(6)
   DECLARE @pyt_description   VARCHAR(75)
   DECLARE @pyt_unit          VARCHAR(6)
   DECLARE @pyt_rateunit      VARCHAR(6)
   DECLARE @pyt_pretax        CHAR(1)
   DECLARE @pyt_minus         INT
   DECLARE @pyt_pr_glnum      VARCHAR(32)
   DECLARE @pyh_payperiod     DATETIME
   DECLARE @pyd_transdate     DATETIME

   SELECT @pyt_itemcode = 'SMWADJ'
   SELECT @pyh_payperiod = '2049-12-31 23:59:00.000'
   SELECT @pyd_transdate = '1950-01-01 00:00:00.000'

   --Data Validation
   IF @processed_pay_period IS NULL
   BEGIN
      RAISERROR('A Processing Period is required',16,1)
      RETURN
   END

   IF @applicable_pay_period_begin IS NULL
   BEGIN
      RAISERROR('A Processing Period Begin is required',16,1)
      RETURN
   END

   IF @applicable_pay_period_end IS NULL
   BEGIN
      RAISERROR('A Processing Period End is required',16,1)
      RETURN
   END

   IF @smwld_id IS NOT NULL AND @smwld_id > 0
      BEGIN
         RAISERROR('Cannot insert Detail that already exists',16,1)
         RETURN
      END

   IF @mpp_id IS NULL OR @mpp_id = 'UNK' OR @mpp_id = 'UNKNOWN' OR LTRIM(RTRIM(@mpp_id)) = ''
      BEGIN
         RAISERROR('A Driver is required',16,1)
         RETURN
      END

   IF @smw_id IS NULL OR @smw_id <= 0
      BEGIN
         RAISERROR('State Minimum Wage Rate is required',16,1)
         RETURN
      END

   --Insert stateminimumwagelog_hdr
   IF @smwlh_id IS NULL OR @smwlh_id <= 0
      BEGIN
         SELECT @smwlh_id = smwlh_id
           FROM stateminimumwagelog_hdr
          WHERE processed_pay_period = @processed_pay_period
         IF @smwlh_id IS NULL OR @smwlh_id <= 0
         BEGIN
            INSERT INTO stateminimumwagelog_hdr
            ( processed_pay_period
            , applicable_pay_period_begin
            , applicable_pay_period_end
            )
            VALUES
            ( @processed_pay_period
            , @applicable_pay_period_begin
            , @applicable_pay_period_end
            )
          SELECT @smwlh_id = SCOPE_IDENTITY()
         END
      END

   --Insert stateminimumwagelog_dtl
   INSERT INTO stateminimumwagelog_dtl
   ( smwlh_id
   , mpp_id
   , applicable_taxable_pay
   , applicable_duty_hours
   , smw_id
   )
   VALUES
   ( @smwlh_id
   , @mpp_id
   , @applicable_taxable_pay
   , @applicable_duty_hours
   , @smw_id
   )
   SELECT @smwld_id = SCOPE_IDENTITY()

   --Insert paydetail
   SELECT @pyt_description = pyt_description
        , @pyt_unit        = pyt_unit
        , @pyt_rateunit    = pyt_rateunit
        , @pyt_pretax      = IsNull(pyt_pretax,'Y')
        , @pyt_minus       = (CASE WHEN IsNull(pyt_minus,'N') = 'N' THEN 1 ELSE -1 END)
        , @pyt_pr_glnum    = pyt_pr_glnum
     FROM paytype
    WHERE pyt_itemcode = @pyt_itemcode

   EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

   INSERT INTO paydetail
   ( pyh_number
   , pyd_number
   , pyh_payperiod
   , pyd_workperiod
   , asgn_type
   , asgn_id
   , pyt_itemcode
   , pyd_smwld_id
   , pyd_description
   , pyd_quantity
   , pyd_unit
   , pyd_rate
   , pyd_rateunit
   , pyd_amount
   , pyd_status
   , pyd_transdate
   , pyd_pretax
   , pyd_minus
   , pyd_glnum
   , std_number
   , pyd_adj_flag
   )
   VALUES
   ( 0
   , @pyd_number
   , @pyh_payperiod
   , @applicable_pay_period_end
   , 'DRV'
   , @mpp_id
   , @pyt_itemcode
   , @smwld_id
   , @pyt_description
   , 1
   , @pyt_unit
   , @adjusted_amount
   , @pyt_rateunit
   , @adjusted_amount
   , 'PND'
   , @pyd_transdate
   , @pyt_pretax
   , @pyt_minus
   , @pyt_pr_glnum
   , 0
   , 'W'
   )

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWageLog_i_sp] TO [public]
GO
