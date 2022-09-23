SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create procedure [dbo].[d_ctx_plan_ord_sp]
	@allowsitting_time  integer,
	@checkcall_req integer,
        @brown_time     integer,
	@yellow_time   integer
as 
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
--vmj1+	PTS 16885	01/24/2003	This SP has been replaced by CTX's version.
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare @CurrentTime datetime

select @CurrentTime = getdate()

--vmj2+	PTS 18451	06/26/2003	Move color selection out to a temp table so it may be 
--refined further..
create table #lgh
		(lgh_number		int			null
		,color			smallint	null
		,min_stp_eta	datetime	null)


--Get the scope of legheaders, and the minimum unactualized stp_arrivaldate for each..
insert	#lgh
		(lgh_number
		,min_stp_eta)
  select c.lgh_number
		,isnull(min(s.stp_eta), convert(datetime, '2049-12-31 23:59:00'))
  from	stops s RIGHT OUTER JOIN ctx_active_legs c ON s.lgh_number = c.lgh_number
  where	c.lgh_outstatus <> 'CMP' 
	and	c.lgh_load_origin is null
	and	s.stp_status = 'OPN'
	and	s.stp_arrivaldate between '1950-12-31' and '2049-01-01'
  group by c.lgh_number

--Supply the color value - these are the original calculations..
update	#lgh
  set	color = case
			when c.lgh_outstatus = 'MPN' then 3									--Blue
			when c.lul_eta is null
				and c.disp_loaded = 'Y' then 7									--Purple
			when c.lld_eta is null
				and (c.disp_for_pu = 'Y' 
					or c.lgh_outstatus = 'PLN') then 7							--Purple
			when c.lgh_outstatus = 'AVL' 
				and c.no_response = 'Y' then 4									--Navy Blue
			when c.lgh_outstatus in ('STD', 'PLN', 'DSP')
				and c.lld_arrivalstatus = 'OPN' 
				and datediff(mi, @CurrentTime, c.lld_arrivaltime) < @yellow_time 
				then 1															--Yellow
			when c.lgh_outstatus = 'STD' 
				and c.lld_departurestatus = 'DNE'
				and c.lul_arrivalstatus = 'OPN' 
				and datediff(mi, @CurrentTime, c.lul_arrivaltime) < @yellow_time 
				then 1															--Yellow
			when c.lld_arrivalstatus = 'DNE' 
				and	c.lld_departurestatus = 'OPN'
				and datediff(mi, c.lld_arrivaltime, @CurrentTime) > @allowsitting_time 
				then 2															--Green
			when c.lul_arrivalstatus = 'DNE'  
				and datediff(mi, c.lul_arrivaltime, @CurrentTime) > @allowsitting_time 
				then 2															--Green
			when isnull(datediff(mi, c.last_ckc_time, c.lul_arrivaltime), 
						@brown_time + 1) > @brown_time 
				and	c.lgh_outstatus = 'STD' 
				and c.lld_departurestatus = 'DNE' 
				and	c.lul_arrivalstatus = 'OPN' 
				and datediff(mi, @CurrentTime, c.lul_arrivaltime) < @brown_time 
				and	c.chryslercmp = 'Y' then 6									--Light Brown
			when c.lgh_outstatus = 'STD' 
				and	c.lld_departurestatus = 'DNE' 
				and	c.lul_arrivalstatus = 'OPN' 
				and	isnull(datediff(mi, c.last_ckc_time, @CurrentTime), 
							@checkcall_req + 1) > @checkcall_req 
				and	datediff(mi, c.lld_departuretime, @CurrentTime) > @checkcall_req 
				then 5															--Red
			else 0
			end
  from	#lgh l
		,ctx_active_legs c
  where	c.lgh_number = l.lgh_number

