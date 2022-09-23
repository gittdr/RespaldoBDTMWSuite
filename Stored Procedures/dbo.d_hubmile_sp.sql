SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* create stored procedure */
CREATE PROC [dbo].[d_hubmile_sp](@strt_dt datetime,@end_dt datetime, @trctr_id varchar(10), @drvr_id varchar(10))
AS
/* Begin of stored procedure d_hubmile_sp */
BEGIN
/***************************************************************************/
/*Declaration and initialization of variables*/
DECLARE @char18  VarChar(8),	
	@char10  VarChar(13),	
	@char15  int,
        @char16  VarChar(30),
        @vchar18 VarChar(18),
	@vchar12 Varchar(12),
        @char2   char(2),
	@maxnum  int,
	@minord  int,
	@ord_stp int,
	@oor     int,
        @origin_city int, 
	@org_cty int,
        @destin_city int,
	@dest_cty int,
        @origin_stpnum int, 
        @destin_stpnum int,
        @origin_hubmiles int,
        @destin_hubmiles int,
	@oor_per float,
        @char12 money,
        @char8 varchar(30),
	@legs_count int,
	@ord_legnum int,
	@nxt_legnum int,
	@ord_movnum int,
        @start_miles int,
 	@end_miles int,
	@ttl_mil int,
	@lgstrt_cmp Varchar(12),
	@lgend_cmp Varchar(12),
	@ord_date datetime,
	@min_dt	datetime,
	@prev_assgn_dt datetime
	
        
	
/* select  @v_date1 = @v_date */
	IF @trctr_id is NULL
	BEGIN
		SELECT @trctr_id = 'UNKNOWN'		
	END
	IF @drvr_id is NULL
	BEGIN
		SELECT @drvr_id = 'UNKNOWN'
	END
 SELECT	@strt_dt  = convert(char(12),@strt_dt) +'00:00:00'
 SELECT	@min_dt = convert(char(12), @strt_dt) + '00:00:00'		
 select  @end_dt   = convert(char(12),@end_dt)+'23:59:59'
/*******************************************************************/
/*Create temporary table for Hubmile Report                        */
/*******************************************************************/
	  	 SELECT	@oor				order_id,
			@oor				ord_legid,
			event.stp_number		evt_stpnum,	
			event.evt_tractor		tractor_id,
			event.evt_trailer1		trailer_id,
		       	event.evt_driver1		driver1_id,      
			event.evt_driver2		driver2_id,
			event.evt_startdate		shpdt,
		        @ord_date			deldt,
			@vchar12			strt_loc,	
			@vchar12			end_loc,
			@vchar18			orig_loc,
			@vchar18			dest_loc,
			@char2				orig_st,
			@char2				dest_st,
			@oor				begin_hub,	
			event.evt_hubmiles		end_hub,
			@oor				hub_miles,
			@oor				ttlmil,
			@oor				oormiles,
			@oor_per			oorpercentage
		INTO	#temp_tbl
		FROM	event
		WHERE	evt_startdate = '01/01/87'
/* if all parameters are provided */
	IF 	(@drvr_id is NOT null) AND (@drvr_id != 'UNKNOWN')
	AND	(@trctr_id is NOT null) AND (@trctr_id != 'UNKNOWN')
	AND	(@strt_dt <= @end_dt)
	BEGIN
		INSERT INTO #temp_tbl
	  	 SELECT	@oor				order_id,
			@oor				ord_legid,
			event.stp_number		evt_stpnum,	
			event.evt_tractor		tractor_id,
			event.evt_trailer1		trailer_id,
		       	event.evt_driver1		driver1_id,      
			event.evt_driver2		driver2_id,
			event.evt_startdate		shpdt,
		        @ord_date			deldt,
			@vchar12			strt_loc,	
			@vchar12			end_loc,
			@vchar18			orig_loc,
			@vchar18			dest_loc,
			@char2				orig_st,
			@char2				dest_st,
			@oor				begin_hub,	
			event.evt_hubmiles		end_hub,
			@oor				hub_miles,
			@oor				ttlmil,
			@oor				oormiles,
			@oor_per			oorpercentage
		FROM	event
		WHERE	(event.evt_startdate BETWEEN @strt_dt and @end_dt) 
		AND	event.evt_tractor = @trctr_id 
		AND 	event.evt_driver1 = @drvr_id 
		AND	event.evt_hubmiles is not null 
		ORDER BY event.evt_startdate, event.stp_number
	END
