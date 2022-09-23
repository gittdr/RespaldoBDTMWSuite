SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_ord_paydetail_cost]
( @ord_hdrnumber  int
, @ord_cost_type  varchar(30)
)
RETURNS MONEY
AS

/**
 *
 * NAME:
 * dbo.fn_ord_paydetail_cost
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to compute Cost from paydetail allocating the share as per the order/invoice
 *
 * RETURNS:
 *
 * MONEY
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber int
 * 002 - @ord_cost_type varchar
 *
 * REVISION HISTORY:
 * PTS 51902 SPN Created 02/11/11
 * 
 **/

BEGIN
   DECLARE @debug                      char(1)
   DECLARE @total_cost                 FLOAT
   DECLARE @linehaul_cost              FLOAT
   DECLARE @accessorial_cost           FLOAT
   DECLARE @fuelsurcharge_cost         FLOAT
   DECLARE @cost                       FLOAT
   DECLARE @ratio                      FLOAT
   DECLARE @mov_number                 int
   DECLARE @consolidated               char(1)
   DECLARE @consolidated_order_count   int
   DECLARE @GI_fuelschg_pyt_itemcodes  varchar(250)
   DECLARE @GI_excluded_pyt_itemcodes  varchar(250)
   DECLARE @mov_amount_tot             FLOAT
   DECLARE @ord_amount_tot             FLOAT
   DECLARE @mov_amount_lgh             FLOAT
   DECLARE @ord_amount_lgh             FLOAT
   DECLARE @mov_amount_acc             FLOAT
   DECLARE @ord_amount_acc             FLOAT
   DECLARE @mov_amount_fsc             FLOAT
   DECLARE @ord_amount_fsc             FLOAT

   SELECT @debug = 'N'
   
   --Verify parameters
   IF IsNull(@ord_cost_type,'NONE') NOT IN ('LINEHAUL','ACCESSORIAL','FUELSURCHARGE','TOTAL')
      RETURN 0

   IF IsNull(@ord_hdrnumber,0) <= 0
      RETURN 0

   SELECT @mov_number = mov_number
     FROM orderheader
    WHERE ord_hdrnumber = @ord_hdrnumber
   IF IsNull(@mov_number,0) <= 0
      RETURN 0

   --Get GI settings
   SELECT @GI_fuelschg_pyt_itemcodes = gi_string1 FROM generalinfo WHERE gi_name = 'FSCPayTypes'
   SELECT @GI_fuelschg_pyt_itemcodes = IsNull(@GI_fuelschg_pyt_itemcodes,'') + ','
   SELECT @GI_excluded_pyt_itemcodes = gi_string1 FROM generalinfo WHERE gi_name = 'Scroll_Order_ExcludePayTypes'
   SELECT @GI_excluded_pyt_itemcodes = IsNull(@GI_excluded_pyt_itemcodes,'') + ','

   SELECT @ratio = 1

   --Check if Consolidated Order
   SELECT @consolidated = 'N'
   SELECT @consolidated_order_count = COUNT(DISTINCT ord_hdrnumber)
     FROM orderheader
    WHERE mov_number = @mov_number
   If @consolidated_order_count > 1
      SELECT @consolidated = 'Y'

   --Get cost from paydetails
   BEGIN
      SELECT @total_cost         = SUM(pd.pyd_amount)
           , @linehaul_cost      = SUM(CASE WHEN pt.pyt_basis <> 'ANC' THEN pd.pyd_amount ELSE 0 END)
           , @accessorial_cost   = SUM(CASE WHEN pt.pyt_basis = 'ANC' AND CharIndex((pd.pyt_itemcode + ','),@GI_fuelschg_pyt_itemcodes)<=0 THEN pd.pyd_amount ELSE 0 END)
           , @fuelsurcharge_cost = SUM(CASE WHEN pt.pyt_basis = 'ANC' AND CharIndex((pd.pyt_itemcode + ','),@GI_fuelschg_pyt_itemcodes)>0 THEN pd.pyd_amount ELSE 0 END)
        FROM paydetail pd
        JOIN paytype pt ON pd.pyt_itemcode = pt.pyt_itemcode
       WHERE pd.mov_number = @mov_number
         AND CharIndex((pd.pyt_itemcode + ','),@GI_excluded_pyt_itemcodes,0) <= 0
         
