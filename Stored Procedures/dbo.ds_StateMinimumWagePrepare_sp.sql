SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWagePrepare_sp]
( @processed_pay_period          DATETIME
, @applicable_pay_period_begin   DATETIME
, @applicable_pay_period_end     DATETIME
, @mpp_terminated                CHAR(1)
, @mpp_type1                     VARCHAR(6)
, @mpp_type2                     VARCHAR(6)
, @mpp_type3                     VARCHAR(6)
, @mpp_type4                     VARCHAR(6)
, @mpp_id                        VARCHAR(8)
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWagePrepare_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return StateMinimumWage to be processed for a given Pay-Period
*
* RETURNS:
*
* NOTHING:
*
* 08/14/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   DECLARE @smwlh_id                INT
   DECLARE @count                   INT
   DECLARE @sn                      INT
   DECLARE @exclude_pyt_itemcodes   VARCHAR(MAX)

   DECLARE @cur_mpp_id              VARCHAR(8)
   DECLARE @cur_mpp_state           VARCHAR(6)

   DECLARE @applicable_taxable_pay  MONEY
   DECLARE @applicable_duty_hours   DECIMAL(10,4)
   DECLARE @smw_id                  INT
   DECLARE @hourly_rate             MONEY
   DECLARE @underpaid_amount        MONEY

   DECLARE @temp_manpowerprofile TABLE
   ( mpp_id    VARCHAR(8) NOT NULL
   , mpp_state VARCHAR(6) NULL
   )

   DECLARE @temp TABLE
   ( sn                          INT            IDENTITY(1,1) NOT NULL
   , smwlh_id                    INT            NULL
   , processed_pay_period        DATETIME       NULL
   , applicable_pay_period_begin DATETIME       NULL
   , applicable_pay_period_end   DATETIME       NULL
   , mpp_id                      VARCHAR(8)     NULL
   , mpp_state                   VARCHAR(6)     NULL
   , applicable_taxable_pay      MONEY          NULL
   , applicable_duty_hours       DECIMAL(10,4)  NULL
   , smw_id                      INT            NULL
   , hourly_rate                 MONEY          NULL
   , payable_amount              MONEY          NULL
   , underpaid_amount            MONEY          NULL
   )

   SELECT @exclude_pyt_itemcodes = gi_string2
     FROM generalinfo
    WHERE gi_name = 'STL_StateMinimumWage'
   IF @exclude_pyt_itemcodes IS NULL OR LTRIM(RTRIM(@exclude_pyt_itemcodes)) = ''
      SELECT @exclude_pyt_itemcodes = '*UNK*'

   SELECT @exclude_pyt_itemcodes = ',' + @exclude_pyt_itemcodes + ','

   IF IsNull(@mpp_terminated,'N') <> 'Y'
      SELECT @mpp_terminated = 'N'

   SELECT @smwlh_id = smwlh_id
     FROM stateminimumwagelog_hdr
    WHERE processed_pay_period = @processed_pay_period
   IF @smwlh_id IS NULL
      SELECT @smwlh_id = -1

   IF @mpp_type1 IS NULL OR @mpp_type1 = ''
      SELECT @mpp_type1 = 'UNK'

   IF @mpp_type2 IS NULL OR @mpp_type2 = ''
      SELECT @mpp_type2 = 'UNK'

   IF @mpp_type3 IS NULL OR @mpp_type3 = ''
      SELECT @mpp_type3 = 'UNK'

   IF @mpp_type4 IS NULL OR @mpp_type4 = ''
      SELECT @mpp_type4 = 'UNK'

   IF @mpp_id IS NULL OR @mpp_id = ''
      SELECT @mpp_id = 'UNK'

   --Drivers List
   INSERT INTO @temp_manpowerprofile
   ( mpp_id
   , mpp_state
   )
   SELECT mpp_id
        , mpp_state
     FROM dbo.manpowerprofile m
    WHERE IsNull(m.mpp_actg_type,'N') IN ('P')
      AND @mpp_terminated = 'N'
      AND @mpp_type1 IN (IsNull(m.mpp_type1,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type2 IN (IsNull(m.mpp_type2,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type3 IN (IsNull(m.mpp_type3,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type4 IN (IsNull(m.mpp_type4,'UNK'),'UNKNOWN','UNK')
      AND @mpp_id    IN (IsNull(m.mpp_id,'UNK'),'UNKNOWN','UNK')
   UNION ALL
   SELECT mpp_id
        , mpp_state
     FROM dbo.manpowerprofile m
    WHERE IsNull(m.mpp_actg_type,'N') IN ('P')
      AND @mpp_terminated = 'Y'
      AND m.mpp_terminationdt >= @applicable_pay_period_begin
      AND m.mpp_terminationdt <= @applicable_pay_period_end
      AND @mpp_type1 IN (IsNull(m.mpp_type1,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type2 IN (IsNull(m.mpp_type2,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type3 IN (IsNull(m.mpp_type3,'UNK'),'UNKNOWN','UNK')
      AND @mpp_type4 IN (IsNull(m.mpp_type4,'UNK'),'UNKNOWN','UNK')
      AND @mpp_id    IN (IsNull(m.mpp_id,'UNK'),'UNKNOWN','UNK')

   --Resultset
   INSERT INTO @temp
   ( smwlh_id
   , processed_pay_period
   , applicable_pay_period_begin
   , applicable_pay_period_end
   , mpp_id
   , mpp_state
   , applicable_taxable_pay
   , applicable_duty_hours
   , smw_id
   , hourly_rate
   , payable_amount
   , underpaid_amount
   )
   SELECT @smwlh_id
        , @processed_pay_period
        , @applicable_pay_period_begin
        , @applicable_pay_period_end
        , m.mpp_id
        , m.mpp_state
        , p.applicable_taxable_pay
        , 0
        , NULL
        , 0
        , 0
        , 0
     FROM @temp_manpowerprofile m
   LEFT OUTER JOIN (SELECT d.mpp_id
                      FROM dbo.stateminimumwagelog_hdr h
                    INNER JOIN dbo.stateminimumwagelog_dtl d ON h.smwlh_id = d.smwlh_id
                     WHERE h.processed_pay_period = @processed_pay_period
                   ) l ON m.mpp_id = l.mpp_id
   INNER JOIN (SELECT asgn_id          AS asgn_id
                    , SUM(pyd_amount)  AS applicable_taxable_pay
                 FROM dbo.paydetail
                WHERE asgn_type = 'DRV'
                  AND pyh_payperiod >= @applicable_pay_period_begin
                  AND pyh_payperiod <= @applicable_pay_period_end
                  AND IsNull(pyd_pretax,'Y') = 'Y'
                  AND IsNull(pyd_minus,1) = 1
                  AND pyd_smwld_id IS NULL
                  AND CHARINDEX (',' + pyt_itemcode + ',',@exclude_pyt_itemcodes) <= 0
               GROUP BY asgn_id
              ) p ON m.mpp_id = p.asgn_id
    WHERE l.mpp_id IS NULL

   --Compute
   SELECT @count = COUNT(1)
     FROM @temp

   SELECT @sn = 0
   WHILE @sn < @count
   BEGIN
      SELECT @sn = @sn + 1

      SELECT @cur_mpp_id             = mpp_id
           , @cur_mpp_state          = mpp_state
           , @applicable_taxable_pay = applicable_taxable_pay
        FROM @temp
       WHERE sn = @sn

      --QHOS Duty Hours
      EXECUTE @applicable_duty_hours = dbo.sp_TS_QHOSDriverLogDutyHours @cur_mpp_id, @applicable_pay_period_begin, @applicable_pay_period_end
      IF @applicable_duty_hours IS NULL
         SELECT @applicable_duty_hours = 0

      --State Minimum Wage (Country is not used as we do not know the driver country)
      SELECT @smw_id       = MAX(smw_id)
           , @hourly_rate  = MAX(hourly_rate)
        FROM dbo.stateminimumwage
       WHERE state = @cur_mpp_state
         AND effective_date = (SELECT MAX(effective_date)
                                 FROM dbo.stateminimumwage
                                WHERE state           = @cur_mpp_state
                                  AND effective_date  <= @applicable_pay_period_begin
                              )
      IF @hourly_rate IS NULL
         SELECT @hourly_rate = 0

      SELECT @underpaid_amount = 0
      IF @hourly_rate > 0 AND @applicable_duty_hours > 0
      BEGIN
         SELECT @underpaid_amount = (@hourly_rate * @applicable_duty_hours) - @applicable_taxable_pay
         IF @underpaid_amount <= 0
            SELECT @underpaid_amount = 0
      END

      UPDATE @temp
         SET applicable_duty_hours  = @applicable_duty_hours
           , smw_id                 = @smw_id
           , hourly_rate            = @hourly_rate
           , payable_amount         = (@hourly_rate * @applicable_duty_hours)
           , underpaid_amount       = @underpaid_amount
       WHERE sn = @sn
   END   --LOOP

   --Delete zero Lines
   DELETE FROM @temp
    WHERE underpaid_amount <= 0

   SELECT *
     FROM @temp

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWagePrepare_sp] TO [public]
GO
