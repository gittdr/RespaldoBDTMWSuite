SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[d_midnight_splits_sp_02] @date1 DATETIME, @date2 DATETIME, @lgh INT,@subcompany varchar(8),@defaultcmp varchar(8)

AS


/**
*
* NAME:
* dbo.d_midight_splits-sp_02
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION
* Used to split the standard hours credited to a driver for trip miles
* driven across a week end or holiday.
* Returns working records with information on trip segments (stop to stop)
* that cross either a week end (midnight Saturday) or a holiday.
*
* Two records are created for a weekend split.  One for the starting
* stop and the check call that falls closest to midnight (to get distance driven
* before midnight) . A second for the same check call closest to midnight and the
* stop that falls in the next week (for distance driven after midnight).
*
* When a holiday occurs between two stops, any weekend split in that interval is not done.  A record
* is created for each day in the interval between stops ( we do not worry which day
* or days are holidays). The first record has the begining stop and the check call closest
* midnight on that date, followed by as many records as needed (one for each distinct day)
* to end with a record showing the check call closest midnight (AM) on the final date of the segment
* plus the ending stop.
*
* RETURNS:
*   N/A
*
* RESULT SETS:
*
* lgh_number int
* mfh_start_sequence INT
* mfh_end_sequence INT
* ord_number varchar(12)
* asgn_id VARCHAR(8)
* pyd_description varchar(64)
* pyd_number INT
* stp_number INT
* paid_miles INT
* pdh_standardhours FLOAT
* start_cmp_id VARCHAR(8)
* start_cmp_city INT
* start_cmp_zip VARCHAR(10)
* start_stp_depart datetime
* start_lat FLOAT
* start_long FLOAT
* end_cmp_id VARCHAR(8)
* end_cmp_city INT
* end_cmp_zip VARCHAR(10)
* end_stp_arrive datetime
* end_lat FLOAT
* end_long FLOAT
* distance INT
* distance_pct FLOAT
* payperiod DATETIME
* subcompanyname VARCHAR(30)
* rsequence int
* isholiday char(1)
*
* PARAMETERS:
* 001 -   @date1 = Midnight (AM) date of first day of the pay period. Must be a valid date.
* 002 -   @date2 = Midnight  (PM) date of the last date of the pay period. Must be a valid date.
* 003 -   @lgh = If not zero, the lgh_number of the trip segment to be processed.
*         If zero, all legs completed between date1 and date2 will be processed
* 004 -   @subcompany = ord_subcompany value, if not UNK limit the trip segments
*         processed to those where the ord_subcompany of the order on the legheader
*         matches (used only when processing all trips in pay period, IE if @lgh = 0)
* 005  -  @defaultcmp = ord_subcompany, if not UNK,  to be used as the ord_subcompany value
*         for empty moves (where there is no ord_subcompany - used only when processing
*         all trips in pay period, IE if @lgh = 0)
*/
/*  MODIFICATION LOG
DPETE PTS28562 add ability to run for a selected ord_subcompany and handle a team driver
     6/30 Need to adjust stops from local time to time zone of trip origin,
     check calls from server time to trip origin time
     7/12/5 found that dates need to be set to midnight dates for comparison to holidays
DPETE PTS 28805 return xsh_recadjtype
DPETE PTS 28631 7/28/05 reset @rseq between legheaders
DPETE PTS 30707 some splits not working over rememberence day 11/11/05.  Found issue with
    Cast(floor(cast done on lgh dates ahead of adjusting them by gmdelta
DPETE PTS 31467 If begining of period date is later than the start date of the trip, sdjust it back
    to the trip start date
DPETE PTS32837 check calls missing for primary driver on a trip that has a team assignment
DPETE PTS 33776 get check call by tractor
DPETE PTS40260 recode Pauls into main source
SPN PTS64373 CalculateLegMiles
*/


CREATE TABLE #temp_lgh1 (
  lgh_number INT)

CREATE INDEX lgh1 ON #temp_lgh1 (lgh_number)

CREATE TABLE #temp_stp (
  lgh_number INT NULL
, stp_arrivaldate DATETIME NULL
, stp_departuredate DATETIME NULL
, cmp_id VARCHAR(8) NULL
, stp_mfh_sequence INT NULL
, stp_lgh_mileage INT NULL
, stp_number INT
)

CREATE INDEX lghstp ON #temp_stp (lgh_number)

CREATE TABLE #return_set (
  lgh_number int NULL
, mfh_start_sequence INT NULL
, mfh_end_sequence INT NULL
, ord_number varchar(12) NULL
, asgn_id VARCHAR(8) NULL
, pyd_description varchar(64) NULL
, pyd_number INT NULL
, stp_number INT NULL
, paid_miles INT NULL
, pdh_standardhours FLOAT NULL

, start_cmp_id VARCHAR(8) NULL
, start_cmp_city INT NULL
, start_cmp_zip VARCHAR(10) NULL
, start_stp_depart datetime NULL
, start_lat decimal(14,6) NULL  --PTS92864
, start_long decimal (14,6) NULL

, end_cmp_id VARCHAR(8) NULL
, end_cmp_city INT NULL
, end_cmp_zip VARCHAR(10) NULL
, end_stp_arrive datetime NULL
, end_lat decimal(14,6) NULL
, end_long decimal(14,6) NULL

, distance INT NULL
, distance_pct FLOAT NULL
, payperiod DATETIME NULL
, subcompanyname VARCHAR(30) NULL
, rsequence tinyint NULL
, isholiday char(1) NULL
, yyyyww int NULL)

