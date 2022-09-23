SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[getstatpayrate] (@driver varchar(8)
, @holiday datetime)
AS
/*
/**
 * 
 * NAME:
 * dbo.getstatpayrate
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is used for computing holiday pay for Paul's Hauling
 *
 * RETURNS:
 * A return value of the average pay over the prior X days
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @driver - driver ID
 * 002 - @holiday - the date of the holiday to be paid
 *
 * REFERENCES: NONE

 * 
 * REVISION HISTORY:
 * 09/07/2004.01 ? PTS24576 - Dan Klein created
 * 10/24/2005.02 - PTS30340 - DPETE concatenate gi string values for BonePayTypes
 * 6/11/08 DPETE PTS 43183 do not pay holiday pay if driver has worked less than 30 days
 **/




*/

CREATE TABLE #temp (
	  startdate datetime null
	, enddate datetime null
	, days int null
	, pay decimal(9,2) null
	, lgh_number int null
	)

DECLARE
  @holidaypaycode varchar(6)
, @enddate datetime
, @pay decimal(9,2)
, @lgh int
, @laststartdate datetime
, @startdate datetime
, @days int
, @cumdays int
, @cumpay decimal(9,2)
, @lastholidaypay decimal(9,2)
, @maxdate datetime
, @i int
, @average decimal(9,2)
, @exempts varchar(255)
, @minseniority int
,@dayssincehire int
,@daystotermination int


select @minseniority = gi_integer1 from generalinfo where gi_name = 'HireDaysBeforeHolidayPay'
select @minseniority =isnull(@minseniority ,30)

select @dayssincehire = datediff(dd,mpp_hiredate,@holiday), 
       @daystotermination = datediff(dd,@holiday,mpp_terminationdt) 
from manpowerprofile where mpp_id = @driver

select @average = 0.0
If (@dayssincehire > @minseniority)  and 
    (@daystotermination) > -1
