SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[invoice_template36]
		@invoice_nbr  	int
		,@copies			int
as

/*	PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	-----------------------------------------
	07/09/2002	Vern Jewett		14570	(none)	Original, copied from invoice_template2.
   12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
*/

declare	@temp_name   	varchar(30)
		,@temp_addr   	varchar(30)
		,@temp_addr2  	varchar(30)
		,@temp_nmstct	varchar(30)
		,@temp_altid  	varchar(25)
		,@counter    	int
		,@ret_value  	int
		,@temp_terms    varchar(20)
		,@temp_resource	varchar(8)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1





--Temp tables needed for pulling in multiple resources.
--#moves is the list of distinct moves involved in each invoice..
create table #moves
		(ivh_hdrnumber		int				null
		,mov_number			int				null)

--#drv1 collects all drivers for each invoice, plus info needed to sequence them within the
--invoice..
create table #drv1
		(ivh_hdrnumber		int				null
		,driver				varchar(8)		null
		,mov_number			int				null
		,stp_mfh_sequence	int				null
		,drv1or2			smallint		null)

--#drv2 has the identity column which helps calculate ivh_seq, the sequence within the 
--invoice..
create table #drv2
		(ivh_hdrnumber	int				null
		,driver			varchar(8)		null
		,seq			numeric(7,0)	identity
		,ivh_seq		numeric(7,0)	null)

--#ivh_drvs stores pivoted data, with 1 row per Invoice and 5 columns for up to 5 drivers 
--per Invoice..
create table #ivh_drvs
		(ivh_hdrnumber	int			null
		,driver1		varchar(8)	null
		,driver2		varchar(8)	null
		,driver3		varchar(8)	null
		,driver4		varchar(8)	null
		,driver5		varchar(8)	null)

--#trc1 collects all tractors for each invoice, plus info needed to sequence them..
create table #trc1
		(ivh_hdrnumber		int				null
		,tractor			varchar(8)		null
		,mov_number			int				null
		,stp_mfh_sequence	int				null)

--#trc2 has the identity column which helps calculate ivh_seq..
create table #trc2
		(ivh_hdrnumber	int				null
		,tractor		varchar(8)		null
		,seq			numeric(7,0)	identity
		,ivh_seq		numeric(7,0)	null)

--#ivh_min stores the minimum overall sequence per Invoice, which helps to calculate the 
--sequence within each Invoice.  It is used for both Drivers & Tractors..
create table #ivh_min
		(ivh_hdrnumber	int	null
		,ivh_min_seq	int	null)

--#ivh_trcs stores pivoted data, with 1 row per Invoice and 5 columns for up to 5 tractors 
--per Invoice..
create table #ivh_trcs
		(ivh_hdrnumber	int			null
		,tractor1		varchar(8)	null
		,tractor2		varchar(8)	null
		,tractor3		varchar(8)	null
		,tractor4		varchar(8)	null
		,tractor5		varchar(8)	null)


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1


