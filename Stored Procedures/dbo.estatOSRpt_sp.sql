SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[estatOSRpt_sp](@login varchar(132),   -- 40655
                              @delstart datetime,@delend datetime,
			      @status0 char,@status1 char, @status2 char,
			      @status3 char, @status4 char, @status5 char,
			      @status6 char, @status10 char,
                  @reftype2 varchar(6), -- orderheader reftype - supplied if user wants a 2nd orderheader 
                                                    -- ref number (in addition to the primary ref number) 
			      @ubo char(6), -- 27173	
-- @refnum: Note: although this proc returns all orders with this ref number that this user is allowed to view,
-- subject to the other parms, the ref number that actually gets returned in the results set is always: 1st one on the order header
-- i.e.  it is possible that the ref number returned is not the same one supplied as the @refnum parm.    
			     @refnum VARchar (20),        -- 6/20/07  return orders that have this ref number, any type.    
			     @shipper varchar(8),           -- 6/23/07 if not blank, filter by this
			     @consignee varchar(8),       -- 6/23/07 if not blank, filter by this
			     @spreadsheet varchar(1))     
	                                        
as
SET NOCOUNT ON

declare @varchar30 varchar(30),@varchar25 varchar(25),
	@money money, @varchar8 varchar(8),@varchar12 varchar(12),
	@varchar13 varchar(13),      --pts 22883
	@varchar6 varchar(6),@int int, @char char, @ordstat1 varchar(6),
	@ordstat2 varchar(6), @ordinvstat1 varchar(6), @ordinvstat2 varchar(6),
	@ord int ,@stp int,
	@shippedweight decimal(9), @shippedvolume decimal(9), @weightunit varchar(6), @volumeunit varchar(6),
	@fgtdesc varchar(60),
	@statusstring varchar(15), @loopcount int, @reportstatus int,
        @varchar100 varchar(100),  
	--@varchar30 varchar(30),       --29308
	@varchar60 varchar(60),    
	@dec9 decimal(9) 	   	
      
SELECT 	@int = 0
SELECT  @reportstatus = 99 

Create table #webusercompanies (cmp_id varchar(8) not null) -- 33393

CREATE TABLE #biglist (
	ord_hdrnumber int null,
	ord_status varchar(6) null,
	ord_invoicestatus varchar(6) null,
	ivh_invoicestatus varchar(6) null, 	
	ivh_hdrnumber int null,   		
	--ivh_batch_id varchar(10) null, 	 --28087 notused
	reportstatus int null,
	ord_shipper varchar(8) null,
	ord_company varchar(8) null,
	ord_consignee varchar(8) null,
	ord_billto varchar(8) null,
	ord_totalweight decimal(9), 	--27963
	ord_totalvolume decimal(9), 	--27963 
	ord_weightunit varchar(6),  	--27963
	ord_volumeunit varchar(6) 	--27963
	)
-- 33393:
-- build a list of candidate orders limited only by dates and customer id.
-- note - leaves out quotes and masterbills and exotic statuses
--       if there is a batch id specified, we know we have invoice records
insert into #webusercompanies select cmp_id from estatusercompanies where login = @login
--end 33393 
if @refnum <> ''  -- all filtering opotions obtain, except date range
begin
insert into #biglist
SELECT  ord.ord_hdrnumber,
		ord_status,
		ord_invoicestatus,
		'',                    --ivh_invoicestatus, 28087
		0,                     --ivh_hdrnumber,     28087
	--	'',                    --ivh_batch_id,      28087 not used
		@int reportstatus,
		ord_shipper,
		ord_company,
		ord_consignee,
		ord_billto,
		ord_totalweight,   	--27963
		ord_totalvolume, 	--27963
		ord_totalweightunits,		--27963
		ord_totalvolumeunits 		--27963	     
	from 
		orderheader ord, referencenumber
	where   	referencenumber.ref_number =  @refnum	
		and	
		referencenumber.ord_hdrnumber  = ord.ord_hdrnumber
		and
		--ord_completiondate between @delstart AND @delend and
		ord.ord_status in ('AVL','CAN','PLN','DSP','STD','CMP','ICO')
		and (ord_shipper =  @shipper or @shipper = 'ALL')   -- 6/23/07
		and (ord_consignee =  @consignee or @consignee = 'ALL')   -- 6/23/07
