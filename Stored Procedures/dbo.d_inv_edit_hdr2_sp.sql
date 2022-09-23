SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_inv_edit_hdr2_sp    Script Date: 6/1/99 11:54:48 AM ******/
create proc [dbo].[d_inv_edit_hdr2_sp] ( @stringparm             varchar(12),
				@numberparm             int,
				@retrieve_by   		varchar(8))

as
/* pts4314 change invoicing to show and update orderheader ref numbers 10/7/98 */
declare @calcmaxstat		varchar(6), 
	@dummydate              datetime, 
	@remarks                varchar(254), 
	@fill6                  varchar(6), 
	@fill3                  varchar(3), 
	@fill13                 varchar(13),    
	@fill8                  varchar(8),     
	@fill20                 varchar(20), 
	@edi                    varchar(30), 
	@invnum                 varchar(12), 
	@comments_count         int,
	@notes_count            int,
	@loadreq_count          int,
	@ref_count              int,
	@pwork_req_count        int,
	@pwork_rec_count        int,
	@vchar6			varchar(6)

create table #temp
(ivh_invoicenumber char(12) null, 
ivh_billto char(8) null,
ivh_terms char(3) null, 
ivh_totalcharge money null,    
ivh_shipper char(8) null, 
ivh_consignee char(8) null, 
ivh_originpoint char(8) null,    
ivh_destpoint char(8) null, 
ivh_invoicestatus char(6) null, 
ivh_origincity int null,     
ivh_destcity int null, 
ivh_originstate char(2) null, 
ivh_deststate char(2) null,      
ivh_originregion1 char(6) null, 
ivh_destregion1 char(6) null, 
ivh_supplier char(8) null,       
ivh_shipdate datetime null, 
ivh_deliverydate datetime null, 
ivh_revtype1 char(6) null,       
ivh_revtype2 char(6) null, 
ivh_revtype3 char(6) null, 
ivh_revtype4 char(6) null, 
ivh_totalweight int null, 
ivh_totalpieces int null, 
ivh_totalmiles int null,     
ivh_currency char(6) null,
ivh_currencydate datetime null, 
ivh_totalvolume int null,    
ivh_taxamount1 money null, 
ivh_taxamount2 money null,       
ivh_taxamount3 money null, 
ivh_taxamount4 money null,
ivh_transtype char(6) null,
ivh_creditmemo char(1) null,     
ivh_applyto char(12) null, 
ivh_printdate datetime null, 
ivh_billdate datetime null, 
ivh_lastprintdate datetime null,   
ivh_hdrnumber int null, 
ord_hdrnumber int null, 
ivh_originregion2 char(6) null,  
ivh_originregion3 char(6) null, 
ivh_originregion4 char(6) null, 
ivh_destregion2 char(6) null,    
ivh_destregion3 char(6) null, 
ivh_destregion4 char(6) null, 
ivh_mbnumber int null, 
ivh_remark char(254) null, 
ivh_driver char(8) null, 
ivh_driver2 char(8) null, 
ivh_tractor char(8) null,
ivh_trailer char(13) null, 
mov_number int null, 
ivh_edi_flag char(30) null,
revtype1 char(8) null, 
revtype2 char(8) null, 
revtype3 char(8) null, 
revtype4 char(8) null, 
ivh_freight_miles int null, 
ivh_priority char(6),
ivh_low_temp int null,
ivh_high_temp int null,
events_count int null,
comments_count int null,
notes_count int null,
loadreq_count int null,
ref_count int null,
paperwork_required int null,
paperwork_received int null,
ivh_order_by char(8) null,
tar_tarriffnumber char(12) null, 
tar_number int null, 
ivh_user_id1 char(20) null, 
ivh_user_id2 char(20) null, 
ivh_ref_number char(20) null,
invoiceheader_ivh_bookyear int null,
invoiceheader_ivh_bookmonth int null,
tar_tariffitem char(12) null,
ivh_mbstatus char(6) null,
calc_maxstatus char(6) null,
ord_number char(12) null,
ivh_quantity int null,
ivh_rate money  null, -- was decimal (4) jude 4/29/97 
ivh_charge money null,-- was decimal (4) jude 4/29/97 
cht_itemcode char(6) null,
ivh_splitbill_flag char(1) null,
dummy_ordstatus char(6) null,
ivh_company char(8) null,
ivh_carrier char(8) null,
ivh_archarge money null,-- was decimal (4) jude 4/29/97 
ivh_arcurrency char(6) null,
ivh_loadtime int null,
ivh_unloadtime int null,
ivh_drivetime int null,
ivh_totaltime int null,
ivh_rateby char(1) null,
ivh_unit char(6) null,
ivh_rateunit char(6) null)
			
