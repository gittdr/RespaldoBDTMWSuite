SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[statutoryholidaypay_final_settlement_sp]
( @pyh_number  INT
, @msg         VARCHAR(255) OUTPUT
)
AS

/*
*
*
* NAME:
* dbo.statutoryholidaypay_final_settlement_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Customized Stored Procedure to insert/update/delete paydetail
*
* RETURNS:
*
* NOTHING:
*
* 09/09/2015 PTS90961  SPN - Created Initial Version
* 01/19/2017 PTS103440 SPN - Revised to consider Vacation Expiration and Exclusion of Pay Categories from Earnings
* 06/15/2017 PTS106548 SPN - pyd_prorap populated from asset profile, pyd_glnum (AR/PR) populated from pay type based on pyd_prorap = A/P, and std_number set to -1
*
*/

BEGIN

   DECLARE @gi_pyt_itemcode            VARCHAR(6)
   DECLARE @gi_paycat_excluded         VARCHAR(60)
   DECLARE @gi_vac_expiration          VARCHAR(60)
   DECLARE @gi_weekbegin               INT

   DECLARE @Period_End                 DATETIME
   DECLARE @Period_Start               DATETIME
   DECLARE @Pay_Denominator            MONEY
   DECLARE @EarningDuringPeriod        MONEY
   DECLARE @HolidayWage                MONEY
   DECLARE @Remarks                    VARCHAR(500)

   DECLARE @TMW_pyd_number             INT
   DECLARE @TMW_pyt_description        VARCHAR(30)
   DECLARE @TMW_pyt_rateunit           VARCHAR(6)
   DECLARE @TMW_pyt_unit               VARCHAR(6)
   DECLARE @TMW_pyd_minus              INT
   DECLARE @TMW_pyt_pretax             VARCHAR(1)
   DECLARE @AccountingType             CHAR(1)
   DECLARE @TMW_pyt_ap_glnum           VARCHAR(66)
   DECLARE @TMW_pyt_pr_glnum           VARCHAR(66)

   DECLARE @Current_pay_period         DATETIME
   DECLARE @Current_asgn_type          VARCHAR(6)
   DECLARE @Current_asgn_id            VARCHAR(13)
   DECLARE @CompensationType           VARCHAR(6)
   DECLARE @HireDate                   DATETIME
   DECLARE @Current_asgn_number        INT
   DECLARE @Holiday_Date               DATETIME
   DECLARE @Id                         INT
   DECLARE @maxId                      INT

   DECLARE @Current_Period_Start       DATETIME
   DECLARE @Current_Period_End         DATETIME

   DECLARE @DateRanges TABLE
   ( Id           INT NOT NULL IDENTITY
   , Period_Start DATETIME NOT NULL
   , Period_End   DATETIME NOT NULL
   )

   DECLARE @HolidayDuringCurrentPeriod TABLE
   ( Id        INT NOT NULL IDENTITY
   , holiday   DATETIME NOT NULL
   )

   SELECT @gi_pyt_itemcode    = gi_string1
        , @gi_paycat_excluded = ISNULL(gi_string2,'')
        , @gi_vac_expiration  = ISNULL(gi_string3,'')
        , @gi_weekbegin       = ISNULL(gi_integer1,1)
     FROM generalinfo
    WHERE gi_name = 'StatPayCode'

   --Validate GI
   BEGIN
      IF @gi_pyt_itemcode IS NULL OR @gi_pyt_itemcode = ''
         BEGIN
            RETURN 0
         END
      IF NOT EXISTS (SELECT 1
                       FROM paytype
                      WHERE pyt_itemcode = @gi_pyt_itemcode
                    )
         BEGIN
            SELECT @msg = 'Pay Type <<' + @gi_pyt_itemcode + '>> does not exist'
            RETURN -1
         END
   END

   IF @gi_weekbegin < 1 OR @gi_weekbegin > 7
      SELECT @gi_weekbegin = 1

   IF LEFT(@gi_paycat_excluded,1) <> ','
      SELECT @gi_paycat_excluded = ',' + @gi_paycat_excluded
   IF RIGHT(@gi_paycat_excluded,1) <> ','
      SELECT @gi_paycat_excluded = @gi_paycat_excluded + ','

   IF LEFT(@gi_vac_expiration,1) <> ','
      SELECT @gi_vac_expiration = ',' + @gi_vac_expiration
   IF RIGHT(@gi_vac_expiration,1) <> ','
      SELECT @gi_vac_expiration = @gi_vac_expiration + ','

   --Get Holiday Paytype details
   SELECT @TMW_pyt_description = pyt_description
        , @TMW_pyt_rateunit    = pyt_rateunit
        , @TMW_pyt_unit        = pyt_unit
        , @TMW_pyd_minus       = (CASE WHEN pyt_minus = 'Y' THEN -1 ELSE 1 END)
        , @TMW_pyt_pretax      = pyt_pretax
        , @TMW_pyt_ap_glnum    = pyt_ap_glnum
        , @TMW_pyt_pr_glnum    = pyt_pr_glnum
     FROM paytype
    WHERE pyt_itemcode = @gi_pyt_itemcode

   --Get Asset Info etc. from Payheader (Holiday Pay is for Drivers Only)
   SELECT @Current_pay_period = p.pyh_payperiod
        , @Current_asgn_type  = p.asgn_type
        , @Current_asgn_id    = p.asgn_id
     FROM payheader p
    WHERE p.pyh_pyhnumber = @pyh_number
   IF @Current_asgn_type <> 'DRV'
      RETURN 0

   --Hiredate and CompensationType
   SELECT @CompensationType = ISNULL(CompensationType,'WAGE')
        , @HireDate = IsNull(mpp_hiredate,CONVERT(DATETIME,'1901-01-01'))
        , @AccountingType = IsNull(mpp_actg_type,'P')
     FROM manpowerprofile
    WHERE mpp_id = @Current_asgn_id

   --Only WAGE and COMMISSION based Drivers are supported
   IF @CompensationType <> 'WAGE' AND @CompensationType <> 'COMM'
      RETURN 0

   --Asset Assignment info
   SELECT @Current_asgn_number = MAX(asgn_number)
     FROM assetassignment
    WHERE asgn_type = @Current_asgn_type
      AND asgn_id = @Current_asgn_id

   --Earnings based on CompensationType
   --Wage-based drivers get 1/20th of last 4 weeks'earnings while commission based drivers get 1/60th of last 12 weeks' of earnings
   IF @CompensationType = 'WAGE'
      BEGIN
         SELECT @Period_End   = Dateadd(dd, -1, dbo.fn_GetAdjacentDateByDayNumber(@Current_pay_period,@gi_weekbegin))   -- Previous Day of the Beginning of this Period
         SELECT @Period_Start = Dateadd(dd, 1, Dateadd(wk, -4, @Period_End))                                            -- Go Back 4 weeks from End Date and take the Next Day
      END
   IF @CompensationType = 'COMM'
      BEGIN
         SELECT @Period_End   = Dateadd(dd, -1, dbo.fn_GetAdjacentDateByDayNumber(@Current_pay_period,@gi_weekbegin))   -- Previous Day of the Beginning of this Period
         SELECT @Period_Start = Dateadd(dd, 1, Dateadd(wk, -12, @Period_End))                                           -- Go Back 12 weeks from End Date
      END

   SELECT @Period_Start = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, @Period_Start,101),10))
   SELECT @Period_End   = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, @Period_End,101),10) + ' 23:59:59')

   --Are there any Holidays during the current period
   INSERT INTO @HolidayDuringCurrentPeriod
   ( holiday )
   SELECT holiday
     FROM holidays
    WHERE holiday > @Period_End AND holiday <= @Current_pay_period
   IF NOT EXISTS (SELECT 1 FROM @HolidayDuringCurrentPeriod)
      RETURN 0

   --Create DateRanges By Week
   SET @Current_Period_Start = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, @Period_Start,101),10))
   WHILE 1 = 1
   BEGIN
      IF @Current_Period_Start > @Period_End
         BREAK

      SET @Current_Period_End = DATEADD(dd, 6,@Current_Period_Start)
      SET @Current_Period_End = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, @Current_Period_End,101),10) + ' 23:59:59')
      IF @Current_Period_End > @Period_End
         SET @Current_Period_End = @Period_End

      INSERT INTO @DateRanges
      (Period_Start, Period_End)
      VALUES
      (@Current_Period_Start, @Current_Period_End)

      SET @Current_Period_Start = DATEADD(dd, 7,@Current_Period_Start)
   END

   --Exclude Week of Vacation
   IF @gi_vac_expiration <> ',,'
   BEGIN
      SELECT @maxId = MAX(Id) FROM @DateRanges
      SELECT @Id = 0
      WHILE @Id < @maxId
      BEGIN
         SELECT @Id = MIN(Id) FROM @DateRanges WHERE id > @Id
         IF @Id IS NULL OR @Id = 0
            BREAK

         SELECT @Current_Period_Start = Period_Start
              , @Current_Period_End = Period_End
           FROM @DateRanges
          WHERE id = @Id

         DELETE FROM @DateRanges
          WHERE Id = @id
            AND EXISTS (SELECT 1
                          FROM EXPIRATION
                         WHERE exp_idtype = @Current_asgn_type
                           AND exp_id = @Current_asgn_id
                           AND CHARINDEX(',' + exp_code + ',', @gi_vac_expiration) > 0
                           AND IsNull(exp_expirationdate, '2049-12-31') <= @Current_Period_End
                           AND IsNull(exp_compldate, '2049-12-31') >= @Current_Period_Start
                       )
      END
   END

   --Use DateRanges to get Denominator (5 per week)
   SELECT @Pay_Denominator = Count(1) * 5 FROM @DateRanges

   --Earnings during the last period (4 or 12 weeks);  Exclude Week of Vacation and Reduce Denominator by 5 per week.
   SELECT @EarningDuringPeriod = SUM(d.pyd_amount)
     FROM paydetail d
     JOIN payheader h ON d.pyh_number = h.pyh_pyhnumber
     JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
     JOIN @DateRanges dr ON h.pyh_payperiod >= dr.Period_Start
                        AND h.pyh_payperiod <= dr.Period_End
    WHERE h.asgn_type = @Current_asgn_type
      AND h.asgn_id   = @Current_asgn_id
      --Begin Excluded Pay Categories from Earnings
      AND CHARINDEX(',' + IsNull(t.pyt_category, '|xxxxx|') + ',', @gi_paycat_excluded) <= 0
      AND CHARINDEX(',' + IsNull(t.pyt_category2,'|xxxxx|') + ',', @gi_paycat_excluded) <= 0
      AND CHARINDEX(',' + IsNull(t.pyt_category3,'|xxxxx|') + ',', @gi_paycat_excluded) <= 0
      AND CHARINDEX(',' + IsNull(t.pyt_category4,'|xxxxx|') + ',', @gi_paycat_excluded) <= 0
      --End Excluded Pay Categories from Earnings


   IF @EarningDuringPeriod IS NULL OR @EarningDuringPeriod <= 0 OR @Pay_Denominator <= 0
      RETURN 0

   --Holiday Wage
   SELECT @HolidayWage = @EarningDuringPeriod / @Pay_Denominator

   SELECT @maxId = MAX(Id) FROM @HolidayDuringCurrentPeriod
   SELECT @Id = 0
   WHILE @Id < @maxId
   BEGIN
      SELECT @Id = MIN(Id) FROM @HolidayDuringCurrentPeriod WHERE id > @Id
      IF @Id IS NULL OR @Id = 0
         BREAK

      SELECT @Holiday_Date = holiday FROM @HolidayDuringCurrentPeriod WHERE id = @Id

      IF (DATEDIFF(dd,@HireDate,@Holiday_Date) + 1) < 30
         CONTINUE

      SELECT @Remarks = 'Auto generated Holiday Pay for ' + CONVERT(VARCHAR, @Holiday_Date, 107)

      --If exists Update(when not zero) / Delete (when zero) else Insert paydetail
      IF EXISTS (SELECT 1
                   FROM paydetail
                  WHERE pyh_number = @pyh_number
                    AND pyt_itemcode = @gi_pyt_itemcode
                    AND pyd_remarks = @Remarks
                )
         BEGIN
            IF @HolidayWage = 0
               BEGIN
                  DELETE
                    FROM paydetail
                   WHERE pyh_number = @pyh_number
                     AND pyt_itemcode = @gi_pyt_itemcode
                     AND pyd_remarks = @Remarks
               END
            ELSE
               BEGIN
                  UPDATE paydetail
                     SET pyd_rate = @HolidayWage
                       , pyd_amount = @HolidayWage
                   WHERE pyh_number = @pyh_number
                     AND pyt_itemcode = @gi_pyt_itemcode
                     AND pyd_remarks = @Remarks
               END
         END
      ELSE
         BEGIN
            IF @HolidayWage <> 0
            BEGIN
               EXECUTE @TMW_pyd_number = dbo.getsystemnumber 'PYDNUM', ''

               INSERT INTO paydetail
               ( pyh_number
               , pyd_number
               , pyd_sequence
               , mov_number
               , ord_hdrnumber
               , lgh_number
               , pyh_payperiod
               , pyd_workperiod
               , asgn_type
               , asgn_id
               , asgn_number
               , pyt_itemcode
               , pyd_description
               , pyd_quantity
               , pyd_rateunit
               , pyd_unit
               , pyd_rate
               , pyd_amount
               , pyd_minus
               , pyd_pretax
               , pyd_prorap
               , pyd_glnum
               , pyd_remarks
               , pyd_status
               , pyd_vendortopay
               , std_number
               )
               VALUES
               ( @pyh_number
               , @TMW_pyd_number
               , 1
               , 0
               , 0
               , 0
               , @Current_pay_period
               , @Holiday_Date
               , @Current_asgn_type
               , @Current_asgn_id
               , @Current_asgn_number
               , @gi_pyt_itemcode
               , @TMW_pyt_description
               , 1
               , @TMW_pyt_rateunit
               , @TMW_pyt_unit
               , @HolidayWage
               , @HolidayWage
               , @TMW_pyd_minus
               , @TMW_pyt_pretax
               , @AccountingType
               , (CASE WHEN @AccountingType = 'A' THEN @TMW_pyt_ap_glnum ELSE @TMW_pyt_pr_glnum END)
               , @Remarks
               , 'PND'
               , 'UNKNOWN'
               , -1
               )
            END
         END
      END

   RETURN 1

END
GO
GRANT EXECUTE ON  [dbo].[statutoryholidaypay_final_settlement_sp] TO [public]
GO
