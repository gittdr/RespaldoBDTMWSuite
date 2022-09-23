SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[invoice_template97](@p_ivh_hdrnumber int, @p_copies int)
as

/**
 * 
 * NAME:
 * dbo.invoice_template97
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
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
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @p_copies, int, input, null;
 *       This parameter indicates the number of hard copies 
 *       to print. The value must be non-null and 
 *       non-empty. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 *
 * REVISION HISTORY:
 * 03/01/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 07/24/2006.01 - PTS33638 - Phil Bidinger - History of this template34:
 * 2/2/99 add cmp_altid from useasbillto company to return set
 * 1/5/00 dpete PTS6469 if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table
 * 06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
 * 12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * End of History for template34
 *
 * 07/24/2006.02 - PTS33638 - Phil Bidinger - New format for Jack B Kelley, based off format34.
 * 05/01/2007.01 - PTS36305 - Michalynn Kelly - changes made to prevent bad data returns on non order invoices.  Also changed the trailer temp table
 * to pull all trailers associated with the move instead of the order.  Changed the ShipDate and DelDate to populate ivh dates
 * when the invoice was not linked to an order.  Added cht_remarks.  Also expanded temp_name, temp_addr, temp_addr2 to prevent 
 * truncating
 * 05/14/2007.01 - PTS36305 - When terms are unknown on misc invoice the terms on the format is blank, added update to temp table to look at
 * billto company profile for terms when ivh_terms = 'UNK' 
 * 06/06/2007.01 - PTS36305 - Updated trailer temp table to show trailers in sort order descending
 * 1/3/08 BDH PTS 40627  added cht_primary & cht_rollintolh.
 * 4/17/08 BDH PTS 41959 - Cust uses minimun charges and they were not rolling into linehaul.  If cht_itemcode for the record = 'MINACC', choose the previous cht_itemcode.
	i.e. the cht_itemcode for Carrier Trailer is CT and CT is rollintolh.  However, when using the minimum Carrier Trailer charge, the cht_itemcode will be 'MINACC' which is not rollintolh.
	Here, we need to get the previous cht_itemcode which is CT and will rollintolh.
 **/  

declare	@temp_name   varchar(50) ,
	@temp_addr   varchar(50) ,
	@temp_addr2  varchar(50),
	@temp_nmstct varchar(30),
	@temp_altid  varchar(25),
	@counter    int,
	@ret_value  int,
-- RE - 5/16/03 - PTS #17427
--	@temp_misc4	varchar(255),
	@temp_routing2 varchar(255),
	@temp_billtoterms varchar(3),
	@v_reflabel varchar(20),
	@v_date DATETIME,
	@v_fgtquantity FLOAT,
	@v_next int , --PTS33638
	@v_trailers varchar(255), --PTS33638
    @v_ordhdrnumber int,  --PTS 44288
    @v_cmdname varchar(60) -- PTD 44289

declare @trailers table (trailer varchar(13) null)
DECLARE @trailers2 table (trailer VARCHAR(13) NULL)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1
-- 44288 replace update of trailers below with faster version 
select @v_ordhdrnumber = ord_hdrnumber from invoiceheader where ivh_hdrnumber = @p_ivh_hdrnumber

select @v_trailers = ''
If @v_ordhdrnumber > 0  
BEGIN
   INSERT INTO @trailers
   SELECT DISTINCT evt_trailer1
     FROM event
    WHERE evt_mov_number IN (SELECT DISTINCT mov_number
                               FROM stops
                              WHERE ord_hdrnumber = @v_ordhdrnumber) AND
          evt_trailer1 <> 'UNKNOWN'

   INSERT INTO @trailers
   SELECT DISTINCT evt_trailer2
     FROm event
    WHERE evt_mov_number IN (SELECT DISTINCT mov_number
                               FROM stops
                              WHERE ord_hdrnumber = @v_ordhdrnumber) AND
          evt_trailer2 <> 'UNKNOWN'

   INSERT INTO @trailers2
   SELECT DISTINCT trailer
     FROM @trailers

   SELECT @v_trailers = @v_trailers + trailer + ','
     FROM @trailers2

   SET @v_trailers = LEFT(@v_trailers, (LEN(@v_trailers) - 1))