--For any row whose color is 0, use the minimum unactualized stop time on the entire trip.
--This catches extra PUPs & DRPs whose deadlines have passed..
update	#lgh
  set	color = 1
  from	#lgh l
		,ctx_active_legs c
  where	l.color = 0
	and	c.lgh_number = l.lgh_number
	and	c.lgh_outstatus in ('STD', 'PLN', 'DSP')
	and (isnull(c.lld_arrivalstatus, 'OPN') = 'OPN' 
		or isnull(c.lul_arrivalstatus, 'OPN') = 'OPN')
	and datediff(mi, @CurrentTime, l.min_stp_eta) < (@yellow_time * -1)


--Final Select..
--vmj2-	NOTE: I added a "c." to the front of all column names below, but these are not 
--		marked with vmj2..
select	c.lgh_number, 
		c.ord_number, 
		c.ord_hdrnumber, 
		c.origin_cmp_id, 
		case upper(c.origin_cmp_name) when 'UNKNOWN' then '' else c.origin_cmp_name end origin_cmp_name, 
		c.dest_cmp_id, 
		c.dest_cmp_name, 
		c.orderby_cmp_id, 
		c.orderby_cmp_name, 
		c.orderby_cty_nmstct, 
		c.billto_cmp_id, 
		c.billto_cmp_name, 
		c.billto_cty_nmstct, 
		c.lgh_outstatus, 
		c.lgh_startdate, 
		c.lgh_completiondate, 
		c.lgh_origincity, 
		c.lgh_destcity, 
		c.lgh_originstate, 
		c.lgh_deststate, 
		c.ord_revtype1, 
		c.orderheader_ord_revtype1_t, 
		c.ord_revtype2, 
		c.orderheader_ord_revtype2_t, 
		c.ord_revtype3, 
		c.orderheader_ord_revtype3_t, 
		c.ord_revtype4, 
		c.orderheader_ord_revtype4_t, 
		c.mov_number, 
		c.ord_charge, 
		c.ord_totalcharge, 
		c.ord_totalweight, 
		c.ord_totalpieces, 
		c.ord_accessorial_chrg, 
		case upper(c.ord_priority) when 'UNK' then '' else c.ord_priority end ord_priority, 
		c.ord_originregion1, 
		c.ord_destregion1, 
		c.ord_reftype, 
		c.ord_refnum, 
		c.ord_invoicestatus, 
		case upper(c.origin_cty_nmstct) when 'UNKNOWN' then '      ' else c.origin_cty_nmstct end origin_cty_nmstct, 
		case upper(c.dest_cty_nmstct) when 'UNKNOWN' then '       ' else c.dest_cty_nmstct end dest_cty_nmstct, 
		c.lld_arrivaltime, 
		c.lld_departuretime, 
		c.lld_arrivalstatus, 
		c.lld_departurestatus, 
		c.lul_arrivaltime, 		
		c.lul_departuretime, 
		c.lul_arrivalstatus, 
		DateDiff ( mi, @CurrentTime, c.lld_arrivaltime ) min_to_arr_lld, 
		DateDiff (mi, c.lld_arrivaltime, @CurrentTime) min_since_arr_lld, 
		DateDiff ( mi, @CurrentTime, c.lul_arrivaltime ) min_to_arr_lul, 
		DateDiff (mi, c.lul_arrivaltime, @CurrentTime) min_since_arr_lul, 
		isnull(DateDiff (mi, c.last_ckc_time, c.lul_arrivaltime),99999) min_ckc_to_arr_lul, 
		c.last_ckc_time, 
		isnull(DateDiff (mi, c.last_ckc_time, @CurrentTime),99999) min_since_last_ckc, 
		c.no_response, 
		case upper(c.lgh_tractor) when 'UNKNOWN' then '' else c.lgh_tractor end lgh_tractor, 
		c.lgh_driver, 
		c.lgh_load_origin, 
		c.disp_for_pu, 
		c.disp_loaded, 
		c.chryslercmp, 

		--vmj2+
		l.color,
		/* Original code
		case when lgh_outstatus = 'MPN' then 3
		when lul_eta IS NULL AND disp_loaded = 'Y' THEN 7
		WHEN lld_eta IS NULL AND (disp_for_pu = 'Y' OR lgh_outstatus = 'PLN') THEN 7
		when  lgh_outstatus = 'AVL' AND	no_response = 'Y' then 4
		 * PTS13728 MBR 3/25/02 Added DSP to in clause *
		when lgh_outstatus IN ('STD', 'PLN', 'DSP')  AND lld_arrivalstatus = 'OPN' and
			DateDiff ( mi, @CurrentTime, lld_arrivaltime ) < @yellow_time then 1

		when lgh_outstatus IN ('STD') AND lld_departurestatus = 'DNE' AND
			lul_arrivalstatus = 'OPN' and DateDiff ( mi, @CurrentTime, lul_arrivaltime ) < @yellow_time then 1
		when lld_arrivalstatus = 'DNE' AND lld_departurestatus = 'OPN' and
			DateDiff (mi, lld_arrivaltime, @CurrentTime) > @allowsitting_time then 2
		when lul_arrivalstatus = 'DNE'  AND DateDiff (mi, lul_arrivaltime, @CurrentTime) > @allowsitting_time then 2
		when isnull(DateDiff (mi, last_ckc_time, lul_arrivaltime),@brown_time + 1) > @brown_time AND lgh_outstatus = 'STD' and
			lld_departurestatus = 'DNE' AND	lul_arrivalstatus = 'OPN' ANd
			DateDiff ( mi, @CurrentTime, lul_arrivaltime ) < @brown_time AND chryslercmp = 'Y' then 6
		when lgh_outstatus = 'STD' AND lld_departurestatus = 'DNE' AND
			lul_arrivalstatus = 'OPN' AND isnull(DateDiff (mi, last_ckc_time, @CurrentTime),@checkcall_req + 1) > @checkcall_req AND
			DateDiff (mi, lld_departuretime, @CurrentTime) > @checkcall_req then 5
		ELSE 0
		END color, */
		--vmj2-

		c.firststp, 
		c.laststp,
		c.lul_origarrivalstatus,
		c.ordratingunit,
		c.lld_eta,
		c.lul_eta
  --vmj2+
  from	#lgh l
		,ctx_active_legs c
  where	c.lgh_number = l.lgh_number
