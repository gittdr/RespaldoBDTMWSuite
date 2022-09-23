SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[GetLiftingReportData] @billto varchar(8), @startdate datetime, @cmdClassTable char(1)
AS

DECLARE @month varchar(10),
		@year varchar(4)

CREATE TABLE #temp (shipper varchar(8),
					shipper_monthly_allocation float,
					class_monthly_allocation float,					
					liftdate datetime,
					cmd_class varchar(8),
					volume	float,
					TotalVolume float,
					TotalVolumePerCmdClass float)

SET NOCOUNT ON

SET @year = DATEPART(yyyy,@startdate)

SELECT @month = CASE DATEPART(mm, @startdate) 
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
		ELSE 'UNKNOWN'
  END

IF (@cmdClassTable = 1)
  BEGIN
	INSERT INTO #temp  (shipper, 
						liftdate, 
						cmd_class, 
						volume,
						class_monthly_allocation)
	SELECT  stp.cmp_id,
			stp.stp_departuredate,
			cmd.cmd_class,
			fgt_volume,
			ISNULL(ca_allocation,0)
	FROM orderheader ord
	INNER JOIN stops stp ON ord.mov_number = stp.mov_number
	INNER JOIN freightdetail fgt ON stp.stp_number = fgt.stp_number
	INNER JOIN commodity cmd ON fgt.cmd_code = cmd.cmd_code
	LEFT OUTER JOIN commodity_allocation ca ON ord.ord_billto = ca.ca_billto AND ca.ca_shipper = stp.cmp_id AND ca.cmd_class = cmd.cmd_class AND ca.ca_month = @month AND ca.ca_year = @year
	WHERE ord.ord_billto = @billto
		AND ord.ord_status IN ('AVL', 'PLN', 'DSP', 'STD', 'CMP')
		AND stp.stp_departuredate >= @startdate
		AND stp.stp_departuredate < DATEADD(m, 1, @startdate)
		AND (stp.stp_event = 'LLD' OR stp.stp_event = 'DLD' OR stp.stp_event = 'PLD')
  END
ELSE
  BEGIN
	INSERT INTO #temp  (shipper, 
						liftdate, 
						cmd_class, 
						volume,
						class_monthly_allocation)
	SELECT  stp.cmp_id,
			stp.stp_departuredate,
			cmd.cmd_class2,
			fgt_volume,
			ISNULL(ca_allocation,0)
	FROM orderheader ord
	INNER JOIN stops stp ON ord.mov_number = stp.mov_number
	INNER JOIN freightdetail fgt ON stp.stp_number = fgt.stp_number
	INNER JOIN commodity cmd ON fgt.cmd_code = cmd.cmd_code
	LEFT OUTER JOIN commodity_allocation ca ON ord.ord_billto = ca.ca_billto AND ca.ca_shipper = stp.cmp_id AND ca.cmd_class = cmd.cmd_class2 AND ca.ca_month = @month AND ca.ca_year = @year
	WHERE ord.ord_billto = @billto
		AND ord.ord_status IN ('AVL', 'PLN', 'DSP', 'STD', 'CMP')
		AND stp.stp_departuredate >= @startdate
		AND stp.stp_departuredate < DATEADD(m, 1, @startdate)
		AND (stp.stp_event = 'LLD' OR stp.stp_event = 'DLD' OR stp.stp_event = 'PLD')
  END

-- Insert any commodity_allocation records that weren't added yet (no lift activity)
SELECT ca_shipper, cmd_class, ca_allocation
INTO #hold
FROM commodity_allocation ca
WHERE ca.ca_month = @month 
	AND ca.ca_year = @year 
	AND ca.ca_billto = @billto

DELETE #hold
FROM #hold, #temp
WHERE #temp.shipper = #hold.ca_shipper 
	AND #temp.cmd_class = #hold.cmd_class

INSERT INTO #temp  (shipper, 
					liftdate,
					cmd_class, 
					volume,
					class_monthly_allocation,
					TotalVolume,
					TotalVolumePerCmdClass,
					shipper_monthly_allocation)
SELECT  ca_shipper,
		'1/1/1900',
		cmd_class,
		0,
		ca_allocation,
		0,
		0,
		0
FROM #hold

-- Total volume picked up per shipper
SELECT SUM(volume) vol, shipper INTO #Sum
FROM #temp 
GROUP BY shipper

UPDATE #temp 
SET TotalVolume = vol
FROM #Sum
WHERE #temp.shipper = #Sum.shipper

-- Total volume picked up per shipper/cmd class
SELECT SUM(volume) vol, shipper, cmd_class INTO #SumCmd
FROM #temp 
GROUP BY shipper, cmd_class

UPDATE #temp 
SET TotalVolumePerCmdClass = vol
FROM #SumCmd
WHERE #temp.shipper = #SumCmd.shipper
	  AND #temp.cmd_class = #SumCmd.cmd_class

-- Calculate total month allocation per shipper
UPDATE #temp
SET shipper_monthly_allocation = (SELECT ISNULL(SUM(ISNULL(ca_allocation,0)),0) 
								  FROM commodity_allocation ca 
								  WHERE ca_billto = @billto 
									AND ca.ca_shipper = #temp.shipper
									AND ca.ca_month = @month
									AND ca.ca_year = @year)

SELECT * 
FROM #temp 
ORDER BY shipper, cmd_class, liftdate
GO
GRANT EXECUTE ON  [dbo].[GetLiftingReportData] TO [public]
GO
