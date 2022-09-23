SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_inroute_trips_complete_sp]
	@revtype1 varchar(254),
	@revtype2 varchar(254),
	@revtype3 varchar(254),
	@revtype4 varchar(254),
	@trltype1 varchar(254),
	@company varchar(254),
	@states varchar(254),
	@cmpids varchar(254),
	@reg1 varchar(254),
	@reg2 varchar(254),
	@reg3 varchar(254),
	@reg4 varchar(254),
	@city int,
	@hoursback int,
	@hoursout int,
	@status char(254),
	@bookedby varchar(254)

AS
/**
 * 
 * NAME:
 * dbo.d_inroute_trips_complete_sp
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
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 **/


DECLARE  @drv1 char(8),
	@drv2 char(8)

IF @hoursback = 0
	SELECT @hoursback = 1000000

IF @hoursout = 0
	SELECT @hoursout = 1000000

SELECT	DISTINCT lgh.lgh_number, 
	cmp_a.cmp_id o_cmpid, 
	cmp_a.cmp_name o_cmpname, 
	cty_a.cty_nmstct o_ctyname, 
	cmp_b.cmp_id d_cmpid, 
	cmp_b.cmp_name d_cmpname, 
	cty_b.cty_nmstct d_ctyname, 
	ord.ord_originpoint f_cmpid,
	convert(char(30), '') f_cmpname,
	ord.ord_origincity f_ctycode,
	convert(char(25), '') f_ctyname,
	ord.ord_destpoint l_cmpid,
	convert(char(30), '') l_cmpname,
	ord.ord_destcity l_ctycode,
	convert(char(25), '') l_ctyname,
	lgh.lgh_startdate, 
	lgh.lgh_enddate, 
	cty_a.cty_state o_state, 
	cty_b.cty_state d_state, 
	lgh.lgh_schdtearliest, 
	lgh.lgh_schdtlatest,
	lgh.cmd_code,
	lgh.fgt_description,
	convert(int, 0) cmd_count,
	lgh.ord_hdrnumber, 
	@drv1 evt_driver1, 
	@drv2 evt_driver2, 
	convert(char(8), '') evt_tractor, 
	lgh.lgh_primary_trailer, 
	ord.trl_type1,
	convert(char(8), '') evt_carrier, 
	lgh.mov_number, 
	ord.ord_availabledate, 
	ord.ord_stopcount, 
	ord.ord_totalcharge, 
	ord.ord_totalweight, 
	ord.ord_length, 
	ord.ord_width, 
	ord.ord_height, 
	ord.ord_totalmiles, 
	ord.ord_number, 
	cty_a.cty_code o_city, 
	cty_b.cty_code d_city,
	lgh.lgh_outstatus, 
	lgh.lgh_instatus, 
	lgh.lgh_priority, 
	ord.ord_subcompany,
	lgh.lgh_class1, 
	lgh.lgh_class2, 
	lgh.lgh_class3, 
	lgh.lgh_class4,
	convert(char(20),'') revlabel1,
	convert(char(20),'') revlabel2,
	convert(char(20),'') revlabel3,
	convert(char(20),'') revlabel4,
	convert(char(20),'') trllabel1,
	ord.ord_bookedby,
	lgh.lgh_etaalert1,
	lgh.lgh_outofroute_routing
INTO	#temp
FROM	city cty_a, 
	company cmp_a, 
	orderheader ord RIGHT OUTER JOIN legheader lgh ON ord.ord_hdrnumber = lgh.ord_hdrnumber, 
	city cty_b, 
	company cmp_b
WHERE	lgh.cmp_id_start = cmp_a.cmp_id
AND	lgh.cmp_id_end = cmp_b.cmp_id
AND	lgh.lgh_startcity = cty_a.cty_code
AND	lgh.lgh_endcity = cty_b.cty_code
--AND	ord.ord_hdrnumber =* lgh.ord_hdrnumber
AND	lgh.lgh_outstatus = 'STD'
AND	(',' + @revtype1 like '%,' + lgh.lgh_class1 + '%' OR @revtype1 = '')
AND	(',' + @revtype2 like '%,' + lgh.lgh_class2 + '%' OR @revtype2 = '')
AND	(',' + @revtype3 like '%,' + lgh.lgh_class3 + '%' OR @revtype3 = '')
AND	(',' + @revtype4 like '%,' + lgh.lgh_class4 + '%' OR @revtype4 = '')
AND	(',' + @states like '%,' + cty_a.cty_state + '%' OR @states = '')
AND	(',' + @cmpids like '%,' + cmp_id_start + '%' OR @cmpids = '')
AND	(@reg1 = cty_a.cty_region1 OR @reg1 = 'UNK')
AND	(@reg2 = cty_a.cty_region2 OR @reg2 = 'UNK')
AND	(@reg3 = cty_a.cty_region3 OR @reg3 = 'UNK')
AND	(@reg4 = cty_a.cty_region4 OR @reg4 = 'UNK')
AND	(@city = cty_a.cty_code OR @city = 0)
AND	lgh.lgh_startdate >= dateadd(hour, -@hoursback, getdate())
AND	lgh.lgh_startdate <= dateadd(hour, @hoursout, getdate())

