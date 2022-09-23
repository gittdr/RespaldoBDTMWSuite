SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_earn_per_mile_rpt_sp]
	@date_from datetime,
	@date_to datetime,
	@type int,
	@id char(12)
AS
/**
 * 
 * NAME:
 * dbo.d_earn_per_mile_rpt_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Retrieve earnings per mile report data (Trimac) for report
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * Output is report data for each order
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
 * wsc 02/07/97 to eliminate return of UNKNOWN data set
 * wsc 03/07/97 to handle date range
 * wsc 09/05/97 to use legheader hours parmaters instead of invoice
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 *
 **/


-- Create a temp table for order data
CREATE TABLE #temp_ord
	(ord_hdrnumber int,
	rgh_id varchar(6) null,
	brn_id varchar(12) null,
	ord_consignee varchar(8),
	ord_originpoint varchar(8) null,
	cmp_id_load varchar(8) null,
	cmp_id_unload varchar(8) null,
	ord_destpoint varchar(8) null,
	cmd_code varchar(8) null,
	ord_unit varchar(6) null,
	ord_quantity int null,
	revenue money null,
	miles int null,
	tot_hrs float null,
	prd_hrs float null)

-- Create a temp table for the report
CREATE TABLE #temp_rpt
	(date_from datetime,
	date_to datetime,
	rgh_id varchar(6) null,
	rgh_name varchar(30) null,
	brn_id varchar(12) null,
	brn_name varchar(40) null,
	ord_consignee varchar(8),
	consignee_name varchar(30) null,
	ord_originpoint varchar(8) null,
	cmp_id_load varchar(8) null,
	cmp_id_unload varchar(8) null,
	ord_destpoint varchar(8) null,
	cmd_code varchar(8) null,
	ord_unit varchar(6) null,
	ord_quantity float null,
	trp int null,
	revenue money null,
	miles int null,
	rpm money null,
	tot_hrs float null,
	rpth money null,
	prd_hrs float null,
	rpph money null)


IF @date_from IS null OR @date_from = ''
	SELECT @date_from = '19490101 00:00:00'

IF @date_to IS null OR @date_to = ''
	SELECT @date_to = '20501231 23:59:59'
ELSE
	SELECT @date_to = DATEADD(dd, 1, @date_to)


IF @type > 0 AND @type < 4
	BEGIN

-- By consignee company
	IF @type = 1
		BEGIN
			INSERT INTO #temp_ord		
			SELECT ord_hdrnumber,
				'UNK',
				ord_revtype1,
				@id,
				ord_originpoint,
				null,
				null,
				ord_destpoint,
				cmd_code,
				ord_unit,
				ord_quantity,
				0,
				0,
				0,
				0		
			FROM orderheader

			WHERE ord_bookdate BETWEEN @date_from AND @date_to
				AND ord_consignee = @id
		END

-- By region
	IF @type = 2
		BEGIN
			INSERT INTO #temp_ord
			SELECT ord_hdrnumber,
				@id,
				ord_revtype1,
				ord_consignee,
				ord_originpoint,
				null,
				null,
				ord_destpoint,
				cmd_code,
				ord_unit,
				ord_quantity,
				0,
				0,
				0,
				0
			FROM orderheader, trimac_hierarchy
			WHERE ord_bookdate BETWEEN @date_from AND @date_to
				AND ord_consignee = trimac_company
				AND trimac_region = @id
		END

-- By branch
	IF @type = 3
		BEGIN
			INSERT INTO #temp_ord
			SELECT ord_hdrnumber,
				'UNK',
				ord_revtype1,
				ord_consignee,
				ord_originpoint,
				null,
				null,
				ord_destpoint,

				cmd_code,
				ord_unit,
				ord_quantity,
				0,
				0,
				0,
				0
			FROM orderheader
			WHERE ord_bookdate BETWEEN @date_from AND @date_to
				AND ord_revtype1 = @id
		END

