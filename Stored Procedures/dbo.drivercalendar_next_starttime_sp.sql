SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[drivercalendar_next_starttime_sp]
AS
set ansi_warnings off
DECLARE	@drv					VARCHAR(8),
		@mpp_bid_next_starttime		DATETIME,
		@next_starttime			DATETIME,
		@next_hours			DECIMAL(4,2),
		@next_type			VARCHAR(6),
		@current_time			DATETIME,
		@current_date			DATETIME,
		@current_min_since_12AM		INTEGER,	
		@current_dow			INTEGER,
		@weekstart_dow			INTEGER,
		@weekstart_date			DATETIME,
		@compare_date			DATETIME,
		@compare_time			DATETIME,
		@compare_dow			DATETIME,
		@drc_week1_starttime		DATETIME,
		@drc_week2_starttime		DATETIME,
		@drc_week1_startdate		DATETIME,
		@drc_week2_startdate		DATETIME,
		@drc_week1_dow			INTEGER,
		@drc_week1_min_since_12AM	INTEGER,
		@drc_week2_min_since_12AM	INTEGER,
		@day_diff			INTEGER,
		@drc_sequence			INTEGER,
		@routestore			VARCHAR(8)
		
SET NOCOUNT ON

SELECT @drv = ''

SELECT @current_time = GETDATE()
SELECT @current_date = CONVERT(DATETIME, CONVERT(VARCHAR(8), @current_time, 112))
SELECT @current_dow = DATEPART(dw, @current_time)
SELECT @current_min_since_12AM = DATEDIFF(mi, @current_date, @current_time)


