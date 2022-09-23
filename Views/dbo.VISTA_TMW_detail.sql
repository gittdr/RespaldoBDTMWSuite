SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE                                    VIEW     [dbo].[VISTA_TMW_detail] 
/*
select * from VISTA_TMW_detail  where ivh_invoicenumber =  '72049''vTTSTMW_detail   where ivh_invoicenumber  ='TMX1591'
select * from  invoicedetail where ivh_hdrnumber =  '72049'

*/ 
    AS   
  SELECT 
	ivh_invoicenumber,
	ivd_quantity = abs(ivd_quantity),
	ivd_unit,
	descripcion = (select  	convert(char, cht_description)
			from chargetype A
			where A.cht_itemcode = invoicedetail.cht_itemcode),
--	ivd_rate,	
	ivd_rate = (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then 0
			Else ivd_rate
			end) ,

--	ivd_charge =  abs(ivd_charge) ,
	ivd_charge = (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then 0
			Else   ivd_charge  
			end) ,
	tasa_iva = (select isnull(ivd_rate,0)  from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
		     A.ivd_charge  > 0 and
		     A.cht_itemcode = 'GST'),
	tipo_imp = (select  isnull(ivd_description,'')   from  invoicedetail  A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
		     A.cht_itemcode = 'GST'),
	 
	iva_monto =  (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then ivd_charge
			Else 
			isnull( (ivd_charge *  (select  
			case when cht_taxtable1 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode = invoicedetail.cht_itemcode)  * 
			(select isnull(ivd_rate,0)  from  invoicedetail A
			where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
			--A.ivd_taxable1   = invoicedetail.ivd_taxable1 and 
			A.ivd_charge  <> 0 and
		     A.cht_itemcode = 'GST') )  / 100 ,0)
			end) ,
	importe_iva_inc = ivd_charge  +   (select  isnull(ivd_charge ,0)   from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
		     A.cht_itemcode = 'GST' ) ,
	tasa_ret = (select  abs(isnull(ivd_rate,0))   from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
		     A.ivd_charge <> 0  and
		    -- A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 
		     A.cht_itemcode = 'PST'),
	Retencion = (select   isnull(ivd_description,'')    from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and	
			--A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 		
		     A.cht_itemcode = 'PST'),
/*	ret_monto = isnull( abs( (ivd_charge * (select  
			case when cht_taxtable1 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode = invoicedetail.cht_itemcode)  * (select isnull(ivd_rate,0)   
			from    invoicedetail A
			where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
			A.ivd_charge <> 0  and
			A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 
		        A.cht_itemcode = 'PST'))/ 100), 0),*/
	ret_monto =    isnull( abs ((select ivd_charge   /*concepto con retencion*/
				from    invoicedetail B
			where  B.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and 
				B.ivd_number  = invoicedetail.ivd_number  
				/*B.ivd_taxable2 = 'Y'*/ )* 
			(select   /*si el concepto lleva retencion*/
			case when cht_taxtable2 = 'Y'  then 1
			Else 0 
			end
		    from chargetype A 
			where A.cht_itemcode = invoicedetail.cht_itemcode)  * 
			(select isnull(ivd_rate,0)   /*Tasa*/
			from    invoicedetail A
			where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
			A.ivd_charge <> 0  and
		        A.cht_itemcode = 'PST'))/ 100   ,0 ) ,

	importe_ret_inc = abs(ivd_charge  +  ( select  isnull(ivd_charge ,0)   from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
		     A.cht_itemcode = 'GST') + 
		( select  isnull(ivd_charge ,0)   from  invoicedetail A
		where  A.ivh_hdrnumber  = invoicedetail.ivh_hdrnumber and
			A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 
		     A.cht_itemcode = 'PST')) 
  FROM invoicedetail,
	invoiceheader
