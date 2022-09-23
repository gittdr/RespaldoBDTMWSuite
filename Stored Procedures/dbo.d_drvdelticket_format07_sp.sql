SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE    PROCEDURE [dbo].[d_drvdelticket_format07_sp]
	@revtype1 	VARCHAR(6),
	@drv		VARCHAR(8), 
	@ordnum		VARCHAR(12),
	@status 	VARCHAR(15),
	@startdate	DATETIME,
	@enddate	DATETIME

AS
/**
 * 
 * NAME:
 * d_drvdelticket_format07_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns result set for delivery ticket 07.  Need Shipper (fgt_shipper) field
 * completed for correct shipper/consignee pairing.
 *
 * RETURNS: 
 *
 * RESULT SETS: see return set
 *
 * PARAMETERS:
 *  @revtype1 	VARCHAR(6)
 *	@drv		VARCHAR(8)
 *	@ordnum		VARCHAR(12)
 *	@status 	VARCHAR(15)
 *	@startdate	DATETIME
 *	@enddate	DATETIME
 *
 *
 * REVISION HISTORY:
 * 10/22/07 EMK - PTS 38817 - Changed quantity to volume for products 1-5.
 *							- Explicitly create #temp_ord 
 * 11/13/07 EMK - PTS 40325 - Product shipper should default to first live load.
 *							- Renamed temporary tables for clarity 
 * 11/15/07 EMK - PTS 40325 - Product shipper should default to first live load with that commodity
 *							- Readded check for status
 * 11/26/07 EMK - PTS 40325 - Customer needs to pull weight or count also.
 *  1/11/08 DPETE 40928 - customer reports commodities are not printing on this format
 * 2/25/08 DPETE PTS 41568 now customer is picking up more than one commodity per stop and needs us to 
 *                   determine the pickup location of the delivered commodity.
 * 3/4/08 BDH PTS 41044 - Cust would like the remarks switched from the shipper & consignee's profile to the 
						comments form the stop record.s
*/
DECLARE @varchar100 	VARCHAR(100),
		@varchar40 		VARCHAR(40),
		@varchar60 		VARCHAR(60),
		@varchar20 		VARCHAR(20),
		@varchar254		VARCHAR(254),
		@varchar400		VARCHAR(400)

CREATE TABLE #delivticket (
	tmp_id				INTEGER 		IDENTITY(1,1), 
	ord_hdrnumber		INTEGER			NULL,
	ord_number			VARCHAR(12) 	NULL,
	startdate			DATETIME		NULL,
	driver1				VARCHAR(8)		NULL,
	driver1_name		VARCHAR(100)	NULL,
	driver2				VARCHAR(8)		NULL,
	driver2_name		VARCHAR(100)	NULL,
	tractor				VARCHAR(8)		NULL,
	trailer				VARCHAR(13)		NULL,
	fgt_number 			INTEGER			NULL,
	cmd_code			VARCHAR(8)		NULL,
	fgt_quantity		FLOAT			NULL,	
	billto				VARCHAR(8)		NULL,
	billto_name			VARCHAR(100)	NULL,
	shipper 			VARCHAR(8)		NULL,
	shipper_name		VARCHAR(100)	NULL,
	shipper_address1	VARCHAR(100)	NULL,
	shipper_address2	VARCHAR(100)	NULL,
	shipper_ctstzip		VARCHAR(40)		NULL,
	shipper_phone		VARCHAR(20)		NULL,
	loading_remarks		VARCHAR(254)	NULL,
	consignee			VARCHAR(8)		NULL,
	consignee_name		VARCHAR(100)	NULL,
	consignee_address1	VARCHAR(100)	NULL,
	consignee_address2	VARCHAR(100)	NULL,
	consignee_ctstzip	VARCHAR(40)		NULL,
	consignee_phone		VARCHAR(20)		NULL,
	delivery_remarks	VARCHAR(254)	NULL,
	directions			VARCHAR(400)	NULL,
	fgt_sequence		INTEGER			NULL,
	lgh_number			INTEGER			NULL,
	stp_number			INTEGER			NULL,
	stp_schdtlatest		DATETIME		NULL,
	evt_pu_dr			VARCHAR(6)		NULL,	
	firstpup_sequence	INTEGER			NULL,
 	prod1				VARCHAR(60)		NULL,
	quant1				FLOAT			NULL,
	prod2				VARCHAR(60)		NULL,
	quant2				FLOAT			NULL,
	prod3				VARCHAR(60)		NULL,
	quant3				FLOAT			NULL,
	prod4				VARCHAR(60)		NULL,
	quant4				FLOAT			NULL,
	prod5				VARCHAR(60)		NULL,
	quant5				FLOAT			NULL,
	relpu1				VARCHAR(30) 	NULL,
	relpu2				VARCHAR(30) 	NULL,
	other1				VARCHAR(30) 	NULL,
	other2				VARCHAR(30) 	NULL,
	ponumber			VARCHAR(30) 	NULL,
	extrainfo1			VARCHAR(30) 	NULL,
	extrainfo2			VARCHAR(30) 	NULL,
	lgh_mfh_number		INTEGER			NULL,
	)

