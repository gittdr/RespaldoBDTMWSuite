SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ctx_trc_view]
	
AS              
/**
 * 
 * NAME:
 * dbo.d_ctx_trc_view
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
 * 01/27/2006	PTS 28420 - DJM  - Remove the Index hints
 * 03/16/2007   PTS36363 - JGUO - Remove index hint on city.pk_code
 * 10/25/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 4/17/08 PTS 40260 recode Pauls (11/20/06 - PTS35279 - jguo - remove index hints and double quotes.)
 **/


DECLARE	@char8		char(8), 
	@char6		char(6), 
	@dt 		datetime, 
	@char1		char(1), 
	@neardate	datetime, 
	@int 		smallint,
	@servicerule	char(6),
	@logdays	int,
	@loghrs 	int,
	@pos		int,
	@strdays	char(3),
	@strhrs		char(3), 
	@avlhrs 	float(2),
	@float		float(2),
	@drv 		char(6),
	@min 		int,
	@varchar20	varchar(20),
	@varchar25	varchar(25),
	@varchar30	varchar(30),
	@char2		char(2),
	@varchar45	varchar(45),
	@hoursbackdate	datetime,
	@hoursoutdate	datetime, 
        @runpups        char(1), 
        @rundrops       char(1), 
        @runweight      char(1),
        @retvarchar     varchar(3)

CREATE TABLE #TT (
	lgh_number int, 
	stp_number_start int null,
	o_cmpid varchar(8) null, 
	o_cmpname varchar(100) null, 
	o_ctyname varchar(25) null, 
	d_cmpid varchar(8) null, 
	d_cmpname varchar(100) null, 
	d_ctyname varchar(25) null,
	f_cmpid varchar(8) null,
	f_cmpname varchar(100) null,
	f_ctycode int null,
	f_ctyname varchar(25) null,
	l_cmpid varchar(8) null,
	l_cmpname varchar(100) null,
	l_ctycode int null,
	l_ctyname varchar(25) null, 
	lgh_startdate datetime null, 
	lgh_enddate datetime null, 
	o_state char(2) null, 
	d_state char(2) null, 
	lgh_outstatus varchar(6) null,
	lgh_instatus varchar(6) null, 
	lgh_priority varchar(6) null, 
	lgh_schdtearliest datetime null, 
	lgh_schdtlatest datetime null, 
	cmd_code varchar(8) null, 
	fgt_description varchar(60) null, 		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
	ord_hdrnumber int null, 
	mpp_type1 varchar(6) null, 
	mpp_type2 varchar(6) null, 
	mpp_type3 varchar(6) null, 
	mpp_type4 varchar(6) null, 
	mpp_teamleader varchar(6) null, 
	mpp_fleet varchar(6) null, 
	mpp_division varchar(6) null, 
	mpp_domicile varchar(6) null, 
	mpp_company varchar(6) null, 
	mpp_terminal varchar(6) null, 
	mpp_last_home datetime null, 
	mpp_want_home datetime null, 
	lgh_class1 varchar(6) null, 
	lgh_class2 varchar(6) null, 
	lgh_class3 varchar(6) null, 
	lgh_class4 varchar(6) null, 
	trc_type1 varchar(6) null, 
	trc_type2 varchar(6) null, 
	trc_type3 varchar(6) null, 
	trc_type4 varchar(6) null, 
	trl_type1 varchar(6) null, 
	trl_type2 varchar(6) null, 
	trl_type3 varchar(6) null, 
	trl_type4 varchar(6) null, 
	trc_company varchar(6) null, 
	trc_division varchar(6) null, 
	trc_fleet varchar(6) null, 
	trc_terminal varchar(6) null, 
	evt_driver1 varchar(8) null, 
	evt_driver2 varchar(8) null, 
	evt_tractor varchar(8) null, 
	lgh_primary_trailer varchar(13) null, 
	mov_number int null, 
	ord_number char(12) null, 
	o_city int null, 
	d_city int null, 
	filtflag varchar(1) null,
	outstatname varchar(20) null,
	instatname varchar(20) null,
	companyname varchar(20) null,
	trltype1name varchar(20) null,
	trltype1labelname varchar(20) null,
	revclass1name varchar(20) null,
	revclass2name varchar(20) null,
	revclass3name varchar(20) null,
	revclass4name varchar(20) null,
	revclass1labelname varchar(20) null,
	revclass2labelname varchar(20) null,
	revclass3labelname varchar(20) null,
	revclass4labelname varchar(20) null,
	pri1exp int null,
	pri1expsoon int null,
	pri2exp int null,
	pri2expsoon int null,
	loghours float null,
	drvstat int null,
	trcstat int null,
	ord_bookedby char(20) null,
	lgh_primary_pup varchar(13) null,
	servicerule char(6) null,
	trltype2name varchar(20) null,
	trltype2labelname varchar(20) null,
	trltype3name varchar(20) null,
	trltype3labelname varchar(20) null,
	trltype4name varchar(20) null,
	trltype4labelname varchar(20) null,
	f_state char(2) null,
	l_state char(2) null,
	mpp_lastfirst_1 varchar(45) null,
	mpp_lastfirst_2 varchar(45) null,
	lgh_enddate_arrival datetime null, 
	lgh_dsp_date datetime null,
	lgh_geo_date datetime null,
	trc_driver char(8) null, 
	p_date datetime null, /*trc_pln_date*/   
	p_cmpid char(8) null, /*trc_pln_cmp_id*/
	p_cmpname varchar(100) null,
	p_ctycode int null, /*trc_pln_city*/
	p_ctyname varchar(30) null, 
	p_state char(8) null,
	trc_gps_desc varchar(45) null,
	trc_gps_date datetime null,
	trc_exp1_date datetime null,
	trc_exp2_date datetime null,
	trl_exp1_date datetime null,
	trl_exp2_date datetime null,
	mpp_exp1_date datetime null,
	mpp_exp2_date datetime null, 
        tot_weight int null, 
        tot_count int null, 
        tot_volume int null, 
        ordercount int null, 
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
	can_cap_expires datetime null,
	ord_originregion1 varchar(6) null,
	ord_originregion2 varchar(6) null,
	ord_originregion3 varchar(6) null,
	ord_originregion4 varchar(6) null,
	ord_destregion1 varchar(6) null,
	ord_destregion2 varchar(6) null,
	ord_destregion3 varchar(6) null,
	ord_destregion4 varchar(6) null,
	lgh_feetavailable integer null 
)

