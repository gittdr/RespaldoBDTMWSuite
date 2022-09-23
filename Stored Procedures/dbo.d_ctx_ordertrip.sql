SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ctx_ordertrip]
	@ord_hdrnumber integer
AS
/**
 * 
 * NAME:
 * dbo.d_ctx_ordertrip
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 * 03/16/2007   PTS36363 - JGUO - Remove index hint on city.pk_code
 * 10/25/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax. change index= to with(index
 * 4/17/08 DPETE PTS42060 recode Pauls Hauling int main source(PTS35279 - jguo - remove index hints and double quotes.)
 * 6/13/11 MCURN PTS57430 Removed hardcoded index hint on company table.
 * 6/19/14 MCURN PTS79441 Removed MORE hardcoded index hints
**/


DECLARE 
	@char8	  	varchar(8),
	@char1		varchar(1),						
	@char30   	varchar(30),
	@char20   	varchar(20),
	@char25   	varchar(25),
	@char40		varchar(40),
	@cmdcount 	int,
	@float		float,
	@hoursbackdate	datetime,
	@hoursoutdate	datetime,
	@gistring1	varchar(60),
	@dttm		datetime,
	@char2		char(2),
	@varchar45	varchar(45),
	@varchar6	varchar(6), 
        @runpups        char(1), 
        @rundrops       char(1), 
        @retvarchar     varchar(3)

CREATE TABLE #temp (
	lgh_number int, 
	o_cmpid varchar(8), 
	o_cmpname varchar(30), 
	o_ctyname varchar(25) null, 
	d_cmpid varchar(8), 
	d_cmpname varchar(30), 
	d_ctyname varchar(25) null, 
	f_cmpid varchar(8) null,
	f_cmpname varchar(30) null,
	f_ctycode int null,
	f_ctyname varchar(25) null,
	l_cmpid varchar(8) null,
	l_cmpname varchar(30) null,
	l_ctycode int null,
	l_ctyname varchar(25) null,
	lgh_startdate datetime null, 
	lgh_enddate datetime null, 
	o_state char(2) null, 
	d_state char(2) null, 
	lgh_schdtearliest datetime null, 
	lgh_schdtlatest datetime null,
	cmd_code varchar(8) null,
	fgt_description varchar(60) null,		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
	cmd_count int null,
	ord_hdrnumber int null, 
	evt_driver1 varchar(45) null, 
	evt_driver2 varchar(45) null, 
	evt_tractor varchar(8) null, 
	lgh_primary_trailer varchar(13) null,
	trl_type1 varchar(6) null,
	evt_carrier varchar(8) null, 
	mov_number int null, 
	ord_availabledate datetime null, 
	ord_stopcount tinyint null, 
	ord_totalcharge float null, 
	ord_totalweight int null, 
	ord_length money null, 
	ord_width money null, 
	ord_height money null, 
	ord_totalmiles int null, 
	ord_number char(12) null, 
	o_city int null, 
	d_city int null,
	lgh_outstatus varchar(6) null, 
	lgh_instatus varchar(6) null, 
	lgh_priority varchar(6) null, 
	ord_subcompany varchar(8) null,
	lgh_class1 varchar(6) null, 
	lgh_class2 varchar(6) null, 
	lgh_class3 varchar(6) null, 
	lgh_class4 varchar(6) null, 
	revlabel1 varchar(20) null, 
	revlabel2 varchar(20) null, 
	revlabel3 varchar(20) null, 
	revlabel4 varchar(20) null, 
	trllabel1 varchar(20) null, 
	ord_bookedby char(20) null,
	lgh_primary_pup varchar(13) null,
	loadtime float null,
	unloadtime float null,
	drivetime float null,
	triptime float null,
	ord_totalweightunits varchar(6) null,
	ord_lengthunit varchar(6) null,
	ord_widthunit varchar(6) null,
	ord_heightunit varchar(6) null,
	unloaddttm datetime null,
	unloaddttm_early datetime null,
	unloaddttm_late datetime null,
	ord_totalvolume int null,
	ord_totalvolumeunits varchar(6) null,
	washstatus varchar(1) null,
	f_state varchar(2) null,	
	l_state varchar(2) null,
	evt_driver1_id varchar(8) null,
	evt_driver2_id varchar(8) null,
	ref_type varchar(6) null,
	ref_number varchar(30) null,
	d_address1 varchar(40) null,
	d_address2 varchar(40) null,
	ord_remark varchar(254) null,
	mpp_teamleader varchar(6) null,
	lgh_dsp_date datetime null,
	lgh_geo_date datetime null,
	ordercount smallint null, 
	xdock int null,
	npup_cmpid varchar(8) null, 
	npup_cmpname varchar(30) null, 
	npup_ctyname varchar(25) null, 
	npup_state varchar(2) null, 
	npup_arrivaldate datetime null, 
	ndrp_cmpid varchar(8) null, 
	ndrp_cmpname varchar(30) null, 
	ndrp_ctyname varchar(25) null, 
	ndrp_state varchar(2) null, 
	ndrp_arrivaldate datetime null, 
	can_ld_expires datetime null,
	feetavailable smallint null,
	opt_trc_type4 varchar(6) null,
	opt_trc_type4_label varchar(20) null,
	opt_trl_type4 varchar(6) null,
	opt_trl_type4_label varchar(20) null,
	ord_originregion1 varchar(6) null,
	ord_originregion2 varchar(6) null,
	ord_originregion3 varchar(6) null,
	ord_originregion4 varchar(6) null,
	ord_destregion1 varchar(6) null,
	ord_destregion2 varchar(6) null,
	ord_destregion3 varchar(6) null,
	ord_destregion4 varchar(6) null
)

