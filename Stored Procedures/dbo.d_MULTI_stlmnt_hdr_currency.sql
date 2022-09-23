SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_MULTI_stlmnt_hdr_currency]
( @paydate     DATETIME
, @asgn_type   VARCHAR(6)
, @asgn_id     VARCHAR(13)
)
AS

/*
*
*
* NAME:
* dbo.d_MULTI_stlmnt_hdr_currency
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to split payheader
*
* PARAMETERS:
* @paydate     DATETIME
* @asgn_type   VARCHAR(6)
* @asgn_id     VARCHAR(13)
*
* RETURNS:
*
* NOTHING:
*
* 01/07/2013 PTS64409 SPN - Created Initial Version
* 06/10/2013 PTS69957 SPN - Fix for Currency and Leg Split
*
*/

BEGIN

   SELECT pd.pyh_number				AS pyh_number
        , ph.pyh_lgh_number		AS lgh_number
        , MAX(pd.mov_number)		AS mov_number
        , MAX(pd.ord_hdrnumber)	AS ord_hdrnumber
        , ph.pyh_currency			AS pyh_currency
     FROM paydetail pd
     JOIN payheader ph ON pd.pyh_number = ph.pyh_pyhnumber
    WHERE pd.pyh_number > 0
      AND pd.asgn_type = @asgn_type
      AND pd.asgn_id = @asgn_id
      AND pd.pyh_payperiod = @paydate
   GROUP BY pd.pyh_number
          , ph.pyh_lgh_number
          , ph.pyh_currency
   ORDER BY pd.pyh_number

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_MULTI_stlmnt_hdr_currency] TO [public]
GO
