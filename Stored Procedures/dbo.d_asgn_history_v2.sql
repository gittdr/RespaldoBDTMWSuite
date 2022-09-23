SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_asgn_history_v2] 
       @asgn_type varchar(6), 
-- PTS 28809 -- BL (start)
--       @asgn_id varchar(12), 
       @asgn_id varchar(13), 
-- PTS 28809 -- BL (end)
       @start_dt datetime, 
       @end_dt datetime
AS
/**
 * 
 * REVISION HISTORY:
 *	LOR	PTS# 35780	add ord_fromorder, ord_route, ordercount
 * 10/24/2007.01 ? PTS40012 - JGUO ? convert convert old style outer join syntax to ansi outer join syntax.
 *	01/27/2012 PTS 61231 SGB Restore commodity description to come from order
 **/

DECLARE @OrderRefTypeList	VARCHAR(100)

CREATE TABLE #temp (
	legheader_mov_number		INT NULL,
	legheader_ord_hdrnumber 	INT NULL,
	city_cty_nmstct			VARCHAR(30) NULL,
	city_cty_nmstct1		VARCHAR(30) NULL,
	legheader_lgh_startdate		DATETIME NULL,
	lgh_number			INT NULL,
	assetassignment_pyd_status	VARCHAR(6) NULL,
	assetassignment_asgn_status	VARCHAR(6) NULL,
	event_evt_tractor		VARCHAR(8) NULL,
	event_evt_driver1		VARCHAR(8) NULL,
	start_cmp_id			VARCHAR(8) NULL,
	end_cmp_id			VARCHAR(8) NULL,
	paperwork			INT NULL,
	miles				INT NULL,
	start_city			VARCHAR(30) NULL,
	end_city			VARCHAR(30) NULL,
	ord_number			VARCHAR(12) NULL,
	ord_origincity			INT NULL,
	ord_destcity			INT NULL,
	pickup_time			DATETIME NULL,
	cmd_code			VARCHAR(8) NULL,
	ord_description			VARCHAR(64) NULL,
	lgh_primary_trailer		VARCHAR(13) NULL,
	lgh_driver2			VARCHAR(8) NULL,
	ord_fromorder			VARCHAR(12) NULL,
	ord_route			VARCHAR(15) NULL,
	ordercount			INT NULL,
	cmd_code2			VARCHAR(8) NULL,
	cmd_name2			VARCHAR(60) NULL,
	cmd_code3			VARCHAR(8) NULL,
	cmd_name3			VARCHAR(60) NULL,
	cmd_code4			VARCHAR(8) NULL,
	cmd_name4			VARCHAR(60) NULL
)

--PTS52520 MBR 07/21/10
SELECT @OrderRefTypeList = gi_string1
  FROM generalinfo
 WHERE gi_name = 'ExcludeOrdersFromHistory'
IF LEN(@OrderRefTypeList) > 0
BEGIN
   SET @OrderRefTypeList = ',' + @OrderRefTypeList + ','
END

INSERT INTO #temp (legheader_mov_number, legheader_ord_hdrnumber, city_cty_nmstct,
		   city_cty_nmstct1, legheader_lgh_startdate, lgh_number,
		   assetassignment_pyd_status, assetassignment_asgn_status, event_evt_tractor,
		   event_evt_driver1, start_cmp_id, end_cmp_id, paperwork, miles,
		   start_city, end_city, ord_number, ord_origincity, ord_destcity,
		   pickup_time, lgh_primary_trailer, lgh_driver2,
		   ord_fromorder, ord_route, ordercount)