--      If @debug = 'Y'
--      Begin
--         Print '<<-- Pay Detail Cost -->>'
--         Print '         Total: ' + convert(varchar,@total_cost)
--         Print '      Linehaul: ' + convert(varchar,@linehaul_cost)
--         Print '   Accessorial: ' + convert(varchar,@accessorial_cost)
--         Print 'Fuel Surcharge: ' + convert(varchar,@fuelsurcharge_cost)
--         Print '-------------------------'
--      End
      
      IF @ord_cost_type = 'TOTAL'
         SELECT @cost = @total_cost
      ELSE IF @ord_cost_type = 'LINEHAUL'
         SELECT @cost = @linehaul_cost
      ELSE IF @ord_cost_type = 'ACCESSORIAL'
         SELECT @cost = @accessorial_cost
      ELSE IF @ord_cost_type = 'FUELSURCHARGE'
         SELECT @cost = @fuelsurcharge_cost
      ELSE
         SELECT @cost = 0
   END
   SELECT @cost = IsNull(@cost,0)
   
   --Allocate per the order/invoice amount if consolidated
   IF @consolidated = 'Y'
   BEGIN
      IF @ord_cost_type = 'TOTAL'
         BEGIN
            SELECT @mov_amount_tot = SUM(CASE WHEN i.ord_hdrnumber IS NULL THEN
                                              IsNull(o.ord_charge,0) +
                                              IsNull(dbo.fn_ord_accessorial_charge(o.ord_hdrnumber),0) +
                                              IsNull(dbo.fn_ord_fuel_charge(o.ord_hdrnumber),0)
                                         ELSE i.ivh_totalcharge
                                         END
                                        )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.mov_number = @mov_number
            SELECT @ord_amount_tot = (CASE WHEN i.ord_hdrnumber IS NULL THEN
                                           IsNull(o.ord_charge,0) +
                                           IsNull(dbo.fn_ord_accessorial_charge(o.ord_hdrnumber),0) +
                                           IsNull(dbo.fn_ord_fuel_charge(o.ord_hdrnumber),0)
                                      ELSE i.ivh_totalcharge
                                      END
                                     )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.ord_hdrnumber = @ord_hdrnumber
            If IsNull(@mov_amount_tot,0) <> 0 AND IsNull(@ord_amount_tot,0) <> 0
               SELECT @ratio = CONVERT(FLOAT,@ord_amount_tot / @mov_amount_tot)
            Else If IsNull(@ord_amount_tot,0) = 0
               SELECT @ratio = 0
            Else If IsNull(@mov_amount_tot,0) = 0
               SELECT @ratio = 1.00 / @consolidated_order_count


--            If @debug = 'Y'
--            Begin
--               Print ' '
--               Print ' Move Total: ' + convert(varchar,@mov_amount_tot)
--               Print 'Order Total: ' + convert(varchar,@ord_amount_tot)
--               Print '      Ratio: ' + convert(varchar,@ratio)
--            End
         END
      ELSE IF @ord_cost_type = 'LINEHAUL'
         BEGIN
            SELECT @mov_amount_lgh = SUM(CASE WHEN i.ord_hdrnumber IS NULL THEN
                                              o.ord_charge
                                         ELSE
                                              i.inv_linehaul_charge
                                         END
                                        )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_linehaul_charge(ivh_hdrnumber)) AS inv_linehaul_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.mov_number = @mov_number
            SELECT @ord_amount_lgh = (CASE WHEN i.ord_hdrnumber IS NULL THEN
                                           o.ord_charge
                                      ELSE
                                           i.inv_linehaul_charge
                                      END
                                     )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_linehaul_charge(ivh_hdrnumber)) AS inv_linehaul_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.ord_hdrnumber = @ord_hdrnumber
            If IsNull(@mov_amount_lgh,0) <> 0 AND IsNull(@ord_amount_lgh,0) <> 0
               SELECT @ratio = CONVERT(FLOAT,@ord_amount_lgh / @mov_amount_lgh)
            Else If IsNull(@ord_amount_lgh,0) = 0
               SELECT @ratio = 0
            Else If IsNull(@mov_amount_lgh,0) = 0
               SELECT @ratio = 1.00 / @consolidated_order_count
               