/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
select	ivh.ivh_invoicenumber
		,ivh.ivh_hdrnumber
		,ivh.ivh_billto
		,@temp_name as ivh_billto_name
		,@temp_addr as ivh_billto_addr
	 	,@temp_addr2 as ivh_billto_addr2
	 	,@temp_nmstct as ivh_billto_nmctst
        ,ivh.ivh_terms
        ,ivh.ivh_totalcharge
		,ivh.ivh_shipper
	 	,@temp_name	as shipper_name
	 	,@temp_addr	as shipper_addr
	 	,@temp_addr2 as shipper_addr2
	 	,@temp_nmstct as shipper_nmctst
        ,ivh.ivh_consignee
		,@temp_name as consignee_name
		,@temp_addr as consignee_addr
		,@temp_addr2 as consignee_addr2
		,@temp_nmstct as consignee_nmctst
		,ivh.ivh_originpoint   
		,@temp_name as originpoint_name
		,@temp_addr as origin_addr
		,@temp_addr2 as origin_addr2
		,@temp_nmstct as origin_nmctst
		,ivh.ivh_destpoint
		,@temp_name as destpoint_name
		,@temp_addr as dest_addr
		,@temp_addr2 as dest_addr2
		,@temp_nmstct as dest_nmctst
		,ivh.ivh_invoicestatus
		,ivh.ivh_origincity 
		,ivh.ivh_destcity  
		,ivh.ivh_originstate
		,ivh.ivh_deststate
		,ivh.ivh_originregion1
		,ivh.ivh_destregion1  
		,ivh.ivh_supplier 
		,ivh.ivh_shipdate
		,ivh.ivh_deliverydate
		,ivh.ivh_revtype1
		,ivh.ivh_revtype2
		,ivh.ivh_revtype3   
		,ivh.ivh_revtype4   
		,ivh.ivh_totalweight
		,ivh.ivh_totalpieces   
		,ivh.ivh_totalmiles   
		,ivh.ivh_currency  
		,ivh.ivh_currencydate
		,ivh.ivh_totalvolume   
		,ivh.ivh_taxamount1   
		,ivh.ivh_taxamount2   
		,ivh.ivh_taxamount3   
		,ivh.ivh_taxamount4   
		,ivh.ivh_transtype   
		,ivh.ivh_creditmemo
		,ivh.ivh_applyto 
		,ivh.ivh_printdate
		,ivh.ivh_billdate   
		,ivh.ivh_lastprintdate
		,ivh.ivh_originregion2   
		,ivh.ivh_originregion3   
		,ivh.ivh_originregion4   
		,ivh.ivh_destregion2  
		,ivh.ivh_destregion3   
		,ivh.ivh_destregion4   
		,ivh.mfh_hdrnumber  
		,ivh.ivh_remark 
		,ivh.ivh_driver   
		,ivh.ivh_tractor
		,ivh.ivh_trailer   
		,ivh.ivh_user_id1
		,ivh.ivh_user_id2   
		,ivh.ivh_ref_number
		,ivh.ivh_driver2 
		,ivh.mov_number   
		,ivh.ivh_edi_flag
		,ivh.ord_hdrnumber
		,ivd.ivd_number 
		,ivd.stp_number   
		,ivd.ivd_description
		,ivd.cht_itemcode 
		,ivd.ivd_quantity   
		,ivd.ivd_rate
		,ivd.ivd_charge
		,ivd.ivd_taxable1
		,ivd.ivd_taxable2   
		,ivd.ivd_taxable3   
		,ivd.ivd_taxable4   
		,ivd.ivd_unit
		,ivd.cur_code   
		,ivd.ivd_currencydate
		,ivd.ivd_glnum
		,ivd.ivd_type   
		,ivd.ivd_rateunit
		,ivd.ivd_billto  
		,@temp_name as ivd_billto_name
		,@temp_addr as ivd_billto_addr
		,@temp_addr2 as ivd_billto_addr2
		,@temp_nmstct as ivd_billto_nmctst
		,ivd.ivd_itemquantity   
		,ivd.ivd_subtotalptr   
		,ivd.ivd_allocatedrev
		,ivd.ivd_sequence
		,ivd.ivd_refnum  
		,ivd.cmd_code  
		,ivd.cmp_id  
		,@temp_name	as stop_name
		,@temp_addr	as stop_addr
		,@temp_addr2 as stop_addr2
		,@temp_nmstct as stop_nmctst
		,ivd.ivd_distance
		,ivd.ivd_distunit   
		,ivd.ivd_wgt
		,ivd.ivd_wgtunit
		,ivd.ivd_count  
		,ivd.ivd_countunit
		,ivd.evt_number 
		,ivd.ivd_reftype
		,ivd.ivd_volume   
		,ivd.ivd_volunit
		,ivd.ivd_orig_cmpid
		,ivd.ivd_payrevenue
		,ivh.ivh_freight_miles
		,ivh.tar_tarriffnumber
		,ivh.tar_tariffitem
		,1 as copies
		,cht.cht_basis
		,cht.cht_description
		,cmd.cmd_name
		,@temp_altid as cmp_altid
		,ivh_hideshipperaddr
		,ivh_hideconsignaddr
		,(Case ivh_showshipper 
			when 'UNKNOWN' then ivh.ivh_shipper
			else IsNull(ivh_showshipper,ivh.ivh_shipper) 
			end) as ivh_showshipper
		,(Case ivh_showcons 
			when 'UNKNOWN' then ivh.ivh_consignee
			else IsNull(ivh_showcons,ivh.ivh_consignee) 
			end) as ivh_showcons
		,@temp_terms as terms_name
		,@temp_resource as driver1
		,@temp_resource as driver2
		,@temp_resource as driver3
		,@temp_resource as driver4
		,@temp_resource as driver5
		,@temp_resource as tractor1
		,@temp_resource as tractor2
		,@temp_resource as tractor3
		,@temp_resource as tractor4
		,@temp_resource as tractor5,
		IsNull(ivh_charge,0.0) ivh_charge
  into	#invtemp_tbl
  from	chargetype cht  RIGHT OUTER JOIN  invoicedetail ivd  ON  cht.cht_itemcode  = ivd.cht_itemcode   
			LEFT OUTER JOIN  commodity cmd  ON  cmd.cmd_code  = ivd.cmd_code ,
		invoiceheader ivh
  where	ivh.ivh_hdrnumber = @invoice_nbr --between @invoice_no_lo and @invoice_no_hi
	--and	@invoice_status  in ('ALL', ivh.ivh_invoicestatus)
	--and	@revtype1 in('UNK', ivh.ivh_revtype1)
	--and	@revtype2 in('UNK', ivh.ivh_revtype2) 
	--and	@revtype3 in('UNK', ivh.ivh_revtype3) 
	--and	@revtype4 in('UNK', ivh.ivh_revtype4) 
	--and	@billto in ('UNKNOWN', ivh.ivh_billto) 
	--and	@shipper in ('UNKNOWN', ivh.ivh_shipper)
	--and	@consignee in ('UNKNOWN', ivh.ivh_consignee)
	--and	ivh.ivh_shipdate between @shipdate1 and @shipdate2
	--and	ivh.ivh_deliverydate between @deldate1 and @deldate2
	--and	(ivh.ivh_billdate between @billdate1 and @billdate2
	--	or ivh.ivh_billdate IS null)
	and	ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
