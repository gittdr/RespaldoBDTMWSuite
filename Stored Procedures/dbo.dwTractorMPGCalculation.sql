SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwTractorMPGCalculation]
(
	@Datasource varchar(32)
	,@SanityCheckLowMPG float = 3.5
	,@SanityCheckHighMPG float = 6.5
	,@DefaultMPG float = 5.0
)
AS


SET NOCOUNT ON 

-- get tractor mpg info
CREATE TABLE #TractorMPG (trc_number varchar(12), MPG float)
CREATE TABLE #tGallons (trc_number varchar(12), DateStart datetime, DateEnd datetime, TotalGallons float) 
CREATE TABLE #tMiles (trc_number varchar(12), TotalMiles float) 

INSERT INTO #tGallons (trc_number, DateStart, DateEnd, TotalGallons)
select t1.trc_number
,DateStart = IsNull(min(t1.fp_date),'19500101 00:00:00.000')
,DateEnd = IsNull(max(t1.fp_date),'20501231 00:00:00.000')
,TotalGallons = SUM(t1.fp_quantity * IsNull(t2.unc_factor, 1))
from Fuelpurchased t1 with (NOLOCK) 
	INNER JOIN UnitConversion t2 with (NOLOCK) ON t1.fp_uom = t2.unc_from AND t2.unc_to = 'GAL'
GROUP BY t1.trc_number

INSERT INTO #tMiles (trc_number, TotalMiles)
SELECT legheader.lgh_tractor, SUM(stops.stp_lgh_mileage)
FROM (Legheader legheader with (NOLOCK) 
	INNER JOIN Stops stops with (NOLOCK) ON legheader.lgh_number = stops.lgh_number) 
INNER JOIN #tGallons t1 ON legheader.lgh_tractor = t1.trc_number
WHERE stops.stp_lgh_mileage IS NOT NULL
AND legheader.lgh_startdate >= t1.DateStart AND legheader.lgh_enddate <= t1.DateEnd
GROUP BY legheader.lgh_tractor

INSERT INTO #TractorMPG (trc_number,MPG)
SELECT t1.trc_number
,MPG =  
	CASE 
		WHEN (t2.TotalMiles / t1.TotalGallons) > @SanityCheckHighMPG THEN @DefaultMPG 
		WHEN (t2.TotalMiles / t1.TotalGallons) < @SanityCheckLowMPG THEN @DefaultMPG  
	ELSE 
		(t2.TotalMiles / t1.TotalGallons)
	END
FROM #tGallons t1 INNER JOIN #tMiles t2 ON t1.trc_number = t2.trc_number

INSERT INTO #TractorMPG (trc_number, MPG)
SELECT trc_number
,@DefaultMPG 
FROM Tractorprofile t1 with (NOLOCK)
WHERE NOT EXISTS
	(
		SELECT trc_number 
		FROM #TractorMPG 
		WHERE trc_number = t1.trc_number
	)

UPDATE #TractorMPG SET MPG = t1.trc_mpg 
FROM Tractorprofile t1 with (NOLOCK)
WHERE t1.trc_number = #TractorMPG.trc_number
AND IsNull(t1.trc_mpg, 0) between @SanityCheckLowMPG AND @SanityCheckHighMPG

--truncate table dwTractorMPG

select @Datasource
,trc_number
,MPG = IsNull(MPG,@DefaultMPG) 
from #TractorMPG T1

drop table #TractorMPG
drop table #tGallons
drop table #tMiles

GO
GRANT EXECUTE ON  [dbo].[dwTractorMPGCalculation] TO [public]
GO
