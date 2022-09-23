SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.get_cur_activity_sp    Script Date: 8/20/97 1:58:58 PM ******/
CREATE PROCEDURE [dbo].[get_cur_activity_sp]	@type       	varchar (6), 
				  	@id 	    	varchar(13), 
					@mov_number 	int, 
					@lgh_number 	int,
				  	@lgh_out    	int 		OUT,
					@mov_out	int 		OUT,
					@ord_num	int 		OUT,
					@cmp_id		varchar(12) 	OUT,
					@city		int 		OUT,
					@status		varchar(6)	OUT, 	
      					@start_date 	datetime	OUT,
      					@end_date 	datetime	OUT,
					@primary_trailer varchar(13)	OUT,
					@primary_pup	varchar(13)	OUT,
					@event		char(6)		OUT,
					@state		varchar(6)	OUT,
					@city_name	varchar(18)	OUT
AS
/*
40260 4/19/08 Recode Pauls 11/30/06 - PTS35279 - jguo - remove index hints.

*/

Declare @maxdt datetime,  @checkon char(3), @end_date_notnull datetime
Declare @trlfirstassn int, @trllastassn int
/*
EXECUTE timerins 'get_cur_activity_sp', 'START'

*/
-- PTS 23928 -- BL (start)
if @id = 'UNKNOWN' Return
-- PTS 23928 -- BL (end)

If @mov_number IS NOT Null or @lgh_number IS NOT Null
   BEGIN
	If @type = 'TRL'
	 begin	
		/*move number*/
		-- 12/3/97 PG removed un-necessary joins with stops
		SELECT 	@maxdt = max(assetassignment.asgn_enddate)
		FROM 	assetassignment,-- with(index=ck_who_status), 
                legheader  
		WHERE 	(assetassignment.lgh_number = legheader.lgh_number) and  
		        (assetassignment.asgn_type = @type) AND  
		        (assetassignment.asgn_id = @id) AND  
			(assetassignment.asgn_status IN ('STD', 'CMP')) AND
			(legheader.mov_number <> @mov_number)
			AND NOT EXISTS (SELECT NULL FROM stops stopsinner WHERE stopsinner.lgh_number = assetassignment.lgh_number AND ISNULL(stopsinner.stp_ico_stp_number_child,0) <> 0) -- PTS 57889 DWG
	 end
	Else
	 If @type = 'TRC' Or @type = 'DRV'
	  begin
		/* LGH number*/
		-- 12/3/97 PG removed un-necessary joins with stops & legheader
		SELECT 	@maxdt = max(assetassignment.asgn_enddate)
		FROM 	assetassignment --with(index=ck_who_status)
		WHERE 	(assetassignment.asgn_type = @type) AND  
		        (assetassignment.asgn_id = @id) AND  
			(assetassignment.asgn_status IN ('STD', 'CMP')) AND
			(assetassignment.lgh_number <> @lgh_number)
			AND NOT EXISTS (SELECT NULL FROM stops stopsinner WHERE stopsinner.lgh_number = assetassignment.lgh_number AND ISNULL(stopsinner.stp_ico_stp_number_child,0) <> 0) -- PTS 57889 DWG
	  end
   END
else
 begin
	-- 12/3/97 PG removed un-necessary joins with stops & legheader
	SELECT 	@maxdt = max(assetassignment.asgn_enddate)
	FROM 	assetassignment  --with(index=ck_who_status)
	WHERE 	(assetassignment.asgn_type = @type) AND  
        	(assetassignment.asgn_id = @id) AND  
		(assetassignment.asgn_status IN ('STD', 'CMP')) AND
		(assetassignment.asgn_enddate <= '20491231 23:59')
		AND NOT EXISTS (SELECT NULL FROM stops stopsinner WHERE stopsinner.lgh_number = assetassignment.lgh_number AND ISNULL(stopsinner.stp_ico_stp_number_child,0) <> 0) -- PTS 57889 DWG
 end