CREATE TABLE #l_mpp (
	name varchar (20) NOT NULL ,
	abbr varchar (6) NOT NULL,
	code int NULL  )


CREATE TABLE #l_trc (
	name varchar (20) NOT NULL ,
	abbr varchar (6) NOT NULL ,
	code int NULL )

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

-- JET - 6/23/00 - 8309, read in flags to stop update of Next PUP, Next DRP or weight fields
SELECT @runpups = 'N', @rundrops = 'N', @runweight = 'N'

SELECT @retvarchar = UPPER(SUBSTRING(gi_string1, 1, 1))
  FROM generalinfo 
 WHERE gi_name = 'RunPUPs'
SELECT @runpups = UPPER(SUBSTRING(@retvarchar, 1, 1))

SELECT @retvarchar = UPPER(SUBSTRING(gi_string1, 1, 1))
  FROM generalinfo 
 WHERE gi_name = 'RunDRPs'
SELECT @rundrops = UPPER(SUBSTRING(@retvarchar, 1, 1))

SELECT @retvarchar = UPPER(SUBSTRING(gi_string1, 1, 1))
  FROM generalinfo 
 WHERE gi_name = 'RunWeight'
SELECT @runweight = UPPER(SUBSTRING(@retvarchar, 1, 1))
-- JET - 6/23/00 - 8309