SELECT DISTINCT 
       lgh.mov_number,
       lgh.ord_hdrnumber, 
       (select cty_nmstct from city where cty_code = sstops.stp_city) 'city_a_cty_nmstct', 
       (select cty_nmstct from city where cty_code = estops.stp_city) 'city_b_cty_nmstct', 
       asgn_date, 
       lgh.lgh_number, 
       pyd_status, 
       asgn_status, 
       lgh.lgh_tractor, 
       lgh.lgh_driver1, 
       sstops.cmp_id start_cmp_id, 
       estops.cmp_id end_cmp_id,
		--42502 JJF 20080513
       /*(SELECT (CASE (COUNT(*) - SUM(CASE pw_received 
                                                     WHEN 'Y' THEN 1 
                                                     ELSE 0 
                                                 END))
                                WHEN 0 THEN 1
                                ELSE -1
                            END)
                      FROM  paperwork  LEFT OUTER JOIN  labelfile  ON  paperwork.abbr  = labelfile.abbr 
                      WHERE  (paperwork.ord_hdrnumber = lgh.ord_hdrnumber AND 
                             labelfile.code < 100 AND 
                             labelfile.labeldefinition = 'PaperWork')) paperwork, 
		*/
		paperwork = CASE (
							isnull((SELECT count(*) - SUM(CASE paperwork.pw_received
														WHEN 'Y' THEN 1
														ELSE 0
													END) 
									FROM labelfile inner join paperwork on labelfile.abbr = paperwork.abbr
																			and paperwork.ord_hdrnumber = lgh.ord_hdrnumber
																			and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber) else paperwork.lgh_number end or lgh_number is null)
									WHERE labeldefinition = 'PaperWork'
									  and retired <> 'Y'
									  and 'A' = (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'PaperWorkMode')
									  and lgh.ord_hdrnumber > 0), 0)

							+

							isnull((SELECT SUM(CASE bdt_inv_required
													WHEN 'Y' THEN 1
													ELSE 0 
												 END) -
											SUM(CASE paperwork.pw_received
													WHEN 'Y' THEN 1
													ELSE 0
												END)
									FROM BillDoctypes left outer JOIN paperwork on paperwork.ord_hdrnumber = lgh.ord_hdrnumber
																			   and paperwork.abbr = BillDoctypes.bdt_doctype
																			   and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber) else paperwork.lgh_number end or lgh_number is null)
										inner join orderheader oh on paperwork.ord_hdrnumber = oh.ord_hdrnumber
									WHERE LEN(bdt_doctype) > 0
									AND IsNull(bdt_inv_required,'Y') = 'Y'
									and BillDoctypes.cmp_id = oh.ord_billto
									and 'B' = (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'PaperWorkMode')), 0)

							+ 

							isnull((SELECT SUM(CASE cpw.cpw_inv_required
													WHEN 'Y' THEN 1
													ELSE 0 
												 END) -
											SUM(CASE paperwork.pw_received
													WHEN 'Y' THEN 1
													ELSE 0
												END)
									FROM chargetypepaperwork cpw INNER JOIN chargetype cht ON cpw.cht_number = cht.cht_number
																 INNER JOIN invoicedetail ivd ON cht.cht_itemcode = ivd.cht_itemcode
																 INNER JOIN invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
																 INNER JOIN paperwork on paperwork.ord_hdrnumber = ivd.ord_hdrnumber
																			   and paperwork.abbr = cpw.cpw_paperwork
																			   and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber) else paperwork.lgh_number end or lgh_number is null)
																 left outer join chargetypepaperworkcmp cpwcmpinner on cht.cht_number = cpwcmpinner.cht_number
									WHERE ivd.ord_hdrnumber = lgh.ord_hdrnumber
									  and ((cht.cht_paperwork_requiretype = 'O'
										and ivh.ivh_billto = cpwcmpinner.cmp_id)
										or (cht.cht_paperwork_requiretype = 'E'
										and ivh.ivh_billto <> cpwcmpinner.cmp_id)
										or cht.cht_paperwork_requiretype = 'A')), 0)

						)
					WHEN 0 THEN 1
					ELSE -1
				END
						,
		--END 42502 JJF 20080513
       (SELECT ISNULL(SUM(stp_lgh_mileage), 0) 
                  FROM stops 
                 WHERE stops.lgh_number = lgh.lgh_number) miles, 
       (SELECT cty_nmstct 
                       FROM city 
                      WHERE cty_code = orderheader.ord_origincity) start_city, 
       (SELECT cty_nmstct 
                     FROM city 
                    WHERE cty_code = orderheader.ord_destcity) end_city, 
       ISNULL(ord_number, '0') ord_number, 
       ord_origincity, 
       ord_destcity,
       isnull((select min(stp_eta) 
		from stops a 
		where a.ord_hdrnumber = orderheader.ord_hdrnumber and
		      stp_type = 'PUP'),
		(select min(stp_arrivaldate) 
		from stops a 
		where a.ord_hdrnumber = orderheader.ord_hdrnumber and
		      stp_type = 'PUP')),
	case when @asgn_type = 'TRL' then @asgn_id
	else lgh.lgh_primary_trailer end lgh_primary_trailer,
	lgh.lgh_driver2, 
	ord_fromorder,
	ord_route,
	l.ordercount
FROM  legheader lgh  LEFT OUTER JOIN  orderheader  ON  lgh.ord_hdrnumber  = orderheader.ord_hdrnumber   
                     LEFT OUTER JOIN  legheader_active l  ON  lgh.lgh_number  = l.lgh_number ,
	 assetassignment,
	 event sevent,
	 stops sstops,
	 event eevent,
	 stops estops 
