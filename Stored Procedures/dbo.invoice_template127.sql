SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create  procedure [dbo].[invoice_template127](@invoice_nbr int,@copies int)
as
/**
 * 
 * NAME:
 * invoice_template127
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns result set for invoice format, copy of invoice_template63
 *
 * RETURNS: 	1 = success
 *
 * RESULT SETS: see return set
 *
 * PARAMETERS:
 * @invoice_nbr int
 * @copies int
 *
 *
 * REVISION HISTORY:
 * 10/04/07 EMK - Created by duplicating invoice_template121.  No other changes at this date.
*/
  
declare @temp_name   varchar(100) ,  
 @temp_addr   varchar(100) ,  
 @temp_addr2  varchar(100),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50)
  
create table #invtemp_tbl (
	ivh_invoicenumber varchar(12) null,     
	ivh_hdrnumber int null,   
	ivh_billto varchar(8) null,   
	ivh_billto_name varchar(100) null,  
	ivh_billto_addr varchar(100) null,
	ivh_billto_addr2 varchar(100) null,        
	ivh_billto_nmctst varchar(50) null,  
	ivh_terms varchar(3) null,      
	ivh_totalcharge money null,     
	ivh_shipper varchar(8) null,     
	shipper_name  varchar(100) null,  
	shipper_addr varchar(100) null, 
	shipper_addr2 varchar(100) null, 
	shipper_nmctst varchar(50) null,  
	ivh_consignee varchar(8) null,     
	consignee_name varchar(100) null, 
	consignee_addr varchar(100) null,
	consignee_addr2 varchar(100) null,
	consignee_nmctst varchar(50) null,
	/* vestige of old unused origin and dest information */
	originpoint varchar(1) null
	,originpoint_name varchar(1) null
	,origin_addr varchar(1) null
	,origin_addr2 varchar(1) null
	,origin_nmstct varchar(1) null
	,destpoint varchar(1) null
	,destpoint_name varchar(1) null
	,destpoint_addr varchar(1) null
	,destpoint_addr2 varchar(1) null
	,destpoint_nmstct varchar(1) null
	,ivh_invoicestatus varchar(6) null    
	,ivh_origincity int null 
	,ivh_destcity int null   
	,ivh_originstate varchar(6) null     
	,ivh_deststate varchar(6) null 
	,ivh_originregion1 varchar(6) null     
	,ivh_destregion1 varchar(6) null 
	,ivh_supplier varchar(8) null    
	,ivh_shipdate datetime null    
	,ivh_deliverydate datetime null    
	,ivh_revtype1 varchar(6) null   
	,ivh_revtype2 varchar(6) null  
	,ivh_revtype3 varchar(6) null   
	,ivh_revtype4 varchar(6) null        
	,ivh_totalweight float null     
	,ivh_totalpieces float null     
	,ivh_totalmiles float null   
	,ivh_currency varchar(6) null   
	,ivh_currencydate datetime null   
	,ivh_totalvolume float null    
	,ivh_taxamount1 money null  
	,ivh_taxamount2 money null
	,ivh_taxamount3 money null
	,ivh_taxamount4 money null  
	,ivh_transtype varchar(6) null
	,ivh_creditmemo char(1) null    
	,ivh_applyto varchar(12) null    
	,ivh_printdate datetime null    
	,ivh_billdate datetime null   
	,ivh_lastprintdate datetime null 
	,ivh_originregion2 varchar(6) null
	,ivh_originregion3 varchar(6) null
	,ivh_originregion4 varchar(6) null       
	,ivh_destregion2 varchar(6) null 
	,ivh_destregion3 varchar(6) null 
	,ivh_destregion4 varchar(6) null    
	,mfh_hdrnumber int null   
	,ivh_remark varchar(254) null   
	,ivh_driver varchar(8) null    
	,ivh_tractor varchar(8) null 
	,ivh_trailer varchar(13) null    
	,ivh_user_id1 varchar(20) null     
	,ivh_user_id2 varchar(20) null    
	,ivh_ref_number varchar(30) null 
	,ivh_driver2 varchar(8) null    
	,mov_number int null    
	,ivh_edi_flag char(30) null    
	,ord_hdrnumber int null    
	,ivd_number int null   
	,stp_number int null    
	,ivd_description varchar(60)  null   
	,cht_itemcode varchar(6)   null 
	,ivd_quantity float null     
	,ivd_rate money null    
	,ivd_charge money null   
	,ivd_taxable1 char(1) null 
	,ivd_taxable2 char(1) null
	,ivd_taxable3 char(1) null
	,ivd_taxable4 char(1) null    
	,ivd_unit varchar(6) null     
	,cur_code varchar(6) null    
	,ivd_currencydate datetime null   
	,ivd_glnum varchar(32) null   
	,ivd_type varchar(6) null  
	,ivd_rateunit varchar(6) null    
	,ivd_billto varchar(8) null     
	,ivd_billto_name varchar(100) null
	,ivd_billto_addr varchar(100) null 
	,ivd_billto_addr2 varchar(100) null 
	,ivd_billto_nmctst varchar(50) null 
	,ivd_itemquantity float null    
	,ivd_subtotalptr int null    
	,ivd_allocatedrev money null    
	,ivd_sequence int null    
	,ivd_refnum varchar(30) null   
	,cmd_code varchar(8) null    
	,cmp_id varchar(8) null    
	,stop_name varchar(100) null 
	,stop_addr varchar(100) null  
	,stop_addr2 varchar(100) null
	,stop_nmctst varchar(50) null
	,ivd_distance float null     
	,ivd_distunit varchar(6) null   
	,ivd_wgt float null     
	,ivd_wgtunit varchar(6) null    
	,ivd_count decimal(10,2) null    
	,ivd_countunit varchar(6) null  
	,evt_number int null   
	,ivd_reftype varchar(6) null    
	,ivd_volume float null    
	,ivd_volunit varchar(6) null    
	,ivd_orig_cmpid varchar(8) null  
	,ivd_payrevenue money null 
	,ivh_freight_miles float null 
	,tar_tarriffnumber varchar(12) null 
	,tar_tariffitem varchar(12) null
	,copies smallint null 
	,cht_basis varchar(6) null 
	,cht_description varchar(30) null
	 ,cmd_name varchar(60) null 
	,cmp_altid varchar(25) null 
	,ivh_showshipper varchar(8) null
	,ivh_showcons varchar(8) null
	,terms_name varchar(20) null
	,ivh_billto_addr3 varchar(100) null
	,ivd_remark varchar(255) null
	,cmp_contact varchar(50) null  
	,shipper_addr3 varchar(100) NULL
	,CONSIGNEE_ADDR3 VARCHAR(100) NULL
	,ivh_charge money null
	,cht_rollintolh int null
	,isDistanceCharge char(1) NULL
	,CHT_PRIMARY CHAR(1) NULL
	,shipperstatezip varchar(20) null
	,consigneestatezip varchar(20) null
	,billtostatezip varchar(20) null
)
  
