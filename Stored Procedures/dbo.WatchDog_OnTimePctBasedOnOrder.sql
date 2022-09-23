SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OnTimePctBasedOnOrder] 
(
	@MinThreshold float = -1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOnTimePctBasedOnOrder',
	@WatchName varchar(255) = 'OnTimePct',
	@ThresholdFieldName varchar(255) = 'Percent',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@DaysofEmployment int = 0,
	@DaysBackToInclude int = 0,
	@OnlyDrvType1 varchar(50)='',
	@OnlyDrvType2 varchar(50)='',
	@OnlyDrvType3 varchar(50)='',
	@OnlyDrvType4 varchar(50)='',
	@OnlyReasonLateCodeList varchar(255)='',
	@MinimumLateThresholdMins int= 60

)

As

Set NoCount On

/*
Procedure Name:    WatchDog_OnTimePctBasedOnOrder
Author/CreateDate: Lori Brickley / 5-17-2005
Purpose: 	    Returns Drivers who are below the OnTimePct Threshold
Revision History:
*/

/*
if not exists (select WatchName from WatchDogItem where WatchName = 'OnTimePctBasedOnOrder')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('OnTimePctBasedOnOrder','12/30/1899','12/30/1899','WatchDog_OnTimePctBasedOnOrder','','',0,0,'','','','','',1,0,'','','')
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

SET @OnlyDrvType1= ',' + ISNULL(@OnlyDrvType1,'') + ','
SET @OnlyDrvType2= ',' + ISNULL(@OnlyDrvType2,'') + ','
SET @OnlyDrvType3= ',' + ISNULL(@OnlyDrvType3,'') + ','
SET @OnlyDrvType4= ',' + ISNULL(@OnlyDrvType4,'') + ','

DECLARE @DateStart as datetime
DECLARE @DateEnd as datetime

IF @DaysBackToInclude <> 0
BEGIN
	set @DateStart = DateAdd(d,-@DaysBackToInclude,getdate())	
	set @DateEnd = Getdate()
END
ELSE
BEGIN
	set @DateStart = DateAdd(d,-@DaysofEmployment,getdate())	
	set @DateEnd = Getdate()
END

	--Temporary Table Creation
	CREATE TABLE #TempResultsStep1 (mov_number int)

	INSERT INTO #TempResultsStep1
	SELECT DISTINCT mov_number 
	FROM orderheader (NOLOCK)
	WHERE
		ord_CompletionDate >=@DateStart AND ord_CompletionDate <@DateEnd
		AND ord_status ='CMP'

	--CREATE #ResultsTable 
	SELECT Stops.mov_number,
			OrdNumber =
			IsNull(
				(SELECT MAX(ord_number)
				FROM Orderheader (NOLOCK)
				WHERE orderheader.mov_number = stops.mov_number)
			,''),
			
			stp_event StopEvent,
			Stops.cmp_id StopCmpID,
			StopsCompanyName = IsNull(
					(SELECT cmp_name
					FROM Company StopsCompany (NOLOCK)
					WHERE stops.cmp_id=StopsCompany.cmp_id	)
				,''),
			StopCity =	(SELECT cty_nmstct
					FROM city StopsCity (NOLOCK)
					WHERE stops.stp_city=stopsCity.cty_code	),
			stp_schdtearliest	StopScheduledEarliest,
			stp_schdtlatest		StopScheduledLatest,
			stp_arrivaldate		StopArrivalDate,
			stp_departuredate	StopDeparure,
			stp_reasonlate		StopReasonLateCode,
			stp_reasonlate_depart	StopReasonLateCodeDepart,	
			Datediff(mi, stp_schdtlatest, stp_arrivaldate) MinutesScheduledArrivalVSActualArrival,
			'N' IsLateVsThreshold, 
			Driver1 = 	(SELECT lgh_driver1 
					FROM Legheader (NOLOCK) 
					WHERE stops.lgh_number=Legheader.lgh_number),
			mpp_lastname As DriverLastName,
			mpp_firstname As DriverFirstName,
			Tractor=	(SELECT lgh_tractor 
					FROM Legheader (NOLOCK) 
					WHERE stops.lgh_number=Legheader.lgh_number),
			stp_status,
			CarrierFaultYN =
				( CASE WHEN	(SELECT CODE 
						FROM LabelFile (NOLOCK) 
						WHERE stp_reasonlate = Abbr	
								AND labeldefinition = 'ReasonLate') < 101 
				THEN 'Y' 
				ELSE 'N'
				END), 
				--0 to 100 Means Our Fault - Carrier
				--101 to 200 customer's fault
				-->201 Means Noones fault
			CarrierFaultYN_Depart =
			( CASE WHEN (SELECT CODE 
						FROM LabelFile (nolock) 
						WHERE stops.stp_reasonlate_depart = Abbr 
								AND labeldefinition = 'ReasonLate') < 101 
				THEN 'Y'
			   	ELSE 'N'
				END),
		stp_mfh_sequence StopSequence
	INTO #TempResultsStep2
	FROM stops (NOLOCK), legheader (NOLOCK), manpowerprofile (NOLOCK)
	WHERE Stops.mov_number IN (SELECT mov_number FROM #TempResultsStep1 (NOLOCK))
		AND	stp_status = 'DNE'
        AND legheader.lgh_number = stops.lgh_number	
		AND manpowerprofile.mpp_id = legheader.lgh_driver1
	ORDER BY stops.Mov_number, stops.stp_mfh_sequence

	--Filter Results Based on Additional/Optional Parameters
	IF (@DaysofEmployment>0)		
	BEGIN
		Delete #TempResultsStep2
		Where Driver1 not in (	select mpp_id 
								from manpowerprofile (NOLOCK)
								where mpp_hiredate >= dateadd(d,-@DaysofEmployment,getdate())
									and mpp_hiredate <= getdate()
							)
	END

	IF (Len(@OnlyReasonLateCodeList)>2)
	BEGIN 
		DELETE #TempResultsStep2
		WHERE CHARINDEX(',' + StopReasonLateCode + ',', @OnlyReasonLateCodeList) = 0
			AND	CHARINDEX(',' + StopReasonLateCodeDepart + ',', @OnlyReasonLateCodeList) = 0
	END

	--Evaluate Late Status
	UPDATE #TempResultsStep2
		SET IsLateVsThreshold ='Y'
		WHERE MinutesScheduledArrivalVSActualArrival > @MinimumLateThresholdMins
	

	SELECT Driver1 as [Driver], DriverLastName, DriverFirstName, OrdNumber, sum(case islatevsthreshold when 'N' then 1 else 0 end) as OnTime,
		sum(case islatevsthreshold when 'Y' then 1 else 1 end) as Total,
		0 as EmploymentDays
	INTO #TempResultsStep3
	FROM #TempResultsStep2
	Group by Driver1, DriverLastName, DriverFirstName, OrdNumber

	SELECT [Driver], DriverLastName, DriverFirstName, sum(case when OnTime = Total then 1 else 0 end) as OnTime,
		sum(1) as Total, EmploymentDays
	INTO #TempResultsStep4
	From #TempResultsStep3
	Group by Driver, DriverLastName, DriverFirstName, EmploymentDays

	update #TempResultsStep4
	set EmploymentDays = (	Select isNull(DateDiff(d,mpp_hiredate,getdate()),0) --PTS 37183
							from manpowerprofile (NOLOCK)
							where Driver = mpp_id
						) 

	SELECT [Driver], DriverLastName,DriverFirstName,
			cast((ISnull(cast(OnTime as decimal(10,2)),0)/Isnull(cast(Total as decimal(10,2)),0))*100 as decimal(10,2)) as [On Time Pct],
			Total as [Total Orders],
			Ontime as [Total On Time Orders],
			EmploymentDays
	into #TempResults
	from #TempResultsStep4
	where total >0
		AND cast((ISnull(cast(OnTime as decimal(10,2)),0)/Isnull(cast(Total as decimal(10,2)),0))*100 as decimal(10,2)) <= @MinThreshold
	order by cast((ISnull(cast(OnTime as decimal(10,2)),0)/Isnull(cast(Total as decimal(10,2)),0))*100 as decimal(10,2))
			

/*
select 	mpp_id as [Driver ID],
		mpp_firstname as [First Name],
		mpp_lastname as [Last Name],
		mpp_hiredate as [Hire Date]
		--cast(cast(month(mpp_hiredate) as varchar(2))+ '/' + cast(day(mpp_hiredate) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime) as [Anniversary Date],
		--datediff(yyyy,mpp_hiredate,cast(cast(month(mpp_hiredate) as varchar(2))+ '/' + cast(day(mpp_hiredate) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) as [Upcoming Anniversary Year]
into #TempResults
from manpowerprofile
WHERE 	mpp_terminationdt>getdate()
	AND (@OnlyDrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1) >0)
	AND (@OnlyDrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2) >0)
	AND	(@OnlyDrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3) >0)
	AND	(@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4) >0)
	AND	dateadd(day, @MinThreshold, mpp_hiredate) >= getdate()
	AND dateadd(day, @MinThreshold, mpp_hiredate) <= dateadd(day,@NotificationDays,getdate())
		
order by mpp_hiredate
*/
--Commits the results to be used in the wrapper
If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1

Begin
	Set @SQL = 'Select * from #TempResults'
End
Else
Begin
	Set @COLSQL = ''
	Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
End

Exec (@SQL)

Set NoCount Off

GO
GRANT EXECUTE ON  [dbo].[WatchDog_OnTimePctBasedOnOrder] TO [public]
GO