--	and	cht.cht_itemcode =* ivd.cht_itemcode
--	and	cmd.cmd_code =* ivd.cmd_code

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
begin
	select @ret_value = 0  
	GOTO ERROR_END
end


/* RETRIEVE COMPANY DATA */	                   			
--if @useasbillto = 'BLT'
--begin
	/*	
	--LOR	PTS#4789(SR# 7160)	
	if ((	select count(*) 
			  from 	company c
					,#invtemp_tbl t
			  where c.cmp_id = t.ivh_billto 
				and	c.cmp_mailto_name = '') > 0 
		or	(select count(*) 
			  from 	company c
					,#invtemp_tbl t
			  where c.cmp_id = t.ivh_billto 
				and	c.cmp_mailto_name is null) > 0 
		or	(select count(*)
			  from 	#invtemp_tbl t
					,chargetype ch
					,company c
			  where c.cmp_id = t.ivh_billto 
				and	ch.cht_itemcode = t.cht_itemcode 
				and	ch.cht_primary = 'Y' 
				and ch.cht_basis='SHP') = 0 
		or	(select count(*) 
			  from 	company c
					,chargetype ch
					,#invtemp_tbl t
			  where c.cmp_id = t.ivh_billto 
				and	c.cmp_mailto_name is not null 
				and	c.cmp_mailto_name not in ('') 
				and	ch.cht_itemcode = t.cht_itemcode 
				and	ch.cht_primary = 'Y' 
				and	ch.cht_basis='SHP' 
				and	t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
	*/
	If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
        Where c.cmp_id = t.ivh_billto
			And Rtrim(IsNull(cmp_mailto_name,'')) > ''
			And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
				Case IsNull(cmp_mailtoTermsMatchFlag,'Y') When 'Y' Then '^^' ELse t.ivh_terms End)
			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	

		update 	#invtemp_tbl
		  set 	ivh_billto_name = company.cmp_name
				,ivh_billto_nmctst = substring(company.cty_nmstct, 1, (charindex('/', company.cty_nmstct))) + ' ' + 
										company.cmp_zip
				,#invtemp_tbl.cmp_altid = company.cmp_altid
				,ivh_billto_addr = company.cmp_address1
				,ivh_billto_addr2 = company.cmp_address2
		  from 	#invtemp_tbl
				,company
		  where company.cmp_id = #invtemp_tbl.ivh_billto

	else	
		update 	#invtemp_tbl
		  set 	ivh_billto_name = company.cmp_mailto_name
			 	,ivh_billto_addr = company.cmp_mailto_address1
			 	,ivh_billto_addr2 = company.cmp_mailto_address2
			 	,ivh_billto_nmctst = substring(company.mailto_cty_nmstct, 1, (charindex('/', company.mailto_cty_nmstct))) + 
										' ' + company.cmp_mailto_zip
				,#invtemp_tbl.cmp_altid = company.cmp_altid 
		  from 	#invtemp_tbl
				,company
		  where company.cmp_id = #invtemp_tbl.ivh_billto
