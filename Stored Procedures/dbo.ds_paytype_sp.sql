SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_paytype_sp]
( @pyt_retired          CHAR(1)     = NULL
) AS

/**
 *
 * NAME:
 * dbo.ds_paytype_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for selecting rows from chargetype table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @pyt_retired         CHAR(1)
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 07/03/12
 *
 **/

SET NOCOUNT ON

BEGIN

   --************--
   --** Select **--
   --************--
   SELECT pyt_number
        , pyt_itemcode
        , pyt_description
        , pyt_basis
        , pyt_basisunit
        , pyt_quantity
        , pyt_rateunit
        , pyt_unit
        , pyt_rate
        , pyt_pretax
        , pyt_minus
        , pyt_editflag
        , pyt_pr_glnum
        , pyt_ap_glnum
        , pyt_status
        , pyt_agedays
        , pyt_fee1
        , pyt_fee2
        , pyt_accept_negatives
        , pyt_fservprocess
        , pyt_expchk
        , pyt_systemcode
        , pyt_maxrate
        , pyt_maxenf
        , pyt_minrate
        , pyt_minenf
        , pyt_zeroenf
        , pyt_incexcoth
        , pyt_retired
        , pyt_paying_to
        , pyt_offset_percent
        , pyt_offset_for
        , pyt_editindispatch
        , pyt_class
        , pyt_classflag
        , pyt_group
        , gp_tax
        , cht_itemcode
        , pyt_authcode_required
        , pyt_otflag
        , pyt_eiflag
        , pyt_pr_glnum_clearing
        , pyt_ap_glnum_clearing
        , pyt_exclude_guaranteed_pay
        , pyt_superv_delete_only
        , pyt_tppcode
        , pyt_payto_splittype
        , pyt_offset_for_splittype
        , pyt_rtd_exclude
        , pyt_offset_basis
        , pyt_taxable
        , pyt_exclude_3pp
        , pyt_category
        , pyt_holiday_vacation
     FROM paytype
    WHERE (IsNull(pyt_retired,'N') = @pyt_retired OR @pyt_retired IS NULL)
   ORDER BY pyt_description

END
GO
GRANT EXECUTE ON  [dbo].[ds_paytype_sp] TO [public]
GO
