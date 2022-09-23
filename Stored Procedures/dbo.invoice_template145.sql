SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_template145](@invoice_nbr   int,@copies  int)  
AS  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  CREATED from templete2 BY Michalynn Kelly for PTS 44093
  Updated invoice_template145 to include rollintoLH functionality for PTS 50327 TMEZE
*/  
  

DECLARE @temp_name		varchar(100) ,  
		@temp_addr		varchar(100) , 
		@temp_addr2		varchar(100),  
		@temp_nmstct	varchar(30),  
		@temp_altid		varchar(25),  
		@counter		int,  
		@ret_value		int,  
		@temp_terms		varchar(20),  
		@varchar50		varchar(50),
		@varchar20      varchar(20),
		@minref         varchar(20),
        @minseq         int,
        @ORD_HDR        int,
        @last_seq 		int,
	    @next_seq 		int,
	    @i 				int,
	    @sql 			Nvarchar(1024),
		@misc4			varchar(254),
		@rollintoLHAmt	money,								-- PTS 50327 
		@rateconvertion	float								-- PTS 50327 
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
SELECT	invoiceheader.ivh_invoicenumber,     
		invoiceheader.ivh_hdrnumber,   
		invoiceheader.ivh_billto,   
		@temp_name ivh_billto_name ,  
		@temp_addr  ivh_billto_addr,  
		@temp_addr2 ivh_billto_addr2,           
		@temp_nmstct ivh_billto_nmctst,  
		invoiceheader.ivh_terms,      
		invoiceheader.ivh_totalcharge,     
		invoiceheader.ivh_shipper,    -- 10   
		@temp_name shipper_name,  
		@temp_addr shipper_addr,  
		@temp_addr2 shipper_addr2,  
		@temp_nmstct shipper_nmctst,  
		invoiceheader.ivh_consignee,     
		@temp_name consignee_name,  
		@temp_addr consignee_addr,  
		@temp_addr2 consignee_addr2,  
		@temp_nmstct consignee_nmctst,  
		invoiceheader.ivh_originpoint,  --20   
		@temp_name originpoint_name,  
		@temp_addr origin_addr,  
		@temp_addr2 origin_addr2,  
		@temp_nmstct origin_nmctst,  
		invoiceheader.ivh_destpoint,     
		@temp_name destpoint_name,  
		@temp_addr dest_addr,  
		@temp_addr2 dest_addr2,  
		@temp_nmstct dest_nmctst,  
		invoiceheader.ivh_invoicestatus,    --30 
		invoiceheader.ivh_origincity,     
		invoiceheader.ivh_destcity,     
		invoiceheader.ivh_originstate,     
		invoiceheader.ivh_deststate,  
		invoiceheader.ivh_originregion1,     
		invoiceheader.ivh_destregion1,     
		invoiceheader.ivh_supplier,     
		invoiceheader.ivh_shipdate,     
		invoiceheader.ivh_deliverydate,     
		invoiceheader.ivh_revtype1,       --40
		invoiceheader.ivh_revtype2,     
		invoiceheader.ivh_revtype3,     
		invoiceheader.ivh_revtype4,     
		invoiceheader.ivh_totalweight,     
		invoiceheader.ivh_totalpieces,     
		invoiceheader.ivh_totalmiles,     
		invoiceheader.ivh_currency,     
		invoiceheader.ivh_currencydate,     
		invoiceheader.ivh_totalvolume,     
		invoiceheader.ivh_taxamount1,     --50
		invoiceheader.ivh_taxamount2,     
		invoiceheader.ivh_taxamount3,     
		invoiceheader.ivh_taxamount4,     
		invoiceheader.ivh_transtype,     
		invoiceheader.ivh_creditmemo,     
		invoiceheader.ivh_applyto,     
		invoiceheader.ivh_printdate,     
		invoiceheader.ivh_billdate,     
		invoiceheader.ivh_lastprintdate,     
		invoiceheader.ivh_originregion2,     --60
		invoiceheader.ivh_originregion3,     
		invoiceheader.ivh_originregion4,     
		invoiceheader.ivh_destregion2,     
		invoiceheader.ivh_destregion3,     
		invoiceheader.ivh_destregion4,     
		invoiceheader.mfh_hdrnumber,     
		invoiceheader.ivh_remark,     
		invoiceheader.ivh_driver,     
		invoiceheader.ivh_tractor,     
		invoiceheader.ivh_trailer,     --70
		invoiceheader.ivh_user_id1,     
		invoiceheader.ivh_user_id2,     
		invoiceheader.ivh_ref_number,     
		invoiceheader.ivh_driver2,     
		invoiceheader.mov_number,     
		invoiceheader.ivh_edi_flag,     
		invoiceheader.ord_hdrnumber,     
		invoicedetail.ivd_number,     
		invoicedetail.stp_number,     
		invoicedetail.ivd_description,     --80
		invoicedetail.cht_itemcode,     
		invoicedetail.ivd_quantity,     
		invoicedetail.ivd_rate,     
		invoicedetail.ivd_charge,
		ivd_taxable1 =IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),  
		ivd_taxable2 =IsNull(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
		ivd_taxable3 =IsNull(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
		ivd_taxable4 =IsNull(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
		invoicedetail.ivd_unit,     
		invoicedetail.cur_code,       --90
		invoicedetail.ivd_currencydate,     
		invoicedetail.ivd_glnum,     
		invoicedetail.ivd_type,     
		invoicedetail.ivd_rateunit,     
		invoicedetail.ivd_billto,     
		@temp_name ivd_billto_name,  
		@temp_addr ivd_billto_addr,  
		@temp_addr2 ivd_billto_addr2,  
		@temp_nmstct ivd_billto_nmctst,  
		invoicedetail.ivd_itemquantity,   -- 100   
		invoicedetail.ivd_subtotalptr,     
		invoicedetail.ivd_allocatedrev,     
		invoicedetail.ivd_sequence,     
		invoicedetail.ivd_refnum,     
		invoicedetail.cmd_code,     
		invoicedetail.cmp_id,     
		@temp_name stop_name,  
		@temp_addr stop_addr,  
		@temp_addr2 stop_addr2,  
		@temp_nmstct stop_nmctst,    --110
		invoicedetail.ivd_distance,      
		invoicedetail.ivd_distunit,     
		invoicedetail.ivd_wgt,     
		invoicedetail.ivd_wgtunit,     
		invoicedetail.ivd_count,     
		invoicedetail.ivd_countunit,     
		invoicedetail.evt_number,     
		invoicedetail.ivd_reftype,     
		invoicedetail.ivd_volume,     
		invoicedetail.ivd_volunit,     -- 120
		invoicedetail.ivd_orig_cmpid,     
		invoicedetail.ivd_payrevenue,
		cht_rollintoLH = coalesce(invoicedetail.cht_rollintoLH, 0),		-- PTS 50327 
		invoiceheader.ivh_freight_miles,  
		invoiceheader.tar_tarrIFfnumber,  
		invoiceheader.tar_tarIFfitem,  
		1 copies,  
		chargetype.cht_basis,  
		chargetype.cht_description,  
		commodity.cmd_name,  
		@temp_altid cmp_altid,  --130
		ivh_hideshipperaddr,     --130
		ivh_hideconsignaddr,  
		 ivh_showshipper,  
		ivh_showcons,  
		@temp_terms terms_name,  
		IsNull(ivh_charge,0) ivh_charge,  
		@temp_addr2    ivh_billto_addr3,  
		@varchar50 cmp_contact,  
		@varchar50 shipper_geoloc,  
		@varchar50 cons_geoloc,
		@varchar20 ord_ref1,   --140
		@varchar20 ord_ref2,
		@varchar20 ord_ref3,
		@varchar20 ord_ref4,
		@varchar20 ord_ref5,
		@varchar20 ord_ref6,
		@varchar20 ord_ref7,
		@misc4 cmp_misc4
INTO	#invtemp_tbl  
		
		
FROM	chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
		LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
		invoiceheader   
   
WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
		invoiceheader.ivh_hdrnumber = @invoice_nbr  

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
IF	(SELECT count(*) FROM #invtemp_tbl) = 0  
	BEGIN  
		SELECT @ret_value = 0    
		GOTO ERROR_END  
	END  

-- PTS 50327 start
/*     *******************ROLLINTOLH************************     */
/* Handle possible roll into lh */
select @rollintoLHAmt = sum(ivd_charge)
from #invtemp_tbl where cht_rollintolh = 1

select @rollintoLHAmt = isnull(@rollintoLHAmt,0)

If @rollintoLHAmt <> 0 and exists(select 1 from #invtemp_tbl where (ivd_type = 'SUB' or cht_itemcode = 'MIN') and ivd_quantity <> 0) 
  BEGIN 
      -- determine if a rate conversion factor is involved in the line haul rate
      If exists (select 1 from #invtemp_tbl where cht_itemcode = 'MIN')
        BEGIN
          select @rateconvertion = unc_factor
          from #invtemp_tbl ttbl
          join unitconversion on ivd_unit = unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
          where ttbl.cht_itemcode = 'MIN'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #invtemp_tbl
          set ivd_charge = 
            case cht_itemcode
            when 'MIN' then ivd_charge + @rollintoLHAmt
            else 0
            end,
          ivd_rate = 
            case ivd_quantity
            when 1 then round((ivd_charge + @rollintoLHAmt) / @rateconvertion,4)
            else round((ivd_charge + @rollintoLHAmt) / (@rateconvertion * ivd_quantity),4)
            end
          from #invtemp_tbl tmp
          where ivd_type = 'SUB' or cht_itemcode = 'MIN'
        END
            
      else 
        BEGIN
          select @rateconvertion = unc_factor
          from #invtemp_tbl ttbl
          join unitconversion on ivd_unit = unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
          where ttbl.ivd_type = 'SUB'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #invtemp_tbl
          set ivd_charge =  ivd_charge + @rollintoLHAmt,
          ivd_rate = 
            case ivd_quantity
            when 1 then round((ivd_charge + @rollintoLHAmt) / @rateconvertion,4)
            else round((ivd_charge + @rollintoLHAmt) / (@rateconvertion * ivd_quantity),4)
            end
          from #invtemp_tbl tmp
          where ivd_type = 'SUB'
        END

    delete from #invtemp_tbl where cht_rollintolh = 1

  END
/* End roll into lh */
/*     *******************ROLLINTOLH************************     */
-- PTS 50327 end

/* RETRIEVE COMPANY DATA */                         

IF Not Exists (SELECT cmp_mailto_name 
				 FROM company c, #invtemp_tbl t 
			    WHERE c.cmp_id = t.ivh_billto  
					  And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
                      And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
											CASE IsNull(cmp_mailtoTermsMatchFlag,'N') WHEN 'Y' THEN '^^' ELSE t.ivh_terms END)  
														And t.ivh_charge <> CASE IsNull(cmp_MailtToForLinehaulFlag,'Y') WHEN 'Y' THEN 0.00 ELSE ivh_charge + 1.00 END )   
  
UPDATE	#invtemp_tbl  
   SET	ivh_billto_name        = company.cmp_name,  
		ivh_billto_nmctst      = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid,  
		ivh_billto_addr        = company.cmp_address1,  
		ivh_billto_addr2       = company.cmp_address2,  
        ivh_billto_addr3       = company.cmp_address3,  
		cmp_contact            = company.cmp_contact,
		#invtemp_tbl.cmp_misc4  = company.cmp_misc4
  FROM	#invtemp_tbl, company  
 WHERE	company.cmp_id = #invtemp_tbl.ivh_billto  
  ELSE   
UPDATE	#invtemp_tbl  
   SET	ivh_billto_name        = company.cmp_mailto_name,  
		ivh_billto_addr        =  company.cmp_mailto_address1 ,  
		ivh_billto_addr2       = company.cmp_mailto_address2,     
		ivh_billto_nmctst      = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid ,
		cmp_contact            = company.cmp_contact  ,
		#invtemp_tbl.cmp_misc4 = company.cmp_misc4
  FROM	#invtemp_tbl, company  
 WHERE	company.cmp_id = #invtemp_tbl.ivh_billto  
 
UPDATE	#invtemp_tbl  
   SET	originpoint_name = company.cmp_name,  
		origin_addr	     = company.cmp_address1,  
		origin_addr2     = company.cmp_address2,  
		origin_nmctst    = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
  FROM	#invtemp_tbl, company, city  
 WHERE	company.cmp_id    = #invtemp_tbl.ivh_originpoint  
		and city.cty_code = #invtemp_tbl.ivh_origincity     
      
UPDATE	#invtemp_tbl  
   SET	destpoint_name = company.cmp_name,  
		dest_addr	   = company.cmp_address1,  
		dest_addr2	   = company.cmp_address2,  
		dest_nmctst    = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
  FROM	#invtemp_tbl, company, city  
 WHERE	company.cmp_id    = #invtemp_tbl.ivh_destpoint  
		and city.cty_code = #invtemp_tbl.ivh_destcity   
  
UPDATE	#invtemp_tbl  
   SET	shipper_name   = company.cmp_name,  
		shipper_addr   =  CASE ivh_hideshipperaddr WHEN 'Y' THEN '' ELSE company.cmp_address1 END,  
		shipper_addr2  = CASE ivh_hideshipperaddr WHEN 'Y' THEN '' ELSE company.cmp_address2 END,  
		shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
		Shipper_geoloc = IsNull(cmp_geoloc,'')  
  FROM	#invtemp_tbl, company  
 WHERE	company.cmp_id = #invtemp_tbl.ivh_showshipper  
  
-- There is no shipper city, so IF the shipper is UNKNOWN, use the origin city to get the nmstct
-- ONLY show stop city/state IF the show shipper city/state has no value
UPDATE	#invtemp_tbl  
   SET	shipper_nmctst = origin_nmctst  
  FROM	#invtemp_tbl  
 WHERE	rtrim(isnull(#invtemp_tbl.shipper_nmctst, ''))  = ''  
  
UPDATE	#invtemp_tbl  
   SET	consignee_name   = company.cmp_name,  
		consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
		consignee_addr   = CASE ivh_hideconsignaddr WHEN 'Y'THEN '' ELSE company.cmp_address1 END,      
		consignee_addr2  = CASE ivh_hideconsignaddr WHEN 'Y' THEN '' ELSE company.cmp_address2 END,  
		cons_geoloc      = IsNull(cmp_geoloc,'')  
  FROM	#invtemp_tbl, company  
 WHERE	company.cmp_id = #invtemp_tbl.ivh_showcons     
   
-- There is no consignee city, so IF the consignee is UNKNOWN, use the dest city to get the nmstct
-- ONLY show stop city/state IF the show consignee city/state has no value    
UPDATE	#invtemp_tbl  
   SET	consignee_nmctst = dest_nmctst  
  FROM	#invtemp_tbl  
 WHERE	rtrim(isnull(#invtemp_tbl.consignee_nmctst, ''))  = ''  
 
    
UPDATE	#invtemp_tbl  
   SET	stop_name  = company.cmp_name,  
		stop_addr  = company.cmp_address1,  
		stop_addr2 = company.cmp_address2  
  FROM	#invtemp_tbl, company  
 WHERE	company.cmp_id = #invtemp_tbl.cmp_id  
  
-- dpete for UNKNOWN companies with cities must get city name FROM city table pts5319   
UPDATE	#invtemp_tbl  
   SET  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
  FROM  #invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city   --pts40188 outer join conversion
 WHERE  #invtemp_tbl.stp_number IS NOT NULL  
		and stops.stp_number =  #invtemp_tbl.stp_number  
  
UPDATE	#invtemp_tbl  
   SET	terms_name = la.name  
  FROM	labelfile la  
 WHERE	la.labeldefinition = 'creditterms' 
		and la.abbr = #invtemp_tbl.ivh_terms 


    
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
SELECT @counter = 1  
	WHILE @counter <>  @copies  
		BEGIN  
			SELECT @counter = @counter + 1  
				INSERT INTO #invtemp_tbl  

     select ivh_invoicenumber,     
		ivh_hdrnumber,   
		ivh_billto,
       ivh_billto_name ,
		 ivh_billto_addr,  
		ivh_billto_addr2,           
		 ivh_billto_nmctst,  
		ivh_terms,      
		ivh_totalcharge,     
		ivh_shipper,     
		shipper_name,    --10
		shipper_addr,  
		shipper_addr2,  
		shipper_nmctst,  
		ivh_consignee,     
		consignee_name,  
		consignee_addr,  
		consignee_addr2,  
		consignee_nmctst,  
		ivh_originpoint,   --20
		originpoint_name,    
		origin_addr,  
		origin_addr2,  
		origin_nmctst,  
		ivh_destpoint,     
		destpoint_name,  
		dest_addr,  
		dest_addr2,  
		dest_nmctst,  
		ivh_invoicestatus,    --30 
	ivh_origincity,     
		ivh_destcity,     
		ivh_originstate,     
		ivh_deststate,  
		ivh_originregion1,     
		ivh_destregion1,     
		ivh_supplier,     
		ivh_shipdate,     
		ivh_deliverydate,     
		ivh_revtype1,       --40
		ivh_revtype2,     
		ivh_revtype3,     
		ivh_revtype4,     
		ivh_totalweight,     
		ivh_totalpieces,     
		ivh_totalmiles,     
		ivh_currency,     
		ivh_currencydate,     
		ivh_totalvolume,     
		ivh_taxamount1,   --50  
		ivh_taxamount2,     
		ivh_taxamount3,     
		ivh_taxamount4,     
		ivh_transtype,     
		ivh_creditmemo,     
		ivh_applyto,     
		ivh_printdate,     
		ivh_billdate,     
		ivh_lastprintdate,     
		ivh_originregion2,   --60  
		ivh_originregion3,     
		ivh_originregion4,     
		ivh_destregion2,     
		ivh_destregion3,     
		ivh_destregion4,     
		mfh_hdrnumber,     
		ivh_remark,     
		ivh_driver,     
		ivh_tractor,     
		ivh_trailer,     --70
		ivh_user_id1,     
		ivh_user_id2,     
		ivh_ref_number,     
		ivh_driver2,     
		mov_number,     
		ivh_edi_flag,     
		ord_hdrnumber,     
		ivd_number,     
		stp_number,     
		ivd_description, --80    
		cht_itemcode,     
		ivd_quantity,     
		ivd_rate,     
		ivd_charge,
		ivd_taxable1 , 
		ivd_taxable2 , 
		ivd_taxable3 ,
		ivd_taxable4 ,
		ivd_unit,     
		cur_code,     --90
ivd_currencydate,     
		ivd_glnum,     
		ivd_type,     
		ivd_rateunit,     
		ivd_billto,     
		 ivd_billto_name,  
		 ivd_billto_addr,  
		ivd_billto_addr2,  
		ivd_billto_nmctst,  
		ivd_itemquantity,  --100
		ivd_subtotalptr,    
		ivd_allocatedrev,     
		ivd_sequence,     
		ivd_refnum,     
		cmd_code,     
		cmp_id,     
		stop_name,  
		stop_addr,  
		stop_addr2,  
		stop_nmctst,  --110
		ivd_distance,     
		ivd_distunit,     
		ivd_wgt,     
		ivd_wgtunit,     
		ivd_count,     
		ivd_countunit,     
		evt_number,     
		ivd_reftype,     
		ivd_volume,     
		ivd_volunit,     --120
		ivd_orig_cmpid,     
        ivd_payrevenue,
		ivh_freight_miles,  
		tar_tarrIFfnumber,  
		tar_tarIFfitem,  
		@counter,  
		cht_basis,  
		cht_description,  
		cmd_name,  
        cmp_altid,    -- 130
		ivh_hideshipperaddr,     --130
		ivh_hideconsignaddr,  
		 ivh_showshipper,  
		ivh_showcons,  
		 terms_name,  
		 ivh_charge,  
		   ivh_billto_addr3,  
		cmp_contact,  
		shipper_geoloc,  
		 cons_geoloc,
		 ord_ref1,   --140
		ord_ref2,
		 ord_ref3,
		 ord_ref4,
		 ord_ref5,
		 ord_ref6,
		 ord_ref7,
		 cmp_misc4			
			FROM #invtemp_tbl  
		   WHERE copies = 1     
	END   
                                                                
  
SET		@last_seq = 0
SET		@next_seq = 0
SET		@i = 1
SELECT	@ord_hdr = (SELECT min(ord_hdrnumber) FROM #invtemp_tbl) 

WHILE	1=1
BEGIN
	SELECT	@next_seq = min(ref_sequence)
      FROM	referencenumber
     WHERE	/*ref_type = 'BL#' 
			AND*/ ref_table = 'orderheader' 
			AND ref_tablekey = @ord_hdr 
			AND ref_sequence > @last_seq


-- if @last_seq is null BREAK
IF @next_seq is null BREAK
	SELECT	@minref = ref_type+': '+ref_number 
      FROM	referencenumber 
     WHERE	/*ref_type = 'BL#' 
			AND*/ ref_table = 'orderheader' 
			AND ref_tablekey = @ord_hdr 
			AND ref_sequence = @next_seq

	IF @i > 7 BREAK
				SELECT @sql = 'update #invtemp_tbl set ord_ref'+ convert(varchar, @i) +' = ''' + @minref + ''''
				  EXEC sp_executesql @sql

	SELECT @i = @i +1
	SELECT @last_seq = @next_seq
END

ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */  
--SELECT *  
--FROM #invtemp_tbl  
  SELECT   
		ivh_invoicenumber,     
		ivh_hdrnumber,   
		ivh_billto,   
		ivh_billto_name ,  
		ivh_billto_addr,  
		ivh_billto_addr2,           
		ivh_billto_nmctst,  
		ivh_terms,      
		ivh_totalcharge,     
		ivh_shipper,     
		shipper_name,  
		shipper_addr,  
		shipper_addr2,  
		shipper_nmctst,  
		ivh_consignee,     
		consignee_name,  
		consignee_addr,  
		consignee_addr2,  
		consignee_nmctst,  
		ivh_originpoint,     
		originpoint_name,  
		origin_addr,  
		origin_addr2,  
		origin_nmctst,  
		ivh_destpoint,     
		destpoint_name,  
		dest_addr,  
		dest_addr2,  
		dest_nmctst,  
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
		ivh_originregion2,     
		ivh_originregion3,     
		ivh_originregion4,     
		ivh_destregion2,     
		ivh_destregion3,     
		ivh_destregion4,     
		mfh_hdrnumber,     
		ivh_remark,     
		ivh_driver,     
		ivh_tractor,     
		ivh_trailer,     
		ivh_user_id1,     
		ivh_user_id2,     
		ivh_ref_number,     
		ivh_driver2,     
		mov_number,     
		ivh_edi_flag,     
		ord_hdrnumber,     
		ivd_number,     
		stp_number,     
		ivd_description,     
		cht_itemcode,     
		ivd_quantity,     
		ivd_rate,     
		ivd_charge,     
		ivd_taxable1,     
		ivd_taxable2,     
		ivd_taxable3,     
		ivd_taxable4,     
		ivd_unit,     
		cur_code,     
		ivd_currencydate,     
		ivd_glnum,     
		ivd_type,     
		ivd_rateunit,     
		ivd_billto,    
		ivd_billto_name,  
		ivd_billto_addr,  
		ivd_billto_addr2,  
		ivd_billto_nmctst,  
		ivd_itemquantity,     
		ivd_subtotalptr,     
		ivd_allocatedrev,     
		ivd_sequence,     
		ivd_refnum,     
		cmd_code,   
		cmp_id,     
		stop_name,  
		stop_addr,  
		stop_addr2,  
		stop_nmctst,  
		ivd_distance,     
		ivd_distunit,     
		ivd_wgt,     
		ivd_wgtunit,     
		ivd_count,     
		ivd_countunit,     
		evt_number,     
		ivd_reftype,     
		ivd_volume,     
		ivd_volunit,     
		ivd_orig_cmpid,     
		ivd_payrevenue,
		ivh_freight_miles,  
		tar_tarrIFfnumber,  
		tar_tarIFfitem,  
		--vmj1+ @counter is constant for all rows!  
		copies,  
		--  @counter,  
		--vmj1-  
		cht_basis,  
		cht_description,  
		cmd_name,
		ord_ref1,
		ord_ref2,
		ord_ref3,
		ord_ref4,
		ord_ref5,
		ord_ref6,
		ord_ref7,
		cmp_misc4
		

 FROM #invtemp_tbl  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 SELECT @ret_value = @@ERROR   
return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[invoice_template145] TO [public]
GO