-- Exit if no rows to process
	IF (SELECT COUNT (*) FROM #temp_ord) > 0
		BEGIN

-- Get the invoiceheader revenue
		UPDATE #temp_ord
		SET revenue = i.ivh_totalcharge
		FROM invoiceheader i, #temp_ord o
		WHERE i.ord_hdrnumber = o.ord_hdrnumber

-- Get the legheader total hours and productive hours
		SELECT tot_hrs = SUM(l.lgh_tot_hr),
			prd_hrs = SUM(l.lgh_prod_hr),
			ord_hdrnumber = l.ord_hdrnumber
		INTO #temp_sum
		FROM legheader l, #temp_ord o
		WHERE l.ord_hdrnumber = o.ord_hdrnumber
		GROUP BY l.ord_hdrnumber

		UPDATE #temp_ord
		SET tot_hrs = t.tot_hrs,
			prd_hrs = t.prd_hrs
		FROM #temp_sum t, #temp_ord o
		WHERE t.ord_hdrnumber = o.ord_hdrnumber

-- Get the region for report by company or branch
		IF @type = 1 OR @type = 3
			UPDATE #temp_ord
			SET rgh_id = trimac_region
			FROM trimac_hierarchy, #temp_ord
			WHERE trimac_company = ord_consignee

-- Setup a temp table with the company id for the first load stop on each order
		SELECT MIN(s.stp_mfh_sequence) stp_mfh_sequence,
			s.ord_hdrnumber,
			s.cmp_id,
			s.stp_number,
			s.stp_sequence
		INTO #temp_lodstp
		FROM stops s, #temp_ord o, event e, eventcodetable ect
		WHERE s.ord_hdrnumber = o.ord_hdrnumber
		AND e.stp_number = s.stp_number
		AND e.evt_eventcode = ect.abbr
		AND ect.mile_typ_from_stop = 'LD'
		GROUP BY s.ord_hdrnumber, s.cmp_id, s.stp_number, s.stp_sequence

-- Update the temp order table with the load stop company id's
		UPDATE #temp_ord
		SET cmp_id_load = tl.cmp_id
		FROM #temp_lodstp tl, #temp_ord o
		WHERE tl.ord_hdrnumber = o.ord_hdrnumber


-- Setup a temp table with the company id for the last unload stop on each order
		SELECT MAX(s.stp_mfh_sequence) stp_mfh_sequence,
			s.ord_hdrnumber,
			s.cmp_id,
			s.stp_number,
			s.stp_sequence
		INTO #temp_uldstp
		FROM stops s, #temp_ord o, event e, eventcodetable ect 
		WHERE s.ord_hdrnumber = o.ord_hdrnumber
		AND e.stp_number = s.stp_number
		AND e.evt_eventcode = ect.abbr
		AND ect.mile_typ_to_stop = 'LD'
		GROUP BY s.ord_hdrnumber, s.cmp_id, s.stp_number, s.stp_sequence

-- Update the temp order table with the unload stop company id's
		UPDATE #temp_ord
		SET cmp_id_unload = tu.cmp_id
		FROM #temp_uldstp tu, #temp_ord o
		WHERE tu.ord_hdrnumber = o.ord_hdrnumber

-- Setup a temp table with the mileage between the load and unload on each order
		SELECT SUM(s.stp_ord_mileage) mileage, s.ord_hdrnumber
		INTO #temp_miles
		FROM stops s, #temp_ord o, #temp_lodstp tl, #temp_uldstp tu
		WHERE s.ord_hdrnumber = o.ord_hdrnumber
		AND o.ord_hdrnumber = tl.ord_hdrnumber
		AND o.ord_hdrnumber = tu.ord_hdrnumber
		AND s.stp_sequence > tl.stp_sequence
		AND s.stp_sequence <= tu.stp_sequence
		GROUP BY s.ord_hdrnumber

-- Update the temp order table with the mileage
		UPDATE #temp_ord
		SET miles = mileage
		FROM #temp_miles tm, #temp_ord o
		WHERE o.ord_hdrnumber = tm.ord_hdrnumber

-- Insert the orderheader data into the report grouped by report deatil
		INSERT INTO #temp_rpt
		SELECT @date_from,
			@date_to,
			rgh_id,
			'UNKNOWN',
			brn_id,
			'UNKNOWN',
			ord_consignee,
			'UNKNOWN',
			ord_originpoint,
			cmp_id_load,
			cmp_id_unload,
			ord_destpoint,
			cmd_code,
			ord_unit,
			ord_quantity,
			COUNT (ord_hdrnumber),
			SUM(revenue),
			SUM(miles),
			0,
			SUM(tot_hrs),
			0,
			SUM(prd_hrs),
			0
		FROM #temp_ord
		GROUP BY rgh_id,
			brn_id,
			ord_consignee,
			ord_originpoint,
			cmp_id_load,
			cmp_id_unload,
			ord_destpoint,
			cmd_code,
			ord_unit,
			ord_quantity

		UPDATE #temp_rpt
		SET rgh_name = name
		FROM labelfile, #temp_rpt
		WHERE abbr = rgh_id

		UPDATE #temp_rpt
		SET brn_name = b.brn_name
		FROM branch b, #temp_rpt tr
		WHERE b.brn_id = tr.brn_id

		UPDATE #temp_rpt
		SET consignee_name = cmp_name
		FROM company, #temp_rpt
		WHERE cmp_id = ord_consignee

		UPDATE #temp_rpt
		SET rpm = revenue / miles
		WHERE miles > 0
		AND miles IS NOT null

		UPDATE #temp_rpt
		SET rpth = revenue / tot_hrs
		WHERE tot_hrs > 0
		AND tot_hrs IS NOT null

		UPDATE #temp_rpt
		SET rpph = revenue / prd_hrs
		WHERE prd_hrs > 0
		AND prd_hrs IS NOT null

	END
END

select date_from,
	date_to,
	rgh_id,
	rgh_name,
	brn_id,
	brn_name,
	ord_consignee,
	consignee_name,
	ord_originpoint,
	cmp_id_load,
	cmp_id_unload,
	ord_destpoint,
	cmd_code,
	ord_unit,
	ord_quantity,
	trp,
	revenue,
	miles,
	rpm,
	tot_hrs,
	rpth,
	prd_hrs,
	rpph
from #temp_rpt
order by rgh_id, brn_id, ord_consignee, ord_originpoint

GO
GRANT EXECUTE ON  [dbo].[d_earn_per_mile_rpt_sp] TO [public]
GO
