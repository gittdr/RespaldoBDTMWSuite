SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
--PTS 59062 JJF 20111024
CREATE PROCEDURE [dbo].[d_ico_associated_intercompany_movements]	(
	@mov_number int
) 

AS BEGIN

	DECLARE @ico_associated_intercompany_trips TABLE	(
		level int null,
		mov_number int null,
		lgh_number int null,
		ord_hdrnumber int null,
		mov_number_parent int null,
		lgh_number_parent int null,
		lgh_startdate datetime null,
		lgh_enddate datetime null,
		lgh_outstatus varchar(6) null,
		lgh_instatus varchar(6) null,
		leafnode bit null,
		ico_lgh_id int null
	)
	
	--Load up associated ICO trips
	INSERT @ico_associated_intercompany_trips	(
		level,
		mov_number,
		lgh_number,
		ord_hdrnumber,
		mov_number_parent,
		lgh_number_parent,
		lgh_startdate,
		lgh_enddate,
		lgh_outstatus,
		lgh_instatus,
		leafnode,
		ico_lgh_id
	)
	SELECT	level,
			mov_number,
			lgh_number,
			ord_hdrnumber,
			mov_number_parent,
			lgh_number_parent,
			lgh_startdate,
			lgh_enddate,
			lgh_outstatus,
			lgh_instatus,
			leafnode,
			ico_lgh_id
	FROM dbo.ico_associated_intercompany_trips_fn(@mov_number)


	--final output	
	SELECT DISTINCT
			level,
			0 sort,
			ico.mov_number,
			ico.mov_number_parent,
			ico.lgh_number_parent,
			lgh.lgh_number,
			oh.ord_hdrnumber,
			oh.ord_number,
			oh.ord_billto,
			oh.ord_revtype1,
			lblrevtype1.name ord_revtype1_name,
			lblrevtype1.userlabelname + ':' ord_revtype1_t,
			oh.ord_revtype2,
			lblrevtype2.name ord_revtype2_name,
			lblrevtype2.userlabelname + ':' ord_revtype2_t,
			oh.ord_revtype3,
			lblrevtype3.name ord_revtype3_name,
			lblrevtype3.userlabelname + ':' ord_revtype3_t,
			oh.ord_revtype4,
			lblrevtype4.name ord_revtype4_name,
			lblrevtype4.userlabelname + ':' ord_revtype4_t,
			--PTS 61653 JJF 20120620
			oh.ord_booked_revtype1,
			lblbooked_revtype1.brn_name ord_booked_revtype1_name,
			'Branch:' ord_booked_revtype1_t,
			--END PTS 61653 JJF 20120620
			oh.ord_originpoint,
			oh.ord_destpoint,
			oh.ord_origincity,
			oh.ord_destcity,
			cty_origin.cty_nmstct origin_cty_nmstct,
			cty_dest.cty_nmstct dest_cty_nmstct,
			oh.ord_originstate,
			oh.ord_deststate,
			oh.ord_startdate,
			oh.ord_completiondate,
			lgh.lgh_carrier,
			(	SELECT	isnull(SUM(pyd_p.pyd_amount), 0)
				FROM	paydetail pyd_p
						inner join paytype pyt_p on pyd_p.pyt_itemcode = pyt_p.pyt_itemcode
				WHERE	lgh.lgh_number = pyd_p.lgh_number
						and pyd_p.asgn_type = 'CAR'
						and pyd_p.asgn_id = lgh.lgh_carrier
			) car_expense,
			lgh.lgh_driver1,
			(	SELECT	isnull(SUM(pyd_p.pyd_amount), 0)
				FROM	paydetail pyd_p
						inner join paytype pyt_p on pyd_p.pyt_itemcode = pyt_p.pyt_itemcode
				WHERE	lgh.lgh_number = pyd_p.lgh_number
						and pyd_p.asgn_type = 'DRV'
						and pyd_p.asgn_id = lgh.lgh_driver1
			) drv1_expense,
			lgh.lgh_startdate,
			lgh.lgh_enddate,
			lgh.cmp_id_start lgh_cmp_id_start,
			lgh.cmp_id_end lgh_cmp_id_end, 
			lgh.lgh_startcity,
			lgh.lgh_endcity,
			lgh.lgh_startcty_nmstct,
			lgh.lgh_endcty_nmstct,
			oh.ord_totalcharge as revenue,
			(	SELECT	isnull(SUM(pyd_p.pyd_amount), 0)
				FROM	paydetail pyd_p
						inner join paytype pyt_p on pyd_p.pyt_itemcode = pyt_p.pyt_itemcode
				WHERE	oh.ord_hdrnumber = pyd_p.ord_hdrnumber
			) as expenses,
			448 indentoffset,	--This controls indentation for each nested trip level when displayed
			-488 tripoffset		--This controls vertical spacing of each trip segment when displayed.  If you adjust vertical detail height in the window, this will vertically adjust the trip segment area so that order information does not repeat when presented.
	FROM	legheader lgh 
			INNER JOIN @ico_associated_intercompany_trips ico on ico.lgh_number = lgh.lgh_number
			LEFT OUTER join orderheader oh on oh.ord_hdrnumber = lgh.ord_hdrnumber
			LEFT OUTER JOIN labelfile lblrevtype1 on (lblrevtype1.labeldefinition = 'RevType1' and oh.ord_revtype1 = lblrevtype1.abbr)
			LEFT OUTER JOIN labelfile lblrevtype2 on (lblrevtype2.labeldefinition = 'RevType2' and oh.ord_revtype2 = lblrevtype2.abbr)
			LEFT OUTER JOIN labelfile lblrevtype3 on (lblrevtype3.labeldefinition = 'RevType3' and oh.ord_revtype3 = lblrevtype3.abbr)
			LEFT OUTER JOIN labelfile lblrevtype4 on (lblrevtype4.labeldefinition = 'RevType4' and oh.ord_revtype4 = lblrevtype4.abbr)
			--PTS 61653 JJF 20120620
			LEFT OUTER JOIN branch lblbooked_revtype1 on (oh.ord_booked_revtype1 = lblbooked_revtype1.brn_id)
			--END PTS 61653 JJF 20120620
			LEFT OUTER JOIN city cty_origin on cty_origin.cty_code = oh.ord_origincity
			LEFT OUTER JOIN city cty_dest on cty_dest.cty_code = oh.ord_destcity


END
GO
GRANT EXECUTE ON  [dbo].[d_ico_associated_intercompany_movements] TO [public]
GO