INSERT INTO	#TT
SELECT	legheader.lgh_number, 
	legheader.stp_number_start,
	company_a.cmp_id o_cmpid, 
	company_a.cmp_name o_cmpname, 
	lgh_startcty_nmstct o_ctyname, 
	company_b.cmp_id d_cmpid, 
	company_b.cmp_name d_cmpname, 
	lgh_endcty_nmstct d_ctyname,
	orderheader.ord_originpoint f_cmpid,
	@varchar30 f_cmpname,
	orderheader.ord_origincity f_ctycode,
	@varchar25 f_ctyname,
	orderheader.ord_destpoint l_cmpid,
	@varchar30 l_cmpname,
	orderheader.ord_destcity l_ctycode,
	@varchar25 l_ctyname, 
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	lgh_startstate o_state, 
	lgh_endstate d_state, 
	legheader.lgh_outstatus,
	legheader.lgh_instatus, 
	legheader.lgh_priority, 
	legheader.lgh_schdtearliest, 
	legheader.lgh_schdtlatest, 
	legheader.cmd_code, 
	legheader.fgt_description, 
	legheader.ord_hdrnumber, 
	legheader.mpp_type1 mpp_type1, 
	legheader.mpp_type2 mpp_type2, 
	legheader.mpp_type3 mpp_type3, 
	legheader.mpp_type4 mpp_type4, 
	legheader.mpp_teamleader mpp_teamleader, 
	legheader.mpp_fleet mpp_fleet, 
	legheader.mpp_division mpp_division, 
	legheader.mpp_domicile mpp_domicile, 
	legheader.mpp_company mpp_company, 
	legheader.mpp_terminal mpp_terminal, 
	@dt mpp_last_home, 
	@dt mpp_want_home, 
	legheader.lgh_class1, 
	legheader.lgh_class2, 
	legheader.lgh_class3, 
	legheader.lgh_class4, 
	legheader.trc_type1, 
	legheader.trc_type2, 
	legheader.trc_type3, 
	legheader.trc_type4, 
	legheader.trl_type1, 
	legheader.trl_type2, 
	legheader.trl_type3, 
	legheader.trl_type4, 
	legheader.trc_company, 
	legheader.trc_division, 
	legheader.trc_fleet, 
	legheader.trc_terminal, 
	lgh_driver1 evt_driver1, 
	lgh_driver2 evt_driver2, 
	legheader.lgh_tractor evt_tractor, 
	legheader.lgh_primary_trailer, 
	legheader.mov_number, 
	orderheader.ord_number, 
	lgh_startcity o_city, 
	lgh_endcity d_city, 
	'F' filtflag,
	@varchar20 outstatname ,
	@varchar20 instatname ,
	@varchar20 companyname ,
	@varchar20 trltype1name,
	@varchar20 trltype1labelname ,
	@varchar20 revclass1name ,
	@varchar20 revclass2name ,
	@varchar20 revclass3name ,
	@varchar20 revclass4name ,
	@varchar20 revclass1labelname,
	@varchar20 revclass2labelname,
	@varchar20 revclass3labelname,
	@varchar20 revclass4labelname,
	@int pri1exp,
	@int pri1expsoon,
	@int pri2exp,
	@int pri2expsoon,
	@float loghours,
	@int drvstat,
	@int trcstat,
	orderheader.ord_bookedby,
	legheader.lgh_primary_pup,
	@char6 servicerule,
	@varchar20 trltype2name,
	@varchar20 trltype2labelname ,
	@varchar20 trltype3name,
	@varchar20 trltype3labelname ,
	@varchar20 trltype4name,
	@varchar20 trltype4labelname,
	@char2 f_state,
	@char2 l_state,
	@varchar45 mpp_lastfirst_1,
	@varchar45 mpp_lastfirst_2,
	lgh_enddate_arrival, 
	lgh_dsp_date,
	lgh_geo_date,
	@char8 trc_driver, 
	@dt p_date, /*trc_pln_date*/   
	@char8 p_cmpid, /*trc_pln_cmp_id*/
	@varchar30 p_cmpname,
	convert(int, 0)	p_ctycode, /*trc_pln_city*/
	@varchar25 p_ctyname, 
	@char8 p_state,
	@varchar45 trc_gps_desc,
	@dt trc_gps_date,
	@dt trc_exp1_date,
	@dt trc_exp2_date,
	@dt trl_exp1_date,
	@dt trl_exp2_date,
	@dt mpp_exp1_date,
	@dt mpp_exp2_date, 
	0, 
	0, 
	0, 
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
	legheader.can_cap_expires,
	orderheader.ord_originregion1, 
	orderheader.ord_originregion2, 
	orderheader.ord_originregion3, 
	orderheader.ord_originregion4, 
	orderheader.ord_destregion1,
	orderheader.ord_destregion2,
	orderheader.ord_destregion3,
	orderheader.ord_destregion4,
	legheader.lgh_feetavailable