CREATE TABLE #temp_lgh (
  lgh_number INT NULL
, lgh_startdate DATETIME NULL
, lgh_enddate DATETIME NULL
, lgh_driver1 VARCHAR(8) NULL
, lgh_driver2 varchar(8) NULL
, mov_number INT NULL
, origingmtdelta INT NULL
, lghstartgmtdelta INT NULL
, lghendgmtdelta INT NULL
, actual_lgh_startdate DATETIME NULL
, actual_lgh_enddate DATETIME NULL
, lgh_tractor varchar(8)NULL)
CREATE INDEX lgh ON #temp_lgh (lgh_number)

CREATE TABLE #temp_ckc (
  ckc_number INT
, ckc_date DATETIME NULL
, ckc_lghnumber INT NULL
, ckc_latseconds INT NULL
, ckc_longseconds INT NULL
)


--BEGIN PTS 64373 SPN
DECLARE @CalculateLegMiles CHAR(1)
--END PTS 64373 SPN

DECLARE @loop_date DATETIME

declare @loop_lgh int
, @loop_seq int
, @next_seq int
, @iloop INT
, @start_arrive datetime
, @start_depart datetime
, @stp_startdepart datetime
, @stp_endarrive datetime
, @end_arrive datetime
, @end_depart datetime
, @lat_origin float
, @long_origin float
, @lat_dest float
, @long_dest float
, @midnight_lat FLOAT
, @midnight_long FLOAT
, @midnight_date DATETIME
, @ckcnum int
, @splitcheckcalllimit int
, @arrive_id varchar(8)
, @depart_id varchar(8)
, @ckctime datetime
, @min_datediff int
, @ckc_closest_midnight int
, @ord_number VARCHAR(12)
, @pyd_description VARCHAR(64)
, @paid_miles INT
, @pdh_standardhours FLOAT
, @asgn_id VARCHAR(8)
, @asgn_id2 varchar(8)
, @saturday DATETIME
, @midnight_today DATETIME
, @diff int
, @origin VARCHAR(8)
, @origin_date DATETIME
, @dest VARCHAR(8)
, @dest_date VARCHAR(8)
, @pyd_number INT
, @stp_number INT
, @payperiod DATETIME
, @subcompanyname varchar(30)
, @pyd_description2 VARCHAR(64)
, @pyd_number2 INT
, @stp_number2 INT
, @rseq INT
, @isserverondst char(1)
, @srvdstadj INT   --  minus 1 if DST applies, 0 if not
, @servergmtdelta  int
, @isholiday char(1)
, @yyyyww int


--BEGIN PTS 64373 SPN
SELECT @CalculateLegMiles = dbo.fn_GetSetting('CalculateLegMiles','C1')
--END PTS 64373 SPN

/* @isserverondst = Y means server on DST, @servergmtdelta is GMT delta for server */
execute tmw_isserverindstmode_sp @servermode = @isserverondst OUTPUT, @servergmtoffset = @servergmtdelta OUTPUT
SELECT @srvdstAdj = Case  @isserverondst When 'Y' Then -1 Else 0 End
SELECT @servergmtdelta = ABS(@servergmtdelta) + @srvdstAdj



SELECT @rseq = 0

Select @payperiod = @date2


Select @subcompanyname = name From labelfile Where labeldefinition = 'Company' and abbr = @subcompany
Select @subcompanyname = ISNULL(@subcompanyname,@subcompany)

/* no longer used since there are too many trips with no check calls inside this limit */
SELECT @splitcheckcalllimit = isNull(gi_integer1,15)
FROM generalinfo
WHERE gi_name = 'PDHoursSplitCheckCallTime'


/* even though dates will be adjusted later for splits, lgh selection is based on local time */
INSERT INTO #temp_lgh1 -- bogus trick to get sqlserver to use the right index
SELECT lgh_number
FROM legheader
WHERE lgh_enddate BETWEEN @date1 AND @date2
  AND (lgh_number = @lgh OR @lgh <= 0)


INSERT INTO #temp_lgh
SELECT #temp_lgh1.lgh_number
, lgh_startdate -- do later when adjusted for gmdelta = CAST(FLOOR(CAST(lgh_startdate AS FLOAT)) AS DATETIME)
, lgh_enddate  -- do later after adj for gmdelta = CAST(FLOOR(CAST(lgh_enddate AS FLOAT)) AS DATETIME)
, lgh_driver1
, lgh_driver2
, mov_number
, origingmtdelta = (SELECT ABS(cty_gmtdelta) + (Case IsNull(cty_dstApplies,'Y')
                       WHEN 'Y' THEN @srvdstadj ELSE 0 END)
                       FROM city WHERE cty_code =
                     (SELECT MAX(stp_city) FROM stops WHERE mov_number = legheader.mov_number
                      and stp_mfh_sequence = 1))
, lghstartgmtdelta = ABS(cs.cty_gmtdelta) + (Case IsNull(cs.cty_dstApplies,'Y')
                       WHEN 'Y' THEN @srvdstadj ELSE 0 END)
, lghendgmtdelta =  ABS(cc.cty_gmtdelta) + (Case IsNull(cc.cty_dstApplies,'Y')
                       WHEN 'Y' THEN @srvdstadj ELSE 0 END)
,actual_lgh_startdate = lgh_startdate
,actual_lgh_enddate = lgh_enddate
,lgh_tractor
FROM legheader
JOIN #temp_lgh1 on legheader.lgh_number = #temp_lgh1.lgh_number
JOIN city cs on cs.cty_code = lgh_startcity
Join city cc on cc.cty_code = lgh_endcity
WHERE legheader.lgh_number = #temp_lgh1.lgh_number