/* SET FOR A SUCCESSFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCESSFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
 insert into #invtemp_tbl 
 SELECT  invoiceheader.ivh_invoicenumber,     
	invoiceheader.ivh_hdrnumber,   
	invoiceheader.ivh_billto,   
	@temp_name ivh_billto_name ,  
	@temp_addr  ivh_billto_addr,  
	@temp_addr2 ivh_billto_addr2,           
	@temp_nmstct ivh_billto_nmctst,  
	invoiceheader.ivh_terms,      
	invoiceheader.ivh_totalcharge,     
	invoiceheader.ivh_shipper,     
	isnull(scmp.cmp_name,'') shipper_name,  
	isnull(scmp.cmp_address1,'') shipper_addr,  
	isnull(scmp.cmp_address2,'') shipper_addr2,  
	isnull(scity.cty_name,'') shipper_nmctst,  
	invoiceheader.ivh_consignee,     
	isnull(ccmp.cmp_name,'') consignee_name,  
	isnull(ccmp.cmp_address1,'') consignee_addr,  
	isnull(ccmp.cmp_address2,'') consignee_addr2,  
	isnull(ccity.cty_name,'')  consignee_nmctst,
	/* vestige of old unused origin and dest information */
	'' originpoint,''originpoint_name,''origin_addr,''origin_addr2,''origin_nmstct
	,''destpoint,''destpoint_name,''destpoint_addr,''destpoint_addr2,''destpoint_nmstct,  
	invoiceheader.ivh_invoicestatus,     
	invoiceheader.ivh_origincity,     
	invoiceheader.ivh_destcity,     
	invoiceheader.ivh_originstate,     
	invoiceheader.ivh_deststate,  
	invoiceheader.ivh_originregion1,     
	invoiceheader.ivh_destregion1,     
	invoiceheader.ivh_supplier,     
	invoiceheader.ivh_shipdate,     
	invoiceheader.ivh_deliverydate,     
	invoiceheader.ivh_revtype1,     
	invoiceheader.ivh_revtype2,     
	invoiceheader.ivh_revtype3,     
	invoiceheader.ivh_revtype4,     
	invoiceheader.ivh_totalweight,     
	invoiceheader.ivh_totalpieces,     
	invoiceheader.ivh_totalmiles,     
	invoiceheader.ivh_currency,     
	invoiceheader.ivh_currencydate,     
	invoiceheader.ivh_totalvolume,     
	invoiceheader.ivh_taxamount1,     
	invoiceheader.ivh_taxamount2,     
	invoiceheader.ivh_taxamount3,     
	invoiceheader.ivh_taxamount4,     
	invoiceheader.ivh_transtype,     
	invoiceheader.ivh_creditmemo,     
	invoiceheader.ivh_applyto,     
	invoiceheader.ivh_printdate,     
	invoiceheader.ivh_billdate,     
	invoiceheader.ivh_lastprintdate,     
	invoiceheader.ivh_originregion2,     
	invoiceheader.ivh_originregion3,     
	invoiceheader.ivh_originregion4,     
	invoiceheader.ivh_destregion2,     
	invoiceheader.ivh_destregion3,     
	invoiceheader.ivh_destregion4,     
	invoiceheader.mfh_hdrnumber,     
	invoiceheader.ivh_remark,     
	invoiceheader.ivh_driver,     
	invoiceheader.ivh_tractor,     
	invoiceheader.ivh_trailer,     
	invoiceheader.ivh_user_id1,     
	invoiceheader.ivh_user_id2,     
	invoiceheader.ivh_ref_number,     
	invoiceheader.ivh_driver2,     
	invoiceheader.mov_number,     
	invoiceheader.ivh_edi_flag,     
	invoiceheader.ord_hdrnumber,     
	invoicedetail.ivd_number,     
	invoicedetail.stp_number,     
	invoicedetail.ivd_description,     
	invoicedetail.cht_itemcode,     
	invoicedetail.ivd_quantity,     
	invoicedetail.ivd_rate,     
	invoicedetail.ivd_charge,  
	--invoicedetail.ivd_taxable1,     
	--invoicedetail.ivd_taxable2,     
	-- invoicedetail.ivd_taxable3,     
	--invoicedetail.ivd_taxable4,   
	ivd_taxable1 =  IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
	ivd_taxable2 =IsNull(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
	ivd_taxable3 =IsNull(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
	ivd_taxable4 =IsNull(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
	invoicedetail.ivd_unit,     
	invoicedetail.cur_code,     
	invoicedetail.ivd_currencydate,     
	invoicedetail.ivd_glnum,     
	invoicedetail.ivd_type,     
	invoicedetail.ivd_rateunit,     
	invoicedetail.ivd_billto,     
	@temp_name ivd_billto_name,  
	@temp_addr ivd_billto_addr,  
	@temp_addr2 ivd_billto_addr2,  
	@temp_nmstct ivd_billto_nmctst,  
	invoicedetail.ivd_itemquantity,     
	invoicedetail.ivd_subtotalptr,     
	invoicedetail.ivd_allocatedrev,     
	invoicedetail.ivd_sequence,     
	invoicedetail.ivd_refnum,     
	invoicedetail.cmd_code,     
	invoicedetail.cmp_id,     
	isnull(stopcmp.cmp_name,'') stop_name,  
	isnull(stopcmp.cmp_address1,'') stop_addr,  
	isnull(stopcmp.cmp_address2,'') stop_addr2, 
	case isnull(invoicedetail.stp_number ,0)
	    when 0 then ''
	    else
	  		isnull(stopcity.cty_name,'')+', '+isnull(stopcity.cty_state,'')+'   '+ isnull(stopcmp.cmp_zip,'')
	    end  stop_nmctst,  
	invoicedetail.ivd_distance,     
	invoicedetail.ivd_distunit,     
	invoicedetail.ivd_wgt,     
	invoicedetail.ivd_wgtunit,     
	invoicedetail.ivd_count,     
	invoicedetail.ivd_countunit,     
	invoicedetail.evt_number,     
	invoicedetail.ivd_reftype,     
	invoicedetail.ivd_volume,     
	invoicedetail.ivd_volunit,     
	invoicedetail.ivd_orig_cmpid,     
	invoicedetail.ivd_payrevenue,  
	invoiceheader.ivh_freight_miles,  
	invoiceheader.tar_tarriffnumber,  
	invoiceheader.tar_tariffitem,  
	1 copies,  
	chargetype.cht_basis,  
	chargetype.cht_description,  
	commodity.cmd_name,  
	@temp_altid cmp_altid,  
	(Case ivh_showshipper   
		when 'UNKNOWN' then invoiceheader.ivh_shipper  
		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
		end) ivh_showshipper,  
	(Case ivh_showcons   
		when 'UNKNOWN' then invoiceheader.ivh_consignee  
		else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
		end) ivh_showcons,  
	isnull(labelfile.name,'')  terms_name,  
	@temp_addr2    ivh_billto_addr3,
	isnull(ivd_remark,'')ivd_remark,  
	@varchar50 cmp_contact
	,isnull(scmp.cmp_address3,'')
	,isnull(ccmp.cmp_address3,'')
	,ivh_charge
	,isnull(chargetype.cht_rollintolh,0) cht_rollintolh
    ,isnull((select 'Y' from labelfile 
		where labeldefinition = 'distanceUnits' 
			and abbr = ivd_unit
			and abbr <> 'UNK'),'N')
    ,isnull(cht_primary,'N') cht_primary
    ,', '+isnull(scity.cty_state,'')+'   '+ isnull(scmp.cmp_zip,'')
    ,', '+isnull(ccity.cty_state,'')+'   '+ isnull(ccmp.cmp_zip,'')
    ,' '
    FROM invoiceheader
	    join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
	    left outer join  chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
	    left outer join  commodity on invoicedetail.cmd_code = commodity.cmd_code 
	    left outer join company scmp on invoiceheader.ivh_showshipper = scmp.cmp_id
	    left outer join company ccmp on invoiceheader.ivh_showcons = ccmp.cmp_id
	    left outer join company stopcmp on invoicedetail.cmp_id = stopcmp.cmp_id
	    left outer join city scity on scmp.cmp_city = scity.cty_code
	    left outer join city ccity on ccmp.cmp_city = ccity.cty_code
	    left outer join city stopcity on stopcmp.cmp_city = stopcity.cty_code
	    left outer join labelfile on ivh_terms = abbr and labeldefinition = 'CreditTerms'
   WHERE 
		invoiceheader.ivh_hdrnumber = @invoice_nbr  

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
 select @ret_value = 0    
 GOTO ERROR_END  
 end  

--PTS 39514 EMK - Funks wants to see First Pickup in detail lines.  Need to retrieve if there wasn't a billable pickup already.
INSERT INTO #invtemp_tbl
 select
	tmp.ivh_invoicenumber, 
	tmp.ivh_hdrnumber, 
	tmp.ivh_billto,  
	tmp.ivh_billto_name , 
	tmp.ivh_billto_addr,
	tmp.ivh_billto_addr2,       
	tmp.ivh_billto_nmctst,
	tmp.ivh_terms ,     
	tmp.ivh_totalcharge ,   
	tmp.ivh_shipper ,    
	tmp.shipper_name ,  
	tmp.shipper_addr,
	tmp.shipper_addr2,
	tmp.shipper_nmctst, 
	tmp.ivh_consignee ,     
	tmp.consignee_name ,
	tmp.consignee_addr,
	tmp.consignee_addr2,
	tmp.consignee_nmctst,
	tmp.originpoint 
	,tmp.originpoint_name 
	,tmp.origin_addr
	,tmp.origin_addr2
	,tmp.origin_nmstct 
	,tmp.destpoint 
	,tmp.destpoint_name
	,tmp.destpoint_addr
	,tmp.destpoint_addr2
	,tmp.destpoint_nmstct 
	,tmp.ivh_invoicestatus    
	,tmp.ivh_origincity  
	,tmp.ivh_destcity    
	,tmp.ivh_originstate      
	,tmp.ivh_deststate 
	,tmp.ivh_originregion1     
	,tmp.ivh_destregion1 
	,tmp.ivh_supplier    
	,tmp.ivh_shipdate     
	,tmp.ivh_deliverydate     
	,tmp.ivh_revtype1   
	,tmp.ivh_revtype2 
	,tmp.ivh_revtype3   
	,tmp.ivh_revtype4        
	,tmp.ivh_totalweight    
	,tmp.ivh_totalpieces     
	,tmp.ivh_totalmiles    
	,tmp.ivh_currency   
	,tmp.ivh_currencydate    
	,tmp.ivh_totalvolume    
	,tmp.ivh_taxamount1  
	,tmp.ivh_taxamount2
	,tmp.ivh_taxamount3
	,tmp.ivh_taxamount4 
	,tmp.ivh_transtype
	,tmp.ivh_creditmemo   
	,tmp.ivh_applyto  
	,tmp.ivh_printdate   
	,tmp.ivh_billdate   
	,tmp.ivh_lastprintdate 
	,tmp.ivh_originregion2 
	,tmp.ivh_originregion3 
	,tmp.ivh_originregion4       
	,tmp.ivh_destregion2  
	,tmp.ivh_destregion3
	,tmp.ivh_destregion4     
	,tmp.mfh_hdrnumber   
	,tmp.ivh_remark   
	,tmp.ivh_driver 
	,tmp.ivh_tractor
	,tmp.ivh_trailer   
	,tmp.ivh_user_id1     
	,tmp.ivh_user_id2   
	,tmp.ivh_ref_number
	,tmp.ivh_driver2    
	,tmp.mov_number   
	,tmp.ivh_edi_flag    
	,tmp.ord_hdrnumber    
	,tmp.ivd_number   
	,stp.stp_number  -- From stops 
	,''  -- tmp.ivd_description    
	,tmp.cht_itemcode  
	,0 --tmp.ivd_quantity     
	,tmp.ivd_rate     
	,tmp.ivd_charge  
	,tmp.ivd_taxable1 
	,tmp.ivd_taxable2 
	,tmp.ivd_taxable3 
	,tmp.ivd_taxable4  
	,tmp.ivd_unit      
	,tmp.cur_code   
	,tmp.ivd_currencydate   
	,tmp.ivd_glnum   
	,tmp.ivd_type  
	,tmp.ivd_rateunit   
	,tmp.ivd_billto      
	,tmp.ivd_billto_name 
	,tmp.ivd_billto_addr  
	,tmp.ivd_billto_addr2
	,tmp.ivd_billto_nmctst 
	,tmp.ivd_itemquantity     
	,tmp.ivd_subtotalptr     
	,tmp.ivd_allocatedrev   
	,0  -- tmp.ivd_sequence     
	,tmp.ivd_refnum    
	,tmp.cmd_code     
	,stp.cmp_id --tmp.cmd_id 
	,isnull(stopcmp.cmp_name,'') stop_name  --tmp.stop_name 
	,isnull(stopcmp.cmp_address1,'') stop_addr --tmp.stop_addr 
	,isnull(stopcmp.cmp_address2,'') stop_addr2 --tmp.stop_addr2
	,case isnull(stp.stp_number ,0) --tmp.stop_nmctst 
	    when 0 then ''
	    else
	  		isnull(stopcity.cty_name,'')+', '+isnull(stopcity.cty_state,'')+'   '+ isnull(stopcmp.cmp_zip,'')
	    end
	,tmp.ivd_distance     
	,tmp.ivd_distunit   
	,stp_weight  --tmp.ivd_wgt     
	,stp_weightunit -- tmp.ivd_wgtunit   
	,stp.stp_count  -- tmp.ivd_count     
	,stp.stp_countunit --tmp.ivd_countunit 
	,evt.evt_number  -- tmp.evt_number  
	,tmp.ivd_reftype     
	,stp.stp_volume  --tmp.ivd_volume    
	,stp.stp_volumeunit --tmp.ivd_volunit     
	,tmp.ivd_orig_cmpid   
	,tmp.ivd_payrevenue 
	,tmp.ivh_freight_miles 
	,tmp.tar_tarriffnumber 
	,tmp.tar_tariffitem 
	,1	--tmp.copies  
	,tmp.cht_basis 
	,tmp.cht_description 
	,tmp.cmd_name 
	,tmp.cmp_altid  
	,tmp.ivh_showshipper 
	,tmp.ivh_showcons 
	,tmp.terms_name 
	,tmp.ivh_billto_addr3 
	,tmp.ivd_remark 
	,tmp.cmp_contact 
	,tmp.shipper_addr3 
	,tmp.CONSIGNEE_ADDR3 
	,tmp.ivh_charge
	,tmp.cht_rollintolh
	,tmp.isDistanceCharge
	,tmp.cht_primary
	,tmp.shipperstatezip 
	,tmp.consigneestatezip
	,tmp.billtostatezip
	from stops stp 
		join invoiceheader ivh on stp.ord_hdrnumber = ivh.ord_hdrnumber
		join event evt on evt.stp_number = stp.stp_number
		join #invtemp_tbl tmp on tmp.ord_hdrnumber = ivh.ord_hdrnumber
		left outer join company stopcmp on stp.cmp_id = stopcmp.cmp_id
	    left outer join city stopcity on stp.stp_city = stopcity.cty_code	
	where 
		ivh.ivh_hdrnumber = @invoice_nbr
		and stp.ord_hdrnumber <> 0
		and stp.stp_type = 'PUP'
		and evt.evt_number not in (SELECT IsNull(evt_number,-1) from #invtemp_tbl)
		and tmp.ivd_sequence = 1   
--PTS 39514
 
If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t  
				Where c.cmp_id = t.ivh_billto  
				And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
				And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    					Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   						And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
	update #invtemp_tbl  
	set ivh_billto_name = isnull(company.cmp_name, ''), 
		ivh_billto_nmctst = isnull(city.cty_name,''),
		billtostatezip =  ', '+isnull(city.cty_state,'')+'   '+ isnull(cmp_zip,''),   
		#invtemp_tbl.cmp_altid = isnull(company.cmp_altid,''),  
		ivh_billto_addr = isnull(company.cmp_address1,'') , 
		ivh_billto_addr2 = isnull(company.cmp_address2,'') , 
		ivh_billto_addr3 = isnull(company.cmp_address3,''),  
		cmp_contact = company.cmp_contact 
     from #invtemp_tbl
	     left outer join company on #invtemp_tbl.ivh_billto  =  company.cmp_id
	     left outer join city on cmp_city = cty_code
 
Else   
	update #invtemp_tbl  
	set ivh_billto_name = isnull( company.cmp_mailto_name,''),  
		ivh_billto_addr =  isnull(company.cmp_mailto_address1 ,  ''),
		ivh_billto_addr2 = isnull(company.cmp_mailto_address2, '')  ,  
		ivh_billto_nmctst =   isnull(city.cty_name ,''), 
		billtostatezip =  ', '+isnull(city.cty_state,'')+'   '+ isnull(cmp_zip,'')   ,  
		#invtemp_tbl.cmp_altid = company.cmp_altid ,  
		cmp_contact = company.cmp_contact ,
		ivh_billto_addr3 = '' 
	from #invtemp_tbl
		left outer join company  on #invtemp_tbl.ivh_billto  = company.cmp_id
		left outer join city on cmp_mailto_city = cty_code
 --end  

 -- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
if exists (select 1 from #invtemp_tbl where ivh_shipper = 'UNKNOWN' )
	update #invtemp_tbl  
	set shipper_nmctst = city.cty_name+', '+city.cty_state 
	from #invtemp_tbl
		join city  on ivh_origincity  = city.cty_code
	where #invtemp_tbl.ivh_shipper = 'UNKNOWN' 


if exists (select 1 from #invtemp_tbl where ivh_consignee = 'UNKNOWN' )
	update #invtemp_tbl  
	set consignee_nmctst = city.cty_name+', '+city.cty_state 
	from #invtemp_tbl
		join city on  ivh_destcity = city.cty_code
	where #invtemp_tbl.ivh_consignee = 'UNKNOWN' 

/* if stop had not company but a city, set the city info from the city table */
if exists (select 1 from #invtemp_tbl where cmp_id = 'UNKNOWN' and ivd_type in ('PUP','DRP') )
	update #invtemp_tbl  
	set  stop_nmctst = 
  		case charindex('/', isnull(city.cty_nmstct,''))
  			when 0 then isnull(city.cty_nmstct,'')
  			else substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'') 
  		end  
	from  #invtemp_tbl
		join stops on #invtemp_tbl.stp_number  = stops.stp_number
		left outer join city  on stops.stp_city  = city.cty_code
    where  #invtemp_tbl.stp_number IS NOT NULL  
		and #invtemp_tbl.cmp_id = 'UNKNOWN'
		and ivd_type in ('PUP','DRP')

--PTS 39514 EMK - Update sequence if we had to add the first PUP
if exists (select 1 from #invtemp_tbl where ivd_sequence = 0)
	update #invtemp_tbl set ivd_sequence = ivd_sequence + 1
--PTS 39514

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @counter = 1  
while @counter <>  @copies  
 begin  
 select @counter = @counter + 1  
  insert into #invtemp_tbl 
   select
	ivh_invoicenumber, 
	ivh_hdrnumber, 
	ivh_billto,  
	ivh_billto_name , 
	ivh_billto_addr,
	ivh_billto_addr2,       
	ivh_billto_nmctst,
	ivh_terms ,     
	ivh_totalcharge ,   
	ivh_shipper ,    
	shipper_name ,  
	shipper_addr,
	shipper_addr2,
	shipper_nmctst, 
	ivh_consignee ,     
	consignee_name ,
	consignee_addr,
	consignee_addr2,
	consignee_nmctst,
	/* vestige of old unused origin and dest information */
	originpoint 
	,originpoint_name 
	,origin_addr
	,origin_addr2
	,origin_nmstct 
	,destpoint 
	,destpoint_name
	,destpoint_addr
	,destpoint_addr2
	,destpoint_nmstct 
	,ivh_invoicestatus    
	,ivh_origincity  
	,ivh_destcity    
	,ivh_originstate      
	,ivh_deststate 
	,ivh_originregion1     
	,ivh_destregion1 
	,ivh_supplier    
	,ivh_shipdate     
	,ivh_deliverydate     
	,ivh_revtype1   
	,ivh_revtype2 
	,ivh_revtype3   
	,ivh_revtype4        
	,ivh_totalweight    
	,ivh_totalpieces     
	,ivh_totalmiles    
	,ivh_currency   
	,ivh_currencydate    
	,ivh_totalvolume    
	,ivh_taxamount1  
	,ivh_taxamount2
	,ivh_taxamount3
	,ivh_taxamount4 
	,ivh_transtype
	,ivh_creditmemo   
	,ivh_applyto  
	,ivh_printdate   
	,ivh_billdate   
	,ivh_lastprintdate 
	,ivh_originregion2 
	,ivh_originregion3 
	,ivh_originregion4       
	,ivh_destregion2  
	,ivh_destregion3
	,ivh_destregion4     
	,mfh_hdrnumber   
	,ivh_remark   
	,ivh_driver 
	,ivh_tractor
	,ivh_trailer   
	,ivh_user_id1     
	,ivh_user_id2   
	,ivh_ref_number
	,ivh_driver2    
	,mov_number   
	,ivh_edi_flag    
	,ord_hdrnumber    
	,ivd_number   
	,stp_number   
	,ivd_description    
	,cht_itemcode  
	,ivd_quantity     
	,ivd_rate     
	,ivd_charge  
	,ivd_taxable1 
	,ivd_taxable2 
	,ivd_taxable3 
	,ivd_taxable4  
	,ivd_unit      
	,cur_code   
	,ivd_currencydate   
	,ivd_glnum   
	,ivd_type  
	,ivd_rateunit   
	,ivd_billto      
	,ivd_billto_name 
	,ivd_billto_addr  
	,ivd_billto_addr2
	,ivd_billto_nmctst 
	,ivd_itemquantity     
	,ivd_subtotalptr     
	,ivd_allocatedrev   
	,ivd_sequence     
	,ivd_refnum    
	,cmd_code     
	,cmp_id    
	,stop_name 
	,stop_addr  
	,stop_addr2 
	,stop_nmctst 
	,ivd_distance     
	,ivd_distunit   
	,ivd_wgt     
	,ivd_wgtunit   
	,ivd_count     
	,ivd_countunit 
	,evt_number    
	,ivd_reftype     
	,ivd_volume    
	,ivd_volunit     
	,ivd_orig_cmpid   
	,ivd_payrevenue 
	,ivh_freight_miles 
	,tar_tarriffnumber 
	,tar_tariffitem 
	, @counter copies  
	,cht_basis 
	,cht_description 
	,cmd_name 
	,cmp_altid  
	,ivh_showshipper 
	,ivh_showcons 
	,terms_name 
	,ivh_billto_addr3 
	,ivd_remark 
	,cmp_contact 
	,shipper_addr3 
	,CONSIGNEE_ADDR3 
	,ivh_charge
	,cht_rollintolh
	,isDistanceCharge
	,cht_primary
	,shipperstatezip 
	,consigneestatezip
	,billtostatezip
	from #invtemp_tbl  
	where copies = 1     
 end   




ERROR_END: 
select
	ivh_invoicenumber, 
	ivh_hdrnumber, 
	ivh_billto,  
	ivh_billto_name , 
	ivh_billto_addr,
	ivh_billto_addr2,       
	ivh_billto_nmctst,
	ivh_terms ,     
	ivh_totalcharge ,   
	ivh_shipper ,    
	shipper_name ,  
	shipper_addr,
	shipper_addr2,
	shipper_nmctst, 
	ivh_consignee ,     
	consignee_name ,
	consignee_addr,
	consignee_addr2,
	consignee_nmctst,
	/* vestige of old unused origin and dest information */
	originpoint 
	,originpoint_name 
	,origin_addr
	,origin_addr2
	,origin_nmstct 
	,destpoint 
	,destpoint_name
	,destpoint_addr
	,destpoint_addr2
	,destpoint_nmstct 
	,ivh_invoicestatus    
	,ivh_origincity  
	,ivh_destcity    
	,ivh_originstate      
	,ivh_deststate 
	,ivh_originregion1     
	,ivh_destregion1 
	,ivh_supplier    
	,ivh_shipdate     
	,ivh_deliverydate     
	,ivh_revtype1   
	,ivh_revtype2 
	,ivh_revtype3   
	,ivh_revtype4        
	,ivh_totalweight    
	,ivh_totalpieces     
	,ivh_totalmiles    
	,ivh_currency   
	,ivh_currencydate    
	,ivh_totalvolume    
	,ivh_taxamount1  
	,ivh_taxamount2
	,ivh_taxamount3
	,ivh_taxamount4 
	,ivh_transtype
	,ivh_creditmemo   
	,ivh_applyto  
	,ivh_printdate   
	,ivh_billdate   
	,ivh_lastprintdate 
	,ivh_originregion2 
	,ivh_originregion3 
	,ivh_originregion4       
	,ivh_destregion2  
	,ivh_destregion3
	,ivh_destregion4     
	,mfh_hdrnumber   
	,ivh_remark   
	,ivh_driver 
	,ivh_tractor
	,ivh_trailer   
	,ivh_user_id1     
	,ivh_user_id2   
	,ivh_ref_number
	,ivh_driver2    
	,mov_number   
	,ivh_edi_flag    
	,ord_hdrnumber    
	,ivd_number   
	,stp_number   
	,ivd_description    
	,cht_itemcode  
	,ivd_quantity     
	,ivd_rate     
	,ivd_charge  
	,ivd_taxable1 
	,ivd_taxable2 
	,ivd_taxable3 
	,ivd_taxable4  
	,ivd_unit      
	,cur_code   
	,ivd_currencydate   
	,ivd_glnum   
	,ivd_type  
	,ivd_rateunit   
	,ivd_billto      
	,ivd_billto_name 
	,ivd_billto_addr  
	,ivd_billto_addr2
	,ivd_billto_nmctst 
	,ivd_itemquantity     
	,ivd_subtotalptr     
	,ivd_allocatedrev   
	,ivd_sequence     
	,ivd_refnum    
	,cmd_code     
	,cmp_id    
	,stop_name 
	,stop_addr  
	,stop_addr2 
	,stop_nmctst 
	,ivd_distance     
	,ivd_distunit   
	,ivd_wgt     
	,ivd_wgtunit   
	,ivd_count     
	,ivd_countunit 
	,evt_number    
	,ivd_reftype     
	,ivd_volume    
	,ivd_volunit     
	,ivd_orig_cmpid   
	,ivd_payrevenue 
	,ivh_freight_miles 
	,tar_tarriffnumber 
	,tar_tariffitem 
	,copies  
	,cht_basis 
	,cht_description 
	,cmd_name 
	,cmp_altid 
	,ivh_showshipper 
	,ivh_showcons 
	,terms_name 
	,ivh_billto_addr3 
	,ivd_remark 
	,cmp_contact 
	,shipper_addr3 
	,CONSIGNEE_ADDR3
	--,ivh_charge not used
	,cht_rollintolh 
	, isDistanceCharge
	,cht_primary
	,shipperstatezip 
	,consigneestatezip
	,billtostatezip
from  #invtemp_tbl 

return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[invoice_template127] TO [public]
GO