--end			
/*
if @useasbillto = 'ORD'
begin
	update 	#invtemp_tbl
	  set	ivh_billto_name = company.cmp_name
			,ivh_billto_addr = company.cmp_address1
			,ivh_billto_addr2 = company.cmp_address2
			,ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct))) + 
									' ' + company.cmp_zip
			,#invtemp_tbl.cmp_altid = company.cmp_altid
	  from 	#invtemp_tbl, company, invoiceheader
	  where	#invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber 
		and	company.cmp_id = invoiceheader.ivh_order_by
end			

if @useasbillto = 'SHP'
begin
	update #invtemp_tbl
	  set 	ivh_billto_name = company.cmp_name
			,ivh_billto_addr = company.cmp_address1
			,ivh_billto_addr2 = company.cmp_address2
			,ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct))) + 
									' ' + company.cmp_zip
			,#invtemp_tbl.cmp_altid = company.cmp_altid 
	  from 	#invtemp_tbl
			,company
	  where company.cmp_id = #invtemp_tbl.ivh_shipper
end			
*/
			
update 	#invtemp_tbl
  set 	originpoint_name = company.cmp_name
		,origin_addr = company.cmp_address1
		,origin_addr2 = company.cmp_address2
		,origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct))) + 
							' ' + ISNULL(city.cty_zip ,'')
  from 	#invtemp_tbl
		,company
		,city
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
from 	#invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city
where 	#invtemp_tbl.stp_number IS NOT NULL
	and	stops.stp_number =  #invtemp_tbl.stp_number
	--and	city.cty_code =* stops.stp_city

update #invtemp_tbl
set terms_name = la.name
from labelfile la
where la.labeldefinition = 'creditterms' and
     la.abbr = #invtemp_tbl.ivh_terms


--Pull in multiple resources if split trips are included..
--Get the distinct list of moves for each Invoice..
insert into #moves
  select distinct ivh.ivh_hdrnumber
		,s.mov_number
  from	#invtemp_tbl it
		,invoiceheader ivh
		,stops s
  where	ivh.ivh_hdrnumber = it.ivh_hdrnumber
	and	s.ord_hdrnumber = ivh.ord_hdrnumber
	and ivh.ord_hdrnumber > 0 
