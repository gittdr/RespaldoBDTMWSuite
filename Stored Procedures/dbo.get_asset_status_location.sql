SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
-	Asset status 
o	?AVL? = available, not planned, completed with last move, not currently on expriation or under QTOPS control
o	?USE? = currently active on a trip
o	?PLN? = currently not active on a trip, but is planned on one.  Note that the planned trip should be in the future, but may be dated in the past.
o	?CTRLQ? = under control of QTOPS
o	?OUT? = out of service, terminated
o	Other values as defined for expirations where the expiration is in effect.
-	Current destination location = company ID for destination of current/last move, or location of current/last expriation, whichever is later
-	Current destination city = city name for destination of current/last move, or location of current/last expriation, whichever is later
-	Current destination state = = state/province for destination of current/last move, or location of current/last expriation, whichever is later
-	Current destination date/time = date/time for completion of current/last move, or of current/last expiration, whichever is later
-	Planned destination location = company ID for destination of latest planned move, or location of next expriation, whichever is later
-	Planned destination city = city name for destination of latest planned move, or location of next expriation, whichever is later
-	Planned destination state = = state/province for destination of latest planned move, or location of next expriation, whichever is later
-	Planned destination date/time = date/time for completion of latest planned move, or of next expiration, whichever is later
-	Last known lattitude
-	Last known longitude
-	Last known nearest city/state as determined by GPS system
-	Last known position timestamp
*/


CREATE PROCEDURE [dbo].[get_asset_status_location] 
					@type       VARCHAR (6), 
				  	@id 	    VARCHAR(13),
					@asof		DATETIME,
					@lgh_out    INT			OUT,
					@mov_out	INT 		OUT,
					@ord_num	INT 		OUT,
					@status		VARCHAR(6)	OUT, 	
					@cmp_id		VARCHAR(12) OUT,
					@city_name	VARCHAR(18)	OUT,
					@state		VARCHAR(6)	OUT,
					@zip		VARCHAR(9)	OUT,
					@end_date 	DATETIME	OUT,
					@planned_dest_id VARCHAR(8) OUT,
					@planned_dest_city VARCHAR(18) OUT,
					@planned_dest_state CHAR(2) OUT,
					@planned_dest_zip VARCHAR(9) OUT,
					@planned_dest_datetime DATETIME OUT,
					@last_gps_lat INT OUT,
					@last_gps_long INT OUT,
					@last_gps_city VARCHAR(18) OUT,
					@last_gps_state CHAR(2) OUT,
					@last_gps_datetime DATETIME OUT,
					@cur_tractor VARCHAR(8) OUT

AS

DECLARE @ckc_number INT			,
		@maxdate	DATETIME	
		
CREATE TABLE #temp (
	asset_type VARCHAR(6)
	, asset_id VARCHAR(13)
	, asset_status VARCHAR(6)
	, cur_move INT
	, cur_ord INT
	, cur_lgh INT
	, cur_dest_id VARCHAR(8)
	, cur_dest_city VARCHAR(18)
	, cur_dest_state CHAR(2)
	, cur_dest_zip VARCHAR(9)
	, cur_dest_datetime DATETIME
	, planned_dest_id VARCHAR(8)
	, planned_dest_city VARCHAR(18)
	, planned_dest_state CHAR(2)
	, planned_dest_zip VARCHAR(9)
	, planned_dest_datetime DATETIME
	, last_gps_lat INT
	, last_gps_long INT
	, last_gps_city VARCHAR(18)
	, last_gps_state CHAR(2)
	, last_gps_datetime DATETIME
	, cur_tractor VARCHAR(8)
)

CREATE TABLE #next (
	mov_number INT
	, ord_hdrnumber INT
	, cmp_id VARCHAR(8)
	, cmp_name VARCHAR(100)
	, lgh_startdate DATETIME
	, lgh_number INT
	, ord_number VARCHAR(12)
--	, ord_fromorder INT
	, ord_fromorder VARCHAR(12)
	, origin_cty_nmstct VARCHAR(30)
	, dest_cty_nmstct VARCHAR(30)
	, schedule_id INT
	, lgh_startcity INT )