UPDATE	#temp
SET	#temp.f_cmpname = cmp_c.cmp_name,
	#temp.f_ctyname = cty_c.cty_nmstct,
	#temp.l_cmpname = cmp_d.cmp_name,
	#temp.l_ctyname = cty_d.cty_nmstct
FROM	city cty_c,
	company cmp_c,
	city cty_d,
	company cmp_d
WHERE	#temp.f_cmpid = cmp_c.cmp_id
AND	#temp.l_cmpid = cmp_d.cmp_id
AND	#temp.f_ctycode = cty_c.cty_code
AND	#temp.l_ctycode = cty_d.cty_code

UPDATE	#temp
SET	evt_driver1 = evt.evt_driver1,
	evt_driver2 = evt.evt_driver2,
	evt_tractor = evt.evt_tractor,
	evt_carrier = evt.evt_carrier
FROM	event evt, stops stp
WHERE	stp.lgh_number = #temp.lgh_number
AND	evt.stp_number = stp.stp_number

UPDATE	#temp
SET	cmd_count = (	SELECT COUNT (DISTINCT frt.cmd_code )
			FROM	stops stp, freightdetail frt
			WHERE	stp.ord_hdrnumber = #temp.ord_hdrnumber
			AND	stp.stp_number = frt.stp_number
			AND	stp.stp_type = 'DRP'
			AND	frt.cmd_code <> 'UNKNOWN')
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
FROM labelfile l_outstat  RIGHT OUTER JOIN  #temp  ON (l_outstat.abbr  = #temp.lgh_outstatus and l_outstat.labeldefinition = 'DispStatus')  
		LEFT OUTER JOIN  labelfile l_instat  ON  (l_instat.abbr  = #temp.lgh_instatus and l_instat.labeldefinition = 'InStatus') 
		LEFT OUTER JOIN  labelfile l_priority  ON  (l_priority.abbr  = #temp.lgh_priority and l_priority.labeldefinition = 'OrderPriority')  
		LEFT OUTER JOIN  labelfile l_subcompany  ON  (l_subcompany.abbr  = #temp.ord_subcompany and l_subcompany.labeldefinition = 'Company')  
		LEFT OUTER JOIN  labelfile l_trltype1  ON  (l_trltype1.abbr  = #temp.trl_type1 and l_trltype1.labeldefinition = 'TrlType1')
		LEFT OUTER JOIN  labelfile l_class1  ON  (l_class1.abbr  = #temp.lgh_class1 and l_class1.labeldefinition = 'RevType1')
		LEFT OUTER JOIN  labelfile l_class2  ON  (l_class2.abbr  = #temp.lgh_class2 and l_class2.labeldefinition = 'RevType2')
		LEFT OUTER JOIN  labelfile l_class3  ON  (l_class3.abbr  = #temp.lgh_class3 and l_class3.labeldefinition = 'RevType3')
		LEFT OUTER JOIN  labelfile l_class4  ON  (l_class4.abbr  = #temp.lgh_class4 and l_class4.labeldefinition = 'RevType4')
WHERE	(',' + @trltype1 like '%,' + #temp.trl_type1 + '%' OR @trltype1 = '')
AND	(',' + @company like '%,' + #temp.ord_subcompany + '%' OR @company = '')
AND	(',' + @bookedby like '%,' + #temp.ord_bookedby + '%' OR @bookedby = 'ALL')

--FROM	
--	#temp,
--	labelfile l_outstat,
--	labelfile l_instat,
--	labelfile l_priority,
--	labelfile l_subcompany,
--	labelfile l_class1,
--	labelfile l_class2,
--	labelfile l_class3,
--	labelfile l_class4,
--	labelfile l_trltype1
--WHERE	l_outstat.abbr =* lgh_outstatus
--AND	l_outstat.labeldefinition = 'DispStatus'
--AND	l_instat.abbr =* lgh_instatus
--AND	l_instat.labeldefinition = 'InStatus'
--AND	l_priority.abbr =* lgh_priority
--AND	l_priority.labeldefinition = 'OrderPriority'
--AND	l_subcompany.abbr =* ord_subcompany
--AND	l_subcompany.labeldefinition = 'Company'
--AND	l_trltype1.abbr =* trl_type1
--AND	l_trltype1.labeldefinition = 'TrlType1'
--AND	l_class1.abbr =* lgh_class1
--AND	l_class1.labeldefinition = 'RevType1'
--AND	l_class2.abbr =* lgh_class2
--AND	l_class2.labeldefinition = 'RevType2'
--AND	l_class3.abbr =* lgh_class3
--AND	l_class3.labeldefinition = 'RevType3'
--AND	l_class4.abbr =* lgh_class4
--AND	l_class4.labeldefinition = 'RevType4'
--AND	(',' + @trltype1 like '%,' + trl_type1 + '%' OR @trltype1 = '')
--AND	(',' + @company like '%,' + ord_subcompany + '%' OR @company = '')
--AND	(',' + @bookedby like '%,' + ord_bookedby + '%' OR @bookedby = 'ALL')


GO
GRANT EXECUTE ON  [dbo].[d_inroute_trips_complete_sp] TO [public]
GO
