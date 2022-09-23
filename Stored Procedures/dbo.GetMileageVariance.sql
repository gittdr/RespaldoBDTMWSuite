SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[GetMileageVariance] @startdate datetime, @enddate datetime, @tractorlist varchar(14)

AS

--SELECT @StartDate = '06/30/01'
--SELECT @EndDate = '08/30/01'
--SELECT @TractorList = '5101'
--drop table #tmp1

SELECT ckc_lghnumber lgh_number, MIN(ckc_tractor) Tractor, min(ckc_odometer) FirstOdometer, 
		max(ckc_odometer) LastOdometer, min(ckc_date) FirstOdometerDate, min(ckc_date) LastOdometerDate 
INTO #tmp1 
FROM checkcall (NOLOCK)
WHERE ckc_date >= @StartDate and ckc_date < dateadd(d, 1, @EndDate) and (isnull(@TractorList, '') = '' or ckc_Tractor in (@TractorList)) and isnull(ckc_odometer, 0) <> 0
GROUP BY ckc_lghnumber

SELECT sum(isnull(stp_lgh_mileage, 0)) ExpectedMileage, max(LastOdometer) - min(FirstOdometer) ActualMileage, 
	CONVERT(Decimal(8,2), CONVERT(real, (max(LastOdometer) - min(FirstOdometer)-sum(isnull(stp_lgh_mileage, 0))))/sum(isnull(stp_lgh_mileage, 0))*100) Variance, 
	Tractor, MIN(FirstOdometer) FirstOdometer, Max(LastOdometer) LastOdometer, min(FirstOdometerDate) FirstOdometerDate, max(LastOdometerDate) LastOdometerDate, 
	min(stp_departuredate) FirstStopDate, max(stp_arrivaldate) LastStopDate
FROM stops (NOLOCK)
inner join #tmp1 (NOLOCK) on stops.lgh_number = #tmp1.lgh_number 
WHERE stp_departuredate >= @StartDate and stp_arrivaldate <= @EndDate 
GROUP BY Tractor

GO
GRANT EXECUTE ON  [dbo].[GetMileageVariance] TO [public]
GO