--Get all Driver1's involved in each invoice..
insert into #drv1
		(ivh_hdrnumber
		,driver
		,mov_number
		,stp_mfh_sequence
		,drv1or2)
  select m.ivh_hdrnumber
		,e.evt_driver1
		,m.mov_number
		,min(stp_mfh_sequence)
		,1
  from	#moves m
		,stops s
		,event e
  where	s.mov_number = m.mov_number
	and	e.stp_number = s.stp_number
	and	e.evt_driver1 is not null
	and	e.evt_driver1 <> 'UNKNOWN'
  group by m.ivh_hdrnumber
		,e.evt_driver1
		,m.mov_number

--If we want ALL drivers involved in an invoice, get evt_driver2 also..
insert into #drv1
		(ivh_hdrnumber
		,driver
		,mov_number
		,stp_mfh_sequence
		,drv1or2)
  select m.ivh_hdrnumber
		,e.evt_driver2
		,m.mov_number
		,min(stp_mfh_sequence)
		,2
  from	#moves m
		,stops s
		,event e
  where	s.mov_number = m.mov_number
	and	e.stp_number = s.stp_number
	and	e.evt_driver2 is not null
	and	e.evt_driver2 <> 'UNKNOWN'
  group by m.ivh_hdrnumber
		,e.evt_driver2
		,m.mov_number

--Remove duplicate drivers per invoice.  This step also sequences the whole table, so drivers
--may be sequenced within Invoices..
insert into #drv2
		(ivh_hdrnumber
		,driver)
  select ivh_hdrnumber
		,driver
  from	#drv1
  group by ivh_hdrnumber
		,driver
  order by ivh_hdrnumber
		,min(mov_number)
		,min(stp_mfh_sequence)
		,min(drv1or2)

--Now store the minimum sequence per Invoice..
insert into #ivh_min
		(ivh_hdrnumber
		,ivh_min_seq)
  select ivh_hdrnumber
		,min(seq)
  from	#drv2
  group by ivh_hdrnumber

--Now provide the sequence within invoice..
update	#drv2
  set	ivh_seq = d2.seq - im.ivh_min_seq + 1
  from	#drv2 d2
		,#ivh_min im
  where	im.ivh_hdrnumber = d2.ivh_hdrnumber

--Provide up to 5 DRVs by pivoting the data..
insert into #ivh_drvs
		(ivh_hdrnumber
		,driver1
		,driver2
		,driver3
		,driver4
		,driver5)
  select ivh_hdrnumber
		,max(replicate(driver, sign(1 - abs(sign(ivh_seq - 1)))))
		,max(replicate(driver, sign(1 - abs(sign(ivh_seq - 2)))))
		,max(replicate(driver, sign(1 - abs(sign(ivh_seq - 3)))))
		,max(replicate(driver, sign(1 - abs(sign(ivh_seq - 4)))))
		,max(replicate(driver, sign(1 - abs(sign(ivh_seq - 5)))))
  from	#drv2
  group by ivh_hdrnumber		  


--Now get all Tractors involved in each invoice..
insert into #trc1
		(ivh_hdrnumber
		,tractor
		,mov_number
		,stp_mfh_sequence)
  select m.ivh_hdrnumber
		,e.evt_tractor
		,m.mov_number
		,min(stp_mfh_sequence)
  from	#moves m
		,stops s
		,event e
  where	s.mov_number = m.mov_number
	and	e.stp_number = s.stp_number
	and	e.evt_tractor is not null
	and	e.evt_tractor <> 'UNKNOWN'
  group by m.ivh_hdrnumber
		,e.evt_tractor
		,m.mov_number