END
-- 44288 current format disaplays a "first cmd_name" made sure that value has a commodity in any row by plugging all rows with the name
-- of the first commodity delivered.
if @v_ordhdrnumber > 0 
   select @v_cmdname = (select top 1 stp_description 
   from stops where ord_hdrnumber = @v_ordhdrnumber and stp_type = 'DRP' order by stp_sequence)
else
   select @v_cmdname = ''

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
 SELECT  invoiceheader.ivh_invoicenumber,   
         invoiceheader.ivh_hdrnumber, 
	 invoiceheader.ivh_billto, 
	 @temp_name ivh_billto_name ,
	 @temp_addr 	ivh_billto_addr,
	 @temp_addr2	ivh_billto_addr2,
	 @temp_nmstct ivh_billto_nmctst,
         invoiceheader.ivh_terms ,   	
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
		-- BDH 41959 If ID = 'MINACC' we need the previous itemcode
		--invoicedetail.cht_itemcode,   --41959
		(case invoicedetail.cht_itemcode
			when 'MINACC' then
				(select cht_itemcode from invoicedetail ivd2
				where ivh_hdrnumber = @p_ivh_hdrnumber
				and ivd_sequence = invoicedetail.ivd_sequence - 1)	
			else invoicedetail.cht_itemcode
			end) cht_itemcode,  	-- 41959 end
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
	 chargetype.cht_remark,  --Added by MRK for PTS #36305
	 @v_cmdname cmd_name, -- format 97 has strange requirement to be sure only first commodity displays  commodity.cmd_name,
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
-- RE - 5/15/03 - PTS #17427
--	@temp_misc4 billto_misc4,
	@temp_routing2 billto_routing2,
	@temp_billtoterms billto_terms,
	IsNull(ivh_charge,0.0) ivh_charge,
        -- PRB added revtype fields
	@v_reflabel revtype3_t, 
	@v_reflabel revtype4_t,
	@v_reflabel revtype1_t,
	@v_date shpdate,
	@v_date deldate,
	invoiceheader.ivh_attention,
	@v_trailers trailers,
	@v_fgtquantity fgtquantity,
	chargetype.cht_primary,  -- BDH 40627
	chargetype.cht_rollintolh cht_rollintolh, -- BDH 40627
    invoicedetail.tar_number tar_number
    into #invtemp_tbl
    FROM invoiceheader
	 JOIN invoicedetail ON invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
	 RIGHT OUTER JOIN chargetype ON chargetype.cht_itemcode = invoicedetail.cht_itemcode
         LEFT OUTER JOIN commodity ON invoicedetail.cmd_code = commodity.cmd_code
   WHERE --(invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and
	 --(invoicedetail.cmd_code *= commodity.cmd_code) and
	  invoiceheader.ivh_hdrnumber = @p_ivh_hdrnumber
	 -- AND invoicedetail.ivd_type IN ('DRP', 'SUB', 'LI')

-- BDH 41959
-- Because with a minimum charge, the itemcode on the invoicedetail may be that of the miminum charge and not the actual ivd_desc. 
update #invtemp_tbl 
set cht_primary = chargetype.cht_primary,
	cht_rollintolh = chargetype.cht_rollintolh 
from chargetype where chargetype.cht_itemcode = #invtemp_tbl.cht_itemcode
-- 41959 end
--44288
if exists (select 1 from #invtemp_tbl where cht_itemcode = 'MINACC')
  update #invtemp_tbl 
  set cht_rollintolh = chargetype.cht_rollintolh
  from tariffheader join chargetype on tariffheader.cht_itemcode = chargetype.cht_itemcode
  where  tariffheader.tar_number = #invtemp_tbl.tar_number
  and #invtemp_tbl.cht_itemcode = 'MINACC'


/* 44288 replaced with code above
--  This section grabs trailers involved to put into comma seperated list per Jack B Kelley.  
--  Modified by MRK for PTS #36305 to create the trailer list based on move number instead of order number. 
CREATE TABLE #temptrailers1
(
  trailer varchar(13) NULL,
  --trailer2 varchar(13) NULL,
  evt_mov_number INT NOT NULL,
  trailer_ident INT identity
)

CREATE TABLE #temptrailers2
(
  trailer varchar(13) NULL,
  --trailer2 varchar(13) NULL,
  evt_mov_number INT NOT NULL,
  trailer_ident INT identity
)

INSERT #temptrailers1
Select evt_trailer1,
		--evt_trailer2,
		evt_mov_number 
From event
Where event.evt_mov_number = (Select Min(mov_number) 
			 From #invtemp_tbl) 
INSERT #temptrailers1
Select --evt_trailer1,
		evt_trailer2,
		evt_mov_number 
From event
Where event.evt_mov_number = (Select Min(mov_number) 
			 From #invtemp_tbl) 
--order by evt_trailer1, evt_trailer2

INSERT #temptrailers2
Select distinct trailer,
		evt_mov_number 
From #temptrailers1
order by trailer



 

Select @v_next = Min(trailer_ident) From #temptrailers2     
Select @v_next = IsNull(@v_next,0)
Select @v_trailers = ''
While @v_next > 0
 BEGIN  

--invoice_template97 1125,1
--select  * from event where evt_mov_number = 1086  
   SELECT @v_trailers = CASE RIGHT(@v_trailers,1)
			  WHEN '' THEN ''
			  WHEN 'N' THEN ''
			  WHEN ',' then @v_trailers
			  ELSE @v_trailers + ','
                        END
            		+ CASE trailer 
			    WHEN '' THEN ''
			    WHEN 'UNKNOWN' THEN ''
			    ELSE  trailer --+ ','
		          END
	    		
   from #temptrailers2  
   where  trailer_ident = @v_next
   select  @v_next = min(trailer_ident) from #temptrailers2 where trailer_ident > @v_next 

 END



DROP TABLE #temptrailers1
DROP TABLE #temptrailers2



If right(@v_trailers,1) = ','
Select @v_trailers = substring(@v_trailers,1,datalength(@v_trailers) -1)

 End Trailer list section */


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
	-- LOR	PTS#4789(SR# 7160)	
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
			ch.cht_primary = 'Y' and ch.cht_basis='SHP') = 0 or
	     (select count(*) 
		from company c, chargetype ch, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is not null and
			c.cmp_mailto_name not in ('') and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y' and
			ch.cht_basis='SHP' and
			t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
		*/
	If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
        Where c.cmp_id = t.ivh_billto
			And Rtrim(IsNull(cmp_mailto_name,'')) > ''
			And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
				Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)		
	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,
-- RE - 5/16/03 - PTS #17427
--			 billto_misc4 = company.cmp_misc4,
			 billto_routing2 = company.cmp_image_routing2,
			 billto_terms = company.cmp_terms
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	Else	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_mailto_name,
			 ivh_billto_addr = company.cmp_mailto_address1,
			 ivh_billto_addr2 = company.cmp_mailto_address2,		
			 ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + company.cmp_mailto_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid,
-- RE - 5/16/03 - PTS #17427
--			 billto_misc4 = company.cmp_misc4,
			 billto_routing2 = company.cmp_image_routing2,
			 billto_terms = company.cmp_terms
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

--PRB Added code here to grab 1st LLD stops shipper.
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
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip
from #invtemp_tbl join  company on #invtemp_tbl.ivh_showshipper = company.cmp_id
/*
from #invtemp_tbl, company, stops
--where company.cmp_id = #invtemp_tbl.ivh_shipper	
where stops.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
AND  company.cmp_id = stops.cmp_id
--AND  stops.stp_number =  #invtemp_tbl.stp_number
AND  stp_event IN ('LLD', 'HPL')
AND stp_sequence = (SELECT MIN(stp_sequence)
		    FROM stops
		    WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
		    AND stp_event IN ('LLD', 'HPL'))

        -- PRB do this in case first stop is not a LLD or HPL.
	IF Exists(SELECT 1 FROM #invtemp_tbl WHERE shipper_name IS NULL OR shipper_name = 'UNKNOWN')
	BEGIN
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
		shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip
	from #invtemp_tbl, company
	--where company.cmp_id = #invtemp_tbl.ivh_shipper	
	where company.cmp_id = #invtemp_tbl.ivh_showshipper
	END
*/
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct  
update #invtemp_tbl
set shipper_nmctst = origin_nmctst
from #invtemp_tbl
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'
				
--PRB correction on Consignee to get Last LUL or DRL
update #invtemp_tbl
set consignee_name = company.cmp_name,
	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip,
	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end
from #invtemp_tbl, company, stops
--where company.cmp_id = #invtemp_tbl.ivh_consignee	
where stops.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
AND  company.cmp_id = stops.cmp_id
--AND  stops.stp_number =  #invtemp_tbl.stp_number
AND  stp_event IN ('LUL', 'DRL')
AND  stp_sequence = (SELECT MAX(stp_sequence)
		    FROM stops
		    WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
		    AND stp_event IN ('LUL', 'DRL'))	

	--In case consignee doesn't have LUL or DRL
	IF Exists(SELECT 1 FROM #invtemp_tbl WHERE consignee_name IS NULL OR consignee_name = 'UNKNOWN')  
	BEGIN
	   update #invtemp_tbl
		set consignee_name = company.cmp_name,
		consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip,
		consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
		consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end
	  from #invtemp_tbl, company
	  --where company.cmp_id = #invtemp_tbl.ivh_consignee	
	  where company.cmp_id = #invtemp_tbl.ivh_showcons	
	END
	
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
from 	#invtemp_tbl
	JOIN stops ON stops.stp_number =  #invtemp_tbl.stp_number
	RIGHT OUTER JOIN city ON city.cty_code = stops.stp_city
where 	#invtemp_tbl.stp_number IS NOT NULL
	--and	stops.stp_number =  #invtemp_tbl.stp_number
	--and	city.cty_code =* stops.stp_city

update	#invtemp_tbl
   set	ivd_description = case isnull(stp_comment, '')
							when '' then ivd_description
							else rtrim(ivd_description) + ' - ' + stp_comment
						  end
  from	stops
 where	#invtemp_tbl.stp_number = stops.stp_number and
		rtrim(ivd_description) = 'Route Point'

update #invtemp_tbl
   set fgtquantity = (SELECT SUM(ISNULL(fgt_quantity, 0.0)) 
		       FROM stops s
		       LEFT OUTER JOIN freightdetail f
		       ON s.stp_number = f.stp_number
		       WHERE s.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
		       AND s.stp_event IN ('LLD', 'HPL'))
WHERE ivd_sequence = 1
--Added by PTS36305 mrk If ivh_terms are unknown, get terms from billto company profile
update #invtemp_tbl
    set ivh_terms = Case when ivh_terms = 'UNK' 
		    then (select cmp_terms from company where cmp_id = #invtemp_tbl.ivh_billto)
		    else ivh_terms
	end
--End PTS36305 for ivh_terms update
delete from #invtemp_tbl
WHERE (stp_number > (SELECT MIN(stp_number) FROM #invtemp_tbl) AND stp_number IS NOT NULL)


delete from #invtemp_tbl
WHERE evt_number = (SELECT MIN(evt_number) FROM #invtemp_tbl) AND ivd_sequence > (SELECT MIN(ivd_sequence) FROM #invtemp_tbl
										  WHERE evt_number = (SELECT MIN(evt_number) FROM #invtemp_tbl))
				
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
         ISNULL(ivh_remark, ''),   
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
	 cht_remark, --Added by MRK for PTS #36305 to show remarks for each chargetype
	 cmd_name,
	 cmp_altid,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,
-- RE - 5/16/03 - PTS #17427
--	billto_misc4,
	billto_routing2,
	billto_terms,
	ivh_charge,
        -- PRB added revtype fields
        'RevType3' revtype3_t, 
	'RevType4' revtype4_t,
	'RevType1' revtype1_t,
	shpdate = Case when ord_hdrnumber = 0 then ivh_shipdate
		  Else (SELECT MIN(stp_arrivaldate) FROM stops
		   WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
		   AND stp_event IN ('LLD', 'HPL'))
		  end,
	deldate = Case when ord_hdrnumber = 0 then ivh_deliverydate
		  Else(SELECT MAX(stp_departuredate) FROM stops
		   WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
 		   AND stp_event IN ('LUL', 'DRL'))
		  end, 
	ISNULL(ivh_attention, '') ivh_attention,
	trailers = @v_trailers,
	ISNULL(fgtquantity, 0.0),
	--fgtquantity = (SELECT SUM(ISNULL(fgt_quantity, 0.0)) 
	--	       FROM stops s
	--	       LEFT OUTER JOIN freightdetail f
	--	       ON s.stp_number = f.stp_number
	--	       WHERE s.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
	--	       AND s.stp_event IN ('LLD', 'HPL'))
	cht_primary,  -- BDH 40627
	cht_rollintolh , -- BDH 40627
    tar_number
	from #invtemp_tbl
	where copies = 1   
	end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
--select *
--from #invtemp_tbl
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
         ISNULL(ivh_remark, ''),   
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
	 copies,
--	 @counter,
	 --vmj1-
	 cht_basis,
	 cht_description,
	 cht_remark, --Added by MRK for PTS #36305 to show remarks for each charge type
	 cmd_name,
	cmp_altid,
	ivh_showshipper,
	ivh_showcons,
-- RE - 5/16/03 - PTS #17427
--	billto_misc4,
	billto_routing2,
	billto_terms,
        'RevType3' revtype3_t, 
	'RevType4' revtype4_t,
	'RevType1' revtype1_t,
	--Modified by MRK for PTS #36305 to handle non order invoices
        shpdate = Case when ord_hdrnumber = 0 then ivh_shipdate
		  Else (SELECT MIN(stp_arrivaldate) FROM stops
		   WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
		   AND stp_event IN ('LLD', 'HPL'))
		  end,
	--Modified by MRK for PTS #36305 to handle non order invoices
	deldate = Case when ord_hdrnumber = 0 then ivh_deliverydate
	          Else (SELECT MAX(stp_departuredate) FROM stops
		   WHERE ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
 		   AND stp_event IN ('LUL', 'DRL'))
                  end,
	--end date modificaitons for PTS36305
	ISNULL(ivh_attention, '') ivh_attention,
	trailers = @v_trailers,
	--trailers = (SELECT TOP 1 l.lgh_primary_trailer + 
        --                 (CASE l.lgh_primary_pup WHEN 'UNKNOWN' THEN ' ' ELSE ', ' + l.lgh_primary_pup END)
	--   	   FROM legheader l
	--           WHERE mov_number = #invtemp_tbl.mov_number),
	ISNULL(fgtquantity, 0.0),
	cht_primary,  -- BDH 40627
	cht_rollintolh  -- BDH 40627
    -- tar_number not returned
	from #invtemp_tbl
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value





GO
GRANT EXECUTE ON  [dbo].[invoice_template97] TO [public]
GO