--  from	ctx_active_legs
--  WHERE  ( lgh_outstatus <> 'CMP' ) and 
--	    ( lgh_load_origin is null ) 


drop table #lgh
--vmj2-


/* Original code..
create procedure d_ctx_plan_ord_sp 
	@allowsitting_time  integer,
	@checkcall_req integer,
        @brown_time     integer,
	@yellow_time   integer
as 
declare @mov_number integer,
	@ord_hdrnumber integer,
	@stoptime datetime,
	@lastckctime datetime,
	@stpdiff integer,
	@currenttime datetime,
	@hourdiff integer,
	@char8   varchar(8),
	@char30  varchar(30),
	@char25  varchar(25),
	@char6   varchar(6),
	@char12  varchar(12),
	@chrysler varchar(64)

create table #temp(
	lgh_number  integer NULL,
	ord_number char (12) NULL ,
        ord_hdrnumber integer null,
        origin_cmp_id varchar(8) null,
        origin_cmp_name varchar(30) null,
        dest_cmp_id varchar(8)null,
        dest_cmp_name varchar(30)null,
        orderby_cmp_id varchar(8) null,
        orderby_cmp_name varchar(30) null,
        orderby_cty_nmstct varchar(25) null,
        billto_cmp_id varchar(8) null,
        billto_cmp_name varchar(30) null,
        billto_cty_nmstct varchar(25) null,
	lgh_outstatus varchar(6)null,
	lgh_startdate datetime null,
	lgh_completiondate datetime null,
        lgh_origincity int null,
	lgh_destcity int null,
	lgh_originstate char(2)null,
	lgh_deststate char(2)null,
	ord_revtype1 varchar(6)null,
	orderheader_ord_revtype1_t varchar(8)null,
	ord_revtype2 varchar(6)null,
	orderheader_ord_revtype2_t varchar(8)null,
	ord_revtype3 varchar(6)null,
	orderheader_ord_revtype3_t varchar(8)null,
	ord_revtype4 varchar(6)null,
	orderheader_ord_revtype4_t varchar(8)null,
	mov_number integer null,
	ord_charge money null,
	ord_totalcharge integer null,
	ord_totalweight integer null,
	ord_totalpieces integer null,
	ord_accessorial_chrg money null,
	ord_priority varchar(6)null,
	ord_originregion1 varchar(6)null,
	ord_destregion1 varchar(6)null,
	ord_reftype varchar(6)null,
	ord_refnum varchar(20)null,
	ord_invoicestatus varchar(6)null,
	origin_cty_nmstct varchar(25)null,
       	dest_cty_nmstct varchar(25)null,
	lld_arrivaltime datetime null,
	lld_departuretime datetime null,
	lld_arrivalstatus char(3) null,
	lld_departurestatus char(3) null,
	lul_arrivaltime datetime null,
	lul_departuretime datetime null,
	lul_arrivalstatus char(3) null,
	min_to_arr_lld int null,
	min_since_arr_lld int null,
	min_to_arr_lul int null,
	min_since_arr_lul int null,	
	min_ckc_to_arr_lul int null,
	last_ckc_time datetime null,
	min_since_last_ckc int null,
	no_response char(1) null,
	lgh_tractor varchar(8) null,
	lgh_driver varchar(8) null,
	lgh_load_origin varchar(12) null,
	disp_for_pu  char(1),
	disp_loaded  char(1),
	chryslercmp char(1)
	, color Int
	, firststp Int null
	, laststp Int null
	--vmj1+	PTS 16882	01/23/2003
	,ordratingunit			varchar(6)	null
	,lul_origarrivalstatus	char(3)		null
	--vmj1-
)

select @currenttime = getdate()

select @chrysler = gi_string1
from   generalinfo
where  gi_name = 'ExpcolorComp'

  insert into #temp
  SELECT	distinct lgh_number,
	  	orderheader.ord_number ,
           	orderheader.ord_hdrnumber,
           	company_a.cmp_id ,
           	company_a.cmp_name ,
           	company_b.cmp_id ,
           	company_b.cmp_name ,
           	company_c.cmp_id ,
	        company_c.cmp_name ,
	        company_c.cty_nmstct ,
	        company_d.cmp_id ,
           	company_d.cmp_name ,
		company_d.cty_nmstct ,
		lgh_outstatus,
		ord_startdate,
		ord_completiondate,
		lgh_startcity,
		lgh_endcity,	
		lgh_startstate,
		lgh_endstate,
		orderheader.ord_revtype1,
		'RevType1' ,
		orderheader.ord_revtype2,
		'RevType2' ,
		orderheader.ord_revtype3,
		'RevType3' ,
		orderheader.ord_revtype4,
		'RevType4' ,
		legheader.mov_number,
		isnull(orderheader.ord_charge,0),
		orderheader.ord_totalcharge,
		orderheader.ord_totalweight,
		orderheader.ord_totalpieces,
		isnull(orderheader.ord_accessorial_chrg,0),
		ord_priority,
		lgh_startregion1,
		lgh_endregion1,
		orderheader.ord_reftype,
		orderheader.ord_refnum,
		orderheader.ord_invoicestatus,
		company_a.cty_nmstct,
           	company_b.cty_nmstct
		,@currenttime 
		,@currenttime 
		,'OPN'
		,'OPN'
		,@currenttime 
		,@currenttime 
		,'OPN'
		,0
		,0	
		,0	
		,0	
		,99999	
		,(select  max(ckc_date)
		  from   checkcall c 
		 where  c.ckc_lghnumber = legheader.lgh_number and
		 	legheader.lgh_outstatus ='STD' and c.ckc_updatedby <> 'TMAIL')
		, 99999
		,'N'
		,lgh_tractor
		,lgh_driver1
		,lgh_load_origin
		,disp_for_pu =
			case 
			WHEN	(SELECT	COUNT(*)
				FROM	stops
				WHERE	stops.lgh_number = legheader.lgh_number
--				  AND	stops.stp_number = event.stp_number
				  AND	lgh_outstatus = 'STD'
				  AND	stp_event = 'LLD'
				  AND	stops.stp_departure_status = 'OPN'
				  AND	stp_sequence = 1 ) > 0
				THEN 'Y'
			when( 	select 	count(*) 
				from 	stops 
				where	stops.lgh_number = legheader.lgh_number 
			    	  AND	lgh_outstatus = 'STD' 
				  AND	stp_event = 'LLD' 
				  and 	stp_status = 'DNE') > 0 
				then 'N' 
			when	lgh_outstatus <> 'STD' 
				then 'N' 
			else 'Y' 
			end

		,disp_loaded =
			case when( select count(*) from stops
			   where  stops.lgh_number = legheader.lgh_number 
--					and stops.stp_number = event.stp_number AND
				  AND lgh_outstatus = 'STD'
				  AND stp_event = 'LLD' and stp_status = 'DNE' 
					AND stp_departure_status = 'DNE') > 0 
			    then 'Y' else 'N' end

		, 'N'
		, 0
		,(SELECT MIN(stp_sequence) 
			FROM stops 
			WHERE stops.ord_hdrnumber = orderheader.ord_hdrnumber AND stops.stp_type = 'PUP')
		,(SELECT MAX(stp_sequence) 
			FROM stops 
			WHERE stops.ord_hdrnumber = orderheader.ord_hdrnumber AND stops.stp_type = 'DRP')
		--vmj1+
		,orderheader.ord_ratingunit
		,'OPN'
		--vmj1-
        FROM    legheader,
		orderheader ,
		company company_a ,
           company company_b ,
           company company_c ,
           company company_d 
        WHERE (legheader.ord_hdrnumber = orderheader.ord_hdrnumber) and
	  ( orderheader.ord_billto = company_d.cmp_id ) and
          ( orderheader.ord_shipper = company_a.cmp_id ) and
          ( orderheader.ord_consignee = company_b.cmp_id ) and
          ( orderheader.ord_company = company_c.cmp_id ) and
	  ( lgh_outstatus <> 'CMP' ) and 
	  ( lgh_active = 'Y') and 
	  ( lgh_load_origin is null )

UPDATE 	#temp
SET	lld_arrivaltime = stp_arrivaldate
	, lld_arrivalstatus = stp_status
	, lld_departuretime = stp_departuredate
	, lld_departurestatus = stp_departure_status
FROM	stops
WHERE	stops.ord_hdrnumber = #temp.ord_hdrnumber
--  AND	stops.stp_number = event.stp_number
  AND	stops.stp_sequence = firststp

UPDATE 	#temp
SET	lul_arrivaltime = stp_arrivaldate
	, lul_arrivalstatus = stp_departure_status
	, lul_departuretime = stp_departuredate
	--vmj1+
	, lul_origarrivalstatus = stp_status
	--vmj1-
FROM	stops
WHERE	stops.ord_hdrnumber = #temp.ord_hdrnumber
--  AND	stops.stp_number = event.stp_number
  AND	stops.stp_sequence = laststp

UPDATE 	#temp
SET 	min_to_arr_lld = DateDiff ( mi, @CurrentTime, lld_arrivaltime )
	, min_since_arr_lld = DateDiff (mi, lld_arrivaltime, @CurrentTime)
	, min_to_arr_lul = DateDiff ( mi, @CurrentTime, lul_arrivaltime )
	, min_since_arr_lul = DateDiff (mi, lul_arrivaltime, @CurrentTime)

UPDATE	#temp
SET	min_since_last_ckc = DateDiff (mi, last_ckc_time, @CurrentTime)
	, min_ckc_to_arr_lul = DateDiff (mi, last_ckc_time, lul_arrivaltime)
WHERE	last_ckc_time IS NOT NULL


UPDATE	#temp
SET	chryslercmp = 'Y'
	WHERE billto_cmp_name LIKE '%' + @chrysler + '%'

UPDATE	#temp
SET	ord_totalweight = (	SELECT 	SUM ( isnull(fgt_weight,0)) 
				FROM 	stops, freightdetail 
				WHERE 	stops.ord_hdrnumber = #temp.ord_hdrnumber
				  AND	stops.stp_number = freightdetail.stp_number 
				  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
	ord_totalpieces =   (	SELECT 	SUM ( isnull(fgt_count,0)) 
				FROM 	stops, freightdetail 
				WHERE 	stops.ord_hdrnumber = #temp.ord_hdrnumber
				  AND	stops.stp_number = freightdetail.stp_number 
				  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' ))

UPDATE	#temp
set 	no_response = CASE
	WHEN EXISTS 	(SELECT *
			FROM 	preplan_assets p1
			WHERE	p1.ppa_lgh_number = lgh_number 
			  AND	lgh_outstatus = 'AVL'
			  AND	p1.ppa_status = 'NO RESPONSE' )
	THEN 'Y'
	ELSE 'N'
	END

UPDATE	#temp
set origin_cty_nmstct = case upper(origin_cty_nmstct) when 'UNKNOWN' then '      ' else origin_cty_nmstct end,
    dest_cty_nmstct = case upper(dest_cty_nmstct) when 'UNKNOWN' then '       ' else dest_cty_nmstct end,
    ord_priority = case upper(ord_priority) when 'UNK' then '' else ord_priority end,
    lgh_tractor = case upper(lgh_tractor) when 'UNKNOWN' then '' else lgh_tractor end,
    origin_cmp_name = case upper(origin_cmp_name) when 'UNKNOWN' then '' else origin_cmp_name end

UPDATE 	#temp
SET	color = 1
WHERE 	lgh_outstatus IN ('STD', 'PLN')
  AND	lld_arrivalstatus = 'OPN' 
  AND 	min_to_arr_lld < @yellow_time
  AND	color = 0

UPDATE 	#temp
SET	color = 1
WHERE 	lgh_outstatus IN ('STD')
  AND	lld_departurestatus = 'DNE' 
  AND	lul_arrivalstatus = 'OPN'
  AND 	min_to_arr_lul < @yellow_time
  AND	color = 0

UPDATE 	#temp
SET	color = 2
WHERE 	lld_arrivalstatus = 'DNE' 
  AND	lld_departurestatus = 'OPN'
  AND 	min_since_arr_lld > @allowsitting_time
  AND	color = 0

UPDATE 	#temp
SET	color = 2
WHERE 	lul_arrivalstatus = 'DNE' 
  AND 	min_since_arr_lul > @allowsitting_time
  AND	color = 0

UPDATE 	#temp
SET	color = 3
WHERE	lgh_outstatus = 'MPN'

UPDATE	#temp
SET	color = 4
WHERE 	lgh_outstatus = 'AVL'
  AND	no_response = 'Y'

UPDATE 	#temp
SET	color = 5
WHERE	lgh_outstatus = 'STD' 
  AND	lld_departurestatus = 'DNE'
  AND	lul_arrivalstatus = 'OPN'
  AND	color = 0
  AND	min_since_last_ckc > @checkcall_req
  AND	DateDiff (mi, lld_departuretime, @CurrentTime) > @checkcall_req

UPDATE 	#temp
SET	color = 6
WHERE	min_ckc_to_arr_lul > @brown_time
  AND	lgh_outstatus = 'STD'
  AND	lld_departurestatus = 'DNE'
  AND	lul_arrivalstatus = 'OPN'
  AND	min_to_arr_lul < @brown_time
  AND	chryslercmp = 'Y'
  AND	(color = 0 or color = 5)

select * from #temp
*/
--vmj1-
GO
GRANT EXECUTE ON  [dbo].[d_ctx_plan_ord_sp] TO [public]
GO