CREATE TABLE #1_pups(
	cmp_id		VARCHAR(8), 
	cmp_name	VARCHAR(30), 
	cty_nmstct	VARCHAR(25), 
	stp_state	VARCHAR(20), 
	stp_arrivaldate	DATETIME, 
	ord_hdrnumber	INT) 

CREATE TABLE #1_drps(
	cmp_id		VARCHAR(8), 
	cmp_name	VARCHAR(30), 
	cty_nmstct	VARCHAR(25), 
	stp_state	VARCHAR(20), 
	stp_arrivaldate	DATETIME, 
	ord_hdrnumber	INT) 

-- JET - 6/23/00 - 8309, read in flags to stop update of Next PUP or Next DRP fields
SELECT @runpups = 'N', @rundrops = 'N'

SELECT @retvarchar = gi_string1
  FROM generalinfo 
 WHERE gi_name = 'RunPUPs'
SELECT @runpups = UPPER(SUBSTRING(@retvarchar, 1, 1))

SELECT @retvarchar = gi_string1
  FROM generalinfo 
 WHERE gi_name = 'RunDRPs'
SELECT @rundrops = UPPER(SUBSTRING(@retvarchar, 1, 1))
-- JET - 6/23/00 - 8309

/* Tune the select remove all converts replace with variables --Jude*/
INSERT INTO #temp
SELECT	distinct legheader.lgh_number, 
	company_a.cmp_id o_cmpid, 
	company_a.cmp_name o_cmpname, 
	lgh_startcty_nmstct o_ctyname, 
	company_b.cmp_id d_cmpid, 
	company_b.cmp_name d_cmpname, 
	lgh_endcty_nmstct d_ctyname, 
	orderheader.ord_originpoint f_cmpid,
	@char30  f_cmpname,
	orderheader.ord_origincity f_ctycode,
	@char25 f_ctyname,
	orderheader.ord_destpoint l_cmpid,
	@char30 l_cmpname,
	orderheader.ord_destcity l_ctycode,
	@char25 l_ctyname,
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	lgh_startstate o_state, 
	lgh_endstate d_state, 