end
else
begin
INSERT INTO #biglist
	SELECT  ord.ord_hdrnumber,
		ord_status,
		ord_invoicestatus,
		'',                    --ivh_invoicestatus, 28087
		0,                     --ivh_hdrnumber,     28087
	--	'',                    --ivh_batch_id,      28087 not used
		@int reportstatus,
		ord_shipper,
		ord_company,
		ord_consignee,
		ord_billto,
		ord_totalweight,   	--27963
		ord_totalvolume, 	--27963
		ord_totalweightunits,		--27963
		ord_totalvolumeunits 		--27963	
	FROM	orderheader ord  --, invoiceheader ivh   28087
	WHERE	
		ord_completiondate between @delstart AND @delend and
		ord.ord_status in ('AVL','CAN','PLN','DSP','STD','CMP','ICO')   	
		and (ord_shipper =  @shipper or @shipper = 'ALL')   -- 6/23/07
		and (ord_consignee =  @consignee or @consignee = 'ALL')   -- 6/23/07
end 
-- begin 27173
if @ubo = 'B' -- delete alll but shipments on which user's company is billto
	delete #biglist where ord_billto not in (select cmp_id from #webusercompanies ) 
else 
if @ubo = 'S' 
	delete #biglist where ord_shipper not in (select cmp_id from #webusercompanies ) 
else
if @ubo = 'C'
	delete #biglist where ord_consignee not in (select cmp_id from #webusercompanies ) 
else
if @ubo = 'O'
	delete #biglist where ord_company not in (select cmp_id from #webusercompanies ) --37819
