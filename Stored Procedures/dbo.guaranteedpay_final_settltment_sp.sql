SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[guaranteedpay_final_settltment_sp]
( @pyh_number  INT
, @msg         VARCHAR(255) OUTPUT
)
AS

/*
*
*
* NAME:
* dbo.guaranteedpay_final_settltment_sp
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
* 10/17/2012 PTS63193 SPN - Created Initial Version
* 01/16/2015 PTS81726 vjh - add pyh_payperiod to insert
*
*/

BEGIN

   DECLARE @gi_is_feature_on           CHAR(1)
   DECLARE @gi_guaranteed_pyt_itemcode VARCHAR(6)

   DECLARE @TMW_pyd_number             INT

   DECLARE @TMW_pyt_description        VARCHAR(30)
   DECLARE @TMW_pyt_rateunit           VARCHAR(6)
   DECLARE @TMW_pyt_unit               VARCHAR(6)
   DECLARE @TMW_pyd_minus              INT
   DECLARE @TMW_pyt_pretax             VARCHAR(1)
   DECLARE @TMW_pyt_ap_glnum           VARCHAR(66)

   DECLARE @TMW_pay_period             DATETIME
   DECLARE @TMW_asgn_type              VARCHAR(6)
   DECLARE @TMW_asgn_id                VARCHAR(13)
   DECLARE @TMW_asgn_number            INT

   DECLARE @guaranteed_pay_promised    MONEY
   DECLARE @guaranteed_pay_grosspay    MONEY
   DECLARE @guaranteed_pay_due         MONEY

   SELECT @gi_is_feature_on = UPPER(SUBSTRING(gi_string1,1,1))
        , @gi_guaranteed_pyt_itemcode = RTRIM(LTRIM(gi_string2))
     FROM generalinfo
    WHERE gi_name = 'STL_GuaranteedPay'
   IF @gi_is_feature_on IS NULL
      SELECT @gi_is_feature_on = 'N'

   --Validate GI
   BEGIN
      IF @gi_is_feature_on <> 'Y'
         BEGIN
            RETURN 0
         END
      IF @gi_guaranteed_pyt_itemcode IS NULL OR @gi_guaranteed_pyt_itemcode = ''
         BEGIN
            RETURN 0
         END
      IF NOT EXISTS (SELECT 1
                       FROM paytype
                      WHERE pyt_itemcode = @gi_guaranteed_pyt_itemcode
                    )
         BEGIN
            SELECT @msg = 'Pay Type <<' + @gi_guaranteed_pyt_itemcode + '>> does not exist'
            RETURN -1
         END
   END

   --Get Paytype details
   SELECT @TMW_pyt_description = pyt_description
        , @TMW_pyt_rateunit    = pyt_rateunit
        , @TMW_pyt_unit        = pyt_unit
        , @TMW_pyd_minus       = (CASE WHEN pyt_minus = 'Y' THEN -1 ELSE 1 END)
        , @TMW_pyt_pretax      = pyt_pretax
        , @TMW_pyt_ap_glnum    = pyt_ap_glnum
     FROM paytype
    WHERE pyt_itemcode = @gi_guaranteed_pyt_itemcode

   --Get Asset Info etc from Payheader (guaranteed Pay is for Drivers Only)
   SELECT @TMW_pay_period = p.pyh_payperiod
        , @TMW_asgn_type  = p.asgn_type
        , @TMW_asgn_id    = p.asgn_id
     FROM payheader p
    WHERE p.pyh_pyhnumber = @pyh_number
   IF @TMW_asgn_type <> 'DRV'
      RETURN 0

   --Asset Assignment info
   SELECT @TMW_asgn_number = MAX(asgn_number)
     FROM assetassignment
    WHERE asgn_type = @TMW_asgn_type
      AND asgn_id = @TMW_asgn_id

   --Guaranteed Pay as promised on the asset profile
   SELECT @guaranteed_pay_promised = guaranteed_pay_promised
     FROM manpowerprofile
    WHERE mpp_id = @TMW_asgn_id
   IF @guaranteed_pay_promised IS NULL
      SELECT @guaranteed_pay_promised = 0

   --Gross Pay
   SELECT @guaranteed_pay_grosspay = SUM(d.pyd_amount)
     FROM paydetail d
     JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
    WHERE d.pyh_number = @pyh_number
      AND d.pyt_itemcode <> @gi_guaranteed_pyt_itemcode
      AND IsNull(t.pyt_exclude_guaranteed_pay,'N') <> 'Y'
   IF @guaranteed_pay_grosspay IS NULL
      SELECT @guaranteed_pay_grosspay = 0

   --Guaranteed Pay
   IF @guaranteed_pay_promised = 0
      SELECT @guaranteed_pay_due = 0
   ELSE
      BEGIN
         SELECT @guaranteed_pay_due = @guaranteed_pay_promised - @guaranteed_pay_grosspay
         IF @guaranteed_pay_due < 0
            SELECT @guaranteed_pay_due = 0
      END

   --If exists Update(when not zero) / Delete (when zero) else Insert paydetail
   IF EXISTS (SELECT 1
                FROM paydetail
               WHERE pyh_number = @pyh_number
                 AND pyt_itemcode = @gi_guaranteed_pyt_itemcode
             )
      BEGIN
         IF @guaranteed_pay_due = 0
            BEGIN
               DELETE
                 FROM paydetail
                WHERE pyh_number = @pyh_number
                  AND pyt_itemcode = @gi_guaranteed_pyt_itemcode
            END
         ELSE
            BEGIN
               UPDATE paydetail
                  SET pyd_rate = @guaranteed_pay_due
                    , pyd_amount = @guaranteed_pay_due
                WHERE pyh_number = @pyh_number
                  AND pyt_itemcode = @gi_guaranteed_pyt_itemcode
            END
      END
   ELSE
      BEGIN
         IF @guaranteed_pay_due <> 0
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
            , pyd_glnum
            , pyd_remarks
            , pyd_status
            , pyd_vendortopay
            )
            VALUES
            ( @pyh_number
            , @TMW_pyd_number
            , 1
            , 0
            , 0
            , 0
            , @TMW_pay_period
            , @TMW_pay_period
            , @TMW_asgn_type
            , @TMW_asgn_id
            , @TMW_asgn_number
            , @gi_guaranteed_pyt_itemcode
            , @TMW_pyt_description
            , 1
            , @TMW_pyt_rateunit
            , @TMW_pyt_unit
            , @guaranteed_pay_due
            , @guaranteed_pay_due
            , @TMW_pyd_minus
            , @TMW_pyt_pretax
            , @TMW_pyt_ap_glnum
            , 'Auto generated Guatanteed Pay'
            , 'PND'
            , 'UNKNOWN'
            )
         END
      END

   RETURN 1

END
GO
GRANT EXECUTE ON  [dbo].[guaranteedpay_final_settltment_sp] TO [public]
GO