/* if tractor is not provided */
	ELSE IF ((@trctr_id is NULL) OR (@trctr_id = 'UNKNOWN')) 
	AND ((@drvr_id is NOT NULL) AND (@drvr_id != 'UNKNOWN')) 
	BEGIN
		INSERT INTO #temp_tbl	
		 SELECT	@oor				order_id,
			@oor				ord_legid,
			event.stp_number		evt_stpnum,	
			event.evt_tractor		tractor_id,
			event.evt_trailer1		trailer_id,
		       	event.evt_driver1		driver1_id,      
			event.evt_driver2		driver2_id,
			event.evt_startdate		shpdt,

		        @ord_date			deldt,
			@vchar12			strt_loc,	
			@vchar12			end_loc,
			@vchar18			orig_loc,
			@vchar18			dest_loc,
			@char2				orig_st,
			@char2				dest_st,
			@oor				begin_hub,	
			event.evt_hubmiles		end_hub,
			@oor				hub_miles,
			@oor				ttlmil,
			@oor				oormiles,
			@oor_per			oorpercentage
		FROM	event
		WHERE	(event.evt_startdate BETWEEN @strt_dt and @end_dt) 
		AND 	event.evt_driver1 = @drvr_id 
		AND	event.evt_hubmiles is not null 
		ORDER BY event.evt_startdate, event.stp_number
	END 
ELSE  IF ((@drvr_id is NULL) OR (@drvr_id = 'UNKNOWN')) 
	AND ((@trctr_id is NOT NULL) AND (@trctr_id != 'UNKNOWN'))
	BEGIN
		INSERT INTO #temp_tbl	
		 SELECT	@oor				order_id,
			@oor				ord_legid,
			event.stp_number		evt_stpnum,	
			event.evt_tractor		tractor_id,
			event.evt_trailer1		trailer_id,
		       	event.evt_driver1		driver1_id,      
			event.evt_driver2		driver2_id,

			event.evt_startdate		shpdt,
		        @ord_date			deldt,
			@vchar12			strt_loc,	
			@vchar12			end_loc,
			@vchar18			orig_loc,
			@vchar18			dest_loc,
			@char2				orig_st,
			@char2				dest_st,
			@oor				begin_hub,	
			event.evt_hubmiles		end_hub,
			@oor				hub_miles,
			@oor				ttlmil,
			@oor				oormiles,
			@oor_per			oorpercentage
		FROM	event
		WHERE	(event.evt_startdate BETWEEN @strt_dt and @end_dt) 
		AND	event.evt_tractor = @trctr_id 
		AND	event.evt_hubmiles is not null 
		ORDER BY event.evt_startdate, event.stp_number
	END 
	ELSE /* IF ((@trctr_id is NULL) OR (@trctr_id = 'UNKNOWN')) */
	BEGIN
		INSERT INTO #temp_tbl	
		 SELECT	@oor				order_id,
			@oor				ord_legid,
			event.stp_number		evt_stpnum,	
			event.evt_tractor		tractor_id,
			event.evt_trailer1		trailer_id,
		       	event.evt_driver1		driver1_id,      
			event.evt_driver2		driver2_id,
			event.evt_startdate		shpdt,
		        @ord_date			deldt,
			@vchar12			strt_loc,	
			@vchar12			end_loc,
			@vchar18			orig_loc,
			@vchar18			dest_loc,
			@char2				orig_st,
			@char2				dest_st,
			@oor				begin_hub,	
			event.evt_hubmiles		end_hub,
			@oor				hub_miles,
			@oor				ttlmil,
			@oor				oormiles,
			@oor_per			oorpercentage
		FROM	event
		WHERE	(event.evt_startdate BETWEEN @strt_dt and @end_dt) 
		AND	event.evt_hubmiles is not null 
		ORDER BY event.evt_startdate, event.stp_number
	END 
		
	
		
  	