--	legheader.lgh_schdtearliest, -- JET 6/3/98 for PTS #3991
--	legheader.lgh_schdtlatest, -- JET 6/3/98 for PTS #3991
	orderheader.ord_origin_earliestdate lgh_schdtearliest, 
	orderheader.ord_origin_latestdate lgh_schdtlatest,
	legheader.cmd_code,
	legheader.fgt_description,
	@cmdcount cmd_count,
	legheader.ord_hdrnumber, 
	@varchar45 evt_driver1, 
	@varchar45 evt_driver2, 
	lgh_tractor evt_tractor, 
	legheader.lgh_primary_trailer,
	orderheader.trl_type1,
	lgh_carrier evt_carrier, 
	legheader.mov_number, 
	orderheader.ord_availabledate, 
	orderheader.ord_stopcount, 
	orderheader.ord_totalcharge, 
	orderheader.ord_totalweight, 
	orderheader.ord_length, 
	orderheader.ord_width, 
	orderheader.ord_height, 
	orderheader.ord_totalmiles, 
	case isnull(upper(lgh_split_flag),'N')
	when 'S' then substring(rtrim(orderheader.ord_number)+'*',1,12)
	when 'F' then substring(rtrim(orderheader.ord_number)+'*',1,12)
	else orderheader.ord_number
	end 'ord_number', 
	lgh_startcity o_city, 
	lgh_endcity d_city,
	legheader.lgh_outstatus, 
	legheader.lgh_instatus, 
	legheader.lgh_priority, 
	orderheader.ord_subcompany,
	legheader.lgh_class1, 
	legheader.lgh_class2, 
	legheader.lgh_class3, 
	legheader.lgh_class4,
	@char20 revlabel1,
	@char20 revlabel2,
	@char20 revlabel3,
	@char20 revlabel4,
	@char20 trllabel1,
	orderheader.ord_bookedby,
	legheader.lgh_primary_pup,
	ord_loadtime loadtime,
	ord_unloadtime unloadtime,
	ord_drivetime drivetime,
	@float triptime,
	ord_totalweightunits,
	ord_lengthunit,
	ord_widthunit,
	ord_heightunit,
	ord_completiondate unloaddttm,
	ord_dest_earliestdate unloaddttm_early,
	ord_dest_latestdate unloaddttm_late,
	ord_totalvolume,
	ord_totalvolumeunits,
	@char1 washstatus,
	@char2 f_state,	
	@char2 l_state,
	lgh_driver1 evt_driver1_id,
	lgh_driver2 evt_driver2_id,
	@varchar6 ref_type,
	@char30 ref_number,
	company_b.cmp_address1 d_address1,
	company_b.cmp_address2 d_address2,
	ord_remark,
	legheader.mpp_teamleader,
	lgh_dsp_date,
	lgh_geo_date,
	0,
	CONVERT(varchar(8), NULL), 
	CONVERT(varchar(30), NULL), 
	CONVERT(varchar(25), NULL), 
	CONVERT(varchar(2), NULL), 
	CONVERT(datetime, NULL), 
	CONVERT(varchar(8), NULL), 
	CONVERT(varchar(30), NULL), 
	CONVERT(varchar(25), NULL), 
	CONVERT(varchar(2), NULL), 
	CONVERT(datetime, NULL),
	legheader.can_ld_expires,
	0,
	legheader.lgh_feetavailable,
	orderheader.opt_trc_type4,
	'',
	orderheader.opt_trl_type4,
	'',
	orderheader.ord_originregion1, 
	orderheader.ord_originregion2, 
	orderheader.ord_originregion3, 
	orderheader.ord_originregion4, 
	orderheader.ord_destregion1,
	orderheader.ord_destregion2,
	orderheader.ord_destregion3,
	orderheader.ord_destregion4
/*
FROM	company company_a with (index(pk_id)), 
	legheader with(index(d_lgh_active_class1)), 
	orderheader with(index(pk_ordhdrnum)), 
	company company_b  with(index(pk_id))
*/
FROM	company company_a , 
	legheader , 
	orderheader, 
	company company_b 
WHERE	lgh_active = 'Y' AND
        cmp_id_start = company_a.cmp_id AND 
	cmp_id_end = company_b.cmp_id AND 
	legheader.ord_hdrnumber = orderheader.ord_hdrnumber and
        orderheader.ord_hdrnumber = @ord_hdrnumber  
  AND	lgh_outstatus IN ( 'AVL', 'DSP', 'PLN', 'STD', 'MPN')

  

/* jude 12/31/96 delete empty moves (ord_hdrnumber=0)*/
select @gistring1 = gi_string1 from generalinfo 
where  gi_name = 'EMPTYMOVE'
if (@gistring1 = 'YES') 
   delete from #temp where ord_hdrnumber = 0

/* dsk pts 7566 cross dock -- total up the wgt, count, vol and stop count from the stops on this lgh */