--            If @debug = 'Y'
--            Begin
--               Print ' '
--               Print ' Move Linehaul: ' + convert(varchar,@mov_amount_lgh)
--               Print 'Order Linehaul: ' + convert(varchar,@ord_amount_lgh)
--               Print '         Ratio: ' + convert(varchar,@ratio)
--            End
         END
      ELSE IF @ord_cost_type = 'ACCESSORIAL'
         BEGIN
            SELECT @mov_amount_acc = SUM(CASE WHEN i.ord_hdrnumber IS NULL THEN
                                              dbo.fn_ord_accessorial_charge(o.ord_hdrnumber)
                                         ELSE
                                              i.inv_accessorial_charge
                                         END
                                        )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_accessorial_charge(ivh_hdrnumber)) AS inv_accessorial_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.mov_number = @mov_number
            SELECT @ord_amount_acc = (CASE WHEN i.ord_hdrnumber IS NULL THEN
                                           dbo.fn_ord_accessorial_charge(o.ord_hdrnumber)
                                      ELSE
                                           i.inv_accessorial_charge
                                      END
                                     )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_accessorial_charge(ivh_hdrnumber)) AS inv_accessorial_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.ord_hdrnumber = @ord_hdrnumber
            If IsNull(@mov_amount_acc,0) <> 0 AND IsNull(@ord_amount_acc,0) <> 0
               SELECT @ratio = CONVERT(FLOAT,@ord_amount_acc / @mov_amount_acc)
            Else If IsNull(@ord_amount_acc,0) = 0
               SELECT @ratio = 0
            Else If IsNull(@mov_amount_acc,0) = 0
               SELECT @ratio = 1.00 / @consolidated_order_count
               
--            If @debug = 'Y'
--            Begin
--               Print ' '
--               Print ' Move Accessorial: ' + convert(varchar,@mov_amount_acc)
--               Print 'Order Accessorial: ' + convert(varchar,@ord_amount_acc)
--               Print '            Ratio: ' + convert(varchar,@ratio)
--            End
         END
      ELSE IF @ord_cost_type = 'FUELSURCHARGE'
         BEGIN
            SELECT @mov_amount_fsc = SUM(CASE WHEN i.ord_hdrnumber IS NULL THEN
                                              dbo.fn_ord_fuel_charge(o.ord_hdrnumber)
                                         ELSE
                                              i.inv_fuel_charge
                                         END
                                        )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_fuel_charge(ivh_hdrnumber)) AS inv_fuel_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.mov_number = @mov_number
            SELECT @ord_amount_fsc = (CASE WHEN i.ord_hdrnumber IS NULL THEN
                                           dbo.fn_ord_fuel_charge(o.ord_hdrnumber)
                                      ELSE
                                           i.inv_fuel_charge
                                      END
                                     )
              FROM orderheader o
            LEFT OUTER JOIN (SELECT ord_hdrnumber
                                  , SUM(ivh_totalcharge) AS ivh_totalcharge
                                  , SUM(dbo.fn_inv_fuel_charge(ivh_hdrnumber)) AS inv_fuel_charge
                               FROM invoiceheader
                              WHERE mov_number = @mov_number
                              GROUP BY ord_hdrnumber
                            ) i ON o.ord_hdrnumber = i.ord_hdrnumber
             WHERE o.ord_hdrnumber = @ord_hdrnumber
            If IsNull(@mov_amount_fsc,0) <> 0 AND IsNull(@ord_amount_fsc,0) <> 0
               SELECT @ratio = CONVERT(FLOAT,@ord_amount_fsc / @mov_amount_fsc)
            Else If IsNull(@ord_amount_fsc,0) = 0
               SELECT @ratio = 0
            Else If IsNull(@mov_amount_fsc,0) = 0
               SELECT @ratio = 1.00 / @consolidated_order_count
            
--            If @debug = 'Y'
--            Begin
--               Print ' '
--               Print ' Move Fuel Surcharge: ' + convert(varchar,@mov_amount_fsc)
--               Print 'Order Fuel Surcharge: ' + convert(varchar,@ord_amount_fsc)
--               Print '               Ratio: ' + convert(varchar,@ratio)
--            End
         END

      IF @ratio > 1
         SELECT @ratio = 1

      SELECT @cost = @cost * @ratio
   END

   RETURN @cost

END
GO
GRANT EXECUTE ON  [dbo].[fn_ord_paydetail_cost] TO [public]
GO