WHERE	 asgn_type  = @asgn_type
		AND	asgn_id  = @asgn_id
		AND	asgn_date  >= @start_dt
		AND	asgn_date  <= @end_dt
		AND	assetassignment.lgh_number  = lgh.lgh_number
		AND	assetassignment.evt_number  = sevent.evt_number
		AND	sevent.stp_number  = sstops.stp_number
		AND	assetassignment.last_evt_number  = eevent.evt_number
		AND	eevent.stp_number  = estops.stp_number
order by asgn_date

UPDATE #temp
   SET cmd_code = (SELECT TOP 1 cmd_code
		     FROM freightdetail 
 		    WHERE stp_number IN (SELECT stops.stp_number
		        		   FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                    event.evt_trailer1 = #temp.lgh_primary_trailer
		       			  WHERE lgh_number = #temp.lgh_number AND
						stp_type = 'DRP') AND
       			  cmd_code <> 'UNKNOWN')

UPDATE #temp
   SET cmd_code2 = (SELECT TOP 1 cmd_code
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROm stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			  cmd_code <> 'UNKNOWN' AND
			  cmd_code <> #temp.cmd_code)

UPDATE #temp
   SET cmd_code3 = (SELECT TOP 1 cmd_code
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			   cmd_code <> 'UNKNOWN' AND
			   cmd_code <> #temp.cmd_code AND
			   cmd_code <> #temp.cmd_code2)

UPDATE #temp
   SET cmd_code4 = (SELECT TOP 1 cmd_code
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			   cmd_code <> 'UNKNOWN' AND
			   cmd_code <> #temp.cmd_code AND
			   cmd_code <> #temp.cmd_code2 AND
			   cmd_code <> #temp.cmd_code3)
			   
-- PTS 61231 SGB

UPDATE #temp
   SET ord_description = (SELECT TOP 1 fgt_description
		     FROM freightdetail 
 		    WHERE stp_number IN (SELECT stops.stp_number
		        		   FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                    event.evt_trailer1 = #temp.lgh_primary_trailer
		       			  WHERE lgh_number = #temp.lgh_number AND
						stp_type = 'DRP') AND
       			  cmd_code <> 'UNKNOWN')

UPDATE #temp
   SET cmd_name2 = (SELECT TOP 1 fgt_description
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROm stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			  cmd_code <> 'UNKNOWN' AND
			  cmd_code <> #temp.cmd_code)

UPDATE #temp
   SET cmd_name3 = (SELECT TOP 1 fgt_description
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			   cmd_code <> 'UNKNOWN' AND
			   cmd_code <> #temp.cmd_code AND
			   cmd_code <> #temp.cmd_code2)

UPDATE #temp
   SET cmd_name4 = (SELECT TOP 1 fgt_description
		      FROM freightdetail
		     WHERE stp_number IN (SELECT stops.stp_number
					    FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                     event.evt_trailer1 = #temp.lgh_primary_trailer
					   WHERE lgh_number = #temp.lgh_number AND
						 stp_type = 'DRP') AND
			   cmd_code <> 'UNKNOWN' AND
			   cmd_code <> #temp.cmd_code AND
			   cmd_code <> #temp.cmd_code2 AND
			   cmd_code <> #temp.cmd_code3)			   

/* PTS 61231 SGB Since this is historical data get the description from the trip
UPDATE #temp
   SET ord_description = (SELECT cmd_name
			    FROM commodity
			   WHERE cmd_code = #temp.cmd_code),
       cmd_name2 = (SELECT cmd_name
		      FROM commodity
		     WHERE cmd_code = #temp.cmd_code2),
       cmd_name3 = (SELECT cmd_name
		      FROM commodity
		     WHERE cmd_code = #temp.cmd_code3),
       cmd_name4 = (SELECT cmd_name
		      FROM commodity
		     WHERE cmd_code = #temp.cmd_code4)
*/		     

IF LEN(@OrderRefTypeList) > 0
BEGIN
   SELECT *
     FROM #temp
    WHERE legheader_ord_hdrnumber NOT IN (SELECT distinct ref_tablekey
                                            FROM referencenumber
                                           WHERE ref_tablekey = legheader_ord_hdrnumber AND
                                                 ref_table = 'orderheader' AND
                                                 CHARINDEX(',' + ref_type + ',', @OrderRefTypeList) > 0)
END
ELSE
BEGIN 
   SELECT *
     FROM #temp
END

GO
GRANT EXECUTE ON  [dbo].[d_asgn_history_v2] TO [public]
GO