else
if @ubo = 'BSCO'
	delete #biglist where ord_shipper not in (select cmp_id from #webusercompanies ) and 
		    ord_consignee not in (select cmp_id from #webusercompanies ) and 
		    ord_company   not in (select cmp_id from #webusercompanies ) and 
		    ord_billto    not in (select cmp_id from #webusercompanies ) 
-- end 27173
--28087 Add invoice info to the order 

UPDATE #biglist
SET	
ivh_invoicestatus  = ivh.ivh_invoicestatus,
ivh_hdrnumber = ivh.ivh_hdrnumber
-- ivh_batch_id = ivh.ivh_batch_id  --28987 not used
from invoiceheader ivh
where
ivh.ord_hdrnumber = #biglist.ord_hdrnumber  --28087
and ISNULL(ivh.ivh_creditmemo ,'N') = 'N'   --28087  
-- Set the report status from the information on the big list
------- Cancelled orders
UPDATE #biglist
SET	reportstatus = 0
WHERE	ord_status = 'CAN' 
------- New/not dispatched orders (XIN is do not invoice)
UPDATE #biglist
SET	reportstatus = 1
WHERE	ord_status = 'AVL' 
AND	ord_invoicestatus in ('PND','XIN')
------- Dispatched orders
UPDATE #biglist
SET	reportstatus = 2
WHERE	(ord_status = 'PLN' OR ord_status = 'DSP')
AND	ord_invoicestatus in ('PND','XIN')
------- Trip in progress orders
UPDATE #biglist
SET	reportstatus = 3
WHERE	ord_status = 'STD' 
AND	ord_invoicestatus in ('PND','AVL','XIN')
------- Trip completed/not invoiced orders (ICO is cancelled but invoice)
UPDATE #biglist
SET	reportstatus = 4
WHERE	ord_status in ('CMP','ICO')
AND	ord_invoicestatus in ('AVL','PND')
------- Order in billing
UPDATE #biglist
SET	reportstatus = 5
WHERE	ord_status in ( 'CMP','ICO') 
AND	ord_invoicestatus = 'PPD'
AND	ivh_invoicestatus <> 'XFR'
------- Order transferred to A/R
UPDATE #biglist
SET	reportstatus = 6
WHERE	ord_status  in ( 'CMP','ICO') 
AND	ord_invoicestatus = 'PPD'
AND	ivh_invoicestatus = 'XFR'
------- Order completed - marked do not invoice
UPDATE #biglist
SET	reportstatus = 10
WHERE	ord_status = 'CMP' 
AND	ord_invoicestatus = 'XIN'
-- Now remove any orders which where notin the statuses requested.
If ISNULL(@status0,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 0
If ISNULL(@status1,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 1
If ISNULL(@status2,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 2
If ISNULL(@status3,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 3
If ISNULL(@status4,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 4
If ISNULL(@status5,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 5
If ISNULL(@status6,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 6
If ISNULL(@status10,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 10


-- Now that we have our list of orders, pick up the rest of the information

create table #ostat (
	ord_hdrnumber int null, 		--b.ord_hdrnumber
	ord_number char(12),    		--o.ord_number
	reportstatus int null,  		--b.reportstatus
	mov_number int,         		--o.mov_number
	ord_originpoint varchar(8),  		--o.ord_originpoint
	ord_destpoint varchar(8),		--o.ord_destpoint 
	ord_status varchar(6) null,		--b.ord_status
	ord_invoicestatus varchar(6) null,	--b.ord_invoicestatus
	ord_totalweight decimal(9), 	--27963 --b.ord_totalweight
	ord_totalvolume decimal(9), 	--27963 --b.ord_totalvolume 	
	ord_weightunit varchar(6),  	--27963 --b.ord_weightunit
	ord_volumeunit varchar(6), 	--27963 --b.ord_volumeunit
            shipdate datetime,    		-- ord_startdate    -- 3/25/05 pts 27264 follow-on
	deliverydate datetime, 		-- o.ord_completiondate  -- 3/25/05 pts 27264 follow-on
	ord_billto varchar(8),  	--o.ord_billto
	billtoname varchar(100), 	--bcmp.cmp_name 
	shippername varchar(100),       --scmp.cmp_name 
	shippernmstct varchar(30),	--scty.cty_nmstct 
	shippercty_name varchar(24),	--scty.cty_name  -- 6/21/07 -- 39046
	shippercty_state varchar(6),	--scty.cty_state   -- 6/21/07 
	consigneename varchar(100),     --ccmp.cmp_name consigneename,
	consigneenmstct varchar(30),	--ccty.cty_nmstct  
	consigneecty_name varchar(24),	--scty.cty_name  -- 6/21/07	-- 39046
	consigneecty_state varchar(6),	--scty.cty_state   -- 6/21/07 
	ivh_hdrnumber int null,         --b.ivh_hdrnumber
	ivhinvoicenumber varchar(12),	--ISNULL(i.ivh_invoicenumber,'') 
	ivhinvoicestatus varchar(6),	--ISNULL(i.ivh_invoicestatus,'') 
	ivhmbstatus varchar(6),		--ISNULL(i.ivh_mbstatus,'') 
	-- ivhtotalcharge money,		--ISNULL(i.ivh_totalcharge,0.00) 28087 not used
	missingpaperworkcount int,
	stpordmiles int,
	triploadmiles int,
	tripuloadmiles int ,
	--ivh_batch_id varchar(10),	--i.ivh_batch_id,   28087 not used
	carrier varchar(100), 		 
	refnumber varchar(30),		  --29308
	reftype varchar(6),		  
	freight varchar(60), 		 
	shippedvolume decimal(9),    	
	shippedweight decimal(9),    		
	deliveredvolume decimal(9),   	
	deliveredweight decimal(9),   	
	weightunit varchar(6), 		
	volumeunit varchar(6), 		
 	refnumber2 varchar(30),		
        refnumberlul varchar(30),	-- 28089 - ref num from first lul stop  --29308 
	refnumberlultype varchar(6)	-- 28089 
)  

create index dk_ostat on #ostat (ord_hdrnumber)

insert into #ostat
SELECT	b.ord_hdrnumber,
	o.ord_number,
	b.reportstatus,
	o.mov_number,
	o.ord_originpoint,
	o.ord_destpoint,
	b.ord_status,
	b.ord_invoicestatus,
	b.ord_totalweight,  	-- 27963
	b.ord_totalvolume,  	-- 27963
	b.ord_weightunit,  	-- 27963
	b.ord_volumeunit,  	-- 27963
	--ISNULL(i.ivh_shipdate,o.ord_startdate) shipdate,
	--ISNULL(i.ivh_deliverydate,o.ord_completiondate) deliverydate ,
	o.ord_startdate shipdate,   -- 3/25/05 pts 27264 follow-on
	o.ord_completiondate deliverydate , -- 3/25/05 pts 27264 follow-on
	o.ord_billto,
	bcmp.cmp_name billtoname,
	scmp.cmp_name shippername,
	scty.cty_nmstct shippernmstct,
	scty.cty_name shippercty_name, --6/21/07
	scty.cty_state shippercty_state,   -- 6/21/07
	ccmp.cmp_name consigneename,
	ccty.cty_nmstct consigneenmstct, 
	ccty.cty_name consigneecty_name, -- 6/21/07
	ccty.cty_state  consigneecty_state,   -- 6/21/07
	b.ivh_hdrnumber,
	'', 	--ISNULL(i.ivh_invoicenumber,'') ivhinvoicenumber,
	'', 	--ISNULL(i.ivh_invoicestatus,'') ivhinvoicestatus,
	'', 	--ISNULL(i.ivh_mbstatus,'') ivhmbstatus,
	--0.00,	--ISNULL(i.ivh_totalcharge,0.00) ivhtotalcharge, 28087 not used
	@int		missingpaperworkcount,
	@int	stpordmiles,
	@int	triploadmiles,
	@int	tripuloadmiles,
	-- '',   	--i.ivh_batch_id,
	@varchar100 carrier, 	 
	@varchar30 refnumber,	 --29308
	@varchar6  reftype,	
	@varchar60 freight, 	 
	@dec9 shippedvolume,    
	@dec9 shippedweight,    	
	@dec9 deliveredvolume,   
	@dec9 deliveredweight,   
	@varchar6 weightunit, 	
	@varchar6 volumeunit, 	
 	@varchar30 refnumber2,	
        @varchar30 refnumberlul,	-- 28089 - ref num from first lul stop  -- 29308 
	@varchar6  refnumberlultype	-- 28089  
FROM 	#biglist b, orderheader o, company bcmp, company scmp, 
		company ccmp, city ccty, city scty  --, invoiceheader i
WHERE	o.ord_hdrnumber = b.ord_hdrnumber
--AND	i.ivh_hdrnumber =* b.ivh_hdrnumber
AND	bcmp.cmp_id = o.ord_billto
AND	scmp.cmp_id = o.ord_originpoint
AND	scty.cty_code = o.ord_origincity
AND	ccmp.cmp_id = o.ord_destpoint
AND	ccty.cty_code = o.ord_destcity
----28087:

UPDATE #ostat
SET	
ivhinvoicenumber  = ISNULL(i.ivh_invoicenumber,''),
ivhinvoicestatus  = ISNULL(i.ivh_invoicestatus,''), 
ivhmbstatus       = ISNULL(i.ivh_mbstatus,'')
--ivhtotalcharge    = ISNULL(i.ivh_totalcharge,0.00) 28087 not used
from invoiceheader i
where
i.ord_hdrnumber = #ostat.ord_hdrnumber  --28087
and ISNULL(i.ivh_creditmemo ,'N') = 'N'   --28087  

-- sum the order miles
UPDATE	#ostat
SET	stpordmiles = (SELECT SUM(ISNULL(stp_ord_mileage,0))
			FROM	stops
			WHERE	stops.ord_hdrnumber = #ostat.ord_hdrnumber
			)

-- sum the loaded miles for the trip (may include other orders
UPDATE	#ostat
SET	triploadmiles = (SELECT SUM(ISNULL(stp_lgh_mileage,0))
			FROM	stops
			WHERE	stops.mov_number = #ostat.mov_number
			AND	stp_loadstatus = 'LD'	
			)

-- sum the unloaded miles for the entire trip 
UPDATE	#ostat
SET	tripuloadmiles = (SELECT SUM(ISNULL(stp_lgh_mileage,0))
			FROM	stops
			WHERE	stops.mov_number = #ostat.mov_number
			AND	(stops.stp_loadstatus IS NULL
				OR
				 stops.stp_loadstatus = 'MT')
			)
update #ostat set carrier = car_name from carrier, orderheader
where orderheader.ord_hdrnumber = #ostat.ord_hdrnumber
and ord_carrier = car_id

-- determine the stp_number and lgh_number of the last leg of the trip
/* 27173:
UPDATE #ostat
SET		laststpnumber = stp_number,
		lastlghnumber = lgh_number
FROM	#ostat, stops
WHERE	stops.mov_number = #ostat.mov_number
AND	stp_sequence = (SELECT max(stp_sequence)
			FROM stops
			WHERE mov_number = #ostat.mov_number
			AND  stops.ord_hdrnumber = #ostat.ord_hdrnumber)
*/
/* 27173:
UPDATE #ostat
SET	lastlghoutstatus = lgh_outstatus,
	lastlghdriver = lgh_driver1,
	lastlghtractor = lgh_tractor,
	lastlghtrailer = lgh_primary_trailer
FROM	legheader, #ostat
WHERE	legheader.lgh_number = lastlghnumber
*/
-- check for any missing paperwork
UPDATE #ostat
SET	missingpaperworkcount = (SELECT COUNT(*)
			FROM	paperwork
			WHERE	paperwork.ord_hdrnumber = #ostat.ord_hdrnumber
			AND	pw_received = 'N')
UPDATE #ostat
SET	missingpaperworkcount = 1
FROM    #ostat
WHERE	missingpaperworkcount > 0	

----- 26963: ---------------------------------------------
--Carrier from 1st stop on the order:
/* 37750 removed this stmt:
it causes a 'Subquery returned more than 1 value... ' error if an order is a crossdock 
i.e., if an order has multiple moves. 
UPDATE	#ostat
SET	carrier = 
(
select car_name  from legheader, carrier
where legheader.lgh_number  = 
 (select lgh_number from stops  
  where stp_number = 
	(
	select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
	stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber) 
	)
 )
 and lgh_carrier = car_id
)
end 37750
*/


--Primary ref number and reftype: (for now just supply reftype abbr)
UPDATE	#ostat
SET	refnumber = ref_number, reftype = ref_type 
from referencenumber
where referencenumber.ord_hdrnumber = #ostat.ord_hdrnumber and ref_table = 'orderheader' 
and ref_sequence = (select min(ref_sequence) from referencenumber 
		where referencenumber.ord_hdrnumber = #ostat.ord_hdrnumber and ref_table = 'orderheader'
                and ref_type <> @reftype2) 
-- then set reftype = 
-- name from labelfile where labeldefinition = 'Referencenumbers' and abbr = reftype

--2nd reference number using reftype supplied as parm
UPDATE	#ostat
SET	refnumber2 = ref_number
from referencenumber
where referencenumber.ord_hdrnumber = #ostat.ord_hdrnumber and ref_table = 'orderheader' and ref_type = @reftype2

--27264:
UPDATE	#ostat
SET	shipdate = 
(
  select stp_arrivaldate from stops where stp_number  =
  (select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
   stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
   and (stp_event = 'LLD' or stp_event = 'HPL')  ) 
  )
)
--end 27264

UPDATE	#ostat
SET	freight = 
(
  select min(fgt_description) from freightdetail where stp_number  =
  (select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
   stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
   and (stp_event = 'LLD' or stp_event = 'HPL')  ) 
  )
)
 
--shippedvolume = sum(fgt_volume), weightunit = min(fgt_weightunit), volumeunit = min(fgt_volumeunit)  
-- shipped weight, shipped volume, weight unit and volume unit:
UPDATE	#ostat
SET	shippedweight = (select sum(isnull(fgt_weight,0))
from freightdetail where stp_number  =
(select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
and (stp_event = 'LLD' or stp_event = 'HPL'  )) ))
 
 
UPDATE	#ostat
SET	shippedvolume = (select sum(isnull(fgt_volume,0))
from freightdetail where stp_number  =
(select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
and (stp_event = 'LLD' or stp_event = 'HPL'  )) ))
 

UPDATE	#ostat
set weightunit = (select min(isnull(fgt_weightunit,''))
from freightdetail where stp_number  =
(select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
and (stp_event = 'LLD' or stp_event = 'HPL'  )) ))

UPDATE	#ostat
set volumeunit = (select min(isnull(fgt_volumeunit,''))  -- ktk
from freightdetail where stp_number  =
(select stp_number from stops where ord_hdrnumber = #ostat.ord_hdrnumber and 
stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
and (stp_event = 'LLD' or stp_event = 'HPL'  )) ))

-- delivered volume and weight:
UPDATE	#ostat
SET	deliveredvolume =
(
select sum (ISNULL(fgt_volume,0)) from freightdetail, stops 
where freightdetail.stp_number  = stops.stp_number
and ord_hdrnumber = #ostat.ord_hdrnumber and stp_event = 'LUL'
)

UPDATE	#ostat
SET	deliveredweight =
(
select sum (ISNULL(fgt_weight,0)) from freightdetail, stops 
where freightdetail.stp_number  = stops.stp_number
and ord_hdrnumber = #ostat.ord_hdrnumber and stp_event = 'LUL'
)
 
----- end 26963 ---------------------------------

-- 27264: get the delivery date from the LAST LUL
UPDATE	#ostat
SET	deliverydate =
(
	select stp_arrivaldate from stops 
	where ord_hdrnumber = #ostat.ord_hdrnumber  -- and stp_event = 'LUL' 37091
	and stp_type = 'DRP' -- 37091
   	and stp_sequence = (select max(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
   	--and (stp_event = 'LUL')  )  37091
	and (stp_type = 'DRP')  )  -- 37091 
)
--end 27264

--28089: get the first stop reference number from the first LUL  
UPDATE	#ostat
SET	refnumberlul =
(
	select stp_refnum from stops 
	where ord_hdrnumber = #ostat.ord_hdrnumber and stp_event = 'LUL'
   	and stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
   	and (stp_event = 'LUL')  ) 
)
UPDATE	#ostat
SET	refnumberlultype =
(
	select stp_reftype from stops 
	where ord_hdrnumber = #ostat.ord_hdrnumber and stp_event = 'LUL'
   	and stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = #ostat.ord_hdrnumber
   	and (stp_event = 'LUL')  ) 
)
--end 28089

if @spreadsheet = 'Y'
begin
	select 
	ord_hdrnumber [Ord_hdrnumber],
	ord_number [Order],   
	ord_status [Status], 
	ord_invoicestatus [Inv. Status], 
	ord_totalweight [Tot. Wt.], 
	ord_weightunit [Wt. Unit], 
	ord_totalvolume  [Tot. Vol.],  	
	ord_volumeunit [Vol. Unit], 
	shipdate	[Ship Date],	
    deliverydate	[Delivery Date],
	billtoname [Bill-to], 
	shippername [Shipper], 
	shippercty_name [City], 
	shippercty_state [St.], 
	consigneename [Consignee], 
	consigneecty_name [City], 
	consigneecty_state [St],   
	missingpaperworkcount [Missing Paperwork],  
	stpordmiles [Stop Ord Miles],  
	triploadmiles [Trip Ld Miles],  
	tripuloadmiles [Trip UnLd Miles],  
	carrier [Carrier],
	refnumber + ' (' + reftype + ')' [Ref. Number] , 
	freight [Freight]    
	from #ostat order by deliverydate  
end
else
begin 
select 
    ord_number [Order],    
	ord_hdrnumber [Ord_hdrnumber], 
	ord_status [Status], 
	ord_invoicestatus [Inv. Status], 
    convert(Varchar(10),ord_totalweight) + ' ' + ord_weightunit [Tot. Wt.],  	-- ord_weightunit, 
    convert(Varchar(10),ord_totalvolume) + ' ' + ord_volumeunit [Tot. Vol.],   	--ord_volumeunit, 
	shipdate	[Ship Date],	
    deliverydate		[Delivery Date],
	billtoname [Bill-to], 
	shippername + ', ' + shippernmstct [Shipper],       	
	consigneename + ', ' + consigneenmstct [Consignee],  	   
	missingpaperworkcount [Missing Paperwork],  
	stpordmiles [Stop Ord Miles],  
	triploadmiles [Trip Ld Miles],  
	tripuloadmiles [Trip UnLd Miles],  
	carrier [Carrier],
	refnumber + ' (' + reftype + ')' [Ref. Number] , 
	--reftype, 
	freight [Freight]    
	from #ostat order by deliverydate  
end
GO
GRANT EXECUTE ON  [dbo].[estatOSRpt_sp] TO [public]
GO
