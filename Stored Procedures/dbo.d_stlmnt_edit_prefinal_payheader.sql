SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_stlmnt_edit_prefinal_payheader]
   @as_asgn_type     VARCHAR(10)
 , @as_asgn_id       VARCHAR(15)
AS

/**
 * 
 * NAME:
 * d_stlmnt_edit_prefinal_payheader
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns payheader to be displayed in the Pre-Final Settlement Folder for update of CIN info
 *
 * RETURNS: NONE
 *
 * RESULT SETS: payheader
 *
 * PARAMETERS:
 * @as_asgn_type     VARCHAR(10) payheader.asgn_type
 * @as_asgn_id       VARCHAR(15) payheader.asgn_id
 *
 * REVISION HISTORY:
 * 11/12/2010 PTS52686 - Suprakash Nandan Created Procedure
 *
 **/
BEGIN

   SELECT pyh_pyhnumber
        , payee_invoice_number
        , payee_invoice_date
     FROM payheader
    WHERE asgn_type  = @as_asgn_type
      AND asgn_id    = @as_asgn_id
      AND pyh_paystatus = 'PND'

   RETURN

END

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_edit_prefinal_payheader] TO [public]
GO