where
invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber   and 
invoicedetail.cht_itemcode NOT IN ( 'PST','GST' ) and
ivd_charge <> 0  and
Convert(varchar,invoiceheader.ivh_printdate,112) >= dateadd(day,-2,getdate()) and
invoiceheader.ivh_invoicestatus = 'PRN'  and
ivh_invoicenumber   not like 'T%'   and
ivh_mbnumber = 0
--group by ivh_invoicenumber,ivd_unit 
Union   /*Master bill */
  SELECT 
	ivh_invoicenumber = max(F.ivh_invoicenumber),
	ivd_quantity =  sum(ivd_quantity) ,
	max(ivd_unit), 
	descripcion = (select   convert(char, cht_description) 
			from chargetype A
			where A.cht_itemcode = invoicedetail.cht_itemcode ),
	ivd_rate = (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then 0
			Else  max(ivd_rate) 
			end) ,

	ivd_charge = (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then 0
			Else sum( abs( ivd_charge) )
			end) ,	  		  
	tasa_iva = (select isnull(max(ivd_rate),0)  from  invoicedetail A
		where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			abs(ivd_charge)  > 0 and
		     A.cht_itemcode = 'GST' ), 
	tipo_imp = (select  isnull(max(ivd_description),'')   from  invoicedetail  A
		where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			abs(ivd_charge)  > 0 and
		     A.cht_itemcode = 'GST'),
 
	/*iva_monto =  isnull( abs(sum(ivd_charge) * (select  
			case when cht_taxtable1 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode =  invoicedetail.cht_itemcode )  *
			 (select isnull(max(ivd_rate),0)  from  invoicedetail A
			where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			abs(A.ivd_charge)  <> 0 and
			--A.ivd_taxable1   = invoicedetail.ivd_taxable1 and 
		     A.cht_itemcode = 'GST')  / 100) ,0) ,*/
	iva_monto =  (select  
			case when invoicedetail.cht_itemcode = 'IVACOM'  then isnull( abs(sum(ivd_charge)),0)
			Else 
			isnull( abs(sum(ivd_charge) * (select  
			case when cht_taxtable1 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode = invoicedetail.cht_itemcode)  * 
			 (select isnull(max(ivd_rate),0)  from  invoicedetail A
			where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			(A.ivd_charge)  <> 0 and
		     A.cht_itemcode = 'GST'))  / 100  ,0) 
			end) ,

	importe_iva_inc = sum(ivd_charge)  +   (select  isnull(sum(ivd_charge),0)   from  invoicedetail A
		where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
		     A.cht_itemcode = 'GST' ) ,
	tasa_ret = (select  abs(isnull(sum(ivd_rate),0))   from  invoicedetail A
		where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
		     A.ivd_charge <> 0  and
		     A.cht_itemcode = 'PST'),
	Retencion = (select   isnull(max(ivd_description),'')    from  invoicedetail A
		where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
		     A.cht_itemcode = 'PST'),
 

	/*ret_monto = isnull( abs( (sum(ivd_charge) * (select  
			case when cht_taxtable2 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode =   invoicedetail.cht_itemcode )  * (select isnull(max(ivd_rate),0)  from  invoicedetail A
			where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			-- en mb si lleva la liga 	
			A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 
		        A.cht_itemcode = 'PST' ))/ 100),0), */
	ret_monto = isnull( ABS( sum(ivd_charge) * (select  
			case when cht_taxtable2 = 'Y'  then 1
			Else 0 
			end
			from chargetype A 
			where A.cht_itemcode =   invoicedetail.cht_itemcode )  * 

			(select isnull(MAX(ivd_rate),0)   /*Tasa*/
			from    invoicedetail A
			where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
			A.ivd_charge <> 0  and
		        A.cht_itemcode = 'PST')/ 100 )  ,0 ) ,
	importe_ret_inc = sum(ivd_charge)  +  ( select  isnull(sum(ivd_charge) ,0)   from  invoicedetail A
	where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
		ivd_charge  > 0 and
	     A.cht_itemcode = 'GST') + 
	( select  isnull(sum(ivd_charge),0)   from  invoicedetail A
	where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
		/*d_charge  > 0 and*/
	     A.cht_itemcode = 'PST')  	
  FROM invoicedetail,
       invoiceheader,
       vTTSTMW_FirstREg  F
where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber   and
invoicedetail.cht_itemcode NOT IN ( 'PST','GST' ) and
ivd_charge <> 0  and
Convert(varchar,invoiceheader.ivh_printdate,112) >='20090701' AND
invoiceheader.ivh_mbnumber = F.ivh_mbnumber and
F.ivh_creditmemo = invoiceheader.ivh_creditmemo 
group by F.ivh_invoicenumber, F.ivh_hdrnumber,  invoicedetail.cht_itemcode,
F.ivh_creditmemo

--, invoicedetail.ivd_taxable2
 






































































GO