WHILE 1 = 1 
BEGIN
	
	SELECT	@drv = MIN(mpp_id)
	  FROM	manpowerprofile mpp
	 WHERE	mpp.mpp_id > @drv 
	 IF @drv is null 
		break	
	
	IF EXISTS(SELECT	*
					 FROM	drivercalendar
					WHERE	mpp_id = @drv)
	BEGIN
	
		SELECT	@mpp_bid_next_starttime = ISNULL(mpp_bid_next_starttime, '19000101')
		  FROM	manpowerprofile
		 WHERE	mpp_id = @drv
	
		SELECT	@weekstart_dow = drc_week1_dow,
				@weekstart_date = CONVERT(DATETIME, CONVERT(VARCHAR(8), drc_week1_starttime, 112))
		  FROM	drivercalendar
		 WHERE	mpp_id = @drv AND
				drc_sequence = 1
	
		IF @current_dow < @weekstart_dow
			SELECT	@compare_date = DATEADD(dd, ((@current_dow + 7) - @weekstart_dow), @weekstart_date)
		ELSE
			SELECT	@compare_date = DATEADD(dd, (@current_dow - @weekstart_dow), @weekstart_date)
	
		SELECT	@compare_time = DATEADD(mi, @current_min_since_12AM, @compare_date)
	
		SELECT	@drc_week1_starttime = MAX(drc_week1_starttime)
		  FROM	drivercalendar
		 WHERE	mpp_id = @drv AND
				drc_week1_starttime <= @compare_time AND
				DATEADD(mi, CONVERT(INTEGER, 60 * CASE drc_week1_type WHEN 'ONCALL' THEN 24.0 ELSE drc_week1_hours END), drc_week1_starttime) >= @compare_time AND
				--PTS 20965  changing this from a hardcoded abbreviation to a range of codes in the labelfile
				--drc_week1_type IN ('ONCALL', 'STRTIM')
				drc_week1_type IN (select abbr from labelfile where labeldefinition = 'drvcalendar' and code between 500 and 600)
	
		IF @drc_week1_starttime IS NULL				
		BEGIN
			SELECT	@drc_week1_starttime = MIN(drc_week1_starttime)
			  FROM	drivercalendar
			 WHERE	mpp_id = @drv AND
					drc_week1_starttime >= @compare_time AND
					--PTS 20965  changing this from a hardcoded abbreviation to a range of codes in the labelfile
					--drc_week1_type IN ('ONCALL', 'STRTIM')
					drc_week1_type IN (select abbr from labelfile where labeldefinition = 'drvcalendar' and code between 500 and 600)
		END
	
		IF @drc_week1_starttime IS NOT NULL
		BEGIN
			SELECT	@drc_sequence = MIN(drc_sequence)
			  FROM	drivercalendar
			 WHERE	mpp_id = @drv AND
					drc_week1_starttime = @drc_week1_starttime AND
					--PTS 20965  changing this from a hardcoded abbreviation to a range of codes in the labelfile
					--drc_week1_type IN ('ONCALL', 'STRTIM')
					drc_week1_type IN (select abbr from labelfile where labeldefinition = 'drvcalendar' and code between 500 and 600)
	
			SELECT 	@next_hours = drc_week1_hours,
				@next_type = drc_week1_type
			  FROM	drivercalendar
			 WHERE	drc_sequence = @drc_sequence AND
					mpp_id = @drv
			--PTS 20965  bring the route or store ID over as well
			SELECT   @routestore = 
			      CASE @next_type
			         WHEN 'ROUTE' THEN drc_week1_route
				 WHEN 'STORE' THEN drc_week1_store
			         ELSE NULL
			      END
			 FROM drivercalendar
			  WHERE	drc_sequence = @drc_sequence
			    and mpp_id = @drv
			 --end 20965
			
			SELECT	@drc_week1_startdate = CONVERT(DATETIME, CONVERT(VARCHAR(8), @drc_week1_starttime, 112)),
					@drc_week1_min_since_12AM = DATEDIFF(mi, @drc_week1_startdate, @drc_week1_starttime)
	
			SELECT	@day_diff = DATEDIFF(dd, @compare_date, @drc_week1_startdate)
	
			SELECT	@next_starttime = DATEADD(dd, @day_diff, @current_date)
			SELECT	@next_starttime = DATEADD(mi, @drc_week1_min_since_12AM, @next_starttime)
	
			IF @next_starttime <> @mpp_bid_next_starttime
			BEGIN
				UPDATE	manpowerprofile
				   SET	mpp_bid_next_starttime = @next_starttime,
					mpp_bid_next_hours = @next_hours,
					mpp_bid_next_type = @next_type,
					mpp_bid_next_routestore = @routestore
				 WHERE	mpp_id = @drv
			END
		END
		ElSE
		BEGIN
			SELECT	@drc_week2_starttime = MIN(DATEADD(dd, 7, drc_week2_starttime))
			  FROM	drivercalendar
			 WHERE	mpp_id = @drv AND
					--PTS 20965  changing this from a hardcoded abbreviation to a range of codes in the labelfile
					--drc_week2_type IN ('ONCALL', 'STRTIM')
					drc_week2_type IN (select abbr from labelfile where labeldefinition = 'drvcalendar' and code between 500 and 600)
	
			IF @drc_week2_starttime IS NULL
			BEGIN
				UPDATE	manpowerprofile
				   SET	mpp_bid_next_starttime = NULL,
					mpp_bid_next_hours = NULL,
					mpp_bid_next_type = NULL
					
				 WHERE	mpp_id = @drv
			END
			ELSE
			BEGIN
				SELECT	@drc_sequence = MIN(drc_sequence)
				  FROM	drivercalendar
				 WHERE	mpp_id = @drv AND
						DATEADD(dd, 7, drc_week2_starttime) = @drc_week2_starttime AND
						--PTS 20965  changing this from a hardcoded abbreviation to a range of codes in the labelfile
						--drc_week2_type IN ('ONCALL', 'STRTIM')
						drc_week2_type IN (select abbr from labelfile where labeldefinition = 'drvcalendar' and code between 500 and 600)
	
				SELECT 	@next_hours = drc_week2_hours,
						@next_type = drc_week2_type
				  FROM	drivercalendar
				 WHERE	drc_sequence = @drc_sequence AND
						mpp_id = @drv
	
				SELECT	@drc_week2_startdate = CONVERT(DATETIME, CONVERT(VARCHAR(8), @drc_week2_starttime, 112)),
						@drc_week2_min_since_12AM = DATEDIFF(mi, @drc_week2_startdate, @drc_week2_starttime)
		
				SELECT	@day_diff = DATEDIFF(dd, @compare_date, @drc_week2_startdate)
		
				SELECT	@next_starttime = DATEADD(dd, @day_diff, @current_date)
				SELECT	@next_starttime = DATEADD(mi, @drc_week2_min_since_12AM, @next_starttime)
		
				IF @next_starttime <> @mpp_bid_next_starttime
				BEGIN
					UPDATE	manpowerprofile
					   SET	mpp_bid_next_starttime = @next_starttime,
						mpp_bid_next_hours = @next_hours,
						mpp_bid_next_type = @next_type,
						mpp_bid_next_routestore = @routestore
					 WHERE	mpp_id = @drv
				END
			END
		END
	END
END

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[drivercalendar_next_starttime_sp] TO [public]
GO
