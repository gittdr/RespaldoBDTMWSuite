SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_trimac_template2](@invoice_no_lo  int,
					    @invoice_no_hi  int,
					  @invoice_status varchar(10),
					  @revtype1       varchar(6),
					  @revtype2       varchar(6),
					  @revtype3       varchar(6),
					  @revtype4       varchar(6),
					  @billto         varchar(8),
						@shipper        varchar(8),
					  @consignee      varchar(8),
					  @shipdate1      datetime,
					  @shipdate2      datetime,
					  @deldate1       datetime,
					  @deldate2       datetime,
					  @billdate1      datetime,
					  @billdate2      datetime,
					  @copies         int,  
					  @queue_number   int,
					  @useasbillto    varchar(3))

as

/*      PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
*/


declare @temp_name         varchar(30) ,
	@temp_addr         varchar(30) ,
	@temp_addr2        varchar(30),
	@temp_nmstct       varchar(30),
	@counter           int,
	@ret_value         int,
	@temp_account_no   varchar(8),
	@temp_load_point   varchar(20),
	@temp_unload_point varchar(20),
	@temp_load_date    datetime,
	@temp_shipper_no   varchar(30),
	@temp_your_no      varchar(30),
	@temp_fgt_number   int,
	@temp_brn_namne    varchar(40),
	@temp_brn_address  varchar(40),
	@temp_brn_address1 varchar(40),
	@temp_brn_city     varchar(40),
	@temp_brn_state    char(2),
	@temp_brn_zip      varchar(7),
	@temp_brn_phone    varchar(12),
	@temp_tax_id       varchar(12),
	@temp_shipper_altid     varchar(8),
	@temp_consignee_altid   varchar(8),
	@temp_billto_altid      varchar(8),
	@temp_arcurrency   varchar(6),
	@temp_currency     varchar(6),
	@temp_rate_exchange money,
	@minstp            int,
	@minfgt            int,
	   @minord            int,
	@rate_ex           money,
	 @temp_curr         varchar(12),
	@temp_arcurr       varchar(12),
	@temp_dte          datetime,
	@temp_string       char(12)
			
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1