--Remove duplicate tractors per invoice.  This step also sequences the whole table, so tractors
--may be sequenced within Invoices..
insert into #trc2
		(ivh_hdrnumber
		,tractor)
  select ivh_hdrnumber
		,tractor
  from	#trc1
  group by ivh_hdrnumber
		,tractor
  order by ivh_hdrnumber
		,min(mov_number)
		,min(stp_mfh_sequence)

--Now store the minimum sequence per Invoice (1st need to remove all old data from Drivers)..
delete	#ivh_min

insert into #ivh_min
		(ivh_hdrnumber
		,ivh_min_seq)
  select ivh_hdrnumber
		,min(seq)
  from	#trc2
  group by ivh_hdrnumber

--Now provide the sequence within invoice..
update	#trc2
  set	ivh_seq = t2.seq - im.ivh_min_seq + 1
  from	#trc2 t2
		,#ivh_min im
  where	im.ivh_hdrnumber = t2.ivh_hdrnumber

--Provide up to 5 TRCs by pivoting the data..
insert into #ivh_trcs
		(ivh_hdrnumber
		,tractor1
		,tractor2
		,tractor3
		,tractor4
		,tractor5)
  select ivh_hdrnumber
		,max(replicate(tractor, sign(1 - abs(sign(ivh_seq - 1)))))
		,max(replicate(tractor, sign(1 - abs(sign(ivh_seq - 2)))))
		,max(replicate(tractor, sign(1 - abs(sign(ivh_seq - 3)))))
		,max(replicate(tractor, sign(1 - abs(sign(ivh_seq - 4)))))
		,max(replicate(tractor, sign(1 - abs(sign(ivh_seq - 5)))))
  from	#trc2
  group by ivh_hdrnumber


--Store drivers & tractors in the results table..
update	#invtemp_tbl
  set	driver1 = idr.driver1
		,driver2 = idr.driver2
		,driver3 = idr.driver3
		,driver4 = idr.driver4
		,driver5 = idr.driver5
		,tractor1 = itr.tractor1
		,tractor2 = itr.tractor2
		,tractor3 = itr.tractor3
		,tractor4 = itr.tractor4
		,tractor5 = itr.tractor5
  from	#ivh_drvs idr  RIGHT OUTER JOIN  #invtemp_tbl it  ON  idr.ivh_hdrnumber  = it.ivh_hdrnumber   
			LEFT OUTER JOIN  #ivh_trcs itr  ON  itr.ivh_hdrnumber  = it.ivh_hdrnumber  
--  where	idr.ivh_hdrnumber =* it.ivh_hdrnumber
--	and	itr.ivh_hdrnumber =* it.ivh_hdrnumber

/* MAKE COPIES OF INVOICES BASED ON INPUTTED VALUE */
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
	 cmp_altid,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,
	terms_name,
		driver1,
		driver2,
		driver3,
		driver4,
		driver5,
		tractor1,
		tractor2,
		tractor3,
		tractor4,
		tractor5,
	ivh_charge
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
	 copies,
	 cht_basis,
	 cht_description,
	 cmd_name,
	cmp_altid,
--JLB PTS 27382  added changes to Driver1, Driver2, and Tractor1 from MRUTH to main source
		driver1 = case	when driver1 is null and ivh_driver <> 'UNKNOWN'
				then ivh_driver
				else driver1
				end,
		driver2 = case	when driver2 is null and ivh_driver2 <> 'UNKNOWN'
				then ivh_driver2
				else driver2
				end,
		driver3,
		driver4,
		driver5,
		tractor1 = case	when tractor1 is null and ivh_tractor <> 'UNKNOWN'
				then ivh_tractor
				else tractor1
				end,
		tractor2,
		tractor3,
		tractor4,
		tractor5
	from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 
	select @ret_value = @@ERROR 


--Drop all temp tables..
drop table #moves
drop table #drv1
drop table #drv2
drop table #ivh_drvs
drop table #trc1
drop table #trc2
drop table #ivh_trcs
drop table #ivh_min
drop table #invtemp_tbl


return @ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template36] TO [public]
GO
