SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_chargetype_sp]
( @cht_primary          CHAR(1)     = NULL
, @cht_retired          CHAR(1)     = NULL
) AS

/**
 *
 * NAME:
 * dbo.ds_chargetype_sp
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
 * @cht_primary         CHAR(1)
 * @cht_retired         CHAR(1)
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 06/13/12
 *
 **/

SET NOCOUNT ON

BEGIN

   --************--
   --** Select **--
   --************--
   SELECT cht_number
        , cht_itemcode
        , cht_description
        , cht_primary
        , cht_basis
        , cht_basisunit
        , cht_basisper
        , cht_quantity
        , cht_rateunit
        , cht_unit
        , cht_rate
        , cht_editflag
        , cht_glnum
        , cht_sign
        , cht_systemcode
        , cht_edicode
        , cht_taxtable1
        , cht_taxtable2
        , cht_taxtable3
        , cht_taxtable4
        , cht_currunit
        , cht_remark
        , cht_rollintolh
        , cht_retired
        , cht_maxrate
        , cht_maxenf
        , cht_minrate
        , cht_minenf
        , cht_zeroenf
        , cht_crchg
        , cht_class
        , cht_rateprotect
        , gp_tax
        , cht_lh_min
        , cht_lh_rev
        , cht_lh_stl
        , cht_lh_rpt
        , cht_lh_prn
        , last_updateby
        , last_updatedate
        , cht_typeofcharge
        , cht_paperwork_requiretype
        , cht_allocation_method
        , cht_allocation_criteria
        , cht_allocation_groupby
        , cht_allocation_group_nbr
        , cht_setrevfromchargetypelist
        , cht_edit_completion_rate
        , cht_category1
        , cht_category2
        , cht_category3
        , cht_category4
        , cht_translation
        , cht_glkey
     FROM chargetype
    WHERE (IsNull(cht_retired,'N') = @cht_retired OR @cht_retired IS NULL)
      AND (IsNull(cht_primary,'Y') = @cht_primary OR @cht_primary IS NULL)
   ORDER BY cht_description

END
GO
GRANT EXECUTE ON  [dbo].[ds_chargetype_sp] TO [public]
GO
