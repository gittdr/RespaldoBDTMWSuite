SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CaculaCasetas] (@order int) 
AS

declare @mtabla int
declare @monto float
declare @leg int
declare @ivh_hdrnumber int
declare @ivd_billto varchar(8)
declare @ivatoll float
declare @tarfija int


if @order <> 0  --inicia validacion que la orden no sea 0

 begin
 
-----------OBTENEMOS LA TABLA DE KMS QUE APLICA PARA EL CLIENTE DE LA ORDEN-------------------------------------------------------------------------------------------
set @ivd_billto = (select ord_billto from orderheader with (nolock) where orderheader.ord_hdrnumber = @order)
set @mtabla = (select cmp_mileagetable  from company with (nolock) where cmp_id =  @ivd_billto )
set @tarfija = isnull((select ord_rate_type  from orderheader with (nolock) where orderheader.ord_hdrnumber = @order),0)


--agregamos validacion para que si la tarifa es fija no calcule casetas ya que deben de venir desde la orden maestra como accesoriales
if (@tarfija != 1)
BEGIN

----------CALCULAMOS EL MONTO DE LAS CASETAS PARA CADA UNO DE LOS STOPS Y LO INSERTAMOS EN STP_ORD_TOLL_COST, ES A NIVEL DE CADA STOP------------------------------------
/* jr1
update stops
 set stp_ord_toll_cost = 

 (case when stp_sequence <> 1
 then  
 (select [dbo].[fnc_TollsBetweenCompany] 
       (
         (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)),
         stops.cmp_id,
         @mtabla
        )
 )
 else null end 
)

where stops.ord_hdrnumber = @order
jr1*/


---------INSERTAMOS EN EL ORDERHEADER LA SUMA DEL ORD TOLL COST DE CADA STOP-------------------------------------------------------------------------------------------




--jr3set @leg  = (select lgh_number from legheader with (nolock) where legheader.ord_hdrnumber = @order)
--jr4set @monto  =  (select sum(stp_ord_toll_cost)  from stops  with (nolock) where stops.ord_hdrnumber = @order)


update orderheader
     set ord_toll_cost_update_date=getdate(),
     ord_toll_cost = @monto  
     where orderheader.ord_hdrnumber = @order

END