UPDATE	#temp
SET	ord_totalweight = (	SELECT 	SUM ( isnull(stp_weight,0)) 
				FROM 	stops, freightdetail 
				WHERE 	stops.lgh_number = #temp.lgh_number
				  AND	stops.stp_number = freightdetail.stp_number 
				  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
	ord_totalvolume = (	SELECT 	SUM ( isnull(stp_volume,0)) 
				FROM 	stops, freightdetail 
				WHERE 	stops.lgh_number = #temp.lgh_number
				  AND	stops.stp_number = freightdetail.stp_number 
				  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
	cmd_count 	= ( 	SELECT 	SUM ( isnull(freightdetail.fgt_count,0) )
				FROM 	stops, freightdetail
				WHERE 	#temp.lgh_number = stops.lgh_number 
				  AND	stops.stp_number = freightdetail.stp_number 
				  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
	ord_stopcount 	= (	SELECT COUNT ( DISTINCT stops.cmp_id )
				FROM	stops
				WHERE	stops.lgh_number = #temp.lgh_number ),
	ordercount	= (	SELECT COUNT ( DISTINCT stops.ord_hdrnumber )
				FROM	stops
				WHERE	stops.lgh_number = #temp.lgh_number 
				  AND	stops.ord_hdrnumber > 0 ),
	xdock 		= (	SELECT	MIN ( mov_number )
				FROM	stops
				WHERE	stops.ord_hdrnumber in 	( SELECT s1.ord_hdrnumber 
								FROM	stops s1
								WHERE	s1.mov_number = #temp.mov_number )
				  AND	stops.mov_number <> #temp.mov_number 
				  AND	stops.ord_hdrnumber > 0 )
/*dsk pts 7566 end */ 

UPDATE	#temp
SET	#temp.f_cmpname = company_c.cmp_name,
	#temp.f_ctyname = city_c.cty_nmstct,
	#temp.l_cmpname = company_d.cmp_name,
	#temp.l_ctyname = city_d.cty_nmstct,
	#temp.f_state = company_c.cmp_state,
	#temp.l_state = company_d.cmp_state
FROM	city city_c,
	company company_c,  --with(index(pk_id)),
	city city_d,
	company company_d  --with(index(pk_id))
WHERE	( #temp.f_cmpid = company_c.cmp_id ) and
	( #temp.l_cmpid = company_d.cmp_id ) and
	( #temp.f_ctycode = city_c.cty_code ) and
	( #temp.l_ctycode = city_d.cty_code )

/* PTS 8521 - DJM */
UPDATE #temp
set opt_trc_type4_label = (Select name from labelfile 
			where labelfile.labeldefinition = 'TrcType4' and
			labelfile.abbr = #temp.opt_trc_type4),
	opt_trl_type4_label = (Select name from labelfile 
			where labelfile.labeldefinition = 'TrlType4' and
			labelfile.abbr = #temp.opt_trl_type4)


/* jude 5/22/97 added manpowerprofile for driver last name */
/*
UPDATE	#temp
SET	evt_driver1 = event.evt_driver1,
	evt_driver2 = event.evt_driver2,
	evt_tractor = event.evt_tractor,
	evt_carrier = event.evt_carrier
FROM	event, stops 
WHERE	stops.lgh_number = #temp.lgh_number AND
	event.stp_number = stops.stp_number 
*/
/*MF 11/12/97 Removed join to event and stops because data is on the legheader*/

UPDATE  #temp   
SET	evt_driver1 = mpp1.mpp_lastfirst,	
    evt_driver2 = mpp2.mpp_lastfirst 
FROM #temp LEFT OUTER JOIN  manpowerprofile mpp1  ON  #temp.evt_driver1_id  = mpp1.mpp_id   
		LEFT OUTER JOIN  manpowerprofile mpp2  ON  #temp.evt_driver2_id  = mpp2.mpp_id  
 
/* jude 9/10/97 trimac's trailer wash of 'P' */
update #temp 
set     washstatus = 'P' 
from	stops with (nolock) --with(index(dk_leghdrnum)) --PTS 79441
where   #temp.lgh_number = stops.lgh_number and
	stp_event in ('WSH','DTW')


/* 970128 dsk kill 'unknown' condition, distint, and remove stops.cmd_code = fgt.cmd_code */

UPDATE	#temp
SET	trllabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType1'),
	revlabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType1'),
	revlabel2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType2'),
	revlabel3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType3'),
	revlabel4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType4')
	
UPDATE #temp
SET triptime = IsNull(#temp.loadtime, 0) + IsNull(#temp.unloadtime, 0) + IsNull(#temp.drivetime, 0)



UPDATE #temp
SET 	ref_type = r.ref_type,
	ref_number = r.ref_number
FROM	#temp t, referencenumber r with (nolock) --with(index(sk_ref_ship)) PTS 79441
WHERE	(t.ref_type not in ('ord') and
	 t.ref_type = r.ref_type and
	 r.ref_tablekey = t.ord_hdrnumber and
	 r.ref_table = 'orderheader') 

UPDATE #temp
SET 	ref_type = r.ref_type,
	ref_number = r.ref_number
FROM	#temp t, referencenumber r with (nolock) --with(index(sk_ref_ship)) PTS 79441
WHERE	(t.ref_type = 'ord' and
	 r.ref_tablekey = t.ord_hdrnumber and
	 r.ref_table = 'orderheader' and 
	 r.ref_sequence = 1) and t.ref_type is null	

-- JET - 6/23/00 - PTS 8309, if new flag is Y then run update
IF @runpups = 'Y' 
BEGIN
       INSERT INTO #1_pups (cmp_id, cmp_name, cty_nmstct, stp_state, stp_arrivaldate, ord_hdrnumber)
              SELECT cmp_id, 
                     cmp_name, 
                     cty_nmstct, 
                     stp_state, 
                     stp_arrivaldate, 
                     s1.ord_hdrnumber 
                FROM stops s1, city, #temp
               WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                           FROM stops s2, eventcodetable 
                                           WHERE stp_status = 'OPN' AND 
                                                 stp_event = abbr AND 
                                                 fgt_event = 'PUP' AND 
                                                 -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                                                 s2.ord_hdrnumber = #temp.ord_hdrnumber AND 
                                                 s2.ord_hdrnumber > 0 AND 
                                                 #temp.ord_hdrnumber > 0) AND 
                     s1.ord_hdrnumber = #temp.ord_hdrnumber AND 
                     -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                     s1.ord_hdrnumber > 0 AND 
                     #temp.ord_hdrnumber > 0 AND 
                     s1.stp_city = cty_code 

	-- update the next PUP fields with the next open PUP event information
	UPDATE #temp
	   SET npup_cmpid = cmp_id, 
	       npup_cmpname = cmp_name, 
	       npup_ctyname = cty_nmstct, 
	       npup_state = stp_state, 
	       npup_arrivaldate = stp_arrivaldate 
	  FROM #1_pups 
	 WHERE #1_pups.ord_hdrnumber = #temp.ord_hdrnumber AND 
               #temp.ord_hdrnumber > 0 
END

-- JET - 6/23/00 - PTS 8309, if new flag is Y then run update
IF @rundrops = 'Y' 
BEGIN
       INSERT INTO #1_drps (cmp_id, cmp_name, cty_nmstct, stp_state, stp_arrivaldate, ord_hdrnumber)
              SELECT cmp_id, 
                     cmp_name, 
                     cty_nmstct, 
                     stp_state, 
                     stp_arrivaldate, 
                     s1.ord_hdrnumber 
                FROM stops s1, city, #temp
               WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                           FROM stops s2, eventcodetable 
                                           WHERE stp_status = 'OPN' AND 
                                                 stp_event = abbr AND 
                                                 fgt_event = 'DRP' AND 
                                                 -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                                                 s2.ord_hdrnumber = #temp.ord_hdrnumber AND 
                                                 s2.ord_hdrnumber > 0 AND 
                                                 #temp.ord_hdrnumber > 0) AND 
                     s1.ord_hdrnumber = #temp.ord_hdrnumber AND 
                     -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                     s1.ord_hdrnumber > 0 AND 
                     #temp.ord_hdrnumber > 0 AND
                     s1.stp_city = cty_code 

	-- update the next DRP fields with the next open DRP event information
	UPDATE #temp
	   SET ndrp_cmpid = cmp_id, 
	       ndrp_cmpname = cmp_name, 
	       ndrp_ctyname = cty_nmstct, 
	       ndrp_state = stp_state, 
	       ndrp_arrivaldate = stp_arrivaldate 
	  FROM #1_drps 
	 WHERE #1_drps.ord_hdrnumber = #temp.ord_hdrnumber AND 
               #temp.ord_hdrnumber > 0 
END

SELECT	lgh_number, 
	o_cmpid, 
	o_cmpname, 
	o_ctyname, 
	d_cmpid, 
	d_cmpname, 
	d_ctyname, 
	f_cmpid,
	f_cmpname,
	f_ctyname,
	l_cmpid,
	l_cmpname,
	l_ctyname,
	lgh_startdate, 
	lgh_enddate, 
	o_state, 
	d_state, 
	lgh_schdtearliest, 
	lgh_schdtlatest, 
	cmd_code, 
	fgt_description, 
	cmd_count,
	ord_hdrnumber, 
	evt_driver1, 
	evt_driver2, 
	evt_tractor, 
	lgh_primary_trailer, 
	trl_type1,
	evt_carrier, 
	mov_number, 
	ord_availabledate, 
	ord_stopcount, 
	ord_totalcharge, 
	ord_totalweight, 
	ord_length, 
	ord_width, 
	ord_height, 
	ord_totalmiles, 
	ord_number, 
	o_city, 
	d_city,
	lgh_priority,
	l_outstat.name, 
	l_instat.name, 
	l_priority.name, 
	l_subcompany.name, 
	l_trltype1.name,
	IsNull(l_class1.name, lgh_class1), 
	IsNull(l_class2.name, lgh_class2),/*jude 4/21/97 */
	IsNull(l_class3.name, lgh_class3), /*jude 4/21/97 */
	IsNull(l_class4.name, lgh_class4),/*jude 4/21/97 */
	'Company',
	trllabel1,
	revlabel1, 
	revlabel2,
	revlabel3, 
	revlabel4,
	ord_bookedby,
	convert(char(10), '') dw_rowstatus,
	lgh_primary_pup,
	triptime,
	ord_totalweightunits,
	ord_lengthunit,
	ord_widthunit,
	ord_heightunit,
	loadtime,
	unloadtime,
	unloaddttm,
	unloaddttm_early,
	unloaddttm_late,
	ord_totalvolume,
	ord_totalvolumeunits,
	washstatus,
	f_state,
	l_state,
	evt_driver1_id,
	evt_driver2_id,
	ref_type,
	ref_number,
	d_address1,
	d_address2,
	ord_remark,
	mpp_teamleader,
	lgh_dsp_date,
	lgh_geo_date, 
        ordercount, 
	npup_cmpid, 
	npup_cmpname, 
	npup_ctyname, 
	npup_state, 
	npup_arrivaldate, 
	ndrp_cmpid, 
	ndrp_cmpname, 
	ndrp_ctyname, 
	ndrp_state, 
	ndrp_arrivaldate,
	can_ld_expires,
	xdock,
	feetavailable,
	opt_trc_type4,
	opt_trc_type4_label,
	opt_trl_type4,
	opt_trl_type4_label  
	ord_originregion1, 
	ord_originregion2, 
	ord_originregion3, 
	ord_originregion4, 
	ord_destregion1,
	ord_destregion2,
	ord_destregion3,
	ord_destregion4
FROM   #temp LEFT OUTER JOIN  labelfile l_outstat  ON  (lgh_outstatus  = l_outstat.abbr and l_outstat.labeldefinition  = 'DispStatus') 
		LEFT OUTER JOIN  labelfile l_instat  ON  (lgh_instatus  = l_instat.abbr and l_instat.labeldefinition  = 'InStatus')
		LEFT OUTER JOIN  labelfile l_priority  ON  (lgh_priority  = l_priority.abbr and l_priority.labeldefinition  = 'OrderPriority')
		LEFT OUTER JOIN  labelfile l_subcompany  ON  (ord_subcompany  = l_subcompany.abbr and l_subcompany.labeldefinition  = 'Company')
		LEFT OUTER JOIN  labelfile l_trltype1  ON  (trl_type1  = l_trltype1.abbr and l_trltype1.labeldefinition  = 'TrlType1') 
		LEFT OUTER JOIN  labelfile l_class1  ON  (lgh_class1  = l_class1.abbr and l_class1.labeldefinition  = 'RevType1')
		LEFT OUTER JOIN  labelfile l_class2  ON  (lgh_class2  = l_class2.abbr and l_class2.labeldefinition  = 'RevType2')
		LEFT OUTER JOIN  labelfile l_class3  ON  (lgh_class3  = l_class3.abbr and l_class3.labeldefinition  = 'RevType3')
		LEFT OUTER JOIN  labelfile l_class4  ON  (lgh_class4  = l_class4.abbr and l_class4.labeldefinition  = 'RevType4')

DROP TABLE #1_pups

DROP TABLE #1_drps

DROP TABLE #temp

GO
GRANT EXECUTE ON  [dbo].[d_ctx_ordertrip] TO [public]
GO