/****************************************************************/
 WHILE (SELECT	COUNT(evt_stpnum) 
	FROM	#temp_tbl
	WHERE	(shpdt > @min_dt)) > 0  
/* Begin traverse each row in temp_tbl table */
 BEGIN 
	SELECT	@min_dt = min(shpdt)
	FROM	#temp_tbl
	WHERE	shpdt > @min_dt 
	SELECT	@ord_stp = evt_stpnum
	FROM	#temp_tbl
	WHERE 	shpdt = @min_dt
/*	SELECT	@vchar12 = convert(Varchar(12), @ord_stp)  + 'step1'  */
/*     	PRINT	@vchar12 */
	
	SELECT  @ord_legnum = lgh_number
	FROM	stops
	WHERE 	stp_number = @ord_stp 
	UPDATE	#temp_tbl
	SET	ord_legid	= @ord_legnum
	WHERE	#temp_tbl.evt_stpnum = @ord_stp
/*	SELECT	@vchar12 = convert(Varchar(12), @ord_legnum)  + 'step2'  */
/*     	PRINT	@vchar12 */
	SELECT 	@minord = ord_hdrnumber
	FROM 	legheader
	WHERE 	lgh_number = @ord_legnum

	UPDATE	#temp_tbl
	SET	order_id	= @minord
	WHERE	#temp_tbl.evt_stpnum = @ord_stp
/*	SELECT	@vchar12 = convert(Varchar(12), @minord)  + 'step3'  */
/*    	PRINT	@vchar12	*/
/* Reset the tractor and driver IDS */
	SELECT	@trctr_id = evt_tractor, @drvr_id = evt_driver1
	FROM	event
	WHERE	stp_number = @ord_stp
/***************************/
/* to find start hub miles */
/***************************/
/*** initialises the prev_assgn_dt to the lowest on events ***/
	SELECT  @prev_assgn_dt = min(evt_startdate)
	FROM 	event
/*** sets the previous assignment date for the previous assignment */
/*** date for that particular tractor. NEED TO INVESTIGATE WHAT    */
/*** HAPPENS WHEN A PREVIOUS ASSIGNMENT FOR THE TRACTOR IS NOT     */
/*** FOUND.prev_assgn_dt = max(evt_startdate) picks up the latest  */  
/*** of the last assignement.                                      */
	SELECT	@prev_assgn_dt = max(evt_startdate)
	FROM	event
	WHERE   evt_tractor = @trctr_id
	AND	evt_startdate < @min_dt
/*	AND 	evt_status = 'DNE' */
	AND	evt_hubmiles is not null
/*** attempts to pick up the hubmiles of then last assignment. */
	SELECT 	@start_miles = evt_hubmiles
	FROM	event
	WHERE	evt_startdate = @prev_assgn_dt
	AND	evt_startdate < @min_dt
	AND	evt_tractor = @trctr_id
	AND	evt_hubmiles is not null
	UPDATE	#temp_tbl
	SET	begin_hub	= @start_miles
	WHERE	#temp_tbl.evt_stpnum = @ord_stp
/*	SELECT	@vchar12 = convert(Varchar(12), @start_miles)  + 'step4' */
/*	PRINT	@vchar12  */
/**************************************************/
/* Find the total miles according to the PC Miler */
/**************************************************/
SELECT @ttl_mil = 0
/* Find the total miles in the leg */
	SELECT	@ttl_mil = sum(stp_lgh_mileage)
	FROM	stops
	WHERE	stops.lgh_number = @ord_legnum
	UPDATE	#temp_tbl
	SET	ttlmil = @ttl_mil
	FROM	#temp_tbl
	WHERE	#temp_tbl.ord_legid = @ord_legnum
	AND	#temp_tbl.order_id = @minord