FROM	company company_a inner join legheader on legheader.cmp_id_start = company_a.cmp_id
	inner join company company_b on legheader.cmp_id_end = company_b.cmp_id  
	left join orderheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber

/*mf 11/12/97 added temp table for labelfile because sometimes 
	it would select to do the label file first resulting in 10,000 IOs on #TT */
INSERT into  #l_mpp
select 	name, abbr, code 
from labelfile
WHERE	labeldefinition = 'DrvStatus'

insert into  #l_trc
select 	name, abbr, code 
from labelfile
WHERE	labeldefinition = 'TrcStatus'

UPDATE	#TT
SET     
	#TT.mpp_last_home = manpowerprofile.mpp_last_home,
	#TT.mpp_want_home = manpowerprofile.mpp_want_home,
	#TT.drvstat = #l_mpp.code,
	#TT.trcstat = #l_trc.code,
	#TT.servicerule = manpowerprofile.mpp_servicerule,
	trc_gps_desc = tractorprofile.trc_gps_desc,
	trc_gps_date = tractorprofile.trc_gps_date,
	trc_driver = tractorprofile.trc_driver,
	p_date = tractorprofile.trc_pln_date,   
	p_cmpid = tractorprofile.trc_pln_cmp_id,
	p_ctycode = tractorprofile.trc_pln_city,
	trc_exp1_date = tractorprofile.trc_exp1_date,
	trc_exp2_date = tractorprofile.trc_exp2_date,
	mpp_exp1_date = manpowerprofile.mpp_exp1_date,
	mpp_exp2_date = manpowerprofile.mpp_exp2_date,
	trl_exp1_date = trailerprofile.trl_exp1_date,
	trl_exp2_date = trailerprofile.trl_exp2_date,
	loghours = manpowerprofile.mpp_hours1
FROM #tt inner join manpowerprofile on #tt.evt_driver1 = manpowerprofile.mpp_id
	inner join tractorprofile on #tt.evt_tractor = tractorprofile.trc_number
	left join trailerprofile on #tt.lgh_primary_trailer = trailerprofile.trl_id
	inner join #l_trc on #l_trc.abbr = tractorprofile.trc_status
	inner join #l_mpp on #l_mpp.abbr = manpowerprofile.mpp_status
	--manpowerprofile (index=u_mpp_id), 
	--tractorprofile (index=pk_trc_number), 
	--trailerprofile (index=pk_id),
	--#l_mpp, #l_trc
