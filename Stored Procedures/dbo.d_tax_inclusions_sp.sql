SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_tax_inclusions_sp]
AS

/**
 * 
 * NAME:
 * d_tax_inclusions_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 *    Returns all applicable tax types applicable to a charge type. 
 *
 * RETURNS:
 *    NONE
 *    
 *
 * RESULT SETS: 
 *    cht_taxtable1 char(1)
 *    cht_taxtable2 char(1)
 *    cht_taxtable3 char(1)
 *    cht_taxtable4 char(1)
 *    code          int
 *
 * PARAMETERS:
 *    NONE
 * 
 * REVISION HISTORY:
 * 07/02/2010 PTS 51492 SPN - Initial Version
 * 
 **/

BEGIN
   SELECT cht.cht_taxtable1
        , cht.cht_taxtable2
        , cht.cht_taxtable3
        , cht.cht_taxtable4
        , lbl.code
     FROM labelfile lbl
     JOIN chargetype cht ON lbl.abbr = cht.cht_itemcode
    WHERE SUBSTRING(lbl.labeldefinition, 1, 7) LIKE 'TaxType%'
      AND IsNull(lbl.code,0) <= 4
END

GO
GRANT EXECUTE ON  [dbo].[d_tax_inclusions_sp] TO [public]
GO