CREATE TABLE #temp_ord (
	ord_hdrnumber INTEGER,
	evt_driver1 VARCHAR(8),
	lgh_number INTEGER
)

CREATE TABLE #tempfreight(
fgt_number 			INTEGER			NULL,
cmd_code			VARCHAR(8)		NULL,
fgt_quantity		FLOAT			NULL,	
fgt_sequence		INTEGER			NULL,
fgt_description		VARCHAR(60)		NULL,
fgt_volume			FLOAT			NULL,  
fgt_weight			FLOAT			NULL,
fgt_count			decimal(10,2)	NULL,
stp_number			INTEGER			NULL,
fgt_shipper			VARCHAR(8)		NULL,
ord_hdrnumber		INTEGER			NULL,
firstpup_sequence	INTEGER			NULL
) 

--create a temp table to hold the ord_hdrnumber based on event and stop.
/*
Insert into   #temp_ord
select distinct event.ord_hdrnumber,evt_driver1,lgh_number
from   event
join stops stp on event.stp_number = stp.stp_number
join orderheader ord on event.ord_hdrnumber = ord.ord_hdrnumber
where  @drv in ('UNKNOWN',  event.evt_driver1) and
	evt_startdate  >= @startdate AND
	evt_enddate <= @enddate and
	event.ord_hdrnumber <> 0 and
	@revtype1 in (ord.ord_revtype1,'UNK') 
	and IsNull(@ordnum,'0') in ('0',ord.ord_number)
group by event.ord_hdrnumber,evt_driver1,lgh_number
*/
Insert into   #temp_ord
select distinct stops.ord_hdrnumber,lgh_driver1,lh.lgh_number
from legheader lh
join stops on lh.lgh_number = stops.lgh_number
join orderheader ord on stops.ord_hdrnumber = ord.ord_hdrnumber
where @drv in ('UNKNOWN',lgh_driver1)
and lgh_startdate >= @startdate
and lgh_enddate <= @enddate
and stops.ord_hdrnumber > 0
and @revtype1 in (ord.ord_revtype1,'UNK')
and IsNull(@ordnum,'0') in ('0',ord.ord_number)



SELECT @status = ',' + LTRIM(RTRIM(ISNULL(@status, ''))) + ','

INSERT INTO #tempfreight
SELECT 
	fgt.fgt_number,
	fgt.cmd_code,
	fgt.fgt_quantity,	
	fgt.fgt_sequence,
	fgt.fgt_description,
	fgt.fgt_volume,
	fgt.fgt_weight,  --40325 11/26/07 Add weight and count
	fgt.fgt_count,
	fgt.stp_number,
	isnull(fgt.fgt_shipper,'UNKNOWN') fgt_shipper ,
	stp.ord_hdrnumber,
	--PTS 40325 11/15/07 EMK
	(SELECT min(stops.stp_mfh_sequence) from stops
	JOIN freightdetail fgt2 on fgt2.stp_number = stops.stp_number
	where stops.ord_hdrnumber = tmp.ord_hdrnumber and stops.stp_event = 'LLD'
	and fgt2.cmd_code = fgt.cmd_code) firstpup_sequence
	--PTS 40325 11/15/07 EMK
from freightdetail fgt
JOIN stops stp on fgt.stp_number = stp.stp_number
JOIN #temp_ord tmp ON (stp.lgh_number = tmp.lgh_number and stp.ord_hdrnumber = tmp.ord_hdrnumber)
JOIN event evt ON stp.stp_number = evt.stp_number
where evt.evt_pu_dr = 'DRP'

