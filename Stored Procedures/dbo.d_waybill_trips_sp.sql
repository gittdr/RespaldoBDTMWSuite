SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/****** Object:  Stored Procedure dbo.d_waybill_trips_sp    Script Date: 8/20/97 1:58:47 PM ******/
create proc [dbo].[d_waybill_trips_sp]
	@revtype1 varchar ( 254 ),
	@revtype2 varchar ( 254 ),
	@revtype3 varchar ( 254 ),
	@revtype4 varchar ( 254 ),
	@trltype1 varchar ( 254 ),
	@company varchar ( 254 ),
	@states varchar ( 254 ),
	@cmpids varchar ( 254 ),
	@reg1 varchar ( 254 ),
	@reg2 varchar ( 254 ),
	@reg3 varchar ( 254 ),
	@reg4 varchar ( 254 ),
	@city int,
	@hoursback int,
	@hoursout int,
	@status char ( 254 ),
	@sStat1 varchar(10),
	@sStat2 varchar(10),
	@sStat3 varchar(10),
	@sStat4 varchar(10),
	@sStat5 varchar(10),
	@sStat6 varchar(10),
	@sStat7 varchar(10),
	@sStat8 varchar(10),
	@sStat9 varchar(10),
	@sStat10 varchar(10),
	@sStat11 varchar(10),
	@sStat12 varchar(10),
	@sStat13 varchar(10),
	@sStat14 varchar(10),
	@sStat15 varchar(10),
	@sStat16 varchar(10),
	@sStat17 varchar(10),
	@sStat18 varchar(10),
	@sStat19 varchar(10),
	@sStat20 varchar(10),
	@sStat21 varchar(10),
	@bookedby varchar( 254 )

