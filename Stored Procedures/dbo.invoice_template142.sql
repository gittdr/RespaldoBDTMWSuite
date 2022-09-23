SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template142](@invoice_nbr   int,@copies int)  
AS  
  
/**
 * 
 * NAME:
 * dbo.invoice_template142
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
 * 001 - @invoice_nbr, int, input, null;
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @copies, int, input, null;
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
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
 * 12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * 09/27/2007   PTS32976 - Imari Bremer - create a new invoice format for the increased size of the trailer number on the datawindow
 * 4/11/08 BDH PTS 41263 Created this from format102 for Crossett.  Also returning freightdfetail.fgt_accountof (from fuel dbs).
 * Also for 41263.  If the billto is listed in gi_string1 of 'PrintBlindInfo', look to the stops.stp_showas_cmpid to print
 * company info for the consignee, shipper, and stopname in detail instead of the regular values.
 * 2/3/9 PTS 44458 fgt_acocount of is not correct	
 * 5/22/09 PTS 47622 comma is printing above the accessorial charge descriptions
 **/

declare	@temp_name   varchar(30) ,
	@temp_addr   varchar(30) ,
	@temp_addr2  varchar(30),
	@temp_nmstct varchar(30),
	@counter    int,
	@ret_value  int,
	@varchar25  varchar(25),
	--PTS# 32916 ILB 08/22/2006
        @v_MinStp   int,
	@reftype    varchar(50),
 	@refnumber  varchar(50),
	--PTS# 32916 ILB 08/22/2006
	@fgt_accountof varchar(8),	-- BDH 41263
	@accountof_name varchar(100),  -- BDH 41263
	@BlindCmps varchar(60),
	@useBlindCmps int,
	@BlindCmp_ID varchar(8),
	@BlindCmpCity int


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1
set @useBlindCmps = 0


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
	 invoiceheader.tar_number,
	invoicedetail.tar_number as ivd_tarnumber,
	invoicedetail.tar_tariffnumber as ivd_tartariffnumber,
	invoicedetail.tar_tariffitem as ivd_tartariffitem,
	@varchar25 as cmp_altid,
	chargetype.cht_primary,        
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
	--PTS# 32916 ILB 08/22/2006
	@reftype ref_type1,
        @refnumber ref_number1,
	@reftype ref_type2,
        @refnumber ref_number2,
	--PTS# 32916 ILB 08/22/2006
	IsNull(ivh_charge,0.0) ivh_charge,
	@fgt_accountof fgt_accountof,-- BDH 41263
	@accountof_name accountof_name,  -- BDH 41263
	ivd_showas_cmpid BlindCmp_ID,
	@BlindCmpCity BlindCmpCity,
    invoicedetail.fgt_number fgt_number
    into #invtemp_tbl
    FROM --invoiceheader, invoicedetail, chargetype, commodity
         invoiceheader JOIN invoicedetail ON (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
         RIGHT OUTER JOIN chargetype ON ( chargetype.cht_itemcode = invoicedetail.cht_itemcode)   
         LEFT OUTER JOIN commodity ON (invoicedetail.cmd_code = commodity.cmd_code) 
   WHERE --(invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and
	 --(invoicedetail.cmd_code *= commodity.cmd_code) and
    	  invoiceheader.ivh_hdrnumber = @invoice_nbr
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end

If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
Where c.cmp_id = t.ivh_billto
		And Rtrim(IsNull(cmp_mailto_name,'')) > ''
		And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
			Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
		And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	

	update #invtemp_tbl
	set ivh_billto_name = company.cmp_name,
		 ivh_billto_addr = company.cmp_address1,
		 ivh_billto_addr2 = company.cmp_address2,		
		 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
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


update #invtemp_tbl
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_originpoint
	and city.cty_code = #invtemp_tbl.ivh_origincity
				
update #invtemp_tbl
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_destpoint
	and city.cty_code = #invtemp_tbl.ivh_destcity		

-- commented out for 41263.  Shipper, Consignee, and Stop Name may come from stops.stp_showas_cmpid
-- if the billto is in gi_string1 of 'PrintBlindInfo'

---- start shipper code
--update #invtemp_tbl
--set shipper_name = company.cmp_name,
--	shipper_addr = Case ivh_hideshipperaddr when 'Y' 
--				then ''
--				else company.cmp_address1
--			end,
--	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
--				then ''
--				else company.cmp_address2
--			end,
--	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
--from #invtemp_tbl, company
----where company.cmp_id = #invtemp_tbl.ivh_shipper
--where company.cmp_id = #invtemp_tbl.ivh_showshipper
--
--update 	#invtemp_tbl
--set 	shipper_nmctst = origin_nmctst
--where     ivh_shipper = 'UNKNOWN'
--
---- end shipper
---- start consignee
--					
--update #invtemp_tbl
--set consignee_name = company.cmp_name,
--	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
--				then ''
--				else company.cmp_address1
--			end,			 
--	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
--				then ''
--				else company.cmp_address2
--			end,
--	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
--from #invtemp_tbl, company
----where company.cmp_id = #invtemp_tbl.ivh_consignee	
--where company.cmp_id = #invtemp_tbl.ivh_showcons	
--	
--update 	#invtemp_tbl
--set 	consignee_nmctst = dest_nmctst
--where     ivh_consignee = 'UNKNOWN'						
--
---- end consignee

--*****************************************************************
------41263 new start for detail.  Use the compid from the stp_showas_cmpid
----update #invtemp_tbl
----set stop_name = company.cmp_name,
----	stop_addr = company.cmp_address1,
----	stop_addr2 = company.cmp_address2
------		 stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
----from #invtemp_tbl, company
----where company.cmp_id = #invtemp_tbl.cmp_id				
----
------ dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
----update #invtemp_tbl
----set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
------from 	#invtemp_tbl, stops,city
----from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
----      RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
----where 	#invtemp_tbl.stp_number IS NOT NULL
----	--and	stops.stp_number =  #invtemp_tbl.stp_number
----	--and	city.cty_code =* stops.stp_city		



set @BlindCmps = (select gi_string1 from generalinfo where gi_name = 'PrintBlindInfo')
select @useBlindCmps = (select count(*) from  #invtemp_tbl where ivh_billto in (select value from CSVStringsToTable_fn(@BlindCmps)))



if @useBlindCmps > 0 
begin
	-- 41263.  Get the Blind Company's ID and City. 
--	update #invtemp_tbl set BlindCmp_ID = stp_showas_cmpid
--	from stops
--	where #invtemp_tbl.stp_number = stops.stp_number

	update #invtemp_tbl set BlindCmpCity = cmp_city
	from company
	where #invtemp_tbl.BlindCmp_ID = company.cmp_id

	-- Update Stop info with this company's info. 
	update #invtemp_tbl
	set stop_name = company.cmp_name,
		stop_addr = company.cmp_address1,
		stop_addr2 = company.cmp_address2
	--		 stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company
	where company.cmp_id = #invtemp_tbl.BlindCmp_ID		--cmp_id				

	-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
	update #invtemp_tbl
	set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
	--from 	#invtemp_tbl, stops,city
	--	from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
	--		  RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
	--	where 	#invtemp_tbl.stp_number IS NOT NULL
	from city where cty_code = #invtemp_tbl.BlindCmpCity  -- 41263

	-- start shipper
	update #invtemp_tbl
	set ivh_shipper = company.cmp_id,
		shipper_name = company.cmp_name,
		shipper_addr = Case ivh_hideshipperaddr when 'Y' 
					then ''
					else company.cmp_address1
				end,
		shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
					then ''
					else company.cmp_address2
				end,
		shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company, stops
	where #invtemp_tbl.ord_hdrnumber = stops.ord_hdrnumber
	and company.cmp_id = (select stp_showas_cmpid 
						from stops 
						where ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
						and stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and stp_event = 'LLD'))
	-- end shipper
	-- start consignee
						
	update #invtemp_tbl
	set ivh_consignee = company.cmp_id,
		consignee_name = company.cmp_name,
		consignee_addr = Case ivh_hideconsignaddr when 'Y' 
					then ''
					else company.cmp_address1
				end,			  
		consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
					then ''
					else company.cmp_address2
				end,
		consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company, stops
	where #invtemp_tbl.ord_hdrnumber = stops.ord_hdrnumber
	and company.cmp_id = (select stp_showas_cmpid 
						from stops 
						where ord_hdrnumber = #invtemp_tbl.ord_hdrnumber
						and stp_sequence = (select max(stp_sequence) from stops where ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and stp_event = 'LUL'))
	-- end consignee
end
else
begin
	
	update #invtemp_tbl
	set stop_name = company.cmp_name,
		stop_addr = company.cmp_address1,
		stop_addr2 = company.cmp_address2
	--		 stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company
	where company.cmp_id = #invtemp_tbl.cmp_id				

	-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
	update #invtemp_tbl
	set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
	--from 	#invtemp_tbl, stops,city
	from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
		  RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
	where 	#invtemp_tbl.stp_number IS NOT NULL

	-- start shipper
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
		shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company
	--where company.cmp_id = #invtemp_tbl.ivh_shipper
	where company.cmp_id = #invtemp_tbl.ivh_showshipper

	update 	#invtemp_tbl
	set 	shipper_nmctst = origin_nmctst
	where     ivh_shipper = 'UNKNOWN'

	-- end shipper
	-- start consignee
						
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
		consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
	from #invtemp_tbl, company
	--where company.cmp_id = #invtemp_tbl.ivh_consignee	
	where company.cmp_id = #invtemp_tbl.ivh_showcons	
		
	update 	#invtemp_tbl
	set 	consignee_nmctst = dest_nmctst
	where     ivh_consignee = 'UNKNOWN'		
	-- end consignee
end

-- BDH 41263 start accountof
update #invtemp_tbl
set fgt_accountof = freightdetail.fgt_accountof
from freightdetail
--where #invtemp_tbl.stp_number = freightdetail.stp_number
where #invtemp_tbl.fgt_number = freightdetail.fgt_number
--and isnull(freightdetail.stp_number, 0) > 0
and isnull(#invtemp_tbl.fgt_number, 0) > 0

update #invtemp_tbl
set accountof_name = cmp_name
from company where fgt_accountof = company.cmp_id
-- BDH 41263 end

--PTS# 32916 ILB 08/22/2006
Select @v_MinStp = 0
WHILE (SELECT COUNT(*) 
         FROM #invtemp_tbl 
        WHERE stp_number > @v_MinStp ) > 0

	BEGIN
		SELECT @v_MinStp = (SELECT MIN(stp_number)
                            	      FROM #invtemp_tbl 
                           	     WHERE stp_number > @v_MinStp)

		update #invtemp_tbl
		   set ref_type1 = 'Reftype ' + ref_type,
                       ref_number1 = 'Ref# ' + ref_number
		  from referencenumber
                 where ref_tablekey = @v_MinStp 
                   and ref_table = 'stops' 
                   and ref_sequence = 1
                   and stp_number = @v_MinStp

		update #invtemp_tbl
		   set ref_type2 = 'Reftype ' + ref_type,
                       ref_number2 = 'Ref# ' + ref_number		 
		  from referencenumber
                 where ref_tablekey = @v_MinStp 
                   and ref_table = 'stops' 
		   and ref_sequence = 2
		   and stp_number = @v_MinStp
	END		
--PTS# 32916 ILB 08/22/2006

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */

select @counter = 1

while @counter <>  @copies
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
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,	
	--PTS# 32916 ILB 08/22/2006
    ref_type1,
	ref_number1,
	ref_type2,
	ref_number2,
	--PTS# 32916 ILB 08/22/2006
	ivh_charge,
	fgt_accountof,  -- BDH 41263
	accountof_name,  -- BDH 41263
	BlindCmp_ID,  -- BDH 41263
	BlindCmpCity,  -- BDH 41263
    fgt_number 
	from #invtemp_tbl
	where copies = 1   
end 
 

                                                   	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
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
	 isnull(stop_nmctst,''),
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
	cmd_name,
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,	
	ivh_showshipper,
	ivh_showcons,	
	--PTS# 32916 ILB 08/22/2006	
	ref_type1,
	ref_number1,
	ref_type2,
	ref_number2,
	--PTS# 32916 ILB 08/22/2006
	ivh_charge,
	fgt_accountof,  -- BDH 41263
	accountof_name  -- BDH 41263	
	--,BlindCmp_ID
	--,BlindCmpCity
from #invtemp_tbl



/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template142] TO [public]
GO