IF @type = 'DRV'
	SELECT @id = mpp_id
	FROM manpowerprofile
	WHERE mpp_otherid = @id

-- find started or completed move where asof is between start and end date/time
SELECT TOP(1) @lgh_out = aa.lgh_number
	, @mov_out = aa.mov_number 
	, @end_date = asgn_enddate
	, @state = cty_state
	, @city_name = cty_name
	, @cmp_id = cmp_id_end
	, @status = aa.asgn_status
FROM assetassignment aa
JOIN legheader lh ON lh.lgh_number = aa.lgh_number
JOIN city c ON c.cty_code = lgh_endcity
WHERE asgn_id = @id 
	AND asgn_type = @type
	AND @asof BETWEEN asgn_date AND asgn_enddate
	AND asgn_status in ('STD', 'CMP')
ORDER BY asgn_date DESC

-- if not found, find latest started or completed that started before asof
IF @lgh_out IS NULL
	SELECT TOP(1) @lgh_out = aa.lgh_number
		, @mov_out = aa.mov_number 
		, @end_date = asgn_enddate
		, @state = cty_state
		, @city_name = cty_name
		, @cmp_id = cmp_id_end
		, @status = aa.asgn_status
	FROM assetassignment aa
	JOIN legheader lh ON lh.lgh_number = aa.lgh_number
	JOIN city c ON c.cty_code = lgh_endcity
	WHERE asgn_id = @id 
		AND asgn_type = @type
		AND @asof > asgn_date 
		AND asgn_status in ('STD', 'CMP')
	ORDER BY asgn_date DESC

IF @status = 'CMP' OR @lgh_out IS NULL
BEGIN
	IF EXISTS (SELECT * FROM assetassignment WHERE asgn_type = @type AND asgn_id = @id AND asgn_status IN ('PLN', 'DSP'))
	SELECT TOP(1) @lgh_out = aa.lgh_number
		, @mov_out = aa.mov_number 
		, @end_date = asgn_enddate
		, @state = cty_state
		, @city_name = cty_name
		, @cmp_id = cmp_id_end
		, @status = aa.asgn_status
	FROM assetassignment aa
	JOIN legheader lh ON lh.lgh_number = aa.lgh_number
	JOIN city c ON c.cty_code = lgh_endcity
	WHERE asgn_id = @id 
		AND asgn_type = @type
		AND asgn_status in ('PLN', 'DSP')
	ORDER BY asgn_date 
END

INSERT INTO #next EXECUTE dbo.d_next_asgn_sp @asgn_id = @id, @asgn_type = @type 

SELECT TOP (1) * INTO #next2 FROM #next ORDER BY lgh_startdate desc