/*
--Update temporary freight records with NULL shippers. Set them to the first LLD on the order
update #tempfreight set fgt_shipper = m2.cmp_id
from #tempfreight fgt
JOIN (
select IsNull(fgt.fgt_shipper,stp.cmp_id) cmp_id, fgt.fgt_number 
from stops stp
JOIN #tempfreight fgt on (stp.ord_hdrnumber = fgt.ord_hdrnumber and stp.stp_mfh_sequence = fgt.firstpup_sequence)
) m2 on m2.fgt_number = fgt.fgt_number
*/
-- if freight shipper is not set first try the first PUP stop with the same commodity
if exists (select 1 from #tempfreight where fgt_shipper = 'UNKNOWN')
  update #tempfreight
   set fgt_shipper = case fgt_shipper
--41568 make it work for multiple commodities at a stop
--  when 'UNKNOWN' then isnull((select top 1 cmp_id from stops s2 where s2.ord_hdrnumber = #tempfreight.ord_hdrnumber and s2.stp_type = 'PUP'   
      when 'UNKNOWN' then isnull((select top 1 cmp_id from stops s2 
                          join freightdetail f2 on s2.stp_number = f2.stp_number 
                           where s2.ord_hdrnumber = #tempfreight.ord_hdrnumber and s2.stp_type = 'PUP'
                            and f2.cmd_code = #tempfreight.cmd_code order by stp_mfh_sequence),'UNKNOWN')
     else fgt_shipper
     end
  where fgt_shipper = 'UNKNOWN'
-- if freight shipper is not set first try the first PUP stop 
if exists (select 1 from #tempfreight where fgt_shipper = 'UNKNOWN')
  update #tempfreight
   set fgt_shipper = case fgt_shipper
     when 'UNKNOWN' then isnull((select top 1 cmp_id from stops s2 where s2.ord_hdrnumber = #tempfreight.ord_hdrnumber and s2.stp_type = 'PUP'),'UNKNOWN')
     else fgt_shipper
     end
  where fgt_shipper = 'UNKNOWN'

INSERT INTO #delivticket
SELECT
	ord.ord_hdrnumber,
	ord.ord_number,
	ord_origin_earliestdate,
	evt.evt_driver1,
	IsNull(mpp.mpp_firstname,'') + ' ' + IsNull(mpp.mpp_lastname,'') driver1_name,
	evt.evt_driver2,
	IsNull(mpp2.mpp_firstname,'') + ' ' + IsNull(mpp2.mpp_lastname,'') driver2_name,
	lgh.lgh_tractor,
	lgh.lgh_primary_trailer,
	fgt.fgt_number,
	fgt.cmd_code,
	fgt.fgt_quantity,
	ord.ord_billto billto,
	cmp_bill.cmp_name billto_name,
	fgt.fgt_shipper shipper, 
	@varchar100 shipper_name,
	@varchar100 shipper_address1,
	@varchar100 shipper_address2,
	@varchar40 shipper_ctstzip,
	@varchar20 shipper_phone,
	--@varchar254 loading_remarks,  -- 40144 BDH.  Getting loading remarks from the stops table for first 'LLD'
	(select stp_comment from stops where stops.ord_hdrnumber = tmp.ord_hdrnumber and stops.stp_event = 'LLD' and stp_mfh_sequence in 
		(SELECT min(stp_mfh_sequence)from stops where stops.ord_hdrnumber = tmp.ord_hdrnumber and stops.stp_event = 'LLD')) loading_remarks,
	-- 40144 end
	stp.cmp_id consignee,
	@varchar100 consignee_name,
	@varchar100 consignee_address1,
	@varchar100 consignee_address2,
	@varchar40 consignee_ctstzip,
	@varchar20 consignee_phone,	
	--@varchar254 delivery_remarks, 40144 BDH getting delivery remarks from stops record for 'LUL'
	stp_comment delivery_remarks,
	-- 40144 end
	@varchar400 directions,
	fgt.fgt_sequence,
	tmp.lgh_number,
	stp.stp_number,
	stp.stp_schdtlatest,
	evt.evt_pu_dr,
	(SELECT min(stp_mfh_sequence)from stops where stops.ord_hdrnumber = tmp.ord_hdrnumber and stops.stp_event = 'LLD') firstpup_sequence,  -- First PUP on the Leg
	--PTS 40325 11/26/07 Added quantity,weight and count options to product and quantity retrieval
	--Prod/Quant 1
	(SELECT fgt_description from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 1 and p.fgt_shipper = fgt.fgt_shipper) prod1,
	(SELECT 	(case when fgt_quantity > 0 then fgt_quantity 
						else
							case when fgt_volume >0 then fgt_volume 
							else
								case when fgt_weight > 0 then fgt_weight 
								else
									case when fgt_count >0 then fgt_count 
									else 0 
									end 
								end 
							end 
						end) from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 1 and p.fgt_shipper = fgt.fgt_shipper) quant1,
	--Prod/Quant 2
	(SELECT fgt_description from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 2 and p.fgt_shipper = fgt.fgt_shipper) prod2,
	(SELECT 	(case when fgt_quantity > 0 then fgt_quantity 
						else
							case when fgt_volume >0 then fgt_volume 
							else
								case when fgt_weight > 0 then fgt_weight 
								else
									case when fgt_count >0 then fgt_count 
									else 0 
									end 
								end 
							end 
						end) from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 2 and p.fgt_shipper = fgt.fgt_shipper) quant2,
	(SELECT fgt_description from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 3 and p.fgt_shipper = fgt.fgt_shipper) prod3,
	--Prod/Quant 3
	(SELECT 	(case when fgt_quantity > 0 then fgt_quantity 
						else
							case when fgt_volume >0 then fgt_volume 
							else
								case when fgt_weight > 0 then fgt_weight 
								else
									case when fgt_count >0 then fgt_count 
									else 0 
									end 
								end 
							end 
						end) from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 3 and p.fgt_shipper = fgt.fgt_shipper) quant3,
	(SELECT fgt_description from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 4 and p.fgt_shipper = fgt.fgt_shipper) prod4,
	--Prod/Quant 4
	(SELECT 	(case when fgt_quantity > 0 then fgt_quantity 
						else
							case when fgt_volume >0 then fgt_volume 
							else
								case when fgt_weight > 0 then fgt_weight 
								else
									case when fgt_count >0 then fgt_count 
									else 0 
									end 
								end 
							end 
						end) from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 4 and p.fgt_shipper = fgt.fgt_shipper) quant4,
	(SELECT fgt_description from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 5 and p.fgt_shipper = fgt.fgt_shipper) prod5,
	--Prod/Quant 5
	(SELECT 	(case when fgt_quantity > 0 then fgt_quantity 
						else
							case when fgt_volume >0 then fgt_volume 
							else
								case when fgt_weight > 0 then fgt_weight 
								else
									case when fgt_count >0 then fgt_count 
									else 0 
									end 
								end 
							end 
						end) from #tempfreight p where p.stp_number = stp.stp_number and p.fgt_sequence = 5 and p.fgt_shipper = fgt.fgt_shipper) quant5,
	(SELECT	MIN(ref_number)FROM	referencenumber WHERE ref_tablekey = tmp.ord_hdrnumber AND ref_type = 'RL/PU1' AND ref_table = 'orderheader') relpu1,
	(SELECT	MIN(ref_number)FROM	referencenumber WHERE ref_tablekey = tmp.ord_hdrnumber AND ref_type = 'RL/PU2' AND ref_table = 'orderheader') relpu2,
	(SELECT	MIN(ref_number)FROM	referencenumber WHERE ref_tablekey = tmp.ord_hdrnumber AND ref_type = 'OTH1' AND ref_table = 'orderheader') other1,
	(SELECT	MIN(ref_number)FROM	referencenumber WHERE ref_tablekey = tmp.ord_hdrnumber AND ref_type = 'OTH2' AND ref_table = 'orderheader') other2,
	(SELECT	MIN(ref_number)FROM	referencenumber WHERE ref_tablekey = tmp.ord_hdrnumber AND ref_type = 'PO' AND ref_table = 'orderheader') ponumber,
	ord_extrainfo1,
	ord_extrainfo2,
	IsNull(lgh.mfh_number,999) lgh_mfh_number
FROM #tempfreight fgt
	JOIN stops stp on fgt.stp_number = stp.stp_number
	JOIN #temp_ord tmp ON (stp.lgh_number = tmp.lgh_number and stp.ord_hdrnumber = tmp.ord_hdrnumber)
	JOIN orderheader ord on stp.ord_hdrnumber = ord.ord_hdrnumber
	JOIN event evt ON stp.stp_number = evt.stp_number
	JOIN legheader lgh on tmp.lgh_number = lgh.lgh_number
	JOIN manpowerprofile mpp on mpp.mpp_id = evt.evt_driver1
	JOIN manpowerprofile mpp2 on mpp2.mpp_id = evt.evt_driver2
	JOIN company cmp_bill on cmp_bill.cmp_id = ord.ord_billto 
where evt.evt_pu_dr = 'DRP'
	AND CHARINDEX(',' + ord.ord_status + ',', @status) > 0


--Update the records with NULL shippers. Set them to the first LLD on the order
update #delivticket set shipper = m2.cmp_id
from #delivticket fgt
JOIN (
select IsNull(fgt.shipper,stp.cmp_id) cmp_id, fgt.fgt_number 
from stops stp
JOIN #delivticket fgt on (stp.ord_hdrnumber = fgt.ord_hdrnumber and stp.stp_mfh_sequence = fgt.firstpup_sequence)
) m2 on m2.fgt_number = fgt.fgt_number

--Set the shipper information 
UPDATE #delivticket 
SET #delivticket.shipper_name = c.cmp_name, 
	#delivticket.shipper_address1 = c.cmp_address1, 
	#delivticket.shipper_address2 = c.cmp_address2, 
	#delivticket.shipper_ctstzip = 	
		CASE charindex('/', c.cty_nmstct)
			WHEN 0 THEN c.cty_nmstct + IsNull(c.cmp_zip,'') 
			ELSE substring(c.cty_nmstct,1, (charindex('/', c.cty_nmstct)-1))+ ' ' + IsNull(c.cmp_zip,'')
		END
	--,#delivticket.loading_remarks = c.cmp_misc1  BDH pts 10144 Getting loading remarks from stops record above.
FROM #delivticket 
JOIN company c ON #delivticket.shipper = c.cmp_id


--Set the consignee information 
UPDATE #delivticket 
SET #delivticket.consignee_name = c.cmp_name, 
	#delivticket.consignee_address1 = c.cmp_address1, 
	#delivticket.consignee_address2 = c.cmp_address2, 
	#delivticket.consignee_ctstzip = 	
		CASE charindex('/', c.cty_nmstct)
			WHEN 0 THEN c.cty_nmstct + IsNull(c.cmp_zip,'') 
			ELSE substring(c.cty_nmstct,1, (charindex('/', c.cty_nmstct)-1))+ ' ' + IsNull(c.cmp_zip,'')
		END,
	--#delivticket.delivery_remarks = c.cmp_misc1,  -- BEH pts 40144 getting delivery remarks from stops record above.
	#delivticket.consignee_phone = c.cmp_primaryphone,
	#delivticket.directions = c.cmp_directions
FROM #delivticket 
JOIN company c ON #delivticket.consignee = c.cmp_id

--Delete the duplicate rows
delete from #delivticket
where tmp_id IN (
	select tmp_id
	from #delivticket as dup_rows
	   inner join (
	      select consignee,shipper,ord_hdrnumber, MIN(tmp_id) as min_id
	      from #delivticket
	      group by consignee,shipper,ord_hdrnumber
	      having count(*) > 1
	   ) as good_rows on (good_rows.consignee = dup_rows.consignee 
							and good_rows.shipper = dup_rows.shipper 
							and good_rows.ord_hdrnumber = dup_rows.ord_hdrnumber)
	      and good_rows.min_id <> dup_rows.tmp_id)

select 	tmp_id	, 
	ord_hdrnumber,
	ord_number,
	startdate,
	driver1	,
	driver1_name,
	driver2	,
	driver2_name,
	tractor	,
	trailer	,
	fgt_number ,
	cmd_code,
	fgt_quantity,	
	billto	,
	billto_name	,
	shipper 	,
	shipper_name	,
	shipper_address1,
	shipper_address2,
	shipper_ctstzip	,
	shipper_phone	,
	loading_remarks	,
	consignee	,
	consignee_name	,
	consignee_address1	,
	consignee_address2	,
	consignee_ctstzip,
	consignee_phone	,
	delivery_remarks,
	directions	,
	fgt_sequence,
	lgh_number,
	stp_number,
	stp_schdtlatest	,
	evt_pu_dr,	
	firstpup_sequence,
 	prod1	,
	quant1	,
	prod2	,
	quant2,
	prod3,
	quant3	,
	prod4	,
	quant4	,
	prod5,
	quant5	,
	relpu1	,
	relpu2	,
	other1	,
	other2	,
	ponumber	,
	extrainfo1	,
	extrainfo2	,
	lgh_mfh_number	
from #delivticket

drop table #delivticket
drop table #tempfreight
drop table #temp_ord


GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format07_sp] TO [public]
GO
