SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PurgeOrderLTL]
 @OrdHrdNumber int
AS
BEGIN
 
begin transaction

delete from order_services where ord_hdrnumber = @OrdHrdNumber

delete from orderheader where ord_hdrnumber = @OrdHrdNumber

delete From orderheaderltlinfo where ord_hdrnumber = @OrdHrdNumber

delete from invoiceheader where ord_hdrnumber = @OrdHrdNumber

delete from invoicedetail where ord_hdrnumber = @OrdHrdNumber

delete from referencenumber where ref_table = 'orderheader' and ord_hdrnumber = @OrdHrdNumber

delete from freightdetail_history where fgt_number in (select fgt_number from freightdetail where order_hdrnumber = @OrdHrdNumber)

delete from freightdetail where order_hdrnumber = @OrdHrdNumber

delete from checkcall where ckc_asgntype='ORDHDR' and cast(ckc_asgnid as INTEGER) = @OrdHrdNumber

delete from manifestdetail where ord_hdrnumber = @OrdHrdNumber 

delete from TrailerSpottingDetail where ord_hdrnumber = @OrdHrdNumber

delete from cod where ord_hdrnumber = @OrdHrdNumber  

delete from ltlosd_detail where osd_id in (select id from ltlosd where ord_hdrnumber = @OrdHrdNumber)

delete from ltlosd where ord_hdrnumber = @OrdHrdNumber

delete from order_split where split_order = @OrdHrdNumber
 
delete from itemdetail where order_hdrnumber = @OrdHrdNumber

delete from ordercarrierdetails_gl where oc_id in (select id from ordercarrier where ord_hdrnumber = @OrdHrdNumber)

delete from ordercarrierdetails where ordercarrier_id in (select id from ordercarrier where ord_hdrnumber = @OrdHrdNumber) 

delete from ordercarrier where ord_hdrnumber = @OrdHrdNumber

delete from terminaltravelservice where ord_hdrnumber = @OrdHrdNumber

delete from terminaltravellog where ord_hdrnumber = @OrdHrdNumber

Delete from paperwork where ord_hdrnumber = @OrdHrdNumber

delete from ltl_order_notify where ord_hdrnumber = @OrdHrdNumber

delete from loadrequirement where ord_hdrnumber = @OrdHrdNumber

delete from d83_calc_log where ord_hdrnumber = @OrdHrdNumber

commit transaction

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[PurgeOrderLTL] TO [public]
GO
