SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_sp2]
	@BegDate datetime,		-- Date range start
	@EndDate datetime,		-- Date range end
	@FuelTaxStatus varchar (6),	-- Type of transfer (PD - retransfer, NPD - new transfer, ALL - transfer both)
	@IncludeCheckCalls varchar (1), -- Y/N to include checkcalls
	@IncludeFuel varchar (1)	-- Y/N to include fuel purchases (only ones with associated legheader)

AS
	/* for testing... 
	DECLARE @BegDate  datetime			
	DECLARE @EndDate  datetime			
	DECLARE @FuelTaxStatus   varchar (6)	
	DECLARE @IncludeCheckCalls varchar (1)	
	DECLARE @IncludeFuel varchar (1)

  	SELECT  @BegDate ='1/1/1998' 	
 	SELECT  @EndDate ='1/1/1999'	
	SELECT  @FuelTaxStatus   = 'NPD' 
 	SELECT  @IncludeCheckCalls ='Y'  
	SELECT  @IncludeFuel = 'Y' */

-- Create the temp table to hold the info
CREATE TABLE #t (
	lgh_number int, lgh_firstlegnumber int, lgh_lastlegnumber int, 	lgh_startdate datetime, lgh_enddate datetime, 	-- 5
	mov_number int,	lgh_startcity int, lgh_endcity int, lgh_outstatus varchar(6), lgh_class1 varchar(6), 		-- 10 
	lgh_class2 varchar(6), lgh_class3 varchar(6), lgh_class4 varchar(6), lgh_instatus varchar(6),lgh_tractor varchar(8),	-- 15
	lgh_fueltaxstatus varchar(6), stp_arrivaldate datetime, stp_type varchar(6), cty_name varchar(18), cty_state char(2), 	-- 20
	cty_zip varchar(10), fp_id varchar(36),	ord_number char(12), fp_date datetime, fp_fueltype varchar(6),		-- 25
	fp_amount money, fp_cost_per float, fp_invoice_no varchar(10), fp_vendorname varchar(30), fp_uom varchar(6),	-- 30
	fp_quantity float, fp_purchcode varchar(6), ord_type int, lgh_ord_hdrnumber int, fix_sort_ind int,		-- 35
	stp_number_start int, stp_number int, trc_type1 varchar(6), trc_type2 varchar(6), trc_type3 varchar(6),   	-- 40
	trc_type4 varchar(6), stp_city int, lgh_driver1 varchar(8), latitude int, longitude int,			-- 45
 	stp_loadstatus char(3), gpstype char(1), lgh_odometerstart int,	lgh_odometerend int, stp_mfh_sequence int,	-- 50
	stp_event char(6), stp_lgh_mileage int,	ord_revtype2 varchar(6))

/* Get all completed legheaders and their associated stops
    within the date range and add them to temp table */
