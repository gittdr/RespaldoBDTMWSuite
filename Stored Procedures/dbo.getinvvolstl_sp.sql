SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getinvvolstl_sp]
( @pl_invnumber   INT
, @pf_vol         FLOAT       OUT
, @pf_vol_unit    VARCHAR(6)  OUT
)
AS

BEGIN
   DECLARE @ord_hdrnumber INT

   SELECT @ord_hdrnumber = ord_hdrnumber
     FROM invoiceheader
    WHERE ivh_hdrnumber = @pl_invnumber

   SELECT @pf_vol = IsNull(SUM(ivd_quantity),0)
        , @pf_vol_unit = IsNull(IsNull(Min(ivd_unit), (SELECT ord_totalvolumeunits
                                                         FROM orderheader
                                                        WHERE ord_hdrnumber = @ord_hdrnumber
                                                      )),'GAL')
    FROM invoicedetail
    JOIN labelfile ON invoicedetail.ivd_unit = labelfile.abbr
                  AND labelfile.labeldefinition = 'VolumeUnits'
    JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
                   AND chargetype.cht_basis = 'SHP'
   WHERE invoicedetail.ivh_hdrnumber = @pl_invnumber
     AND invoicedetail.ivd_quantity > 0
     AND invoicedetail.cht_itemcode <> 'DEL'

   If @pf_vol = 0
   BEGIN
      SELECT @pf_vol = IsNull(ivh_totalvolume, 0)
        FROM invoiceheader
       WHERE invoiceheader.ivh_hdrnumber = @pl_invnumber

      SELECT @pf_vol_unit = IsNull(ivd_volunit,'GAL')
        FROM invoicedetail
        JOIN labelfile ON invoicedetail.ivd_unit = labelfile.abbr
                      AND labelfile.labeldefinition = 'VolumeUnits'
       WHERE invoicedetail.ivh_hdrnumber = @pl_invnumber
         AND invoicedetail.ivd_volume > 0
         AND invoicedetail.cht_itemcode = 'DEL'

   END
END
GO
GRANT EXECUTE ON  [dbo].[getinvvolstl_sp] TO [public]
GO