/* remove legs that have orders not in the passed subcompany value (if not UNK) */
If @subcompany <> 'UNK'
  DELETE
  FROM #temp_lgh
  WHERE NOT EXISTS
    (SELECT ord_number
     FROM orderheader o
     WHERE o.mov_number = #temp_lgh.mov_number
     AND ord_subcompany =
       CASE  ord_subcompany
         WHEN  'UNK' THEN
             CASE @subcompany WHEN @defaultcmp THEN ord_subcompany ELSE '?%$' END
         WHEN  'UNKNOW' THEN
             CASE @subcompany WHEN @defaultcmp THEN ord_subcompany ELSE '?%$' END
         ELSE @subcompany
         END)
/* remove legs where there are no paydetails for drivers for distance */
DELETE
FROM  #temp_lgh
WHERE NOT EXISTS
  (SELECT * FROM paydetail p WHERE p.lgh_number =   #temp_lgh.lgh_number
   AND p.asgn_type = 'DRV' and pyd_unit = 'KMS')

/* leg may not be first on move therefore lgh_start is not necessarily trip origin    */

UPDATE #temp_lgh
SET lgh_startdate = CAST(FLOOR(CAST(dateadd(hh,(lghstartgmtdelta - origingmtdelta ),lgh_startdate) AS FLOAT)) AS DATETIME)
  , lgh_enddate   = CAST(FLOOR(CAST(dateadd(hh,(lghendgmtdelta - origingmtdelta ),lgh_enddate)  AS FLOAT)) AS DATETIME)