IF @FuelTaxStatus = 'ALL'   -- Pull all records regardless of lgh_fueltaxstatus (ie. both PD and NPD)
	INSERT #t (lgh_number, lgh_firstlegnumber, lgh_lastlegnumber, 	lgh_startdate, lgh_enddate, 	-- 5
		mov_number, lgh_startcity, lgh_endcity, lgh_outstatus, lgh_class1,	 		-- 10 
		lgh_class2, lgh_class3, lgh_class4, lgh_instatus, lgh_tractor,				-- 15
		lgh_fueltaxstatus, stp_arrivaldate, stp_type, cty_name, cty_state,		 	-- 20
		cty_zip, fp_id, ord_number, fp_date, fp_fueltype,					-- 25
		fp_amount, fp_cost_per, fp_invoice_no, fp_vendorname, fp_uom,				-- 30
		fp_quantity, fp_purchcode, ord_type, lgh_ord_hdrnumber, fix_sort_ind,			-- 35
		stp_number_start, stp_number, trc_type1, trc_type2, trc_type3,			   	-- 40
		trc_type4, stp_city, lgh_driver1, latitude, longitude,					-- 45
 		stp_loadstatus, gpstype, lgh_odometerstart, lgh_odometerend, stp_mfh_sequence,		-- 50
		stp_event, stp_lgh_mileage, ord_revtype2)
		SELECT  legheader.lgh_number,
			legheader.lgh_firstlegnumber, 
			legheader.lgh_lastlegnumber,
		  	legheader.lgh_startdate, 
			legheader.lgh_enddate, 		--5

			stops.mov_number,
			legheader.lgh_startcity,  
			legheader.lgh_endcity, 
			legheader.lgh_outstatus, 
			legheader.lgh_class1,		--10

			legheader.lgh_class2, 
			legheader.lgh_class3, 
			legheader.lgh_class4, 
			legheader.lgh_instatus,		
			legheader.lgh_tractor, 		--15
	
			legheader.lgh_fueltaxstatus,  
			stops.stp_arrivaldate, 
			eventcodetable.fgt_event stp_type, 
			city.cty_name, 			
			city.cty_state, 		--20

			ISNULL ( company.cmp_zip, "" ) cty_zip, 
 			CONVERT(varchar(36), null) fp_id,
			CONVERT(char(12),'') ord_number, 
			CONVERT(datetime, null) fp_date, 
			CONVERT(varchar(6),'') fp_fueltype, --25

			CONVERT(money,0) fp_amount, 
			CONVERT(float,0) fp_cost_per, 
			CONVERT(varchar(10),'') fp_invoice_no, 
			CONVERT(varchar(30),'') fp_vendorname,  
			CONVERT(varchar(6),'') fp_uom,		--30

			CONVERT(float,0) fp_quantity,
			CONVERT(varchar(6),'') fp_purchcode, 
			0 ord_type,
			stops.ord_hdrnumber lgh_ord_hdrnumber, 
			1 fix_sort_ind,				--35

			legheader.stp_number_start,
			stops.stp_number,
			tractorprofile.trc_type1,
			tractorprofile.trc_type2,		
			tractorprofile.trc_type3,		--40
	
			tractorprofile.trc_type4,
			stops.stp_city,
			legheader.lgh_driver1,			
			CONVERT(int, null) latitude,		
			CONVERT(int, null) longitude,		--45

			stp_loadstatus,
			CONVERT(varchar(1),'')	gpstype,
			legheader.lgh_odometerstart,
			legheader.lgh_odometerend,		
			stops.stp_mfh_sequence,			-- 50

			stops.stp_event,	
			stops.stp_lgh_mileage,
			orderheader.ord_revtype2
		FROM legheader, stops, city, tractorprofile, eventcodetable, company, orderheader
		WHERE (legheader.lgh_startdate >= @BegDate AND legheader.lgh_startdate < DATEADD(dd,1,@EndDate))
		  AND legheader.lgh_number = stops.lgh_number
		  AND stops.stp_city = city.cty_code
		  AND legheader.lgh_outstatus = 'CMP'
		  AND tractorprofile.trc_number = legheader.lgh_tractor
		  AND eventcodetable.abbr = stops.stp_event
		  AND company.cmp_id = stops.cmp_id
		  AND legheader.mov_number *= orderheader.mov_number