/*******************************************************************/
/* Load the #temp_tbl with origin and dest city, state and company     */
/*******************************************************************/
	SELECT	@lgstrt_cmp = cmp_id_start, @lgend_cmp = cmp_id_end
	FROM	legheader
	WHERE	lgh_number = @ord_legnum
	AND 	ord_hdrnumber = @minord
	
	
	SELECT	@org_cty = lgh_startcity, @dest_cty = lgh_endcity
	FROM 	legheader
	WHERE	lgh_number = @ord_legnum
	AND	ord_hdrnumber = @minord
/*Find the origin city details */
	UPDATE	#temp_tbl
	SET 	#temp_tbl.orig_loc = city.cty_name,
		#temp_tbl.orig_st = city.cty_state,
		#temp_tbl.strt_loc = @lgstrt_cmp,
		#temp_tbl.end_loc = @lgend_cmp
	FROM	city, #temp_tbl
	WHERE	city.cty_code = @org_cty
	AND	#temp_tbl.order_id = @minord
	AND	#temp_tbl.ord_legid = @ord_legnum 
/*Find the destination city details */
	UPDATE	#temp_tbl
	SET	#temp_tbl.dest_loc = city.cty_name,
		#temp_tbl.dest_st = city.cty_state
	FROM 	city, #temp_tbl
	WHERE	city.cty_code = @dest_cty
	AND	#temp_tbl.order_id = @minord
	AND	#temp_tbl.ord_legid = @ord_legnum
/* Load #temp_tbl with end date of trip segment */
	UPDATE	#temp_tbl
	SET 	#temp_tbl.deldt = legheader.lgh_enddate
	FROM 	legheader, #temp_tbl
	WHERE	legheader.ord_hdrnumber = #temp_tbl.order_id
	AND	legheader.lgh_number = #temp_tbl.ord_legid		
/*Load #temp_tbl with calculations  */
		
	IF (@ttl_mil > 0)
	BEGIN
		UPDATE	#temp_tbl
		SET	hub_miles = (end_hub - begin_hub),	
			oormiles = ((end_hub -begin_hub) - ttlmil),
			oorpercentage = ((((end_hub - begin_hub) - ttlmil) * 100) / ttlmil)
		FROM 	#temp_tbl
		WHERE	end_hub is not null
		AND 	begin_hub is not null
		AND 	#temp_tbl.order_id = @minord
		AND	#temp_tbl.ord_legid = @ord_legnum
	END
	IF (@ttl_mil = 0)
	BEGIN
		UPDATE	#temp_tbl
		SET	begin_hub = end_hub,
			hub_miles = 0,
			oormiles = 0,
			oorpercentage	= 0
		FROM	#temp_tbl
		WHERE	end_hub is not null
		AND 	begin_hub is not null
		AND	#temp_tbl.order_id = @minord
		AND	#temp_tbl.ord_legid = @ord_legnum
	END
			
	
/* End traverse each row in #temp_tbl table */
END
/* end of stored procedure d_hubmile_sp */
END
/* end of create procedure d_hubmile_sp */
/*END  */
	SELECT	order_id,  
		tractor_id, 
		trailer_id,
		driver1_id, 
		driver2_id, 
		shpdt, 
		deldt,
		strt_loc,
		end_loc,
		orig_loc,
		dest_loc,
		orig_st,
		dest_st,
		begin_hub,
		end_hub,
		hub_miles,
		ttlmil,
		oormiles,
		oorpercentage
		FROM #temp_tbl
/*** SELECT * ****/
/**FROM #temp_tbl ***/

GO
GRANT EXECUTE ON  [dbo].[d_hubmile_sp] TO [public]
GO
