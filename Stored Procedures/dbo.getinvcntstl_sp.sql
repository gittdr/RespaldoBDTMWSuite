SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getinvcntstl_sp]
( @pl_invnumber   INT
, @pf_cnt         FLOAT       OUT
, @pf_cnt_unit    VARCHAR(6)  OUT
)
AS

BEGIN
   DECLARE @ord_hdrnumber INT

   SELECT @ord_hdrnumber = ord_hdrnumber
     FROM invoiceheader
    WHERE ivh_hdrnumber = @pl_invnumber

   SELECT @pf_cnt = IsNull(SUM(ivd_quantity),0)
        , @pf_cnt_unit = IsNull(IsNull(Min(ivd_unit), (SELECT ord_totalcountunits
                                                         FROM orderheader
                                                        WHERE ord_hdrnumber = @ord_hdrnumber
                                                      )),'PCS')
    FROM invoicedetail
    JOIN labelfile ON invoicedetail.ivd_unit = labelfile.abbr
                  AND labelfile.labeldefinition = 'CountUnits'
    JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
                   AND chargetype.cht_basis = 'SHP'
   WHERE invoicedetail.ivh_hdrnumber = @pl_invnumber
     AND invoicedetail.ivd_quantity > 0
     AND invoicedetail.cht_itemcode <> 'DEL'

   If @pf_cnt = 0
   BEGIN
      SELECT @pf_cnt = IsNull(ivh_totalpieces, 0)
        FROM invoiceheader
       WHERE invoiceheader.ivh_hdrnumber = @pl_invnumber

      SELECT @pf_cnt_unit = IsNull(ivd_countunit,'PCS')
        FROM invoicedetail
        JOIN labelfile ON invoicedetail.ivd_unit = labelfile.abbr
                      AND labelfile.labeldefinition = 'CountUnits'
       WHERE invoicedetail.ivh_hdrnumber = @pl_invnumber
         AND invoicedetail.ivd_count > 0
         AND invoicedetail.cht_itemcode = 'DEL'

   END
END
GO
GRANT EXECUTE ON  [dbo].[getinvcntstl_sp] TO [public]
GO