WHERE	--#TT.evt_driver1 = manpowerprofile.mpp_id AND
	--#TT.evt_tractor = tractorprofile.trc_number AND
	--#TT.lgh_primary_trailer *= trailerprofile.trl_id and
	( #l_trc.abbr = trc_status ) AND 
	( #l_mpp.abbr = mpp_status ) 

/* KM  2-27-99 PTS 5191 - Use outer joins on company table to make sure */
/* company info gets set properly */
UPDATE  #TT   
SET	#TT.f_cmpname = company_c.cmp_name,	
    #TT.f_ctyname = city_c.cty_nmstct,	
    #TT.l_cmpname = company_d.cmp_name,	
    #TT.l_ctyname = city_d.cty_nmstct,	
    #TT.f_state = company_c.cmp_state,	
    #TT.l_state = company_d.cmp_state,	
    #TT.p_cmpname = company_p.cmp_name,	
    #TT.p_ctyname = city_p.cty_nmstct,	
    #TT.p_state = company_p.cmp_state 
/*
FROM  #TT LEFT OUTER JOIN  company company_c WITH(index(pk_id))  ON  #TT.f_cmpid  = company_c.cmp_id   
		LEFT OUTER JOIN  company company_d WITH(index(pk_id))  ON  #TT.l_cmpid  = company_d.cmp_id   
		LEFT OUTER JOIN  company company_p WITH(index(pk_id))  ON  #TT.p_cmpid  = company_p.cmp_id   
		LEFT OUTER JOIN  city city_c  ON  #TT.f_ctycode  = city_c.cty_code   
		LEFT OUTER JOIN  city city_p  ON  #TT.p_ctycode  = city_p.cty_code   
		LEFT OUTER JOIN  city city_d  ON  #TT.l_ctycode  = city_d.cty_code 
*/ 
FROM  #TT LEFT OUTER JOIN  company company_c  ON  #TT.f_cmpid  = company_c.cmp_id   
		LEFT OUTER JOIN  company company_d   ON  #TT.l_cmpid  = company_d.cmp_id   
		LEFT OUTER JOIN  company company_p   ON  #TT.p_cmpid  = company_p.cmp_id   
		LEFT OUTER JOIN  city city_c  ON  #TT.f_ctycode  = city_c.cty_code   
		LEFT OUTER JOIN  city city_p  ON  #TT.p_ctycode  = city_p.cty_code   
		LEFT OUTER JOIN  city city_d  ON  #TT.l_ctycode  = city_d.cty_code
 

/* END PTS 5191  */



/*pts 6200 */
update #tt
set pri1exp = CASE 
			WHEN trc_exp1_date <= GetDate() or mpp_exp1_date <= GetDate() or 
				trl_exp1_date <= GetDate() THEN 1
			ELSE 0
		END, 
    pri1expsoon = CASE 
			WHEN trc_exp1_date <= @neardate or mpp_exp1_date <= @neardate or 
				trl_exp1_date <= @neardate THEN 1
			ELSE 0
		END, 
    pri2exp = CASE 
			WHEN trc_exp2_date <= GetDate() or mpp_exp2_date <= GetDate() or 
				trl_exp2_date <= GetDate() THEN 1
			ELSE 0
		END, 
    pri2expsoon = CASE 
			WHEN trc_exp2_date <= @neardate or mpp_exp2_date <= @neardate or 
				trl_exp2_date <= @neardate THEN 1
			ELSE 0
		END


/* EXEC timerins "INBOUND", "FINISH" */
update #TT
SET outstatname = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_outstatus AND labeldefinition = 'DispStatus' ), 
	instatname = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_instatus AND labeldefinition = 'InStatus' ), 
	companyname = ( SELECT name FROM labelfile WHERE abbr = #TT.trc_company AND labeldefinition = 'Company' )

update #TT
SET	trltype1name = ( SELECT name FROM labelfile WHERE abbr = #TT.trl_type1 AND labeldefinition = 'TrlType1' ),
	trltype1labelname = ( SELECT DISTINCT userlabelname FROM labelfile WHERE labeldefinition = 'TrlType1' ),
	trltype2name = ( SELECT name FROM labelfile WHERE abbr = #TT.trl_type2 AND labeldefinition = 'TrlType2' ),
	trltype2labelname = ( SELECT DISTINCT userlabelname FROM labelfile WHERE labeldefinition = 'TrlType2' ),
	trltype3name = ( SELECT name FROM labelfile WHERE abbr = #TT.trl_type3 AND labeldefinition = 'TrlType3' ),
	trltype3labelname = ( SELECT DISTINCT userlabelname FROM labelfile WHERE labeldefinition = 'TrlType3' ),
	trltype4name = ( SELECT name FROM labelfile WHERE abbr = #TT.trl_type4 AND labeldefinition = 'TrlType4' ),
	trltype4labelname = ( SELECT DISTINCT userlabelname FROM labelfile WHERE labeldefinition = 'TrlType4' )

update #TT
SET	revclass1name = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_class1 AND labeldefinition = 'RevType1' ),
	revclass2name = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_class2 AND labeldefinition = 'RevType2' ),
	revclass3name = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_class3 AND labeldefinition = 'RevType3' ),
	revclass4name = ( SELECT name FROM labelfile WHERE abbr = #TT.lgh_class4 AND labeldefinition = 'RevType4' ),
	revclass1labelname = ( SELECT MAX ( userlabelname ) FROM labelfile WHERE labeldefinition = 'RevType1' ),
	revclass2labelname = ( SELECT MAX ( userlabelname ) FROM labelfile WHERE labeldefinition = 'RevType2' ),
	revclass3labelname = ( SELECT MAX ( userlabelname ) FROM labelfile WHERE labeldefinition = 'RevType3' ),
	revclass4labelname = ( SELECT MAX ( userlabelname ) FROM labelfile WHERE labeldefinition = 'RevType4' )

update #TT
SET	#TT.mpp_lastfirst_1 = manpowerprofile.mpp_lastfirst
FROM	manpowerprofile

WHERE	#TT.evt_driver1 = manpowerprofile.mpp_id 

update #TT
SET	#TT.mpp_lastfirst_2 = manpowerprofile.mpp_lastfirst
FROM	manpowerprofile
WHERE	#TT.evt_driver2 = manpowerprofile.mpp_id 

-- JET - 6/23/00 - PTS 8309, if new flag is Y then run update
IF @runweight = 'Y' 
	/* dsk pts 7566 cross dock -- total up the wgt, count, vol and stop count from the stops on this lgh */
	UPDATE	#tt
	SET	tot_weight = (	SELECT 	SUM ( stp_weight) 
					FROM 	stops, freightdetail 
					WHERE 	stops.lgh_number = #tt.lgh_number
					  AND	stops.stp_number = freightdetail.stp_number 
					  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
		tot_volume = (	SELECT 	SUM ( stp_volume) 
					FROM 	stops, freightdetail 
					WHERE 	stops.lgh_number = #tt.lgh_number
					  AND	stops.stp_number = freightdetail.stp_number 
					  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
		tot_count 	= ( 	SELECT 	SUM ( freightdetail.fgt_count )
					FROM 	stops, freightdetail
					WHERE 	#tt.lgh_number = stops.lgh_number 
					  AND	stops.stp_number = freightdetail.stp_number 
					  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )),
		ordercount	= (	SELECT COUNT ( DISTINCT stops.ord_hdrnumber )
					FROM	stops
					WHERE	stops.lgh_number = #tt.lgh_number 
					  AND	stops.ord_hdrnumber > 0 )
/*dsk pts 7566 end */ 

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
                FROM stops s1, city, #tt
               WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                           FROM stops s2, eventcodetable 
                                           WHERE stp_status = 'OPN' AND 
                                                 stp_event = abbr AND 
                                                 fgt_event = 'PUP' AND 
                                                 -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                                                 s2.ord_hdrnumber = #tt.ord_hdrnumber AND 
                                                 s2.ord_hdrnumber > 0 AND 
                                                 #tt.ord_hdrnumber > 0) AND 
                     s1.ord_hdrnumber = #tt.ord_hdrnumber AND 
                     -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                     s1.ord_hdrnumber > 0 AND 
                     #tt.ord_hdrnumber > 0 AND 
                     s1.stp_city = cty_code 

	-- update the next PUP fields with the next open PUP event information
	UPDATE #tt
	   SET npup_cmpid = cmp_id, 
	       npup_cmpname = cmp_name, 
	       npup_ctyname = cty_nmstct, 
	       npup_state = stp_state, 
	       npup_arrivaldate = stp_arrivaldate 
	  FROM #1_pups 
	 WHERE #1_pups.ord_hdrnumber = #tt.ord_hdrnumber AND 
               #tt.ord_hdrnumber > 0 
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
                FROM stops s1, city, #tt
               WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                           FROM stops s2, eventcodetable 
                                           WHERE stp_status = 'OPN' AND 
                                                 stp_event = abbr AND 
                                                 fgt_event = 'DRP' AND 
                                                 -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                                                 s2.ord_hdrnumber = #tt.ord_hdrnumber AND 
                                                 s2.ord_hdrnumber > 0 AND 
                                                 #tt.ord_hdrnumber > 0) AND 
                     s1.ord_hdrnumber = #tt.ord_hdrnumber AND 
                     -- JET - 6/26/00 - PTS #8309, ignore stops that have ord_hdrnumber = 0
                     s1.ord_hdrnumber > 0 AND 
                     #tt.ord_hdrnumber > 0 AND
                     s1.stp_city = cty_code 

	-- update the next DRP fields with the next open DRP event information
	UPDATE #tt
	   SET ndrp_cmpid = cmp_id, 
	       ndrp_cmpname = cmp_name, 
	       ndrp_ctyname = cty_nmstct, 
	       ndrp_state = stp_state, 
	       ndrp_arrivaldate = stp_arrivaldate 
	  FROM #1_drps 
	 WHERE #1_drps.ord_hdrnumber = #tt.ord_hdrnumber AND 
               #tt.ord_hdrnumber > 0 
END

SELECT lgh_number, 
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
	lgh_outstatus, 
	lgh_instatus, 
	lgh_priority, 
	lgh_schdtearliest, 
	lgh_schdtlatest, 
	cmd_code, 
	fgt_description, 
	ord_hdrnumber, 
	mpp_last_home, 
	mpp_want_home, 
	evt_driver1, 
	evt_driver2, 
	evt_tractor, 
	trc_company,
	lgh_primary_trailer,
	trltype1name,
	trltype1labelname,
	trltype2name,
	trltype2labelname,
	trltype3name,
	trltype3labelname,
	trltype4name,
	trltype4labelname, 
	mov_number, 
	ord_number, 
	o_city, 
	d_city, 
	filtflag,
	outstatname,
	instatname ,
	companyname,
	revclass1name,
	revclass2name,
	revclass3name,
	revclass4name,
	revclass1labelname,
	revclass2labelname,
	revclass3labelname,
	revclass4labelname,
	pri1exp,
	pri2exp,
	pri1expsoon,
	pri2expsoon,
	loghours,
	ord_bookedby,
	lgh_primary_pup,
	f_state,
	l_state,
	mpp_lastfirst_1,
	mpp_lastfirst_2,		
	lgh_enddate_arrival, 
	lgh_dsp_date,
	lgh_geo_date,
	trc_driver, 
	p_date, /*trc_pln_date*/   
	p_cmpid, /*trc_pln_cmp_id*/
	p_cmpname,
	p_ctycode, /*trc_pln_city*/
	p_ctyname, 
	p_state,
	trc_gps_desc,
	trc_gps_date, 
        tot_weight, 
	tot_count, 
	tot_volume, 
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
	can_cap_expires, 
	ord_originregion1, 
	ord_originregion2, 
	ord_originregion3, 
	ord_originregion4, 
	ord_destregion1,
	ord_destregion2,
	ord_destregion3,
	ord_destregion4,
	lgh_feetavailable
FROM	#TT
WHERE	trcstat <> 900 
	
DROP TABLE #TT

DROP TABLE #1_pups

DROP TABLE #1_drps

GO
GRANT EXECUTE ON  [dbo].[d_ctx_trc_view] TO [public]
GO
