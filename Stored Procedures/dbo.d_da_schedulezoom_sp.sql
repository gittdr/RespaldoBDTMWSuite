SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_schedulezoom_sp] ( 
	@TimeType VARCHAR(6) , 
	@ZeroZoomTimeDistance INT 
) 
AS

DECLARE @labelfiles TABLE ( 
	secs_per_pixel_code      INT          NULL , 
	secs_per_pixel_name      VARCHAR(255) NULL , 
	zoom_unit_labeldef       VARCHAR(60)  NULL , 
	zoom_unit                VARCHAR(6)   NULL , 
	secs_per_zoom_unit       INT          NULL , 
	zoom_unit_name           VARCHAR(255) NULL , 
	secs_per_timetype_unit   INT          NULL , 
	time_per_pixel           INT          NULL , 
	zero_zoom_timedistance   INT          NULL , 
	pixels_per_timetype_unit INT          NULL , 
	percent_zoom             DECIMAL(9,4) NULL  
) 

-- Get all applicable Schedule Zoom Times labelfiles
--  * This labelfile consists of all the zoom factors available to users.
--  * The schedule zooms by setting the number of pixels for a unit time.  The unit time is a 
--    property of the schedule (called TimeType) and may be either HOUR, DAY, or WEEK (the 
--    schedule also supports MONTH and YEAR, but this proc does not).
--  * By default, the system has one labelfile for every integer factor up to a week.  E.g., 1 hour 
--    can be factored evenly into 60, 30, 20, 15, 12, 10, 6, 5, 4, 3, 2, 1 minutes (+ same factors 
--    for seconds).  If the schedule's TimeType unit is set HOUR, the zoom factor needs to be set so 
--    that 1 pixel equals one of these factor values.  Otherwize, not only would the time per pixel 
--    have to be unevenly distributed across the hour unit time, but the snap to grid feature would 
--    not work properly.
--  * All labelfile zoom factors are expressed in seconds, or more precisely second per pixel.
--  * This proc excludes labelfiles for zoom factors that are too large enough: those that result in 
--    the TimeType unit being less than one pixel (e.g., 1 pixel = 2 hours).  The schedule control 
--    does not allow these.  The larger zoom factors are for larger TimeType settings.
INSERT @labelfiles ( 
       secs_per_pixel_code, secs_per_pixel_name, zoom_unit_labeldef, zoom_unit, 
       secs_per_zoom_unit, zoom_unit_name, secs_per_timetype_unit 
       ) 
SELECT l.code         secs_per_pixel_code    , -- SecondsPerPixel zoom setting
       l.name         secs_per_pixel_name    , -- Description of SecondsPerPixel in largest unit (not used)
       l.param1_label zoom_unit_labeldef     , -- Labledefinition for converting SecondsPerPixel to zoom units (should be TimePerPixelUnits) 
       u.abbr         zoom_unit              , -- Units for SecondsPerPixel converted to zoom units (e.g., MINUTE)
       u.code         secs_per_zoom_unit     , -- SecondsPerPixel conversion to zoom units, the largest unit that can be expressed in whole numbers (e.g., 3600 -> 1)
       u.name         zoom_unit_name         , -- Unit name label for SecondsPerPixel converted to zomm units (e.g., Min/Pixel)
       t.code         secs_per_timetype_unit   -- Converts TimePerPixel units to seconds (e.g, for HOUR -> 3600)
  FROM labelfile l 
       JOIN labelfile u ON 
       	l.param1_label = u.labeldefinition AND 
       	l.param1 = u.abbr 
       CROSS JOIN ( 
       	SELECT code 
       	  FROM labelfile 
       	 WHERE labeldefinition = 'TimePerPixelUnits' AND 
       	       abbr = @TimeType 
       ) t --ON 1=1 
 WHERE l.labeldefinition = 'ScheduleZoomTimes' AND 
       ISNULL( l.retired, 'N' ) <> 'Y' AND 
       l.code <= t.code -- exclude too large zooms

--  * Convert SecsPerPixel to zoom units.
--  * Make sure passed Zero Zoom is one of the labelfile codes:  round up to next value or set to last 
--    if greater than all values.
UPDATE @labelfiles 
   SET time_per_pixel = secs_per_pixel_code / secs_per_zoom_unit , 
       zero_zoom_timedistance = ISNULL( 
       	( SELECT MIN( secs_per_pixel_code ) 
       	    FROM @labelfiles 
       	   WHERE secs_per_pixel_code >= @ZeroZoomTimeDistance ) , 
       	( SELECT MAX( secs_per_pixel_code ) 
       	    FROM @labelfiles ) ) 

-- * Calculate the TimeDistace (pixels_per_timetype_unit) and percentage zoom (100% = ZeroZoomTimeDistance).
UPDATE @labelfiles 
   SET pixels_per_timetype_unit = secs_per_timetype_unit / secs_per_pixel_code , 
       percent_zoom = CONVERT( FLOAT, secs_per_timetype_unit ) / ( zero_zoom_timedistance * secs_per_pixel_code ) 

SELECT secs_per_pixel_code       , 
       pixels_per_timetype_unit  , -- TimeDistance
       percent_zoom              , 
       time_per_pixel            , -- In zoom units
       zoom_unit_name            , 
       secs_per_pixel_name       , 
       zoom_unit_labeldef        , 
       zoom_unit                 , 
       secs_per_zoom_unit        , 
       secs_per_timetype_unit    , 
       zero_zoom_timedistance      
  FROM @labelfiles 
ORDER BY secs_per_pixel_code DESC -- same as percent_zoom ASC

GO
GRANT EXECUTE ON  [dbo].[d_da_schedulezoom_sp] TO [public]
GO