/*
------------CASO 1  EN EL CUAL EXISTE EN INVOICE DETAIL EL RENGLON DE TOLL CON VALOR 0 Y EXISTE INVOICEHEADER  MODIFICAMOS EL REGISTRO CON NUEVOS VALORES---------------

if (select count(ivd_number)  from invoicedetail with (nolock) where cht_itemcode = 'Toll' and ivd_charge = 0 and  invoicedetail.ord_hdrnumber = @order) > 0
and (select ord_invoicestatus from orderheader with (nolock) where orderheader.ord_hdrnumber = @order)  in ('PPD')
 and (  select cmp_inv_toll_detail from company with (nolock) where cmp_id = @ivd_billto ) = 'Y' 

 BEGIN
   
   set @ivatoll =  ((@monto)* (select (tax_rate/100) from taxRate where   tax_type = '1' and tax_state  =  (select ord_originstate  from orderheader where orderheader.ord_hdrNumber = @order)))

Insert into  Pruebasem (TEXTO) Values ( 'Entro Caso 1')
         update invoicedetail
                    set ivd_charge = (@monto), ivd_rate  = (@monto)
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('TOLL')

        update invoicedetail
                    set ivd_charge = (ivd_charge + @ivatoll) 
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('GST','IVA')
           
        update invoiceheader set ivh_totalcharge = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order)
        where invoiceheader.ord_hdrnumber = @order

        update invoiceheader set ivh_taxamount1 = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order and cht_itemcode in ('GST','IVA'))
        where invoiceheader.ord_hdrnumber = @order
     
 END

------------CASO 2 EN EL CUAL EXISTE EN INVOICE DETAIL EL RENGLON DE TOLL CON VALOR mayor a 0 y Existe InvoiceHeader MODIFICAMOS EL REGISTRO CON NUEVOS VALORES---------------

if (select count(ivd_number)  from invoicedetail with (nolock) where cht_itemcode = 'Toll' and ivd_charge > 0 and  invoicedetail.ord_hdrnumber = @order) > 0
and (select ord_invoicestatus from orderheader with (nolock) where orderheader.ord_hdrnumber = @order)  in ('PPD')
 and (  select cmp_inv_toll_detail from company with (nolock) where cmp_id = @ivd_billto ) = 'Y' 

 BEGIN

declare @ivatollAnt float
   
   set @ivatoll =  ((@monto)* (select (tax_rate/100) from taxRate where   tax_type = '1' and tax_state  =  (select ord_originstate  from orderheader where orderheader.ord_hdrNumber = @order)))
   set @ivatollAnt = ((Select ivd_charge From Invoicedetail where invoicedetail.ord_hdrnumber = @order and cht_itemcode in ('TOLL'))* ((select (tax_rate/100) from taxRate where   tax_type = '1' and tax_state  =  (select ord_originstate  from orderheader where orderheader.ord_hdrNumber = @order))))

Insert into  Pruebasem (TEXTO) Values ( 'Entro Caso 2')
         update invoicedetail
                    set ivd_charge = (@monto), ivd_rate  = (@monto)
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('TOLL')

        update invoicedetail
                    set ivd_charge = (ivd_charge - @ivatollAnt + @ivatoll) 
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('GST','IVA')
           
        update invoiceheader set ivh_totalcharge = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order)
        where invoiceheader.ord_hdrnumber = @order

        update invoiceheader set ivh_taxamount1 = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order and cht_itemcode in ('GST','IVA'))
        where invoiceheader.ord_hdrnumber = @order
     
 END


------------CASO 3 EN EL CUAL NO EXISTE EN INVOICE DETAIL  Y NO  EXISTE AUN EL INOVICEHEADER EL RENGLON DE TOLL LO INGRESAMOS Y SUMAMOS SU IVA AL IVA TOTAL.------------------------------------------------

If (select count(ivd_number)  from invoicedetail with (nolock) where cht_itemcode = 'Toll' and invoicedetail.ord_hdrnumber = @order) = 0
and (select ord_invoicestatus from orderheader with (nolock)  where orderheader.ord_hdrnumber = @order)  in ('AVL')
         and (  select cmp_inv_toll_detail from company with (nolock) where cmp_id = @ivd_billto ) = 'Y' 
 BEGIN
   
   declare @i_totalmsgs4p int
   declare @ivd_glnump char(32)
   declare @ivd_sequencep int
    
 Insert into  Pruebasem (TEXTO) Values ( 'Entro Caso 3')
    execute @i_totalmsgs4p = tmwSuite..getsystemnumber N'INVDET',NULL
    set @ivd_glnump = (select cht_glnum from chargetype with (nolock) where cht_itemcode = 'TOLL')
    set @ivd_sequencep = (isnull((select max(ivd_sequence)from invoicedetail with (nolock)  where invoicedetail.ord_hdrnumber = @order),0) + 1)
    set @ivatoll =  ((@monto)* (select (tax_rate/100) from taxRate where   tax_type = '1' and tax_state  =  (select ord_originstate  from orderheader where orderheader.ord_hdrNumber = @order)))
    --recordar el taxtype 4 o 1 el que se quedo es el que ponemos.


    	INSERT INTO invoicedetail ( ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity, ivd_rate,
                                    ivd_charge , ivd_taxable1, ivd_taxable2, ivd_taxable3, ivd_taxable4, ivd_unit, cur_code, 
			                        ivd_glnum, ord_hdrnumber, ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr, 
			                        ivd_sequence, cmp_id, ivd_distance, ivd_distunit, ivd_wgt, ivd_wgtunit, ivd_count, 
		                            ivd_reftype, ivd_volume, ivd_volunit, ivd_countunit, cht_itemcode, cmd_code, ivd_sign, 
                                    cht_basisunit, ivd_fromord, cht_rollintolh, ivd_quantity_type, cht_class, ivd_charge_type, 
			                        ivd_rate_type, cht_lh_min, cht_lh_rev, cht_lh_stl, cht_lh_rpt, 
			                        ivd_ordered_volume, ivd_ordered_loadingmeters, ivd_ordered_count, ivd_ordered_weight,
                                    ivd_loadingmeters, ivd_revtype1, ivd_artaxauth, fgt_supplier, ivd_loaded_distance, ivd_empty_distance,
                                    ivd_maskfromrating, ivd_car_key, ivd_showas_cmpid ) 
			
                            VALUES ( 0, @i_totalmsgs4p, 'UNKNOWN', 1.000000, @monto,
                                     @monto, 'Y', 'N', 'N', 'Y','FLT', 'US',
                                     @ivd_glnump, @order, 'LI', 'FLT', @ivd_billto, 0, 0, 
			                         @ivd_sequencep, 'UNKNOWN', 0, null, null, null, null, 
			                         'UNK', null, null, null, 'TOLL', 'UNKNOWN', 1, 
                                     'FLT', 'Y', 0, 0, 'UNK', 0,0, 'N', 'N', 'N', 
                                     'N',0, 0, 0, 0, 
			                         0,'BAJ', '', 'UNKNOWN', 0, 0, 
                                     'N', 0, 'UNKNOWN' )


         update invoicedetail
                    set ivd_charge = (ivd_charge + @ivatoll) 
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('GST','IVA')

  
  END


------------CASO 4 EN EL CUAL NO EXISTE EN INVOICE DETAIL  Y YA EXISTE EL INOVICEHEADER EL RENGLON DE TOLL LO INGRESAMOS Y SUMAMOS SU IVA AL IVA TOTAL.------------------------------------------------


If (select count(ivd_number)  from invoicedetail with (nolock) where cht_itemcode = 'Toll' and invoicedetail.ord_hdrnumber = @order) = 0
and (select ord_invoicestatus from orderheader with (nolock)  where orderheader.ord_hdrnumber = @order)  in ('PPD')
         and (  select cmp_inv_toll_detail from company with (nolock) where cmp_id = @ivd_billto ) = 'Y' 
 BEGIN
   
   declare @i_totalmsgs4 int
   declare @ivd_glnum char(32)
   declare @ivd_sequence int

    Insert into  Pruebasem (TEXTO) Values ( 'Entro Caso 4')

    set @ivh_hdrnumber = isnull((select ivh_hdrnumber from invoiceheader with (nolock) where invoiceheader.ord_hdrnumber = @order),0)
    execute @i_totalmsgs4 = tmwSuite..getsystemnumber N'INVDET',NULL
    set @ivd_glnum = (select cht_glnum from chargetype with (nolock) where cht_itemcode = 'TOLL')
    set @ivd_sequence = (isnull((select max(ivd_sequence)from invoicedetail with (nolock)  where invoicedetail.ord_hdrnumber = @order),0) + 1)
    set @ivatoll =  ((@monto)* (select (tax_rate/100) from taxRate where   tax_type = '1' and tax_state  =  (select ord_originstate  from orderheader where orderheader.ord_hdrNumber = @order)))
    

    	INSERT INTO invoicedetail ( ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity, ivd_rate,
                                    ivd_charge , ivd_taxable1, ivd_taxable2, ivd_taxable3, ivd_taxable4, ivd_unit, cur_code, 
			                        ivd_glnum, ord_hdrnumber, ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr, 
			                        ivd_sequence, cmp_id, ivd_distance, ivd_distunit, ivd_wgt, ivd_wgtunit, ivd_count, 
		                            ivd_reftype, ivd_volume, ivd_volunit, ivd_countunit, cht_itemcode, cmd_code, ivd_sign, 
                                    cht_basisunit, ivd_fromord, cht_rollintolh, ivd_quantity_type, cht_class, ivd_charge_type, 
			                        ivd_rate_type, cht_lh_min, cht_lh_rev, cht_lh_stl, cht_lh_rpt, 
			                        ivd_ordered_volume, ivd_ordered_loadingmeters, ivd_ordered_count, ivd_ordered_weight,
                                    ivd_loadingmeters, ivd_revtype1, ivd_artaxauth, fgt_supplier, ivd_loaded_distance, ivd_empty_distance,
                                    ivd_maskfromrating, ivd_car_key, ivd_showas_cmpid ) 
			
                            VALUES ( @ivh_hdrnumber, @i_totalmsgs4, 'UNKNOWN', 1.000000, @monto,
                                     @monto, 'Y', 'N', 'N', 'Y','FLT', 'US',
                                     @ivd_glnum, @order, 'LI', 'FLT', @ivd_billto, 0, 0, 
			                         @ivd_sequence, 'UNKNOWN', 0, null, null, null, null, 
			                         'UNK', null, null, null, 'TOLL', 'UNKNOWN', 1, 
                                     'FLT', 'Y', 0, 0, 'UNK', 0,0, 'N', 'N', 'N', 
                                     'N',0, 0, 0, 0, 
			                         0,'BAJ', '', 'UNKNOWN', 0, 0, 
                                     'N', 0, 'UNKNOWN' )


         update invoicedetail
                    set ivd_charge = (ivd_charge + @ivatoll) 
                    where  invoicedetail.ord_hdrnumber = @order  and cht_itemcode in ('GST','IVA')

        update invoiceheader set ivh_totalcharge = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order)
        where invoiceheader.ord_hdrnumber = @order

        update invoiceheader set ivh_taxamount1 = ( select sum(ivd_charge) from invoicedetail where invoicedetail.ord_hdrNumber = @order and cht_itemcode in ('GST','IVA'))
        where invoiceheader.ord_hdrnumber = @order
      

      

  END
*/
end --acaba validacion de que no sea 0 el numero de la orden.

	SET NOCOUNT OFF




GO