as
/**
 * 
 * NAME:
 * dbo.d_waybill_trips_sp
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
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:

--PTS# 3044 Modified 10/14/97  by IB
--The contents of the stored proc appear twice , the first version accepts a value from the
--@status parameter and only retrieves records with that status type, the second version will
--return all status values. This was done because the filter on the mass print of waysbills was
--not working properly.

--10/24/97 IB
--used isnull() function on the updates of driver, tractor and carrier to eliminate the possibility
--of inserting a null value into the temp table. This was a Sybase issue.

--10/28/97 MRH Replaced isnull function with ISNULL function for compatablity with sybase.
--11/11/97 ILB Added 21 arguments to the parameter list to allow the user to input multiple 
--status's to retrieve the mass print of waybills.
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

IF @hoursback = 0
	SELECT @hoursback = 1000000

IF @hoursout = 0
	SELECT @hoursout = 1000000


IF @status <> '' 

 BEGIN

 SELECT DISTINCT legheader.lgh_number, 
	company_a.cmp_id o_cmpid, 
	company_a.cmp_name o_cmpname, 
	city_a.cty_nmstct o_ctyname, 
	company_b.cmp_id d_cmpid, 
	company_b.cmp_name d_cmpname, 
	city_b.cty_nmstct d_ctyname, 
	orderheader.ord_originpoint f_cmpid,
	convert(char(30), '') f_cmpname,
	orderheader.ord_origincity f_ctycode,
	convert(char(25), '') f_ctyname,
	orderheader.ord_destpoint l_cmpid,
	convert(char(30), '') l_cmpname,
	orderheader.ord_destcity l_ctycode,
	convert(char(25), '') l_ctyname,
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	city_a.cty_state o_state, 
	city_b.cty_state d_state, 
	legheader.lgh_schdtearliest, 
	legheader.lgh_schdtlatest,
	legheader.cmd_code,
	legheader.fgt_description,
	convert(int, 0) cmd_count,
	legheader.ord_hdrnumber, 
	convert(char(8), '') evt_driver1, 
	convert(char(8), '') evt_driver2, 
	convert(char(8), '') evt_tractor, 
	legheader.lgh_primary_trailer, 
	orderheader.trl_type1,
	convert(char(8), '') evt_carrier, 
	legheader.mov_number, 
	orderheader.ord_availabledate, 
	orderheader.ord_stopcount, 
	orderheader.ord_totalcharge, 
	orderheader.ord_totalweight, 
	orderheader.ord_length, 
	orderheader.ord_width, 
	orderheader.ord_height, 
	orderheader.ord_totalmiles, 
	orderheader.ord_number, 
	city_a.cty_code o_city, 
	city_b.cty_code d_city,
	legheader.lgh_outstatus, 
	legheader.lgh_instatus, 
	legheader.lgh_priority, 
	orderheader.ord_subcompany,
	legheader.lgh_class1, 
	legheader.lgh_class2, 
	legheader.lgh_class3, 
	legheader.lgh_class4,
	convert(char(20),'') revlabel1,
	convert(char(20),'') revlabel2,
	convert(char(20),'') revlabel3,
	convert(char(20),'') revlabel4,
	convert(char(20),'') trllabel1,
	orderheader.ord_bookedby,
	legheader.lgh_etaalert1,
	legheader.lgh_outofroute_routing
INTO	#temp
FROM	orderheader  RIGHT OUTER JOIN  legheader  ON  orderheader.ord_hdrnumber  = legheader.ord_hdrnumber ,
	 city city_a,
	 company company_a,
	 city city_b,
	 company company_b 
WHERE	( legheader.cmp_id_start = company_a.cmp_id ) and 
	( legheader.cmp_id_end = company_b.cmp_id ) and 
	( legheader.lgh_startcity = city_a.cty_code ) and 
	( legheader.lgh_endcity = city_b.cty_code ) and 
	--( orderheader.ord_hdrnumber =* legheader.ord_hdrnumber ) and 
	( legheader.lgh_outstatus in (@sStat1,@sStat2,@sStat3,@sStat4,@sStat5,@sStat6,@sStat7,@sStat8,@sStat9,@sStat10,@sStat11,@sStat12,@sStat13,@sStat14,@sStat15,@sStat16,@sStat17,@sStat18,@sStat19,@sStat20,@sStat21)) and
	( ','+@revtype1 like '%,'+legheader.lgh_class1+'%' OR @revtype1 = '') AND 
	( ','+@revtype2 like '%,'+legheader.lgh_class2+'%' OR @revtype2 = '') AND 
	( ','+@revtype3 like '%,'+legheader.lgh_class3+'%' OR @revtype3 = '') AND 
	( ','+@revtype4 like '%,'+legheader.lgh_class4+'%' OR @revtype4 = '') AND 
	( ','+@states like '%,'+city_a.cty_state+'%' OR @states = '') AND 
	( ','+@cmpids like '%,'+cmp_id_start+'%' OR @cmpids = '') AND 
	( @reg1 = city_a.cty_region1 OR @reg1 = 'UNK' ) AND 
	( @reg2 = city_a.cty_region2 OR @reg2 = 'UNK' ) AND 
	( @reg3 = city_a.cty_region3 OR @reg3 = 'UNK' ) AND 
	( @reg4 = city_a.cty_region4 OR @reg4 = 'UNK' ) AND 
	( @city = city_a.cty_code OR @city = 0 ) AND 
	( legheader.lgh_startdate >= dateadd ( hour, -@hoursback, getdate() ) AND 
	legheader.lgh_startdate <= dateadd ( hour, @hoursout, getdate() ) )

UPDATE	#temp
SET	#temp.f_cmpname = company_c.cmp_name,
	#temp.f_ctyname = city_c.cty_nmstct,
	#temp.l_cmpname = company_d.cmp_name,
	#temp.l_ctyname = city_d.cty_nmstct
FROM	city city_c,
	company company_c,
	city city_d,
	company company_d
WHERE	( #temp.f_cmpid = company_c.cmp_id ) and
	( #temp.l_cmpid = company_d.cmp_id ) and
	( #temp.f_ctycode = city_c.cty_code ) and
	( #temp.l_ctycode = city_d.cty_code )

UPDATE	#temp
SET	evt_driver1 = isnull(event.evt_driver1,''),
	evt_driver2 = isnull(event.evt_driver2,''),
	evt_tractor = isnull(event.evt_tractor,''),
	evt_carrier = isnull(event.evt_carrier,'')
FROM	event, stops
WHERE	stops.lgh_number = #temp.lgh_number AND
	event.stp_number = stops.stp_number

UPDATE	#temp
SET	cmd_count = ( SELECT	COUNT (DISTINCT freightdetail.cmd_code )
			FROM	stops, freightdetail
			WHERE	stops.ord_hdrnumber = #temp.ord_hdrnumber AND
				stops.stp_number = freightdetail.stp_number AND
				stops.stp_type = 'DRP' AND
				freightdetail.cmd_code <> 'UNKNOWN')
FROM	#temp

UPDATE	#temp
SET	trllabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType1'),
	revlabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType1'),
	revlabel2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType2'),
	revlabel3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType3'),
	revlabel4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType4')
	

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
	isnull(l_class1.name, lgh_class1), 
	isnull(l_class1.name, lgh_class2),
	isnull(l_class1.name, lgh_class3), 
	isnull(l_class1.name, lgh_class4),
	'Company',
	trllabel1,
	revlabel1, 
	revlabel2,
	revlabel3, 
	revlabel4,
	ord_bookedby,
	convert(char(10), '') dw_rowstatus,
	lgh_etaalert1,
	lgh_outofroute_routing
FROM	
	labelfile l_outstat  RIGHT OUTER JOIN  #temp  ON  (l_outstat.abbr = #temp.lgh_outstatus AND l_outstat.labeldefinition = 'DispStatus')  
		LEFT OUTER JOIN  labelfile l_instat  ON  ( l_instat.abbr = #temp.lgh_instatus AND l_instat.labeldefinition = 'InStatus' )
		LEFT OUTER JOIN  labelfile l_priority  ON  ( l_priority.abbr = #temp.lgh_priority AND l_priority.labeldefinition = 'OrderPriority' )   
		LEFT OUTER JOIN  labelfile l_subcompany  ON ( l_subcompany.abbr = #temp.ord_subcompany AND l_subcompany.labeldefinition = 'Company' ) 
		LEFT OUTER JOIN  labelfile l_trltype1  ON  ( l_trltype1.abbr = #temp.trl_type1 AND l_trltype1.labeldefinition = 'TrlType1' ) 
		LEFT OUTER JOIN  labelfile l_class1  ON  ( l_class1.abbr = #temp.lgh_class1 AND l_class1.labeldefinition = 'RevType1' )
		LEFT OUTER JOIN  labelfile l_class2  ON  ( l_class2.abbr = #temp.lgh_class2 AND l_class2.labeldefinition = 'RevType2' ) 
		LEFT OUTER JOIN  labelfile l_class3  ON  ( l_class3.abbr = #temp.lgh_class3 AND l_class3.labeldefinition = 'RevType3' )  
		LEFT OUTER JOIN  labelfile l_class4  ON ( l_class4.abbr = #temp.lgh_class4 AND l_class4.labeldefinition = 'RevType4' ) 
WHERE
	( ','+@trltype1 like '%,'+ trl_type1+'%' OR @trltype1 = '') AND
	( ','+@company like '%,'+ord_subcompany+'%' OR @company = '') AND
	( ','+@bookedby like '%,'+ord_bookedby+'%' OR @bookedby = 'ALL')

--#temp,
--	labelfile l_outstat,
--	labelfile l_instat,
--	labelfile l_priority,
--	labelfile l_subcompany,
--	labelfile l_class1,
--	labelfile l_class2,
--	labelfile l_class3,
--	labelfile l_class4,
--	labelfile l_trltype1
--WHERE	( l_outstat.abbr =* lgh_outstatus AND l_outstat.labeldefinition = 'DispStatus' ) AND
--	( l_instat.abbr =* lgh_instatus AND l_instat.labeldefinition = 'InStatus' ) AND
--	( l_priority.abbr =* lgh_priority AND l_priority.labeldefinition = 'OrderPriority' ) AND
--	( l_subcompany.abbr =* ord_subcompany AND l_subcompany.labeldefinition = 'Company' ) AND
--	( l_trltype1.abbr =* trl_type1 AND l_trltype1.labeldefinition = 'TrlType1' ) AND
--	( l_class1.abbr =* lgh_class1 AND l_class1.labeldefinition = 'RevType1' ) AND
--	( l_class2.abbr =* lgh_class2 AND l_class2.labeldefinition = 'RevType2' ) AND
--	( l_class3.abbr =* lgh_class3 AND l_class3.labeldefinition = 'RevType3' ) AND
--	( l_class4.abbr =* lgh_class4 AND l_class4.labeldefinition = 'RevType4' ) AND
--	( ','+@trltype1 like '%,'+ trl_type1+'%' OR @trltype1 = '') AND
--	( ','+@company like '%,'+ord_subcompany+'%' OR @company = '') AND
--	( ','+@bookedby like '%,'+ord_bookedby+'%' OR @bookedby = 'ALL')



 END

ELSE

 BEGIN

 SELECT	DISTINCT legheader.lgh_number, 
	company_a.cmp_id o_cmpid, 
	company_a.cmp_name o_cmpname, 
	city_a.cty_nmstct o_ctyname, 
	company_b.cmp_id d_cmpid, 
	company_b.cmp_name d_cmpname, 
	city_b.cty_nmstct d_ctyname, 
	orderheader.ord_originpoint f_cmpid,
	convert(char(30), '') f_cmpname,
	orderheader.ord_origincity f_ctycode,
	convert(char(25), '') f_ctyname,
	orderheader.ord_destpoint l_cmpid,
	convert(char(30), '') l_cmpname,
	orderheader.ord_destcity l_ctycode,
	convert(char(25), '') l_ctyname,
	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	city_a.cty_state o_state, 
	city_b.cty_state d_state, 
	legheader.lgh_schdtearliest, 
	legheader.lgh_schdtlatest,
	legheader.cmd_code,
	legheader.fgt_description,
	convert(int, 0) cmd_count,
	legheader.ord_hdrnumber, 
	convert(char(8), '') evt_driver1, 
	convert(char(8), '') evt_driver2, 
	convert(char(8), '') evt_tractor, 
	legheader.lgh_primary_trailer, 
	orderheader.trl_type1,
	convert(char(8), '') evt_carrier, 
	legheader.mov_number, 
	orderheader.ord_availabledate, 
	orderheader.ord_stopcount, 
	orderheader.ord_totalcharge, 
	orderheader.ord_totalweight, 
	orderheader.ord_length, 
	orderheader.ord_width, 
	orderheader.ord_height, 
	orderheader.ord_totalmiles, 
	orderheader.ord_number, 
	city_a.cty_code o_city, 
	city_b.cty_code d_city,
	legheader.lgh_outstatus, 
	legheader.lgh_instatus, 
	legheader.lgh_priority, 
	orderheader.ord_subcompany,
	legheader.lgh_class1, 
	legheader.lgh_class2, 
	legheader.lgh_class3, 
	legheader.lgh_class4,
	convert(char(20),'') revlabel1,
	convert(char(20),'') revlabel2,
	convert(char(20),'') revlabel3,
	convert(char(20),'') revlabel4,
	convert(char(20),'') trllabel1,
	orderheader.ord_bookedby,
	legheader.lgh_etaalert1,
	legheader.lgh_outofroute_routing
INTO	#temp1
FROM	city city_a, 
	company company_a, 
	orderheader RIGHT OUTER JOIN legheader ON orderheader.ord_hdrnumber = legheader.ord_hdrnumber, 
	city city_b, 
	company company_b
WHERE	( legheader.cmp_id_start = company_a.cmp_id ) and 
	( legheader.cmp_id_end = company_b.cmp_id ) and 
	( legheader.lgh_startcity = city_a.cty_code ) and 
	( legheader.lgh_endcity = city_b.cty_code ) and 
	--( orderheader.ord_hdrnumber =* legheader.ord_hdrnumber ) and 
	( legheader.lgh_outstatus <> 'CMP') and
	( ','+@revtype1 like '%,'+legheader.lgh_class1+'%' OR @revtype1 = '') AND 
	( ','+@revtype2 like '%,'+legheader.lgh_class2+'%' OR @revtype2 = '') AND 
	( ','+@revtype3 like '%,'+legheader.lgh_class3+'%' OR @revtype3 = '') AND 
	( ','+@revtype4 like '%,'+legheader.lgh_class4+'%' OR @revtype4 = '') AND 
	( ','+@states like '%,'+city_a.cty_state+'%' OR @states = '') AND 
	( ','+@cmpids like '%,'+cmp_id_start+'%' OR @cmpids = '') AND 
	( @reg1 = city_a.cty_region1 OR @reg1 = 'UNK' ) AND 
	( @reg2 = city_a.cty_region2 OR @reg2 = 'UNK' ) AND 
	( @reg3 = city_a.cty_region3 OR @reg3 = 'UNK' ) AND 
	( @reg4 = city_a.cty_region4 OR @reg4 = 'UNK' ) AND 
	( @city = city_a.cty_code OR @city = 0 ) AND 
	( legheader.lgh_startdate >= dateadd ( hour, -@hoursback, getdate() ) AND 
	legheader.lgh_startdate <= dateadd ( hour, @hoursout, getdate() ) )

UPDATE	#temp1
SET	#temp1.f_cmpname = company_c.cmp_name,
	#temp1.f_ctyname = city_c.cty_nmstct,
	#temp1.l_cmpname = company_d.cmp_name,
	#temp1.l_ctyname = city_d.cty_nmstct
FROM	city city_c,
	company company_c,
	city city_d,
	company company_d
WHERE	( #temp1.f_cmpid = company_c.cmp_id ) and
	( #temp1.l_cmpid = company_d.cmp_id ) and
	( #temp1.f_ctycode = city_c.cty_code ) and
	( #temp1.l_ctycode = city_d.cty_code )

UPDATE	#temp1
SET	evt_driver1 = isnull(event.evt_driver1,''),
	evt_driver2 = isnull(event.evt_driver2,''),
	evt_tractor = isnull(event.evt_tractor,''),
	evt_carrier = isnull(event.evt_carrier,'')
FROM	event, stops
WHERE	stops.lgh_number = #temp1.lgh_number AND
	event.stp_number = stops.stp_number

UPDATE	#temp1
SET	cmd_count = ( SELECT	COUNT (DISTINCT freightdetail.cmd_code )
			FROM	stops, freightdetail
			WHERE	stops.ord_hdrnumber = #temp1.ord_hdrnumber AND
				stops.stp_number = freightdetail.stp_number AND
				stops.stp_type = 'DRP' AND
				freightdetail.cmd_code <> 'UNKNOWN')
FROM	#temp1

UPDATE	#temp1
SET	trllabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType1'),
	revlabel1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType1'),
	revlabel2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType2'),
	revlabel3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType3'),
	revlabel4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType4')
	

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
	isnull(l_class1.name, lgh_class1), 
	isnull(l_class1.name, lgh_class2),
	isnull(l_class1.name, lgh_class3), 
	isnull(l_class1.name, lgh_class4),
	'Company',
	trllabel1,
	revlabel1, 
	revlabel2,
	revlabel3, 
	revlabel4,
	ord_bookedby,
	convert(char(10), '') dw_rowstatus,
	lgh_etaalert1,
	lgh_outofroute_routing
FROM	
	labelfile l_outstat RIGHT OUTER JOIN #temp1 ON ( l_outstat.abbr = #temp1.lgh_outstatus AND l_outstat.labeldefinition = 'DispStatus' )
		LEFT OUTER JOIN labelfile l_instat ON ( l_instat.abbr = #temp1.lgh_instatus AND l_instat.labeldefinition = 'InStatus' )
		LEFT OUTER JOIN labelfile l_priority ON ( l_priority.abbr = #temp1.lgh_priority AND l_priority.labeldefinition = 'OrderPriority' ) 
		LEFT OUTER JOIN labelfile l_subcompany ON ( l_subcompany.abbr = #temp1.ord_subcompany AND l_subcompany.labeldefinition = 'Company' )
		LEFT OUTER JOIN labelfile l_class1 ON ( l_class1.abbr = #temp1.lgh_class1 AND l_class1.labeldefinition = 'RevType1' )
		LEFT OUTER JOIN labelfile l_class2 ON ( l_class2.abbr = #temp1.lgh_class2 AND l_class2.labeldefinition = 'RevType2' )
		LEFT OUTER JOIN labelfile l_class3 ON ( l_class3.abbr = #temp1.lgh_class3 AND l_class3.labeldefinition = 'RevType3' )
		LEFT OUTER JOIN labelfile l_class4 ON ( l_class4.abbr = #temp1.lgh_class4 AND l_class4.labeldefinition = 'RevType4' )
		LEFT OUTER JOIN labelfile l_trltype1 ON ( l_trltype1.abbr = #temp1.trl_type1 AND l_trltype1.labeldefinition = 'TrlType1' ) 
WHERE	
	( ','+@trltype1 like '%,'+ #temp1.trl_type1+'%' OR @trltype1 = '') AND
	( ','+@company like '%,'+ #temp1.ord_subcompany+'%' OR @company = '') AND
	( ','+@bookedby like '%,'+ #temp1.ord_bookedby+'%' OR @bookedby = 'ALL')

--FROM	#temp1,
--	labelfile l_outstat,
--	labelfile l_instat,
--	labelfile l_priority,
--	labelfile l_subcompany,
--	labelfile l_class1,
--	labelfile l_class2,
--	labelfile l_class3,
--	labelfile l_class4,
--	labelfile l_trltype1
--WHERE	( l_outstat.abbr =* lgh_outstatus AND l_outstat.labeldefinition = 'DispStatus' ) AND
--	( l_instat.abbr =* lgh_instatus AND l_instat.labeldefinition = 'InStatus' ) AND
--	( l_priority.abbr =* lgh_priority AND l_priority.labeldefinition = 'OrderPriority' ) AND
--	( l_subcompany.abbr =* ord_subcompany AND l_subcompany.labeldefinition = 'Company' ) AND
--	( l_trltype1.abbr =* trl_type1 AND l_trltype1.labeldefinition = 'TrlType1' ) AND
--	( l_class1.abbr =* lgh_class1 AND l_class1.labeldefinition = 'RevType1' ) AND
--	( l_class2.abbr =* lgh_class2 AND l_class2.labeldefinition = 'RevType2' ) AND
--	( l_class3.abbr =* lgh_class3 AND l_class3.labeldefinition = 'RevType3' ) AND
--	( l_class4.abbr =* lgh_class4 AND l_class4.labeldefinition = 'RevType4' ) AND
--	( ','+@trltype1 like '%,'+ trl_type1+'%' OR @trltype1 = '') AND
--	( ','+@company like '%,'+ord_subcompany+'%' OR @company = '') AND
--	( ','+@bookedby like '%,'+ord_bookedby+'%' OR @bookedby = 'ALL')

END
GO
GRANT EXECUTE ON  [dbo].[d_waybill_trips_sp] TO [public]
GO