ELSE   -- Either PD or NPD transfer
	INSERT #t (lgh_number, lgh_firstlegnumber, lgh_lastlegnumber, 	lgh_startdate, lgh_enddate, 	-- 5
		mov_number, lgh_startcity, lgh_endcity, lgh_outstatus, lgh_class1,	 		-- 10 
		lgh_class2, lgh_class3, lgh_class4, lgh_instatus, lgh_tractor,				-- 15
		lgh_fueltaxstatus, stp_arrivaldate, stp_type, cty_name, cty_state,		 	-- 20
		cty_zip, fp_id, ord_number, fp_date, fp_fueltype,					-- 25
		fp_amount, fp_cost_per, fp_invoice_no, fp_vendorname, fp_uom,				-- 30
		fp_quantity, fp_purchcode, ord_type, lgh_ord_hdrnumber, fix_sort_ind,			-- 35
		stp_number_start, stp_number, trc_type1, trc_type2, trc_type3,			   	-- 40
		trc_type4, stp_city, lgh_driver1, latitude, longitude,					-- 45
	 	stp_loadstatus, gpstype, lgh_odometerstart, lgh_odometerend, stp_mfh_sequence,		-- 50
		stp_event, stp_lgh_mileage, ord_revtype2)
		SELECT  legheader.lgh_number,
			legheader.lgh_firstlegnumber, 
			legheader.lgh_lastlegnumber,
		  	legheader.lgh_startdate, 
			legheader.lgh_enddate, 		--5

			stops.mov_number,
			legheader.lgh_startcity,  
			legheader.lgh_endcity, 
			legheader.lgh_outstatus, 
			legheader.lgh_class1,		--10

			legheader.lgh_class2, 
			legheader.lgh_class3, 
			legheader.lgh_class4, 
			legheader.lgh_instatus,		
			legheader.lgh_tractor, 		--15
		
			legheader.lgh_fueltaxstatus,  
			stops.stp_arrivaldate, 
			eventcodetable.fgt_event stp_type, 
			city.cty_name, 			
			city.cty_state, 		--20

			ISNULL (company.cmp_zip, "") cty_zip, 
 			CONVERT(varchar(36), null) fp_id,
			CONVERT(char(12),'') ord_number, 
			CONVERT(datetime, null) fp_date, 
			CONVERT(varchar(6),'') fp_fueltype, --25

			CONVERT(money,0) fp_amount, 
			CONVERT(float,0) fp_cost_per, 
			CONVERT(varchar(10),'') fp_invoice_no, 
			CONVERT(varchar(30),'') fp_vendorname,  
			CONVERT(varchar(6),'') fp_uom,		--30

			CONVERT(float,0) fp_quantity,
			CONVERT(varchar(6),'') fp_purchcode, 
			0 ord_type,
			stops.ord_hdrnumber lgh_ord_hdrnumber, 
			1 fix_sort_ind,				--35

			legheader.stp_number_start,
			stops.stp_number,
			tractorprofile.trc_type1,
			tractorprofile.trc_type2,		
			tractorprofile.trc_type3,		--40

			tractorprofile.trc_type4,
			stops.stp_city,
			legheader.lgh_driver1,			
			CONVERT(int, null) latitude,		
			CONVERT(int, null) longitude,		--45

			stp_loadstatus,
			CONVERT(varchar(1),'')	gpstype,
			legheader.lgh_odometerstart,
			legheader.lgh_odometerend,		
			stops.stp_mfh_sequence,			-- 50

			stops.stp_event,	
			stops.stp_lgh_mileage,
			orderheader.ord_revtype2
		FROM legheader, stops, city, tractorprofile, eventcodetable, company, orderheader
		WHERE (legheader.lgh_startdate >= @BegDate AND legheader.lgh_startdate < DATEADD(dd,1,@EndDate))
		  AND (legheader.lgh_fueltaxstatus = @FuelTaxStatus)
		  AND legheader.lgh_number = stops.lgh_number
		  AND stops.stp_city = city.cty_code
		  AND legheader.lgh_outstatus = 'CMP'
		  AND tractorprofile.trc_number = legheader.lgh_tractor
		  AND eventcodetable.abbr = stops.stp_event
		  AND company.cmp_id = stops.cmp_id
		  AND legheader.mov_number *= orderheader.mov_number