SET @loop_date = @date1
If (Select min(lgh_startdate) from #temp_lgh) < @loop_date
   Select @Loop_date = Cast(Floor(cast( (Select min(lgh_startdate) from #temp_lgh)  as float)) as datetime)

WHILE @loop_date <= @date2


BEGIN   /* #1 Loop on date , PICK UP ALL STOPS FROM LEGS THAT SPAN A SATURDAY OR A HOLIDAY */


 IF DATEPART(dw, @loop_date) = 1 -- get the legheaders that cross saturday midnight

  INSERT INTO #temp_stp
  SELECT stops.lgh_number
  , stp_arrivaldate =
  DATEADD(hh,(ABS(cty_GMTDelta ) + (Case cty_dstapplies When 'Y' Then @srvdstadj Else 0 END) - origingmtdelta ),stops.stp_arrivaldate)
  , stp_departuredate = DATEADD(hh,
  (ABS(cty_GMTDelta ) + (Case cty_dstapplies When 'Y' Then @srvdstadj Else 0 END) - origingmtdelta ),stops.stp_departuredate)
  , stops.cmp_id, stops.stp_mfh_sequence, (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) AS stp_lgh_mileage, stops.stp_number
  FROM stops
  JOIN #temp_lgh lh on  stops.lgh_number = lh.lgh_number
  Join city on stp_city = cty_code
  WHERE lgh_startdate < @loop_date
  AND lgh_enddate >= @loop_date
  AND stp_event not in ('RTP','TRP')
  AND lgh_driver1 <> 'UNKNOWN'
  AND EXISTS (SELECT * FROM paydetail WHERE paydetail.lgh_number = lh.lgh_number)
  AND (stops.lgh_number = @lgh OR @lgh <= 0)
  AND NOT EXISTS (SELECT * FROM #temp_stp WHERE lgh_number = lh.lgh_number)


 IF EXISTS (SELECT * FROM holidays WHERE holiday = @loop_date) -- get the legheaders that span, cross into, or cross out of a holiday
  INSERT INTO #temp_stp
  SELECT stops.lgh_number
  , stp_arrivaldate = DATEADD(hh,(ABS(cty_GMTDelta ) + (Case cty_dstapplies When 'Y' Then @srvdstadj Else 0 END) - origingmtdelta ),stops.stp_arrivaldate)
  , stp_departuredate = DATEADD(hh,(ABS(cty_GMTDelta ) + (Case cty_dstapplies When 'Y' Then @srvdstadj Else 0 END) - origingmtdelta),stops.stp_departuredate)
  , stops.cmp_id, stops.stp_mfh_sequence, (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) AS stp_lgh_mileage, stops.stp_number
  FROM stops
  JOIN #temp_lgh lh on  stops.lgh_number = lh.lgh_number
  Join city on stp_city = cty_code
  WHERE stops.lgh_number = lh.lgh_number
  AND ((lgh_startdate < @loop_date AND lgh_enddate >= @loop_date) OR (lgh_startdate <= @loop_date AND lgh_enddate > @loop_date)) -- need to look at trips that cross either midnight of holiday or midnight of very next day
  AND stp_event not in ('RTP','TRP')
  AND lgh_driver1 <> 'UNKNOWN'
  AND EXISTS (SELECT * FROM paydetail WHERE paydetail.lgh_number = lh.lgh_number)
  AND (stops.lgh_number = @lgh OR @lgh <= 0)
  AND NOT EXISTS (SELECT * FROM #temp_stp WHERE lgh_number = lh.lgh_number)

 SET @loop_date = DATEADD(dd, 1, @loop_date)

END  /* #1 LOOP ON DATE */
/*Select 'lgh',* from #temp_lgh */
/* Select 'STOPS',* from #temp_stp order by stp_arrivaldate */

SELECT @loop_lgh = 0
SELECT @loop_seq = 0
WHILE EXISTS (SELECT * FROM #temp_stp WHERE lgh_number > @loop_lgh) -- and stp_mfh_sequence > @loop_seq)
BEGIN  /* #2  Loop each lgh_number going thru the stops by mfh_sequence  */

 SELECT @loop_lgh = MIN(lgh_number) from #temp_stp WHERE lgh_number > @loop_lgh
 SELECT @rseq = 0
 WHILE EXISTS (select * from #temp_stp where lgh_number = @loop_lgh AND stp_mfh_sequence > @loop_seq)
 BEGIN  /* #3 go thru each stop finding the curent stop and the one after   */
    -- find each pair of stops that straddle midnight for any saturday or holiday between date1 and date2

  SELECT @loop_seq = MIN(stp_mfh_sequence) FROM #temp_stp WHERE lgh_number = @loop_lgh AND stp_mfh_sequence > @loop_seq
  SET @next_seq = NULL
  SELECT @next_seq = MIN(stp_mfh_sequence) FROM #temp_stp WHERE lgh_number = @loop_lgh AND stp_mfh_sequence > @loop_seq
  IF @next_seq IS NOT NULL

  BEGIN    /* #4 process the stop pair   */
   SELECT @start_arrive = CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME),
      @depart_id = cmp_id, @start_depart =  CAST(FLOOR(CAST(stp_departuredate AS FLOAT)) AS DATETIME)
      ,@stp_startdepart = stp_departuredate
      from #temp_stp
         WHERE lgh_number = @loop_lgh AND stp_mfh_sequence = @loop_seq

   SELECT @end_arrive =  CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME), @arrive_id = cmp_id,
    @end_depart =  CAST(FLOOR(CAST(stp_departuredate AS FLOAT)) AS DATETIME)
    , @stp_endarrive = stp_arrivaldate
    FROM #temp_stp WHERE lgh_number = @loop_lgh AND stp_mfh_sequence = @next_seq


   SELECT @ord_number = ord_number
   FROM legheader, orderheader
   WHERE legheader.ord_hdrnumber = orderheader.ord_hdrnumber
     AND legheader.lgh_number = @loop_lgh

   SELECT @paid_miles = SUM((CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END)) FROM stops
   WHERE lgh_number = @loop_lgh AND stp_mfh_sequence between @loop_seq + 1 AND @next_seq

   SELECT @asgn_id = lgh_driver1 from #temp_lgh where lgh_number = @loop_lgh /* Main driver */

   SELECT @pyd_description = pyd_description, @asgn_id = paydetail.asgn_id, @pyd_number = paydetail.pyd_number, @stp_number = pdh_stp_number
   FROM paydetail, pdhours
   WHERE paydetail.pyd_number = pdhours.pyd_number
     AND paydetail.lgh_number = @loop_lgh
     AND asgn_id = @asgn_id
     AND pdh_stp_number in (SELECT stp_number FROM stops
   WHERE lgh_number = @loop_lgh AND stp_mfh_sequence = @loop_seq + 1)

   SELECT @asgn_id2 = lgh_driver2 from #temp_lgh where lgh_number = @loop_lgh
   IF @asgn_id2 <> 'UNKNOWN'
     SELECT @pyd_description2 = pyd_description,@pyd_number2 = paydetail.pyd_number, @stp_number2 = pdh_stp_number
     FROM paydetail, pdhours
     WHERE paydetail.pyd_number = pdhours.pyd_number
        AND paydetail.lgh_number = @loop_lgh
        AND asgn_id = @asgn_id2
        AND pdh_stp_number in (SELECT stp_number FROM stops
            WHERE lgh_number = @loop_lgh AND stp_mfh_sequence = @loop_seq + 1)

  SELECT @pdh_standardhours = SUM(pdh_standardhours)
   FROM pdhours, paydetail
   WHERE paydetail.pyd_number = pdhours.pyd_number
     AND paydetail.lgh_number = @loop_lgh
     AND pdh_stp_number in (SELECT stp_number FROM stops
   WHERE lgh_number = @loop_lgh AND stp_mfh_sequence BETWEEN @loop_seq + 1 AND @next_seq)
   AND   asgn_id = @asgn_id

    /* Adjust check call times from the server to the origincity
   TRUNCATE TABLE #temp_ckc
   INSERT INTO #temp_ckc
   SELECT ckc_number
   , ckc_date = DATEADD(hh,(@servergmtdelta - origingmtdelta ),ckc_date)
   , ckc_lghnumber, ckc_latseconds, ckc_longseconds
   FROM checkcall
   JOIN  #temp_lgh on    lgh_number = ckc_lghnumber
   WHERE ckc_lghnumber = @loop_lgh
   ORDER BY  ckc_date
*/
/* start attempt not working to get check calls by asset and leg date range */
declare @ckcstart datetime, @ckcend datetime,@origingmdelta int ,@drv varchar(8) ,@drv2 varchar(8),@trc varchar(15)
Select @ckcstart = dateadd(hh,-2,lgh_startdate), @ckcend = dateadd(hh, 2,lgh_enddate) ,@drv = lgh_driver1 ,@drv2 = lgh_driver2
,@trc = lgh_tractor
from legheader
where lgh_number = @loop_lgh
select @origingmdelta = origingmtdelta
from #temp_lgh where lgh_number = @loop_lgh



    TRUNCATE TABLE #temp_ckc
/*
if @drv2 = 'UNKNOWN'
   INSERT INTO #temp_ckc
   SELECT ckc_number
   , ckc_date = DATEADD(hh,(@servergmtdelta - @origingmdelta ),ckc_date)
   , ckc_lghnumber, ckc_latseconds, ckc_longseconds
   FROM checkcall
   WHERE ckc_asgntype = 'DRV'
   and ckc_asgnid = @drv
   and ckc_date between @ckcstart and @ckcend
   ORDER BY  ckc_date
else
  INSERT INTO #temp_ckc
   SELECT ckc_number
   , ckc_date = DATEADD(hh,(@servergmtdelta - @origingmdelta ),ckc_date)
   , ckc_lghnumber, ckc_latseconds, ckc_longseconds
   FROM checkcall
   WHERE ckc_asgntype = 'DRV'
   and (ckc_asgnid = @drv or ckc_asgnid = @drv2)
   and ckc_date between @ckcstart and @ckcend
   ORDER BY  ckc_date
  */
if @trc <> 'UNKNOWN'
INSERT INTO #temp_ckc
   SELECT ckc_number
   , ckc_date = DATEADD(hh,(@servergmtdelta - @origingmdelta ),ckc_date)
   , ckc_lghnumber, ckc_latseconds, ckc_longseconds
   FROM checkcall
   WHERE ckc_tractor = @trc
   and ckc_date between @ckcstart and @ckcend
   ORDER BY  ckc_date

 /* Select * from #temp_ckc order by ckc_date --##*/

   SET @diff = DATEDIFF(dd, @start_depart, @end_arrive) + DATEPART(dw, @start_depart)
   SET @iloop = 0

   WHILE @diff >= 8 -- stop pair crosses saturday midnight, maybe more than one
    AND NOT EXISTS (SELECT * FROM holidays WHERE holiday BETWEEN @start_depart AND @end_arrive) -- no holiday involved
   BEGIN /* #5  stop pair crosses saturday, first record  */

    SET @iloop = @iloop + 1

    -- if first loop, origin is from stops, otherwise is from last midnight checkcall
    IF @iloop = 1

     SELECT @lat_origin = cmp_latseconds/3600.00, @long_origin = cmp_longseconds/3600.00, @origin = @depart_id, @origin_date = @start_depart
     FROM company
     WHERE cmp_id = @depart_id

    ELSE
     SELECT @origin = '**GPS**', @lat_origin = @midnight_lat, @long_origin = @midnight_long, @origin_date = @midnight_date

    -- now find closest check call to midnight
    SET @ckc_closest_midnight = 0
    SET @ckcnum = 0
    SET @midnight_lat = 0
    SET @midnight_long = 0
    SET @midnight_date = '1/1/1950'
    SET @min_datediff = @splitcheckcalllimit

    SET @saturday = CAST(FLOOR(CAST(@origin_date AS FLOAT)) AS DATETIME)
    SET @saturday = dateadd(dd, 8 - datepart(dw, @saturday), @saturday)

/* handle instance where there are no check calls before midnight, first one is closest */
    SELECT @ckctime = Min(ckc_date) From  #temp_ckc WHERE  ckc_date >= @origin_date
    SET @min_datediff = ABS(DATEDIFF(mi, @ckctime, @saturday))
    SELECT @ckc_closest_midnight = ckc_number from #temp_ckc Where ckc_date  = @ckctime

    WHILE EXISTS (SELECT * FROM #temp_ckc WHERE ckc_number > @ckcnum AND ckc_date > @origin_date)
    BEGIN  /* #6 loop to find checkcall closest midnight */
      SELECT @ckcnum = MIN(ckc_number) FROM #temp_ckc WHERE ckc_number > @ckcnum AND ckc_date > @origin_date
      SELECT @ckctime = ckc_date FROM #temp_ckc WHERE ckc_number = @ckcnum
      IF ABS(DATEDIFF(mi, @ckctime, @saturday)) < @min_datediff
      BEGIN
       SET @min_datediff = ABS(DATEDIFF(mi, @ckctime, @saturday))
       SET @ckc_closest_midnight = @ckcnum
      END
    END  /* #6 end finding check call closest midnight */

    SELECT @midnight_lat = ckc_latseconds/3600.00, @midnight_long = ckc_longseconds/3600.00, @midnight_date = ckc_date
    FROM #temp_ckc
    WHERE ckc_number = @ckc_closest_midnight

    Select @yyyyww =  Datepart(ww,dateadd(d,7 - (select datepart(dw,@origin_date)),@origin_date))

    Select @rseq = @rseq + 1
    INSERT INTO #return_set (
      lgh_number
    , mfh_start_sequence
    , mfh_end_sequence
    , ord_number
    , asgn_id
    , pyd_description
    , pyd_number
    , stp_number
    , paid_miles
    , pdh_standardhours

    , start_cmp_id
    , start_cmp_city
    , start_cmp_zip
    , start_stp_depart
    , start_lat
    , start_long

    , end_cmp_id
    , end_cmp_city
    , end_cmp_zip
    , end_stp_arrive
    , end_lat
    , end_long

    , distance
    , distance_pct
    , payperiod
    , subcompanyname
    , rsequence
    , isholiday
    , yyyyww)
   VALUES (
      @loop_lgh
    , @loop_seq
    , @next_seq
    , @ord_number
    , @asgn_id
    , @pyd_description
    , @pyd_number
    , @stp_number
    , @paid_miles
    , @pdh_standardhours

    , @origin
    , 0
    , ''
    , @stp_startdepart --@origin_date
    , @lat_origin
    , @long_origin

    , '**GPS**'
    , 0
    , ''
    , @midnight_date
    , @midnight_lat
    , @midnight_long

    , 0
    , 0
    , @payperiod
    , @subcompanyname
    , @rseq
    , 'N'
    , @yyyyww)

   /* Team Driver */
    IF @asgn_id2 <> 'UNKNOWN'
       INSERT INTO #return_set (
        lgh_number
        , mfh_start_sequence
        , mfh_end_sequence
        , ord_number
        , asgn_id
        , pyd_description
        , pyd_number
        , stp_number
        , paid_miles
        , pdh_standardhours

        , start_cmp_id
        , start_cmp_city
        , start_cmp_zip
        , start_stp_depart
        , start_lat
        , start_long

        , end_cmp_id
        , end_cmp_city
        , end_cmp_zip
        , end_stp_arrive
        , end_lat
        , end_long
        , distance
        , distance_pct
        , payperiod
        , subcompanyname
        , rsequence
        , isholiday
        , yyyyww  )
       VALUES (
          @loop_lgh
        , @loop_seq
        , @next_seq
        , @ord_number
        , @asgn_id2
        , @pyd_description2
        , @pyd_number2
        , @stp_number2
        , @paid_miles
        , @pdh_standardhours

        , @origin
        , 0
        , ''
        , @stp_startdepart --@origin_date
        , @lat_origin
        , @long_origin

        , '**GPS**'
        , 0
        , ''
        , @midnight_date
        , @midnight_lat
        , @midnight_long

        , 0
        , 0
        , @payperiod
        , @subcompanyname
        , @rseq
        , 'N'
        , @yyyyww )



       SET @diff = @diff - 7
   END /* #5  stop pair crosses saturday, first record  */

   IF @iloop > 0
   BEGIN   /* #8 stop pair crossses saturday, second record */

    SELECT @lat_dest = cmp_latseconds/3600.00, @long_dest = cmp_longseconds/3600.00, @dest = @arrive_id
    FROM company
    WHERE cmp_id = @arrive_id

    Select @yyyyww = Datepart(ww,dateadd(d,7 - (select datepart(dw,@end_arrive)),@end_arrive))

    SELECT  @rseq = @rseq + 1
    INSERT INTO #return_set (
      lgh_number
    , mfh_start_sequence
    , mfh_end_sequence
    , ord_number
    , asgn_id
    , pyd_description
    , pyd_number
    , stp_number
    , paid_miles
    , pdh_standardhours

    , start_cmp_id
    , start_cmp_city
    , start_cmp_zip
    , start_stp_depart
    , start_lat
    , start_long

    , end_cmp_id
    , end_cmp_city
    , end_cmp_zip
    , end_stp_arrive
    , end_lat
    , end_long

    , distance
    , distance_pct
    , payperiod
    , subcompanyname
    , rsequence
    , isholiday
    , yyyyww )
    VALUES (
      @loop_lgh
    , @loop_seq
    , @next_seq
    , @ord_number
    , @asgn_id
    , @pyd_description
    , @pyd_number
    , @stp_number
    , @paid_miles
    , @pdh_standardhours

    , '**GPS**'
    , 0
    , ''
    , @midnight_date
    , @midnight_lat
    , @midnight_long

    , @arrive_id
    , 0
    , ''
    , @stp_endarrive --@end_arrive
    , @lat_dest
    , @long_dest

    , 0
    , 0
    , @payperiod
    , @subcompanyname
    , @rseq
    , 'N'
    , @yyyyww )

    IF @asgn_id2 <> 'UNKNOWN'

        INSERT INTO #return_set (
        lgh_number
        , mfh_start_sequence
        , mfh_end_sequence
        , ord_number
        , asgn_id
        , pyd_description
        , pyd_number
        , stp_number
        , paid_miles
        , pdh_standardhours

        , start_cmp_id
        , start_cmp_city
        , start_cmp_zip
        , start_stp_depart
        , start_lat
        , start_long

        , end_cmp_id
        , end_cmp_city
        , end_cmp_zip
        , end_stp_arrive
        , end_lat
        , end_long

        , distance
        , distance_pct
        , payperiod
        , subcompanyname
        , rsequence
        , isholiday
        , yyyyww )
        VALUES (
          @loop_lgh
        , @loop_seq
        , @next_seq
        , @ord_number
        , @asgn_id2
        , @pyd_description2
        , @pyd_number2
        , @stp_number2
        , @paid_miles
        , @pdh_standardhours

        , '**GPS**'
        , 0
        , ''
        , @midnight_date
        , @midnight_lat
        , @midnight_long

        , @arrive_id
        , 0
        , ''
        , @stp_endarrive --@end_arrive
        , @lat_dest
        , @long_dest

        , 0
        , 0
        , @payperiod
        , @subcompanyname
        , @rseq
        , 'N'
        , @yyyyww)


   END /* #8 stop pair crossses saturday, second record */

   IF EXISTS (SELECT * FROM holidays WHERE holiday BETWEEN @start_depart AND @end_arrive) -- holiday IS involved
   BEGIN  /* #9 Holiday in trip segment which covers multiple days */
    SET @iloop = 0 --##?????????????????????????????????
     /* second condition handles mulitple day holidays like Christmas and Boxing */
    WHILE DATEDIFF(dd, @start_depart, @end_arrive) > 0 and
      ((Select count(*) from holidays where holiday between @start_depart and @end_arrive) <
      (Select Datediff(dd,@start_depart,@end_arrive) + 1))

    BEGIN   /* #10  trip segment crossed into and/or out of holiday dates */
     SET @iloop = @iloop + 1
      -- if first loop, origin is from stops, otherwise is from last midnight checkcall
     IF @iloop = 1
       SELECT @lat_origin = cmp_latseconds/3600.00, @long_origin = cmp_longseconds/3600.00, @origin = @depart_id, @origin_date = @start_depart
       FROM company
       WHERE cmp_id = @depart_id
     ELSE
       SELECT @origin = '**GPS**', @lat_origin = @midnight_lat, @long_origin = @midnight_long, @origin_date = @midnight_date

     -- now find closest check call to midnight
     SET @ckc_closest_midnight = 0
     SET @ckcnum = 0
     SET @midnight_lat = 0
     SET @midnight_long = 0
     SET @midnight_date = '1/1/1950'
     SET @min_datediff = @splitcheckcalllimit
/*    handle trip seg that is (day - day - holiday)
     IF DATEDIFF (d,@start_depart,@end_arrive) > 1
        --if segment spans more than 2 days look for first non-holiday/holiday  midnight
        BEGIN
          IF Not Exists (SELECT * FROM holidays Where DateDiff(dd,@start_depart,holiday) = 0)
             BEGIN
               Select @loop_date = @start_depart
               While Not Exists (SELECT * FROM holidays Where DateDiff(dd,@loop_date,holiday) = 0)
                 BEGIN
                   SELECT @loop_date = DATEADD(dd,1,@loop_date)
                  --   SELECT @start_depart = DATEADD(dd,1,@start_depart)
                 END
                 SET  @midnight_today = CAST(FLOOR(CAST(@loop_date AS FLOAT)) AS DATETIME)
                 SET @origin_date = DATEADD(dd,-1,@loop_date)
                 --  SET  @midnight_today = CAST(FLOOR(CAST(@start_depart AS FLOAT)) AS DATETIME)
                 --  SET @origin_date = DATEADD(dd,-1,@start_depart)
             END
        END
     ELSE
 */
        BEGIN

          SET @midnight_today = CAST(FLOOR(CAST(@start_depart AS FLOAT)) AS DATETIME)
          SET @midnight_today = DATEADD(dd, 1, @midnight_today)
        END

       /*  WHen first check cal was the closest to midnight , it did not get selected */
     declare @entry int
     Select @entry = 1
     WHILE EXISTS (SELECT * FROM #temp_ckc WHERE ckc_number > @ckcnum AND ckc_date > @origin_date)
     BEGIN    /* #11 loop to find checkcall closest midnight */
      SELECT @ckcnum = MIN(ckc_number) FROM #temp_ckc WHERE ckc_number > @ckcnum AND ckc_date > @origin_date
      SELECT @ckctime = ckc_date FROM #temp_ckc WHERE ckc_number = @ckcnum
      If @entry = 1
         BEGIN
           SET @min_datediff = ABS(DATEDIFF(mi, @ckctime, @midnight_today))
           SET @ckc_closest_midnight = @ckcnum
           Select @entry = @entry + 1
         END

      IF ABS(DATEDIFF(mi, @ckctime, @midnight_today)) < @min_datediff
      BEGIN
       SET @min_datediff = ABS(DATEDIFF(mi, @ckctime, @midnight_today))
       SET @ckc_closest_midnight = @ckcnum
      END
     END  /* #11 end finding check call closest midnight */
     SELECT @midnight_lat = ckc_latseconds/3600.00, @midnight_long = ckc_longseconds/3600.00, @midnight_date = ckc_date
     FROM #temp_ckc
     WHERE ckc_number = @ckc_closest_midnight

    If Exists (Select * from holidays where  holiday = @origin_date)
       Select @isholiday = 'Y'
    Else
       Select @isholiday = 'N'

     Select @yyyyww = Datepart(ww,dateadd(d,7 - (select datepart(dw,@origin_date)),@origin_date))
     SELECT @rseq = @rseq + 1
     INSERT INTO #return_set (
       lgh_number
     , mfh_start_sequence
     , mfh_end_sequence
     , ord_number
     , asgn_id
     , pyd_description
     , pyd_number
     , stp_number
     , paid_miles
     , pdh_standardhours

     , start_cmp_id
     , start_cmp_city
     , start_cmp_zip
     , start_stp_depart
     , start_lat
     , start_long

     , end_cmp_id
     , end_cmp_city
     , end_cmp_zip
     , end_stp_arrive
     , end_lat
     , end_long

     , distance
     , distance_pct
     , payperiod
     , subcompanyname
     , rsequence
     , isholiday
     , yyyyww )
     VALUES (
       @loop_lgh
     , @loop_seq
     , @next_seq
     , @ord_number
     , @asgn_id
     , @pyd_description
     , @pyd_number
     , @stp_number
     , @paid_miles
     , @pdh_standardhours

     , @origin
     , 0
     , ''
     , @origin_date
     , @lat_origin
     , @long_origin

     , '**GPS**'
     , 0
     , ''
     , @midnight_date
     , @midnight_lat
     , @midnight_long

     , 0
     , 0
    , @payperiod
    , @subcompanyname
    , @rseq
    , @isholiday
    , @yyyyww)

     IF @asgn_id2 <> 'UNKNOWN'
       INSERT INTO #return_set (
       lgh_number
       , mfh_start_sequence
       , mfh_end_sequence
       , ord_number
       , asgn_id
       , pyd_description
       , pyd_number
       , stp_number
       , paid_miles
       , pdh_standardhours
       , start_cmp_id
       , start_cmp_city
       , start_cmp_zip
       , start_stp_depart
       , start_lat
       , start_long
       , end_cmp_id
       , end_cmp_city
       , end_cmp_zip
       , end_stp_arrive
       , end_lat
       , end_long
       , distance
       , distance_pct
       , payperiod
       , subcompanyname
       , rsequence
       , isholiday
       , yyyyww )
       VALUES (
         @loop_lgh
       , @loop_seq
       , @next_seq
       , @ord_number
       , @asgn_id2
       , @pyd_description2
       , @pyd_number2
       , @stp_number2
       , @paid_miles
       , @pdh_standardhours
       , @origin
       , 0
       , ''
       , @origin_date
       , @lat_origin
       , @long_origin
       , '**GPS**'
       , 0
       , ''
       , @midnight_date
       , @midnight_lat
       , @midnight_long
       , 0
       , 0
      , @payperiod
      , @subcompanyname
      , @rseq
      , @isholiday
      , @yyyyww )
     SET @start_depart = @midnight_today
     SET @origin_date = @midnight_today
 -- SET @start_depart = DATEADD(dd,1,@midnight_today )
    END
    IF @iloop > 0
    BEGIN  /* #9 add holiday record */
      If Exists (Select * from holidays where  holiday = @end_arrive)
       Select @isholiday = 'Y'
      Else
       Select @isholiday = 'N'

      Select @yyyyww = Datepart(ww,dateadd(d,7 - (select datepart(dw,@end_arrive)),@end_arrive))

     SELECT @lat_dest = cmp_latseconds/3600.00, @long_dest = cmp_longseconds/3600.00, @dest = @arrive_id
     FROM company
     WHERE cmp_id = @arrive_id

     SELECT @rseq = @rseq + 1
     INSERT INTO #return_set (
     lgh_number
     , mfh_start_sequence
     , mfh_end_sequence
     , ord_number
     , asgn_id
     , pyd_description
     , pyd_number
     , stp_number
     , paid_miles
     , pdh_standardhours
     , start_cmp_id
     , start_cmp_city
     , start_cmp_zip
     , start_stp_depart
     , start_lat
     , start_long
     , end_cmp_id
     , end_cmp_city
     , end_cmp_zip
     , end_stp_arrive
     , end_lat
     , end_long
     , distance
    , distance_pct
    , payperiod
    , subcompanyname
    , rsequence
    , isholiday
    , yyyyww )
     VALUES (
     @loop_lgh
     , @loop_seq
     , @next_seq
     , @ord_number
     , @asgn_id
     , @pyd_description
     , @pyd_number
     , @stp_number
     , @paid_miles
     , @pdh_standardhours
     , '**GPS**'
     , 0
     , ''
     , @midnight_date
     , @midnight_lat
     , @midnight_long
     , @arrive_id
     , 0
     , ''
     , @end_arrive
     , @lat_dest
     , @long_dest
     , 0
     , 0
     , @payperiod
     , @subcompanyname
     , @rseq
     , @isholiday
     , @yyyyww)

     If @Asgn_id2 <> 'UNKNOWN'
       INSERT INTO #return_set (
       lgh_number
       , mfh_start_sequence
       , mfh_end_sequence
       , ord_number
       , asgn_id
       , pyd_description
       , pyd_number
       , stp_number
       , paid_miles
       , pdh_standardhours
       , start_cmp_id
       , start_cmp_city
       , start_cmp_zip
       , start_stp_depart
       , start_lat
       , start_long
       , end_cmp_id
       , end_cmp_city
       , end_cmp_zip
       , end_stp_arrive
       , end_lat
       , end_long
       , distance
      , distance_pct
      , payperiod
      , subcompanyname
      , rsequence
      , isholiday
      , yyyyww)
       VALUES (
       @loop_lgh
       , @loop_seq
       , @next_seq
       , @ord_number
       , @asgn_id2
       , @pyd_description2
       , @pyd_number2
       , @stp_number2
       , @paid_miles
       , @pdh_standardhours
       , '**GPS**'
       , 0
       , ''
       , @midnight_date
       , @midnight_lat
       , @midnight_long
       , @arrive_id
       , 0
       , ''
       , @end_arrive
       , @lat_dest
       , @long_dest
       , 0
       , 0
       , @payperiod
       , @subcompanyname
       , @rseq
       , @isholiday
       , @yyyyww)

       /* what if trip segment passes thru holiday EG hoiday on 5/31 seg goes from 5/29 to 6/1 */
       /* would need an additional split */

    END   /* #9 add holiday record */
   END

  END -- IF @next_seq IS NOT NULL
 END -- WHILE EXISTS (select * from #temp_stp where lgh_number = @loop_lgh AND stp_mfh_sequence > @loop_seq)
 SET @loop_seq = 0
END -- WHILE EXISTS (SELECT * FROM #temp_stp WHERE lgh_number > @loop_lgh) -- and stp_mfh_sequence > @loop_seq)

UPDATE #return_set
SET start_cmp_city = c1.cmp_city
 , start_cmp_zip = c1.cmp_zip
FROM company c1
WHERE #return_set.start_cmp_id = c1.cmp_id

UPDATE #return_set
SET end_cmp_city = c1.cmp_city
 , end_cmp_zip = c1.cmp_zip
FROM company c1
WHERE #return_set.end_cmp_id = c1.cmp_id

SELECT * FROM #return_set
DROP TABLE #temp_lgh1
DROP TABLE #temp_lgh
DROP TABLE #temp_stp
DROP TABLE #temp_ckc
DROP TABLE #return_set

GO
GRANT EXECUTE ON  [dbo].[d_midnight_splits_sp_02] TO [public]
GO