BEGIN


  --SELECT @exempts = ',' + gi_string1 + ',' FROM generalinfo WHERE gi_name = 'BonusPayTypes'
  SELECT @exempts = ',' + gi_string1 + ','+
   (Case IsNull(gi_string2,'%^%') When '%^%' Then '' Else gi_string2+',' end) + 
   (Case IsNull(gi_string3,'%^%') When '%^%' Then '' Else gi_string3+',' end) +
   (Case IsNull(gi_string4,'%^%') When '%^%' Then '' Else gi_string4+',' end) 
  FROM generalinfo WHERE gi_name = 'BonusPayTypes'
  SELECT @holidaypaycode = gi_string1 FROM generalinfo WHERE gi_name = 'StatPayCode'

  SELECT @enddate = @holiday
  SELECT @lastholidaypay = IsNull(pyd_amount, 0)
  FROM paydetail, pdhours
  WHERE asgn_type = 'DRV'
  AND asgn_id = @driver
  AND pdhours.pyd_number = paydetail.pyd_number
  AND pyt_itemcode = @holidaypaycode
  AND pdhours.pdh_date = (SELECT MAX(pdh_date)
									FROM paydetail, pdhours
									WHERE asgn_type = 'DRV'
									  AND asgn_id = @driver
									  AND pdhours.pyd_number = paydetail.pyd_number
									  AND pdhours.pdh_date < @holiday
									  AND pyt_itemcode = @holidaypaycode)
  IF @LastHolidayPay IS NULL
	SET @LastHolidayPay = 0

  WHILE EXISTS (SELECT asgn_enddate
					FROM 	assetassignment
					WHERE asgn_type = 'DRV'
					  AND	asgn_id = @driver
					  AND asgn_enddate < @enddate)
  BEGIN
	SELECT @enddate = MAX(asgn_enddate) 
					FROM 	assetassignment
					WHERE asgn_type = 'DRV'
					  AND	asgn_id = @driver
					  AND asgn_enddate < @enddate
	SELECT @lgh = lgh_number, @startdate = asgn_date FROM assetassignment WHERE asgn_type = 'DRV' AND asgn_id = @driver AND asgn_enddate = @enddate
	IF datepart(dd, @startdate) < datepart(dd, @laststartdate) AND @cumdays >= 20
		BREAK
	SELECT @pay = ISNULL(SUM(pyd_amount), 0) FROM paydetail WHERE pyd_pretax = 'Y' AND asgn_type = 'DRV' AND asgn_id = @driver AND lgh_number = @lgh
	IF @laststartdate IS NULL -- first time through
		BEGIN
		SET @days = DateDiff(dd, @startdate, @enddate) + 1.00
		SET @cumdays = @days
		END
	ELSE IF DateDiff(dd, @enddate, @laststartdate) > 0 -- this trip ended before next one started (remember, we're going in reverse order)
		BEGIN
		SET @days = DateDiff(dd, @startdate, @enddate) + 1.00 -- that is, count the beginning day, ending day, and all between days
		SET @cumdays = @cumdays + @days
		END
	ELSE 
		BEGIN
		SET @days = DateDiff(dd, @startdate, @enddate) -- that is, count the beginning day, but not the ending day (was already counted)
		SET @cumdays = @cumdays + @days
		END
	INSERT INTO #temp
	VALUES (
		  @startdate
		, @enddate
		, @days
		, @pay
		, @lgh
		)
	SET @laststartdate = @startdate

  END

  SELECT @startdate = MIN(startdate), @enddate = MAX(enddate)
  FROM #temp

  IF @LastHolidayPay > 0 
  BEGIN
	INSERT INTO #temp
	SELECT 
	  CASE WHEN exp_expirationdate < @startdate THEN	@startdate
		ELSE exp_expirationdate
		END
	, CASE WHEN exp_compldate > @holiday THEN @holiday
		ELSE exp_compldate 
		END
	, DateDiff(dd, exp_expirationdate, exp_compldate) + 1.00
	, @lastholidaypay
	, 0
	FROM expiration
	WHERE (exp_expirationdate <= @holiday AND exp_compldate >= @startdate )
	  AND exp_idtype = 'DRV'
	  AND exp_id = @driver
	  AND exp_compldate < '12/31/2049'
	  AND exp_code = 'VAC'
	
	UPDATE #temp
	SET days = DateDiff(dd, startdate, enddate) + 1
	WHERE DateDiff(dd, startdate, enddate) + 1 < days
	  AND lgh_number = 0
  END

  INSERT INTO #temp
  SELECT 
  pdhours.pdh_date
  , pdhours.pdh_date
  , 1
  , isnull(pyd_amount, 0)
  , 0
  FROM paydetail, pdhours
  WHERE paydetail.pyd_number = pdhours.pyd_number
  AND asgn_type = 'DRV'
  AND asgn_id = @driver
  AND pyt_itemcode = @holidaypaycode 
  AND paydetail.lgh_number = 0
  --  AND pdhours.pdh_date BETWEEN @startdate AND @holiday -- dsk050107
  AND pdhours.pdh_date BETWEEN @startdate AND DateAdd(mi, -1, @holiday)

  -- dsk050107 -- get non-trip related pay
  INSERT INTO #temp
  SELECT 
  pyd_transdate
  , pyd_transdate
  , 0
  , isnull(pyd_amount, 0)
  , -1
  FROM paydetail
  WHERE asgn_type = 'DRV'
  AND asgn_id = @driver
  AND paydetail.lgh_number = 0
  AND pyd_transdate BETWEEN @startdate AND DateAdd(mi, -1, @holiday)
  AND pyd_pretax = 'Y'
  AND	CHARINDEX(','+pyt_itemcode+',', @exempts) = 0



  SELECT @maxdate = DateAdd(dd, 1, @holiday), @cumdays = 0, @cumpay = 0
  WHILE EXISTS (SELECT startdate FROM #temp WHERE startdate < @maxdate)
  BEGIN
	SELECT @maxdate = MAX(startdate) FROM #temp WHERE startdate < @maxdate
	SELECT @days = days, @pay = pay, @lgh = lgh_number, @startdate = startdate FROM #temp WHERE startdate = @maxdate
	IF @lgh = 0 -- vacation or holiday, rate is per day
	BEGIN
		SET @i = 1
		WHILE @i <= @days
		BEGIN
			IF NOT EXISTS
				(SELECT * FROM #temp
				WHERE startdate <> @maxdate
				  AND cast(floor(cast(startdate as float)) as datetime) = cast(floor(cast(@maxdate as float)) as datetime))
			BEGIN
				SET @cumdays = @cumdays + 1
			END
			SET @cumpay = @cumpay + @pay 
			SET @i = @i + 1
			IF @cumdays >= 20
				BREAK
		END
	END
	ELSE
	BEGIN

		IF @lgh < 0 AND NOT EXISTS (SELECT * FROM #temp
			WHERE startdate <> @maxdate
				AND (cast(floor(cast(startdate as float)) as datetime) = cast(floor(cast(@startdate as float)) as datetime)
				OR cast(floor(cast(enddate as float)) as datetime) = cast(floor(cast(@startdate as float)) as datetime)
				OR (cast(floor(cast(startdate as float)) as datetime) < cast(floor(cast(@startdate as float)) as datetime) 
						AND cast(floor(cast(enddate as float)) as datetime) > cast(floor(cast(@startdate as float)) as datetime))))
			BEGIN
				SET @days = 1
				update #temp set days = 1 WHERE startdate = @maxdate
			END

		IF @cumdays >= 20 AND @days > 0 OR @cumdays > 20
			BREAK

		SET @cumdays = @cumdays + @days
		SET @cumpay = @cumpay + @pay 
	END
  END

  IF @cumdays <= 0 
	SET @average = 0
  ELSE
	SET @average = @cumpay/@cumdays
END

SELECT @average

GO
GRANT EXECUTE ON  [dbo].[getstatpayrate] TO [public]
GO