-- Now add in check calls 
IF @IncludeCheckCalls = 'Y' or @IncludeCheckCalls = 'y'
BEGIN
	SELECT MIN(ckc_number) ckc_number
	INTO #temp_ckc
	FROM checkcall
		/* Only grab all the checkcalls between the date range
		that have a tractor, legheader # and a position.

		Round the position to nearest 100 lat/long seconds (1.9 miles apart).
		The will eliminate checkcalls that are really the same locale	*/
	WHERE (checkcall.ckc_date >= @BegDate AND checkcall.ckc_date < DATEADD(dd,1,@EndDate))
	  AND checkcall.ckc_tractor IS NOT NULL
	  AND checkcall.ckc_lghnumber IN (SELECT DISTINCT lgh_number FROM #t)
	  AND  (ckc_latseconds <> 0)		
	  AND (ckc_latseconds IS NOT NULL)
	GROUP BY ckc_lghnumber, ckc_tractor, 
	  CONVERT(int, (ckc_latseconds + 50)/100)*100,
	  CONVERT(int, (ckc_longseconds + 50)/100)*100	

	/* Next, Grab the other checkcalls with no GPS data, but have a city */
	/* Grab the ones with no GPS too */
	INSERT #temp_ckc (ckc_number)
	SELECT ckc_number
	FROM checkcall
	WHERE (checkcall.ckc_date >= @BegDate AND checkcall.ckc_date < DATEADD(dd,1,@EndDate))
	  AND checkcall.ckc_lghnumber IN (SELECT DISTINCT lgh_number FROM #t)
	  AND checkcall.ckc_tractor IS NOT NULL
	  AND (ckc_latseconds = 0 OR ckc_latseconds IS NULL)
	  AND ckc_city <> 0

	/* Now add the checks to the temp table */
	INSERT #t (lgh_number,
		lgh_firstlegnumber,  
		lgh_lastlegnumber,
	  	lgh_startdate, 
		lgh_enddate,     -- 5

		mov_number,
		lgh_startcity, 
		lgh_endcity, 
		lgh_outstatus, 
		lgh_class1,      -- 10

		lgh_class2, 
		lgh_class3, 
		lgh_class4, 
		lgh_instatus,
		lgh_tractor, 	-- 15

		lgh_fueltaxstatus, 
		stp_arrivaldate, 
		stp_type, 
		cty_name, 
		cty_state, 	-- 20

		cty_zip, 
	 	fp_id,
		ord_number, 
		fp_date, 
		fp_fueltype,	-- 25

		fp_amount, 
		fp_cost_per, 
		fp_invoice_no, 
		fp_vendorname, 
		fp_uom,		-- 30

		fp_quantity,
		fp_purchcode, 
		ord_type,
		lgh_ord_hdrnumber,
		fix_sort_ind,	-- 35

		stp_number_start,
		stp_number,
		trc_type1,
		trc_type2,
		trc_type3,	-- 40
	
		trc_type4,
		stp_city,
		lgh_driver1,
		latitude,
		longitude,	-- 45

		stp_loadstatus,
		gpstype,
		lgh_odometerstart,
		lgh_odometerend,
		stp_mfh_sequence,
		stp_event)
	SELECT 
		ckc_lghnumber,
		0, 		-- lgh_firstlegnumber, 
		0, 		-- lgh_lastlegnumber,
	  	ckc_date, 	-- lgh_startdate, 
		ckc_date, 	-- lgh_enddate, 

		0, 		-- mov_number,
		ckc_city, 	-- lgh_startcity, 
		ckc_city,	-- lgh_endcity, 
		"CMP", 		-- lgh_outstatus, 
		"UNK",		-- lgh_class1,

		"UNK",		-- lgh_class2, 
		"UNK",		-- lgh_class3, 
		"UNK",		-- lgh_class4, 
		"HST",		-- lgh_instatus,
		ckc_tractor,	-- lgh_tractor, 

		@FuelTaxStatus,	-- lgh_fueltaxstatus, 
		ckc_date,	-- stp_arrivaldate, 
		"CKC",		-- stp_type, 
		ISNULL (city.cty_name, "" ), 
		ISNULL (checkcall.ckc_state, ''),   -- Get state from checkcall table

		ISNULL(CONVERT(varchar(5),checkcall.ckc_zip), ''),  -- Get zip from checkcall table
	 	CONVERT(varchar(36), null),	-- fp_id,
		CONVERT(char(12),''),		-- ord_number, 
		CONVERT(datetime, null),  	-- fp_date, 
		CONVERT(varchar(6),''),		-- fp_fueltype,

		CONVERT(money,0),		-- fp_amount,                                                                                                                                                                                                                                                             
		CONVERT(float,0),		-- fp_cost_per, 
		CONVERT(varchar(10),''),	-- fp_invoice_no, 
		CONVERT(varchar(30),''),	-- fp_vendorname, 
		CONVERT(varchar(6),''),		-- fp_uom,

		CONVERT(float,0),		-- fp_quantity,
		CONVERT(varchar(6),''),		-- fp_purchcode, 	 
		0,				-- ord_type,
		0,				-- lgh_ord_hdrnumber,
		1,				-- fix_sort_ind,

		0,				-- stp_number_start,
		0,				-- stp_number,
		tractorprofile.trc_type1,
		tractorprofile.trc_type2,
		tractorprofile.trc_type3,

		tractorprofile.trc_type4,
		ckc_city,		 	-- stp_city
		CONVERT(varchar(8),''),		-- lgh_driver1,
		ckc_latseconds,
		ckc_longseconds,

		CONVERT(char(3),''),		-- stp_loadstatus
		ckc_validity,
		0,				-- lgh_odometerstart,
		0,				-- lgh_odometerend
		0,				-- stp_mfh_sequence
		CONVERT(varchar(6),'')		-- stp_event
	FROM #temp_ckc, city, tractorprofile, checkcall
	WHERE #temp_ckc.ckc_number = checkCall.ckc_number
	  AND city.cty_code =* ckc_city
	  AND ckc_tractor = tractorprofile.trc_number

	-- Update states for Comdata type checkcall records 
	--  (need to get the state from the city table)
	UPDATE #t
	SET #t.cty_state = city.cty_state
	FROM city, #t
	WHERE city.cty_code = #t.stp_city
		AND ISNULL(#t.cty_state, '') = ''

	-- Add in move numbers for checkcall records
	UPDATE #t
	SET mov_number = legheader.mov_number
	FROM #t,legheader
	WHERE #t.lgh_number = legheader.lgh_number
		AND #t.stp_type = 'CKC'
END
/* End add in check calls */

/* Mark F jam - set the sort index so that all the stops will come  before the fuel purchases */
/* MZ 4/20/00 commented out following because not using fix_sort_ind to sort at end, but rather lgh and date/time.
UPDATE #t 
SET fix_sort_ind = -1   --before fuelpurchase
WHERE stp_number = stp_number_start */

/* Get the zip codes from the city file */	
UPDATE #t
SET #t.cty_zip = ISNULL(city.cty_zip,'')  
FROM city
WHERE city.cty_code  = #t.stp_city
  AND #t.cty_zip = ''
	
-- Insert fuel purchases if flagged to do so
IF @IncludeFuel = 'Y' or @IncludeFuel = 'y'
BEGIN	
	-- Now insert the fuel purchases that have legheader numbers 
	IF @FuelTaxStatus = 'ALL'
		INSERT INTO #t (lgh_number,
			lgh_firstlegnumber, 
			lgh_lastlegnumber,
		  	lgh_startdate, 
			lgh_enddate, 		--5

			mov_number,
			lgh_startcity, 
			lgh_endcity, 
			lgh_outstatus, 
			lgh_class1,		--10
	
			lgh_class2, 
			lgh_class3, 
			lgh_class4, 
			lgh_instatus,
			lgh_tractor, 		--15

			lgh_fueltaxstatus, 
			stp_arrivaldate, 
			stp_type, 
			cty_name, 
			cty_state, 		--20

			cty_zip, 
		 	fp_id,
			ord_number, 
			fp_date, 
			fp_fueltype,		--25

			fp_amount, 
			fp_cost_per, 
			fp_invoice_no, 
			fp_vendorname, 
			fp_uom,			--30

			fp_quantity,
			fp_purchcode, 
			ord_type,
			lgh_ord_hdrnumber,
			fix_sort_ind,		--35

			stp_number_start,
			stp_number,
			trc_type1,
			trc_type2,
			trc_type3,		--40

			trc_type4,
			stp_city,
			lgh_driver1,
			latitude,
			longitude,		--45

			stp_loadstatus,
			gpstype,
			lgh_odometerstart,
			lgh_odometerend,
			stp_mfh_sequence, 	-- 50  	
			stp_event)		

		SELECT  fuelpurchased.lgh_number, 
			0,
			0,
		 	'', 
			'', 				--5

			fuelpurchased.mov_number,
			0, 
			0, 
			'', 
			'',				--10

		  	'',
			'',
			'',
			'',
		   	fuelpurchased.trc_number,  	--15	

		   	'',
   			fuelpurchased.fp_date,
	   		'',
			ISNULL (city.cty_name, ""),	
			ISNULL (city.cty_state, ""), 	--20  

		   	ISNULL(city.cty_zip,''),  
   			fuelpurchased.fp_id, 
	   		fuelpurchased.ord_number, 
	   		fuelpurchased.fp_date, 
		   	fuelpurchased.fp_fueltype, 	--25

		   	fuelpurchased.fp_amount, 
   			fuelpurchased.fp_cost_per,
	   		ISNULL(fuelpurchased.fp_invoice_no, ''), 
   			fuelpurchased.fp_vendorname, 
		   	fuelpurchased.fp_uom,		--30

		   	fuelpurchased.fp_quantity,
 			fuelpurchased.fp_purchcode,
	 		ord_type = 0,
	 		0, 
			0, 				--35

			0,
			0,
			tractorprofile.trc_type1,
			tractorprofile.trc_type2,
			tractorprofile.trc_type3,	 --40

			tractorprofile.trc_type4,
			0,
			mpp_id,		-- lgh_driver1,
			0,		-- latitude,
			0,		-- longitude,	 45

			CONVERT(char(3),''),	-- stp_loadstatus
			CONVERT(varchar(6),''), -- gpstype,
			0,
			0,			-- 49
			0,			-- stp_mfh_sequence
			CONVERT(varchar(6),'')  -- stp_event
		FROM fuelpurchased, city, legheader, tractorprofile
		WHERE (fuelpurchased.fp_date >= @BegDate AND fuelpurchased.fp_date < DATEADD(dd,1,@EndDate))
		  AND fp_city *= city.cty_code
		  AND legheader.lgh_number = fuelpurchased.lgh_number
		  AND legheader.lgh_outstatus = 'CMP'
		  AND tractorprofile.trc_number =* fuelpurchased.trc_number
	ELSE  --Either PD or NPD transfer, not ALL
		INSERT INTO #t (lgh_number,
			lgh_firstlegnumber, 
			lgh_lastlegnumber,
		  	lgh_startdate, 
			lgh_enddate, 		--5

			mov_number,
			lgh_startcity, 
			lgh_endcity, 
			lgh_outstatus, 
			lgh_class1,		--10
	
			lgh_class2, 
			lgh_class3, 
			lgh_class4, 
			lgh_instatus,
			lgh_tractor, 		--15

			lgh_fueltaxstatus, 
			stp_arrivaldate, 
			stp_type, 
			cty_name, 
			cty_state, 		--20

			cty_zip, 
		 	fp_id,
			ord_number, 
			fp_date, 
			fp_fueltype,		--25

			fp_amount, 
			fp_cost_per, 
			fp_invoice_no, 
			fp_vendorname, 
			fp_uom,			--30

			fp_quantity,
			fp_purchcode, 
			ord_type,
			lgh_ord_hdrnumber,
			fix_sort_ind,		--35

			stp_number_start,
			stp_number,
			trc_type1,
			trc_type2,
			trc_type3,		--40

			trc_type4,
			stp_city,
			lgh_driver1,
			latitude,
			longitude,		--45

			stp_loadstatus,
			gpstype,
			lgh_odometerstart,
			lgh_odometerend,
			stp_mfh_sequence, 	-- 50  	
			stp_event)		

		SELECT  fuelpurchased.lgh_number, 
			0,
			0,
		 	'', 
			'', 				--5

			fuelpurchased.mov_number,
			0, 
			0, 
			'', 
			'',				--10

		  	'',
			'',
			'',
			'',
		   	fuelpurchased.trc_number,  	--15	

		   	'',
   			fuelpurchased.fp_date,
	   		'',
			ISNULL (city.cty_name, ""),	
			ISNULL (city.cty_state, ""), 	--20  

		   	ISNULL(city.cty_zip,''),  
   			fuelpurchased.fp_id, 
	   		fuelpurchased.ord_number, 
	   		fuelpurchased.fp_date, 
		   	fuelpurchased.fp_fueltype, 	--25

		   	fuelpurchased.fp_amount, 
   			fuelpurchased.fp_cost_per,
	   		ISNULL(fuelpurchased.fp_invoice_no, ''), 
   			fuelpurchased.fp_vendorname, 
		   	fuelpurchased.fp_uom,		--30

		   	fuelpurchased.fp_quantity,
 			fuelpurchased.fp_purchcode,
	 		ord_type = 0,
	 		0, 
			0, 				--35

			0,
			0,
			tractorprofile.trc_type1,
			tractorprofile.trc_type2,
			tractorprofile.trc_type3,	 --40

			tractorprofile.trc_type4,
			0,
			mpp_id,		-- lgh_driver1,
			0,		-- latitude,
			0,		-- longitude,	 45

			CONVERT(char(3),''),	-- stp_loadstatus
			CONVERT(varchar(6),''), -- gpstype,
			0,
			0,			-- 49
			0,			-- stp_mfh_sequence
			CONVERT(varchar(6),'')  -- stp_event
		FROM fuelpurchased, city, legheader, tractorprofile
		WHERE (fuelpurchased.fp_date >= @BegDate AND fuelpurchased.fp_date < DATEADD(dd,1,@EndDate))
		  AND fp_city *= city.cty_code
		  AND legheader.lgh_number = fuelpurchased.lgh_number
		  AND legheader.lgh_fueltaxstatus = @FuelTaxStatus
		  AND legheader.lgh_outstatus = 'CMP'
		  AND tractorprofile.trc_number =* fuelpurchased.trc_number
