SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_stlmnt_edit_prefinal_paydetail]
   @as_asgn_type     VARCHAR(10)
 , @as_asgn_id       VARCHAR(15)
AS

/**
 * 
 * NAME:
 * d_stlmnt_edit_prefinal_paydetail
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns paydetail to be displayed in the Pre-Final Settlement Folder for update of CIN info
 *
 * RETURNS: NONE
 *
 * RESULT SETS: paydetail
 *
 * PARAMETERS:
 * @as_asgn_type     VARCHAR(10) paydetail.asgn_type
 * @as_asgn_id       VARCHAR(15) paydetail.asgn_id
 *
 * REVISION HISTORY:
 * 11/12/2010 PTS52686 - Suprakash Nandan Created Procedure
 *
 **/
BEGIN

   SELECT pd.pyh_number
        , pd.pyd_number
        , pd.mov_number
        , pd.ord_hdrnumber
        , oh.ord_number
        , pd.lgh_number
        , pd.asgn_number
        , pd.asgn_type
        , pd.asgn_id
        , pd.pyd_sequence
        , pd.std_number
        , pd.pyt_itemcode
        , pd.pyd_description
        , pd.pyd_quantity
        , pd.pyd_unit
        , pd.pyd_rate
        , pd.pyd_amount
        , pd.pyd_minus
        , pd.pyd_carinvnum
        , pd.pyd_carinvdate
        , pd.pyh_payperiod
        , pd.pyd_workperiod
        , pd.pyd_status
        , pd.pyd_glnum
        , pd.tar_tarriffnumber
     FROM paydetail pd
     LEFT OUTER JOIN payheader ph ON pd.pyh_number = ph.pyh_pyhnumber
     LEFT OUTER JOIN orderheader oh ON pd.ord_hdrnumber = oh.ord_hdrnumber
    WHERE pd.asgn_type  = @as_asgn_type
      AND pd.asgn_id    = @as_asgn_id
      AND pd.pyd_status = 'PND'
      AND (pd.pyh_number = 0 OR (pd.pyh_number <> 0 AND ph.pyh_paystatus = 'PND'))
      AND pd.lgh_number <> 0

   RETURN

END

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_edit_prefinal_paydetail] TO [public]
GO