/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/

 SELECT  invoiceheader.ivh_invoicenumber,   
	 invoiceheader.ivh_hdrnumber, 
	 invoiceheader.ivh_billto,
	 @temp_account_no acct_no,
	 @temp_name ivh_billto_name ,
	 @temp_addr ivh_billto_addr,
	 @temp_addr2    ivh_billto_addr2,
	 @temp_nmstct ivh_billto_nmctst,                      
	 invoiceheader.ivh_terms,       
	 invoiceheader.ivh_totalcharge,
	 invoiceheader.ivh_archarge,   
	 invoiceheader.ivh_shipper,   
	 @temp_name     shipper_name,
	 @temp_addr     shipper_addr,
	 @temp_addr2    shipper_addr2,
	 @temp_nmstct shipper_nmctst,
	 invoiceheader.ivh_consignee,   
	 @temp_name consignee_name,
	 @temp_addr consignee_addr,
	 @temp_addr2    consignee_addr2,
	 @temp_nmstct consignee_nmctst,
	 invoiceheader.ivh_originpoint,   
	 @temp_name originpoint_name,
	 @temp_addr origin_addr,
	 @temp_addr2    origin_addr2,
	 @temp_nmstct origin_nmctst,
	 invoiceheader.ivh_destpoint,   
	 @temp_name destpoint_name,
	 @temp_addr dest_addr,
	 @temp_addr2    dest_addr2,
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
	 invoiceheader.ivh_arcurrency,   
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
	 invoiceheader.ord_number,   
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
	 @temp_addr2    ivd_billto_addr2,
	 @temp_nmstct ivd_billto_nmctst,
	 invoicedetail.ivd_itemquantity,   
	 invoicedetail.ivd_subtotalptr,   
	 invoicedetail.ivd_allocatedrev,   
	 invoicedetail.ivd_sequence,   
	 invoicedetail.ivd_refnum,   
	 invoicedetail.cmd_code,   
	 invoicedetail.cmp_id,   
	 @temp_name     stop_name,
	 @temp_addr     stop_addr,
	 @temp_addr2    stop_addr2,
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
-- replaced invoiceheader.tar_tarriffnumber with invoiceheader.tar_number
-- VJ 01/23/97
	 invoiceheader.tar_number,
	 invoiceheader.tar_tariffitem,
	 1 copies,
	 chargetype.cht_basis,
	 chargetype.cht_description,
	 commodity.cmd_name,
	 @temp_load_point load_point,
	 @temp_unload_point unload_point,
	 @temp_load_date load_date,
	 @temp_shipper_no shipper_wb_no ,
	 @temp_your_no  your_order_no,
	 @temp_fgt_number fgt_number,
	 @temp_brn_namne  brn_name,
	 @temp_brn_address  brn_address,
	 @temp_brn_address1 brn_address1,

	 @temp_brn_city     brn_city,
	 @temp_brn_state    brn_state,
	 @temp_brn_zip      brn_zip,
	 @temp_brn_phone    brn_phone,
	 @temp_tax_id       brn_tax_id,
	 @temp_shipper_altid shipper_altid,
	 @temp_consignee_altid consignee_altid,
	 @temp_billto_altid  billto_altid,
	 @temp_arcurrency arcurrency,
	 @temp_currency   currency /*,
	 @temp_rate_exchange rate_exchange*/

    INTO #invtemp_tbl
    FROM chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
			LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code , --pts40188 outer join conversion
		invoiceheader
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
	 ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
	 ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
	 ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and                         
	 ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
	 ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
	 ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	 ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	 ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
	 (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
	 (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
	 ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	 (invoiceheader.ivh_billdate IS null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end

/*update information to appear for the branch*/
	update #invtemp_tbl
	   set brn_name = branch.brn_name,
	       brn_address= branch.brn_add1,
	       brn_address1= branch.brn_add2,           
	       brn_city = branch.brn_city,
	       brn_state = branch.brn_state_c,
	       brn_zip = branch.brn_zip,
	       brn_phone = branch.brn_phone,
	       brn_tax_id = branch.brn_tax_id 
	 from branch ,#invtemp_tbl
	where #invtemp_tbl.ivh_revtype1 = branch.brn_id 

-- IB modified code 10/03/97 
-- VJ inserted code 02/19/97 to populate #invtemp_tbl.Tar_number
--         update #invtemp_tbl
--            set tar_number = tariffheader.tar_number
--           from tariffheader, invoiceheader, #invtemp_tbl
--          where tariffheader.tar_tarriffnumber = invoiceheader.tar_tarriffnumber
--            and invoiceheader.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber    



         update #invtemp_tbl
            set tar_number = tariffheader.tar_number
           from tariffheader,invoiceheader,#invtemp_tbl
          where invoiceheader.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and
		tariffheader.tar_number = invoiceheader.tar_number    
-- VJ inserted code 02/19/97 
-- IB modified code 10/01/97 ended

/*update currency and arcurrency from the labelfile*/
	update #invtemp_tbl
	   set arcurrency = labelfile.name
	  from labelfile,#invtemp_tbl
	 where #invtemp_tbl.ivh_arcurrency = labelfile.abbr and
	       labelfile.labeldefinition = 'Currencies' 

	update #invtemp_tbl
	   set currency = labelfile.name
	  from labelfile,#invtemp_tbl
	 where #invtemp_tbl.ivh_currency = labelfile.abbr and
	       labelfile.labeldefinition = 'Currencies' 


/*Determine freight load point and unload point */
/* find first freight stop */ 

DECLARE @minivh int, @stop int
SELECT @minivh = 0, @stop = 1
WHILE ( SELECT COUNT (*)
		FROM #invtemp_tbl
		WHERE #invtemp_tbl.ivh_hdrnumber > @minivh ) > 0
	BEGIN
		SELECT @minivh = MIN ( #invtemp_tbl.ivh_hdrnumber  )
		FROM #invtemp_tbl
		WHERE #invtemp_tbl.ivh_hdrnumber > @minivh

		SELECT @minord = #invtemp_tbl.ord_hdrnumber
		FROM #invtemp_tbl
		WHERE #invtemp_tbl.ivh_hdrnumber = @minivh

		SELECT @stop = MIN ( stops.stp_mfh_sequence )
		FROM stops, eventcodetable, #invtemp_tbl
		WHERE stops.ord_hdrnumber = @minord and
                        stops.stp_type = 'PUP' AND
                        stops.stp_event = eventcodetable.abbr AND
			eventcodetable.ect_billable = 'Y' 

           UPDATE #invtemp_tbl
              SET load_point = city.cty_name+'  ,'+city.cty_state, 
                  load_date = stops.stp_departuredate          
             FROM stops,city,#invtemp_tbl
            WHERE stops.ord_hdrnumber = @minord and 
                  stops.stp_city = city.cty_code and 
                  stops.stp_mfh_sequence = @stop AND
		  #invtemp_tbl.ivh_hdrnumber = @minivh

		SELECT @stop = MAX ( stops.stp_mfh_sequence )
		FROM stops, eventcodetable, #invtemp_tbl
		WHERE stops.ord_hdrnumber = @minord and
                        stops.stp_type = 'DRP' AND
                        stops.stp_event = eventcodetable.abbr AND
			eventcodetable.ect_billable = 'Y' 

/* find last freight stop */  

           UPDATE #invtemp_tbl
              SET unload_point = city.cty_name+'   ,'+city.cty_state                                          
             FROM stops,city,#invtemp_tbl
            WHERE stops.ord_hdrnumber = @minord and
                  stops.stp_city = city.cty_code and 
                  stops.stp_mfh_sequence = @stop AND
		  #invtemp_tbl.ivh_hdrnumber = @minivh

	END


/* rate exchange 

select @temp_curr = ivh_currency,@temp_arcurr = ivh_arcurrency,@temp_dte = ivh_currencydate
  from #invtemp_tbl

execute s_get_exchangerate @temp_curr,@temp_arcurr,@temp_dte,@rate_ex OUT

update #invtemp_tbl
   set #invtemp_tbl.rate_exchange = @rate_ex
*/

/*Determine Your Order No. and Shipper W/B No. */

SELECT @minstp = 0
SELECT @minord = #invtemp_tbl.ord_hdrnumber
  FROM #invtemp_tbl

 WHILE (SELECT COUNT(stp_number) FROM #invtemp_tbl
	 WHERE stp_number > @minstp) > 0

  BEGIN

    SELECT @minstp = min (stp_number)
	   FROM #invtemp_tbl
	   WHERE stp_number > @minstp     


       UPDATE #invtemp_tbl
	  SET fgt_number = freightdetail.fgt_number
	 FROM freightdetail,#invtemp_tbl
	WHERE freightdetail.stp_number = @minstp and
	      #invtemp_tbl.stp_number = @minstp and 
	      #invtemp_tbl.ord_hdrnumber = @minord

  END


 SELECT @minfgt = 0

 WHILE (SELECT COUNT(fgt_number) FROM #invtemp_tbl
	 WHERE fgt_number > @minfgt) > 0


 BEGIN

  SELECT @minfgt = min (fgt_number )
	 FROM #invtemp_tbl
	 WHERE fgt_number > @minfgt     

   

       UPDATE #invtemp_tbl
	  SET shipper_wb_no = #invtemp_tbl.ivd_refnum                                          
	 FROM #invtemp_tbl
	WHERE #invtemp_tbl.fgt_number = @minfgt and
	      #invtemp_tbl.ord_hdrnumber = @minord and
	      #invtemp_tbl.ivd_reftype = 'SWB#'

       UPDATE #invtemp_tbl
	  SET your_order_no = #invtemp_tbl.ivd_refnum                                          
	 FROM #invtemp_tbl
	WHERE #invtemp_tbl.fgt_number = @minfgt and
	      #invtemp_tbl.ord_hdrnumber = @minord and
	      #invtemp_tbl.ivd_reftype = 'YO#'
 END    


/* RETRIEVE COMPANY DATA */                                             
if @useasbillto = 'BLT'
       begin
	update #invtemp_tbl
	   set ivh_billto_name = company.cmp_name,
	       ivh_billto_addr = company.cmp_address1,
	       ivh_billto_addr2 = company.cmp_address2,         
	       ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
	       acct_no = #invtemp_tbl.ivh_billto
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.ivh_billto
	end                     

if @useasbillto = 'ORD'
	begin

	update #invtemp_tbl
	   set ivh_billto_name = company.cmp_name,
	       ivh_billto_addr = company.cmp_address1,
	       ivh_billto_addr2 = company.cmp_address2,         
	       ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
	       acct_no = invoiceheader.ivh_order_by 
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
	       ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
	       acct_no = #invtemp_tbl.ivh_shipper 
	 from  #invtemp_tbl, company
	where  company.cmp_id = #invtemp_tbl.ivh_shipper
	end                     

			
	update #invtemp_tbl
	   set originpoint_name = company.cmp_name,
	       origin_addr = company.cmp_address1,
	       origin_addr2 = company.cmp_address2,
	       origin_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.ivh_originpoint
				
				
	update #invtemp_tbl
	   set destpoint_name = company.cmp_name,
	       dest_addr = company.cmp_address1,
	       dest_addr2 = company.cmp_address2,
	       dest_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.ivh_destpoint
				

	update #invtemp_tbl
	   set shipper_name = company.cmp_name,
	       shipper_addr = company.cmp_address1,
	       shipper_addr2 = company.cmp_address2,
	       shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.ivh_shipper
				
					
	update #invtemp_tbl
	   set consignee_name = company.cmp_name,
	       consignee_addr = company.cmp_address1,
	       consignee_addr2 = company.cmp_address2,
	       consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.ivh_consignee
				
					

	update #invtemp_tbl
	   set stop_name = company.cmp_name,
	       stop_addr = company.cmp_address1,

	       stop_addr2 = company.cmp_address2,
	       stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	  from #invtemp_tbl, company
	 where company.cmp_id = #invtemp_tbl.cmp_id


       /*update shipper alternate id*/          
	   update #invtemp_tbl
	      set shipper_altid = company.cmp_altid
	     from company ,#invtemp_tbl
	    where #invtemp_tbl.ivh_shipper = company.cmp_id 


       /*update company alternate id*/          
	   update #invtemp_tbl
	      set consignee_altid = company.cmp_altid
	     from company ,#invtemp_tbl
	    where #invtemp_tbl.ivh_consignee = company.cmp_id 

	/*update company alternate id*/         
	   update #invtemp_tbl
	      set billto_altid = company.cmp_altid
	     from company ,#invtemp_tbl
	    where #invtemp_tbl.ivh_billto = company.cmp_id 



/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @counter = 1

while @counter <>  @copies
	begin
	select @counter = @counter + 1

	 insert into #invtemp_tbl

	 SELECT         ivh_invoicenumber,   
			ivh_hdrnumber, 
			ivh_billto, 
			acct_no,
			ivh_billto_name ,
			ivh_billto_addr,
			ivh_billto_addr2,
			ivh_billto_nmctst,
			ivh_terms,      
			ivh_totalcharge,
			ivh_archarge,   
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
			ivh_arcurrency,   
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
			ord_number,   
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
--  replaced tar_tarriffnumber to tar_number - VJ 01/23/97
			tar_number,
			tar_tariffitem,
			@counter,
			cht_basis,
			cht_description,
			cmd_name,
			load_point,
			unload_point,
			load_date,
			shipper_wb_no ,
			your_order_no,
			fgt_number,
			brn_name,
			brn_address,
			brn_address1,
			brn_city,
			brn_state,
			brn_zip,
			brn_phone,
			brn_tax_id,
			shipper_altid,
			consignee_altid,
			billto_altid,
			arcurrency,
			currency /*,
			rate_exchange    */
    
		       
	 from #invtemp_tbl
	where copies = 1   

	end 
									

ERROR_END:

/* FINAL SELECT - FORMS RETURN SET */
select *
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 


return @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_trimac_template2] TO [public]
GO