END  -- Add in fuel purchases

/* Now return the data from the temp table */
SELECT  lgh_number,
	lgh_firstlegnumber, 
	lgh_lastlegnumber,
  	lgh_startdate, 
	lgh_enddate, 	-- 5

	mov_number,
	lgh_startcity, 
	lgh_endcity, 
	lgh_outstatus, 
	lgh_class1,	-- 10 

	lgh_class2, 
	lgh_class3, 
	lgh_class4, 
	lgh_instatus,
	lgh_tractor, 	-- 15

	lgh_fueltaxstatus, 	
	stp_arrivaldate, 
	stp_type, 
	cty_name, 
	cty_state, 	-- 20

	cty_zip, 
 	fp_id,
	ord_number, 
	fp_date, 
	fp_fueltype,	-- 25

	fp_amount, 
	fp_cost_per, 
	fp_invoice_no, 
	fp_vendorname, 
	fp_uom,		-- 30

	fp_quantity,
	fp_purchcode, 
	ord_type,
	lgh_ord_hdrnumber,
	trc_type1,	-- 35

	trc_type2,
	trc_type3,
	trc_type4 ,
	lgh_driver1,
	latitude,	-- 40

	longitude,
	stp_loadstatus,
	gpstype,
	lgh_odometerstart,
	lgh_odometerend,	-- 45

	stp_mfh_sequence,	
	stp_event,
	stp_lgh_mileage,
	ord_revtype2
FROM #t
-- 3/10/00 MZ Changed the sort order
--ORDER BY lgh_number, fix_sort_ind, stp_arrivaldate, ord_type
ORDER BY lgh_number, stp_arrivaldate, ord_type
GO
GRANT EXECUTE ON  [dbo].[fueltax_export_sp2] TO [public]
GO