IF @retrieve_by = 'ORDNUM'
	BEGIN
	SELECT @numberparm = ord_hdrnumber 
	FROM orderheader
	WHERE ord_number = @stringparm

	SELECT @retrieve_by = 'ORDHDR'
	END

if (@retrieve_by = "ORDHDR") 
	BEGIN
	/****************************************************
	*       RETRIEVE BY ORDER NUMBER 
	*       THERE MAY BE MORE THAN ONE INVOICE PER ORDER
	*       THUS A TEMP TABLE IS REQUIRED
	*****************************************************/
	if (select count(*) FROM invoiceheader 
		WHERE invoiceheader.ord_hdrnumber = @numberparm) > 0
		BEGIN
		insert into #temp
		select i.ivh_invoicenumber, 
			i.ivh_billto, 
			i.ivh_terms, 
			i.ivh_totalcharge, 
			i.ivh_shipper, 
			i.ivh_consignee,    
			i.ivh_originpoint, 
			i.ivh_destpoint, 
			i.ivh_invoicestatus,        
			i.ivh_origincity, 
			i.ivh_destcity, 
			i.ivh_originstate,  
			i.ivh_deststate, 
			i.ivh_originregion1, 
			i.ivh_destregion1,  
			i.ivh_supplier, 
			i.ivh_shipdate, 
			i.ivh_deliverydate, 
			i.ivh_revtype1, 
			i.ivh_revtype2, 
			i.ivh_revtype3, 
			i.ivh_revtype4, 
			i.ivh_totalweight, 
			i.ivh_totalpieces,  
			i.ivh_totalmiles, 
			i.ivh_currency, 
			i.ivh_currencydate,         
			i.ivh_totalvolume, 
			i.ivh_taxamount1, 
			i.ivh_taxamount2,   
			i.ivh_taxamount3, 
			i.ivh_taxamount4, 
			i.ivh_transtype,    
			i.ivh_creditmemo, 
			i.ivh_applyto,      
			i.ivh_printdate, 
			i.ivh_billdate, 
			i.ivh_lastprintdate,        
			i.ivh_hdrnumber, 
			i.ord_hdrnumber, 
			i.ivh_originregion2,        
			i.ivh_originregion3, 
			i.ivh_originregion4, 
			i.ivh_destregion2,  
			i.ivh_destregion3, 
			i.ivh_destregion4, 
			i.ivh_mbnumber, 
			i.ivh_remark,
			i.ivh_driver,       
			i.ivh_driver2, 
			i.ivh_tractor, 
			i.ivh_trailer,      

			i.mov_number ,
			i.ivh_edi_flag, 
			"RevType1", 
			"RevType2", 
			"RevType3",    
			"RevType4", 
			i.ivh_freight_miles ,
			i.ivh_priority ,    
			i.ivh_low_temp, 
			i.ivh_high_temp , 
			0,
			0,
			0,
			0,
			0,
			0,
			0,

			i.ivh_order_by, 
			i.tar_tarriffnumber,        
			i.tar_number , 
			i.ivh_user_id1, 
			i.ivh_user_id2 ,    
			i.ivh_ref_number, 
			i.ivh_bookyear, 
			i.ivh_bookmonth, 
			i.tar_tariffitem, 
			i.ivh_mbstatus, 
			@calcmaxstat, 

			i.ord_number, 
			i.ivh_quantity, 
			i.ivh_rate, 
			i.ivh_charge, 
			i.cht_itemcode, 
			i.ivh_splitbill_flag, 
			@calcmaxstat,
			i.ivh_company,
			i.ivh_carrier,
			i.ivh_archarge,
			i.ivh_arcurrency,
			i.ivh_loadtime,
			i.ivh_unloadtime,
			i.ivh_drivetime,
			i.ivh_totaltime,
			i.ivh_rateby,
			@vchar6,
			@vchar6
		FROM invoiceheader i
		WHERE i.ord_hdrnumber = @numberparm
			   
			if (select count(*) from #temp) > 0
				BEGIN
				update #temp
				set comments_count = (select count(*) 
					FROM orderheader o, #temp
					WHERE o.ord_hdrnumber = #temp.ord_hdrnumber
					and o.ord_remark > "")

				update #temp
				set notes_count= (select count(*) 
					from notes n, #temp
					where n.ntb_table = 'orderheader'
					and n.nre_tablekey = convert(varchar(18), #temp.ord_hdrnumber))

				update #temp
				set loadreq_count = (select count(*) 
					from loadrequirement l, #temp
					where l.ord_hdrnumber = #temp.ord_hdrnumber)

				update #temp
				set  ref_count = ( select count(*)
					from referencenumber r, #temp
					where r.Ref_table = 'orderheader'
					and r.ref_tablekey = #temp.ord_hdrnumber)

/* pts4314 edit order refs in invoicing */
				update #temp 
				set ivh_ref_number = (select ord_refnum 
					from orderheader o, #temp
					where o.ord_hdrnumber = #temp.ord_hdrnumber)
	

				update #temp
				set paperwork_required = (select count(*)
					from labelfile
					where labelfile.labeldefinition = 'PaperWork')

				update #temp
				set paperwork_received = (select count(paperwork.pw_received) 
					from paperwork, #temp
					where paperwork.ord_hdrnumber = #temp.ord_hdrnumber
					and paperwork.pw_received = 'Y')
 
				END
		END
	ELSE
	 /*****************************************************************
	 *  IF NO INVOICE EXISTS CREATE NEW INVOICE FROM ORDER INFORMATION
	 ******************************************************************/
		BEGIN
		if (select count(*) from orderheader
			where orderheader.ord_number = @stringparm
			and ord_invoicestatus = 'AVL') > 0 			
			BEGIN

			select @comments_count= (select count(*) 
				from orderheader o
				where o.ord_number = @stringparm
				and o.ord_remark > ""
				group by o.ord_number) 
		
			select @notes_count= (select count(*) 
				from notes n, orderheader o
				where n.ntb_table = 'orderheader'
				and o.ord_number = @stringparm
				and n.nre_tablekey  = convert(varchar(18), o.ord_hdrnumber)
				group by o.ord_number)		 
		
			select @loadreq_count= (select count(*) 
				from loadrequirement l, orderheader o
				where o.ord_number = @stringparm
				and l.ord_hdrnumber = o.ord_hdrnumber
				group by o.ord_number)  

	--4314	 	SELECT @ref_count = 0  
			SELECT  @ref_count = ( select count(*)
			from referencenumber r,orderheader o
			where r.Ref_table = 'orderheader'
			and o.ord_number = @stringparm
			and r.ref_tablekey = o.ord_hdrnumber) 	 
		
			SELECT @pwork_req_count = (select count(*) 
				from labelfile

				where labelfile.labeldefinition = 'PaperWork')		 

			SELECT @pwork_rec_count = (select count(paperwork.pw_received) 
				from paperwork, orderheader o
				where o.ord_number = @stringparm
				and paperwork.ord_hdrnumber = o.ord_hdrnumber
				and paperwork.pw_received = 'Y')		
		
		/* ALWAYS PERFORM SELECT REGARDLESS DW REQUIRES A RETURN SET 
		   THIS WILL CREATE AN INVOICE FROM AN ORDER */        
		
		insert into #temp
		select @invnum invoice_number, 
			o.ord_billto,
			o.ord_terms terms, 
			o.ord_totalcharge,    
			o.ord_shipper, 
			o.ord_consignee, 
			o.ord_originpoint,    
			o.ord_destpoint, 
			o.ord_invoicestatus, 
			o.ord_origincity,     
			o.ord_destcity, 
			o.ord_originstate, 
			o.ord_deststate,      
			o.ord_originregion1, 
			o.ord_destregion1, 
			o.ord_supplier,       
			o.ord_startdate, 
			o.ord_completiondate, 
			o.ord_revtype1,       
			o.ord_revtype2, 
			o.ord_revtype3, 
			o.ord_revtype4, 
			o.ord_totalweight, 
			o.ord_totalpieces, 
			o.ord_totalmiles,     
			ISNULL(o.ord_currency, "CAN$"),
			o.ord_currencydate, 
			o.ord_totalvolume,    
			0, 
			0,       
			0, 
			0,
			@fill6,
			"N",     
			@invnum, 
			@dummydate, 
			getdate(), 
			@dummydate,   
			0, 
			o.ord_hdrnumber, 

			o.ord_originregion2,  
			o.ord_originregion3, 
			o.ord_originregion4, 
			o.ord_destregion2,    
			o.ord_destregion3, 
			o.ord_destregion4, 
			0, 
			@remarks, 
			o.ord_driver1, 
			o.ord_driver2, 
			o.ord_tractor,
			o.ord_trailer, 
			o.mov_number, 
			@edi, 
			"RevType1", 
			"RevType2", 
			"RevType3", 
			"RevType4", 
			0, 
			o.ord_priority, 
			0, 
			0,
			0,
			@comments_count,
			@notes_count,
			@loadreq_count,
			@ref_count,
			@pwork_req_count,
			@pwork_rec_count,
			o.ord_company, 
			o.tar_tarriffnumber, 
			o.tar_number, 
			@fill20, 
			@fill20, 
			ord_refnum, 
			0, 
			0, 
			o.tar_tariffitem, 
			@fill6, 
			@fill6, 
			o.ord_number, 
			o.ord_quantity, 
			o.ord_rate, 
			o.ord_charge, 
			o.cht_itemcode, 
			"N", 
			o.ord_status,
			o.ord_subcompany,
			@fill8,
			0,
			"",
			o.ord_loadtime,
			o.ord_unloadtime,
			o.ord_drivetime,
			0,
			o.ord_rateby ivh_rateby,
/* ivh_unit & ivh_rateunit are needed for ratebytotal mode only for the first time to populate 
these fields for the subtotal row */
			o.ord_unit ivh_unit,
			o.ord_rateunit ivh_rateunit
		FROM orderheader o
		WHERE (o.ord_number = @stringparm)
/* pts4314 edit and display order refnumbers in invoicing */
--		update #temp
--		set  ref_count = ( select count(*)
--			from referencenumber r,temp#
--			where r.Ref_table = 'orderheader'
--			and r.ref_tablekey = #temp.ord_hdrnumber) 		      
			END
		END

	END

/******************************************************************
			RETRIEVE BY INVOICE NUMBER
******************************************************************/

if (@retrieve_by = "INVNUM")
	BEGIN
	RETURNEMPTYSET:
	/* IF INVOICE EXISTS POPULATE VARIABLES */
	if (select count(*) FROM invoiceheader 
		WHERE invoiceheader.ivh_invoicenumber = @stringparm) > 0
		BEGIN

		select @comments_count= (select count(*) 
			from orderheader o, invoiceheader i 
			where i.ivh_invoicenumber = @stringparm
			and o.ord_hdrnumber = i.ord_hdrnumber
			and o.ord_remark > ""
			group by i.ivh_hdrnumber ) 
		
		select @notes_count= (select count(*) 
			from notes n, invoiceheader i
			where i.ivh_invoicenumber = @stringparm
			and n.ntb_table = 'orderheader'
			and n.nre_tablekey  = convert(varchar(18), i.ord_hdrnumber)
			group by i.ord_hdrnumber)	 
		
		select @loadreq_count= (select count(*) 
			from loadrequirement l, invoiceheader i
			where i.ivh_invoicenumber = @stringparm
			and l.ord_hdrnumber = i.ord_hdrnumber
			group by i.ivh_hdrnumber) 

		select @ref_count = (select count(*) 
			from referencenumber r, invoiceheader i 
			where i.ivh_invoicenumber = @stringparm
			and r.ref_table = 'orderheader'
			and r.ref_tablekey = i.ord_hdrnumber 
			group by i.ord_hdrnumber)
	
		select @pwork_req_count = (select count(*) 
			from labelfile
			where labelfile.labeldefinition = 'PaperWork')

		select @pwork_rec_count = (select count(p.pw_received) 
			from paperwork p, invoiceheader i
			where i.ivh_invoicenumber = "118A"
			and p.ord_hdrnumber = i.ord_hdrnumber
			and p.pw_received = 'Y') 
		END

	/* ALWAYS PERFORM SELECT REGARDLESS DW REQUIRES A RETURN SET*/
	insert into #temp
	select i.ivh_invoicenumber, 
		i.ivh_billto, 
		i.ivh_terms, 
		i.ivh_totalcharge, 
		i.ivh_shipper, 
		i.ivh_consignee,    
		i.ivh_originpoint, 
		i.ivh_destpoint, 
		i.ivh_invoicestatus,        
		i.ivh_origincity, 
		i.ivh_destcity, 
		i.ivh_originstate,  
		i.ivh_deststate, 
		i.ivh_originregion1, 
		i.ivh_destregion1,  
		i.ivh_supplier, 
		i.ivh_shipdate, 
		i.ivh_deliverydate, 
		i.ivh_revtype1, 
		i.ivh_revtype2, 
		i.ivh_revtype3, 
		i.ivh_revtype4, 
		i.ivh_totalweight, 
		i.ivh_totalpieces,  
		i.ivh_totalmiles, 
		i.ivh_currency, 
		i.ivh_currencydate,         
		i.ivh_totalvolume, 
		i.ivh_taxamount1, 
		i.ivh_taxamount2,   
		i.ivh_taxamount3, 
		i.ivh_taxamount4, 
		i.ivh_transtype,    
		i.ivh_creditmemo, 
		i.ivh_applyto,      
		i.ivh_printdate, 
		i.ivh_billdate, 
		i.ivh_lastprintdate,        
		i.ivh_hdrnumber, 
		i.ord_hdrnumber, 
		i.ivh_originregion2,        
		i.ivh_originregion3, 
		i.ivh_originregion4, 
		i.ivh_destregion2,  
		i.ivh_destregion3, 
		i.ivh_destregion4, 
		i.ivh_mbnumber,
		i.ivh_remark,
		i.ivh_driver,       
		i.ivh_driver2, 
		i.ivh_tractor, 
		i.ivh_trailer,      
		i.mov_number,
		i.ivh_edi_flag, 
		"RevType1", 
		"RevType2", 
		"RevType3",    
		"RevType4", 
		i.ivh_freight_miles,
		i.ivh_priority,    
		i.ivh_low_temp, 
		i.ivh_high_temp, 
		0,

		@comments_count,
		@notes_count,
		@loadreq_count,
		@ref_count ref_count,
		@pwork_req_count,
		@pwork_rec_count,
		i.ivh_order_by, 
		i.tar_tarriffnumber,        
		i.tar_number , 
		i.ivh_user_id1, 
		i.ivh_user_id2 ,    
		i.ivh_ref_number, 
		i.ivh_bookyear, 
		i.ivh_bookmonth, 
		i.tar_tariffitem, 
		i.ivh_mbstatus, 
		@calcmaxstat, 
		i.ord_number, 
		i.ivh_quantity, 
		i.ivh_rate, 
		i.ivh_charge, 
		i.cht_itemcode , 
		i.ivh_splitbill_flag, 
		@calcmaxstat dummy_ordstatus,
		i.ivh_company,
		i.ivh_carrier,
		i.ivh_archarge,
		i.ivh_arcurrency,
		i.ivh_loadtime,
		i.ivh_unloadtime,
		i.ivh_drivetime,
		i.ivh_totaltime,
		i.ivh_rateby,
		@vchar6,
		@vchar6 
	FROM invoiceheader i
	WHERE i.ivh_invoicenumber = @stringparm

-- code add BEGIN - VJ 02/24/97
    
          UPDATE #temp
          SET tar_number = tariffheader.tar_number
          FROM tariffheader, invoiceheader, #temp
          WHERE  tariffheader.tar_tarriffnumber = invoiceheader.tar_tarriffnumber
          AND    invoiceheader.ord_hdrnumber = #temp.ord_hdrnumber
       
-- code add END - VJ 02/24/97
	UPDATE #temp
	Set ivh_ref_number = o.ord_refnum
	FROM orderheader o, #temp
	WHERE o.ord_hdrnumber = #temp.ord_hdrnumber

	UPDATE #temp
	SET ref_count = (Select count(*)
		FROM referencenumber r, #temp
		WHERE r.ref_tablekey = #temp.ord_hdrnumber
		AND r.ref_table = 'orderheader')

	END


SELECT ivh_invoicenumber, 
ivh_billto,
ivh_terms, 
ivh_totalcharge,    

ivh_shipper, 
ivh_consignee, 
ivh_originpoint,    
ivh_destpoint, 
ivh_invoicestatus, 
ivh_origincity,     
ivh_destcity, 
ivh_originstate, 
ivh_deststate,      
ivh_originregion1, 
ivh_destregion1, 
ivh_supplier,       
ivh_shipdate, 
ivh_deliverydate, 
ivh_revtype1,       
ivh_revtype2, 
ivh_revtype3, 
ivh_revtype4, 
ivh_totalweight, 
ivh_totalpieces, 
ivh_totalmiles,     
ivh_currency,
ivh_currencydate, 
ivh_totalvolume,    
ivh_taxamount1, 
ivh_taxamount2,       
ivh_taxamount3, 
ivh_taxamount4,
ivh_transtype,

ivh_creditmemo,     
ivh_applyto, 
ivh_printdate, 
ivh_billdate, 
ivh_lastprintdate,   
ivh_hdrnumber, 
ord_hdrnumber, 
ivh_originregion2,  
ivh_originregion3, 
ivh_originregion4, 
ivh_destregion2,    

ivh_destregion3, 
ivh_destregion4, 
ivh_mbnumber, 
ivh_remark, 
ivh_driver,
ivh_driver2, 
ivh_tractor,
ivh_trailer, 
mov_number, 
ivh_edi_flag, 
revtype1, 
revtype2, 
revtype3, 
revtype4, 
ivh_freight_miles, 
ivh_priority,
ivh_low_temp, 
ivh_high_temp,
events_count,
comments_count,
notes_count,
loadreq_count,
ref_count,
paperwork_required,
paperwork_received,
ivh_order_by, 
tar_tarriffnumber, 
tar_number, 
ivh_user_id1, 
ivh_user_id2, 
ivh_ref_number, 
invoiceheader_ivh_bookyear, 
invoiceheader_ivh_bookmonth, 
tar_tariffitem, 
ivh_mbstatus, 
calc_maxstatus, 
ord_number, 
ivh_quantity, 
ivh_rate, 
ivh_charge, 
cht_itemcode, 
ivh_splitbill_flag, 
dummy_ordstatus,
ivh_company,
ivh_carrier,
ivh_archarge,
ivh_arcurrency,
ivh_loadtime,
ivh_unloadtime,
ivh_drivetime,
ivh_totaltime,
ivh_rateby,
ivh_unit,
ivh_rateunit
from #temp




GO
GRANT EXECUTE ON  [dbo].[d_inv_edit_hdr2_sp] TO [public]
GO