SET ROWCOUNT 1
SELECT 	@mov_out = legheader.mov_number,   
	@ord_num = legheader.ord_hdrnumber ,
	@lgh_out = legheader.lgh_number, 
	@cmp_id = legheader.cmp_id_end, 
	@city = legheader.lgh_endcity,
	@status = assetassignment.asgn_status, 
      	@start_date = assetassignment.asgn_date,
      	@end_date = assetassignment.asgn_enddate,
	@primary_trailer = legheader.lgh_primary_trailer,
	@primary_pup = legheader.lgh_primary_pup,
	@event = stops.stp_event, 
	@trlfirstassn = assetassignment.asgn_trl_first_asgn,
	@trllastassn = assetassignment.asgn_trl_last_asgn
FROM 	assetassignment --with(index=ck_who_status)
   , stops, legheader  
WHERE 	(assetassignment.lgh_number = legheader.lgh_number) and  
        (legheader.stp_number_end = stops.stp_number) and  
        (assetassignment.asgn_type = @type) AND  
        (assetassignment.asgn_id = @id) AND  
	(assetassignment.asgn_status IN ('STD', 'CMP')) AND
	(assetassignment.asgn_enddate = @maxdt)
	AND NOT EXISTS (SELECT NULL FROM stops stopsinner WHERE stopsinner.lgh_number = assetassignment.lgh_number AND ISNULL(stopsinner.stp_ico_stp_number_child,0) <> 0) -- PTS 57889 DWG

If @type = 'TRL'
BEGIN
	if isnull(@trllastassn, 0) > 0
		SELECT 	@cmp_id = cmp_id, 
			@city = stp_city, 
			@event = event.evt_eventcode,
			@end_date = event.evt_enddate,
			@end_date_notnull = event.evt_startdate
		FROM 	stops, event, assetassignment -- (index=ck_who_status) vjh recoding Mook's change 20856
		WHERE 	assetassignment.asgn_number = @trllastassn AND
			stops.lgh_number = assetassignment.lgh_number AND
			stops.stp_number = event.stp_number AND
			(event.evt_trailer1 = @id OR event.evt_trailer2 = @id)
		ORDER BY stops.stp_arrivaldate desc
	else
		SELECT 	@cmp_id = cmp_id, 
			@city = stp_city, 
			@event = event.evt_eventcode,
			@end_date = event.evt_enddate,
			@end_date_notnull = event.evt_startdate
		FROM 	stops, event
		WHERE 	lgh_number = @lgh_out AND
			stops.stp_number = event.stp_number AND
			(event.evt_trailer1 = @id OR event.evt_trailer2 = @id) 
		ORDER BY stops.stp_arrivaldate desc

	IF @end_date IS NULL
		SELECT @end_date = @end_date_notnull

	if isnull(@trlfirstassn, 0) > 0
		SELECT 	@start_date = event.evt_startdate
		FROM 	stops, event, assetassignment -- (index=ck_who_status) vjh recoding Mook's change 20856
		WHERE 	assetassignment.asgn_number = @trlfirstassn AND
			stops.lgh_number = assetassignment.lgh_number AND
			stops.stp_number = event.stp_number AND
			(event.evt_trailer1 = @id OR event.evt_trailer2 = @id)
		ORDER BY stops.stp_arrivaldate
	else
		SELECT 	@start_date = event.evt_startdate
		FROM 	stops, event
		WHERE 	lgh_number = @lgh_out AND
			stops.stp_number = event.stp_number AND
			(event.evt_trailer1 = @id OR event.evt_trailer2 = @id) 
		ORDER BY stops.stp_arrivaldate
END

/*	LOR	01/16/98	4.0.  Assets Beaming	*/
SELECT	@state = cty_state,
	@city_name = cty_name
FROM	city
WHERE	cty_code = @city
/*	LOR	01/16/98				*/

SET ROWCOUNT 0

If @mov_out IS Null
	SELECT @mov_out = 0
Else
	If @status = 'STD'
		SELECT @status = 'OPN'
	Else
		SELECT @status = 'DNE'
/*
EXECUTE timerins 'get_cur_activity_sp', 'END'
*/


GO
GRANT EXECUTE ON  [dbo].[get_cur_activity_sp] TO [public]
GO
