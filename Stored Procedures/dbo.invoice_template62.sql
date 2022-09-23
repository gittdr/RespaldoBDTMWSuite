SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[invoice_template62](@p_invoice_nbr int,@p_copies int)
as

/*
 * 
 * NAME:invoice_templpate62
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices detials and number of copies required to print 
 * based invoicenumber and the number of copies selected in Invoiceselection interface.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND
 * 1 - IF SUCCESFULLY EXECUTED
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_invoice_nbr, int, input, null;
 *       invoice number used for the retrival of invoice details
 * 002 - @p_copies, int, input, null;
 *       number of required copies
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 2/2/99                               -add cmp_altid from useasbillto company to return set
 * 1/5/00     PTS6469 - dpete -  if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table
 * 06/29/2001 PTS 10870 - Vern Jewett - not returning copy # correctly.
 * 12/5/02    PTS 16314 - DPETE - use GI settings to control terms and linehaul restricitons on mail to
 * 04/07/2006 PTS 25002 - ILB - Ceate new invooice formatt for Truck Load Services
 **/

declare	@temp_name   varchar(30) ,
	@temp_addr   varchar(30) ,
	@temp_addr2  varchar(30),
	@temp_nmstct varchar(30),
	@temp_altid  varchar(8),
	@counter    int,
	@ret_value  int,
        @money      money,
        @rate       money,
        @gst_idnumber varchar(60),
        @qst_idnumber varchar(60),
        @ref_type varchar(20),
        @ref_number varchar(30),
        @MinRef varchar(30),
        @MinType varchar(20),
        @MinOrd int,
        @count int,
	@MinSeq int,
        @MinRefType varchar(6),
        @TypeDesc varchar(10),
        @TVQ_QST  varchar(30),
        @TPS_GST  varchar(30),
	@notes    varchar(254),
        @MinInvNumber varchar(18),
        @MinOrdString varchar(18),
	@MinNotNumber int,
        @Not_Text varchar(254)
   

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
 SELECT  invoiceheader.ivh_invoicenumber,   
         invoiceheader.ivh_hdrnumber, 
	 invoiceheader.ivh_billto, 
	 @temp_name ivh_billto_name ,
	 @temp_addr 	ivh_billto_addr,
	 @temp_addr2	ivh_billto_addr2,
	 @temp_nmstct ivh_billto_nmctst,
         invoiceheader.ivh_terms,   	
         invoiceheader.ivh_totalcharge,   
	 invoiceheader.ivh_shipper,   
	 @temp_name	shipper_name,
	 @temp_addr	shipper_addr,
	 @temp_addr2	shipper_addr2,
	 @temp_nmstct shipper_nmctst,
         invoiceheader.ivh_consignee,   
	 @temp_name consignee_name,
	 @temp_addr consignee_addr,
	 @temp_addr2	consignee_addr2,
	 @temp_nmstct consignee_nmctst,
         invoiceheader.ivh_originpoint,   
	 @temp_name originpoint_name,
	 @temp_addr origin_addr,
	 @temp_addr2	origin_addr2,
	 @temp_nmstct origin_nmctst,
         invoiceheader.ivh_destpoint,   
	 @temp_name destpoint_name,
	 @temp_addr dest_addr,
	 @temp_addr2	dest_addr2,
	 @temp_nmstct dest_nmctst,
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
         invoicedetail.ivd_taxable1,   
         invoicedetail.ivd_taxable2,   
	 invoicedetail.ivd_taxable3,   
         invoicedetail.ivd_taxable4,   
         invoicedetail.ivd_unit,   
         invoicedetail.cur_code,   
         invoicedetail.ivd_currencydate,   
         invoicedetail.ivd_glnum,   
         invoicedetail.ivd_type,   
         invoicedetail.ivd_rateunit,   
         invoicedetail.ivd_billto,   
	 @temp_name ivd_billto_name,
	 @temp_addr ivd_billto_addr,
	 @temp_addr2	ivd_billto_addr2,
	 @temp_nmstct ivd_billto_nmctst,
         invoicedetail.ivd_itemquantity,   
         invoicedetail.ivd_subtotalptr,   
         invoicedetail.ivd_allocatedrev,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_refnum,   
         invoicedetail.cmd_code,   
         invoicedetail.cmp_id,   
	 @temp_name	stop_name,
	 @temp_addr	stop_addr,
	 @temp_addr2	stop_addr2,
	 @temp_nmstct stop_nmctst,
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
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	(Case ivh_showshipper 
		when 'UNKNOWN' then invoiceheader.ivh_shipper
		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper) 
	end) ivh_showshipper,
	(Case ivh_showcons 
		when 'UNKNOWN' then invoiceheader.ivh_consignee
		else IsNull(ivh_showcons,invoiceheader.ivh_consignee) 
	end) ivh_showcons,
	IsNull(ivh_charge,0.0) ivh_charge,
        @money qst_total,
        @money gst_total,
        @rate qst_rate,
        @rate gst_rate,
        @gst_idnumber gst_number,
        @qst_idnumber qst_number,
        @ref_type ref_type1,
        @ref_number ref_number1,
	@ref_type ref_type2,
        @ref_number ref_number2,
	@ref_type ref_type3,
        @ref_number ref_number3,
	@ref_type ref_type4,
        @ref_number ref_number4,
        @temp_addr2 shipper_addr3,
        @temp_addr2 consignee_addr3,
        @temp_addr2 ivh_billto_addr3,
        @typedesc type_desc,
        @TVQ_QST qst_desc,
        @TPS_GST gst_desc,
        @notes Notes
    into #invtemp_tbl
    FROM invoiceheader join invoicedetail as invoicedetail on ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )
	 right outer join chargetype as chargetype on (chargetype.cht_itemcode = invoicedetail.cht_itemcode)
	 left outer join commodity as commodity on (invoicedetail.cmd_code = commodity.cmd_code)
	--invoiceheader, invoicedetail, chargetype, commodity

   WHERE invoiceheader.ivh_hdrnumber =  @p_invoice_nbr
	 --( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and
	 --(invoicedetail.cmd_code *= commodity.cmd_code) and

	-- ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
        -- ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
	-- ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
	-- ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
 	-- ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
  	-- ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
	-- ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	-- ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	-- ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
	-- (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
   	-- (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
	-- ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	-- (invoiceheader.ivh_billdate IS null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end


/* RETRIEVE COMPANY DATA */	                   			
--if @useasbillto = 'BLT'
--	begin
/*
	--	LOR	PTS#4789(SR# 7160)	
	If ((select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name = '') > 0 or
	     (select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is null) > 0 or
	     (select count(*)
		from #invtemp_tbl t, chargetype ch, company c
		where c.cmp_id = t.ivh_billto and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y') = 0 or
	     (select count(*) 
		from company c, chargetype ch, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is not null and
			c.cmp_mailto_name not in ('') and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y' and
			t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
		*/
  If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
        Where c.cmp_id = t.ivh_billto
			And Rtrim(IsNull(cmp_mailto_name,'')) > ''
			And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
				Case IsNull(cmp_mailtoTermsMatchFlag,'Y') When 'Y' Then '^^' ELse t.ivh_terms End)
			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	

		update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,
                         ivh_billto_addr3 = company.cmp_address3,		
			 ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	Else	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_mailto_name,
			 ivh_billto_addr = company.cmp_mailto_address1,
			 ivh_billto_addr2 = company.cmp_mailto_address2,		
			 ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + company.cmp_mailto_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
--	end	
/*		
if @useasbillto = 'ORD'
	begin
	update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company, invoiceheader
		where #invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
				company.cmp_id = invoiceheader.ivh_order_by
	end			
if @useasbillto = 'SHP'
	begin
	update #invtemp_tbl

		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_shipper
	end			
*/			
update #invtemp_tbl
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_originpoint
	and city.cty_code = #invtemp_tbl.ivh_origincity   
	
update #invtemp_tbl
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_destpoint
	and city.cty_code =  #invtemp_tbl.ivh_destcity 
				
update #invtemp_tbl
set shipper_name = company.cmp_name,
	shipper_addr = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,
	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
        shipper_addr3 = isnull(company.cmp_address3,''),
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip 
from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.ivh_shipper
where company.cmp_id = #invtemp_tbl.ivh_showshipper

-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct  
update #invtemp_tbl
set shipper_nmctst = origin_nmctst
from #invtemp_tbl
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'
								
update #invtemp_tbl
set consignee_name = company.cmp_name,
	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	consignee_addr3 = isnull(company.cmp_address3,''),
	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.ivh_consignee
where company.cmp_id = #invtemp_tbl.ivh_showcons
				
	
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct  
update #invtemp_tbl
set consignee_nmctst = dest_nmctst
from #invtemp_tbl
where #invtemp_tbl.ivh_consignee = 'UNKNOWN'	
		
update #invtemp_tbl
set stop_name = company.cmp_name,
	stop_addr = company.cmp_address1,
	stop_addr2 = company.cmp_address2
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.cmp_id

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
update #invtemp_tbl
set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from 	#invtemp_tbl, stops
        right outer join city as city on (city.cty_code = stops.stp_city)
where 	#invtemp_tbl.stp_number IS NOT NULL
	and stops.stp_number = #invtemp_tbl.stp_number
	--and	city.cty_code =* stops.stp_city

select @gst_idnumber = gi_string1     
  from generalinfo
 where upper(gi_name) = 'GSTNUMBER'

select @qst_idnumber = gi_string1     
  from generalinfo
 where upper(gi_name) = 'QSTNUMBER'

update #invtemp_tbl
   set type_desc = CASE 
			WHEN ivd_type = 'DRP' THEN 'Delivery'
			WHEN ivd_type = 'PUP' THEN 'Pickup'
			ELSE ''
		   END
update #invtemp_tbl
   set gst_number = @gst_idnumber,
       qst_number = @qst_idnumber

Update #invtemp_tbl
   set gst_total = ivd.ivd_charge,
       gst_rate  = ivd.ivd_rate
  from invoicedetail ivd
 where ivd.ivh_hdrnumber = @p_invoice_nbr and
       ivd.cht_itemcode = 'GST'

Update #invtemp_tbl
   set qst_total = ivd.ivd_charge,
       qst_rate  = ivd.ivd_rate
  from invoicedetail ivd
 where ivd.ivh_hdrnumber = @p_invoice_nbr and
       ivd.cht_itemcode = 'TAX3'

Select @TVQ_QST = cht_description
  From #invtemp_tbl
 Where upper(cht_itemcode) = 'QST'

Update #invtemp_tbl
   Set qst_desc = @TVQ_QST 

Select @TPS_GST = cht_description
  From #invtemp_tbl
 Where upper(cht_itemcode) = 'GST'

Update #invtemp_tbl
   Set gst_desc = @TPS_GST 



--04/18/2005
set @minord = 0
select @minord = MIN(ord_hdrnumber) FROM #invtemp_tbl
Select @MinInvNumber = MIN(ivh_invoicenumber) FROM #invtemp_tbl
SELECT @MinOrdString = cast(@MinOrd as varchar(18))
   SET @MinNotNumber = 0
   SET @NOT_TEXT = ''
   SET @NOTES = ''

WHILE (SELECT COUNT(*) 
         FROM notes 
        WHERE not_number > @MinNotNumber and 
              nre_tablekey = @MinOrdString and               
              UPPER(not_type) = 'B' and --billing invoices only
              UPPER(not_viewlevel) = 'E') > 0 --OK to print

	     BEGIN		      	       		
		
	       SELECT @MinNotNumber = (SELECT MIN(not_number)
				         FROM notes 
        			        WHERE not_number > @MinNotNumber and 
              				      nre_tablekey  = @MinOrdString and               
              				      UPPER(not_type) = 'B' and 
              				      UPPER(not_viewlevel) = 'E') 	

		SELECT @NOT_TEXT = not_text
                  FROM NOTES
                 WHERE NOT_NUMBER = @MinNotNumber

		SELECT @NOTES = @NOTES + @NOT_TEXT
	    END

UPDATE #invtemp_tbl
   SET notes = @notes
--04/18/2005

   SET @MinRef = ''
   SET @count = 0
   SET @MinType = ''
   SET @MinRefType = ''
   SET @MinSeq = 0

WHILE (SELECT COUNT(*) 
         FROM referencenumber 
        WHERE ref_sequence > @Minseq and 
              ref_tablekey = @MinOrd and 
              ref_table = 'orderheader' ) > 0

	     BEGIN	   	    

               SELECT @count = @count + 1	
		
	       SELECT @MinSeq = (SELECT MIN(ref_sequence) 
			    	   FROM referencenumber 
				  WHERE ref_sequence > @MinSeq and 
					ref_tablekey = @MinOrd and 
					ref_table = 'orderheader')	       
		       
	       SELECT @MinRefType = (SELECT ref_type 
			    	   FROM referencenumber 
				  WHERE ref_sequence = @MinSeq and 
					ref_tablekey = @MinOrd and 
					ref_table = 'orderheader')
		
	      SELECT @MinRef = (select ref_number
                 		  FROM referencenumber
                		 WHERE ref_sequence = @MinSeq and 
		        	       ref_tablekey = @MinOrd and 
		         	       ref_table = 'orderheader')	       

	       SELECT @MinType = labelfile.Name
                 FROM labelfile
                WHERE labelfile.abbr = @MInRefType and
                      labelfile.labeldefinition = 'ReferenceNumbers'   
	
		IF @count = 1
		BEGIN         
	 		UPDATE #invtemp_tbl
            		   SET REF_TYPE1 = @MinType,
          		       REF_NUMBER1 = @MinRef
                END
		
		IF @count = 2
		BEGIN         
	 		UPDATE #invtemp_tbl
            		   SET REF_TYPE2 = @MinType,
          		       REF_NUMBER2 = @MinRef
                END

		IF @count = 3
		BEGIN       
	 		UPDATE #invtemp_tbl
            		   SET REF_TYPE3 = @MinType,
          		       REF_NUMBER3 = @MinRef
                END

		IF @count = 4
		BEGIN			         
	 		UPDATE #invtemp_tbl
            		   SET REF_TYPE4 = @MinType,
          		       REF_NUMBER4 = @MinRef
			BREAK
                END
	       
		SET @MinType = ''
                SET @MinRef = ''
		SET @MinRefType = ''
	     END		
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @counter = 1
while @counter <>  @p_copies
begin
	select @counter = @counter + 1
	insert into #invtemp_tbl
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
	 tar_tarriffnumber,
	 tar_tariffitem,
	 @counter,
	 cht_basis,
	 cht_description,
	 cmd_name,
	cmp_altid,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,
	IsNull(ivh_charge,0) ivh_charge,
        isnull(qst_total,0)qst_total,
        isnull(gst_total,0)gst_total,
        isnull(qst_rate,0)qst_rate,
        isnull(gst_rate,0)gst_rate,
        gst_number,
        qst_number,
        ref_type1,
        ref_number1,
	ref_type2,
        ref_number2,
	ref_type3,
        ref_number3,
	ref_type4,
        ref_number4,
	shipper_addr3,
        consignee_addr3,
	ivh_billto_addr3,
        type_desc,
	qst_desc,
        gst_desc,
        notes
	from #invtemp_tbl
	where @p_copies = 1 and
              cht_itemcode NOT IN ('TAX3','GST') 
end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select   ivh_invoicenumber,   
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
	 tar_tarriffnumber,
	 tar_tariffitem,

	 --vmj1+	@counter is constant for all rows!
	 @p_copies,
--	 @counter,
	 --vmj1-
	 cht_basis,
	 cht_description,
	 cmd_name,
	ivh_showshipper,
	ivh_showcons,
        isnull(qst_total,0)qst_total,
        isnull(gst_total,0)gst_total,
        isnull(qst_rate,0)qst_rate,
        isnull(gst_rate,0)gst_rate,
 	gst_number,
        qst_number,
	ref_type1,
        ref_number1,
	ref_type2,
        ref_number2,
	ref_type3,
        ref_number3,
	ref_type4,
        ref_number4,
        shipper_addr3,
        consignee_addr3,
	ivh_billto_addr3,
        type_desc,
        qst_desc,
        gst_desc,
        notes
from #invtemp_tbl
where cht_itemcode NOT IN ('TAX3','GST')

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template62] TO [public]
GO