IF EXISTS (SELECT * FROM #next2)
	INSERT INTO #temp
	SELECT
		  @type -- asset_type
		, @id -- asset_id 
		, @status -- asset_status 
		, @mov_out -- cur_move 
		, @ord_num -- cur_ord 
		, @lgh_out -- cur_lgh 
		, @cmp_id -- cur_dest_id 
		, @city_name -- cur_dest_city 
		, @state -- cur_dest_state 
		, c1.cmp_zip -- cur_dest_zip 
		, @end_date -- cur_dest_datetime 
		, lgh.cmp_id_end -- planned_dest_id 
		, city.cty_name -- planned_dest_city 
		, city.cty_state -- planned_dest_state 
		, c2.cmp_zip -- planned_dest_zip 
		, lgh.lgh_enddate -- planned_dest_datetime 
		, '' -- last_gps_lat 
		, '' -- last_gps_long 
		, '' -- last_gps_city 
		, '' -- last_gps_state 
		, GETDATE() -- last_gps_datetime 
		, '' -- cur_tractor 
	FROM #next2
	JOIN legheader lgh ON #next2.lgh_number = lgh.lgh_number
	LEFT OUTER JOIN company c1 ON c1.cmp_id = @cmp_id
	JOIN company c2 ON c2.cmp_id = lgh.cmp_id_end
	JOIN city ON city.cty_code = lgh.lgh_endcity

ELSE
	INSERT INTO #temp
	SELECT
		  @type -- asset_type
		, @id -- asset_id
		, @status -- asset_status 
		, @mov_out -- cur_move 
		, @ord_num -- cur_ord 
		, @lgh_out -- cur_lgh 
		, @cmp_id -- cur_dest_id 
		, @city_name -- cur_dest_city 
		, @state -- cur_dest_state 
		, c1.cmp_zip -- cur_dest_zip 
		, @end_date -- cur_dest_datetime 
		, 'UNKNOWN' -- planned_dest_id 
		, '' -- planned_dest_city 
		, '' -- planned_dest_state 
		, '' -- planned_dest_zip 
		, '' -- planned_dest_datetime 
		, '' -- last_gps_lat 
		, '' -- last_gps_long
		, '' -- last_gps_city
		, '' -- last_gps_state 
		, GETDATE() -- last_gps_datetime 
		, '' -- cur_tractor 
	FROM company c1 
	WHERE c1.cmp_id = @cmp_id

UPDATE #temp
SET cur_ord = (SELECT MIN(ord_hdrnumber)
				FROM stops
				WHERE stops.ord_hdrnumber > 0
				AND stops.lgh_number = #temp.cur_lgh)

IF @type = 'DRV'
BEGIN
	UPDATE #temp
	SET asset_status = mpp_status
	FROM manpowerprofile
	WHERE mpp_id = @id AND @status <> 'DSP'

	select @cur_tractor = MAX(ds_trc_id) from driverseating where (ds_driver1 = @id OR ds_driver2 = @id) and GETDATE() between ds_seated_dt and ds_unseated_dt
	
	IF ISNULL (@cur_tractor, '') = ''
		UPDATE #temp
		SET cur_tractor = lgh_tractor
		FROM legheader lgh
		WHERE lgh.lgh_number = cur_lgh	
	ELSE
		UPDATE #temp
		SET cur_tractor = @cur_tractor
END
IF @type = 'TRC'
BEGIN
	UPDATE #temp
	SET asset_status = trc_status
	FROM tractorprofile
	WHERE trc_number = @id AND @status <> 'DSP' 
END
IF @type = 'TRL'
BEGIN
	UPDATE #temp
	SET asset_status = trl_status
	FROM trailerprofile
	WHERE trl_id = @id AND @status <> 'DSP' 
END

SELECT @maxdate = MAX(ckc_date)
FROM checkcall cc
JOIN assetassignment aa ON aa.lgh_number = cc.ckc_lghnumber
AND aa.asgn_type = @type 
AND aa.asgn_id = @id

SELECT @ckc_number = ckc_number
FROM checkcall cc
JOIN assetassignment aa ON aa.lgh_number = cc.ckc_lghnumber
AND aa.asgn_type = @type 
AND aa.asgn_id = @id
AND ckc_date = @maxdate

UPDATE #temp
SET last_gps_lat = cc.ckc_latseconds
	, last_gps_long = cc.ckc_longseconds
	, last_gps_city = cty_name
	, last_gps_state = cty_state
	, last_gps_datetime = ckc_date
FROM checkcall cc
JOIN city ON cty_code = ckc_city
WHERE cc.ckc_number = @ckc_number

SELECT 
	@lgh_out = cur_lgh,
	@mov_out = cur_move,
	@ord_num = cur_ord,
	@status	= asset_status,
	@cmp_id	= cur_dest_id,
	@city_name = cur_dest_city,
	@state = cur_dest_state,
	@zip = cur_dest_zip,
	@end_date = cur_dest_datetime,
	@planned_dest_id = planned_dest_id,
	@planned_dest_city = planned_dest_city,
	@planned_dest_state = planned_dest_state,
	@planned_dest_zip = planned_dest_zip,
	@planned_dest_datetime = planned_dest_datetime,
	@last_gps_lat = last_gps_lat,
	@last_gps_long = last_gps_long,
	@last_gps_city = last_gps_city,
	@last_gps_state = last_gps_state,
	@last_gps_datetime = last_gps_datetime,
	@cur_tractor = cur_tractor
FROM #temp

GO
GRANT EXECUTE ON  [dbo].[get_asset_status_location] TO [public]
GO
