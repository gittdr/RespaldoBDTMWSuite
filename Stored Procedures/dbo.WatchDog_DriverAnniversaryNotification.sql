SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DriverAnniversaryNotification] 
(
	@MinThreshold float = -1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalDriverAnniversaryNotification',
	@WatchName varchar(255) = 'DriverAnniversaryNotification',
	@ThresholdFieldName varchar(255) = 'Years',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyDrvType1 varchar(50)='',
	@OnlyDrvType2 varchar(50)='',
	@OnlyDrvType3 varchar(50)='',
	@OnlyDrvType4 varchar(50)='',
	@Mode varchar(20) = 'Month' ,
	@ParameterToUseForDynamicEmail varchar(140)='',
	@OnlyDrvTerminal varchar(128)='',
	@OnlyDrvDivision varchar(128) =''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_DriverAnniversaryNotification
	Author/CreateDate: Lori Brickley / 4-13-2005
	Purpose: 	    Returns Drivers who are celebrating an anniversary
					notifies x days in advance
	Revision History:
	*/

	/*

	if not exists (select WatchName from WatchDogItem where WatchName = 'DriverAnniversaryNotification')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	VALUES ('DriverAnniversaryNotification','12/30/1899','12/30/1899','WatchDog_DriverAnniversaryNotification','','',0,0,'','','','','',1,0,'','','')

	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	SET @OnlyDrvType1= ',' + ISNULL(@OnlyDrvType1,'') + ','
	SET @OnlyDrvType2= ',' + ISNULL(@OnlyDrvType2,'') + ','
	SET @OnlyDrvType3= ',' + ISNULL(@OnlyDrvType3,'') + ','
	SET @OnlyDrvType4= ',' + ISNULL(@OnlyDrvType4,'') + ','
	SET @OnlyDrvTerminal= ',' + ISNULL(@OnlyDrvTerminal,'') + ','
	SET @OnlyDrvDivision= ',' + ISNULL(@OnlyDrvDivision,'') + ','
	
	select mpp_id,
			mpp_firstname,
			mpp_lastname,
			ISNULL(mpp_hiredate,getdate()) as [Hire Date],
			ISNULL(mpp_hiredate,getdate()) as [Adjusted Hire Date],
			EmailSend = dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, mpp_company,mpp_division, mpp_domicile, default, mpp_type1,mpp_type2,mpp_type3, mpp_type4,default,default,default,default,default, mpp_teamleader, mpp_terminal,default, default, default,default,default, default,default,default,default,default,default),
			mpp_terminal,
			mpp_division
 --TeamLeaderEmail
	into #TempREsultsStep1a
	from manpowerprofile (NOLOCK)
	WHERE mpp_terminationdt>getdate()
		AND mpp_hiredate is not null
		AND (@OnlyDrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1) >0)
		AND (@OnlyDrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2) >0)
		AND	(@OnlyDrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3) >0)
		AND	(@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4) >0)
		AND	(@OnlyDrvTerminal =',,' or CHARINDEX(',' + mpp_terminal + ',', @OnlyDrvTerminal) >0)
		AND	(@OnlyDrvDivision =',,' or CHARINDEX(',' + mpp_division + ',', @OnlyDrvDivision) >0)
		
	UPDATE #TempResultsStep1a
		SET [Adjusted Hire Date] = DATEADD(day,-1,[Hire Date])
	WHERE DatePart(day,[Hire Date])=29 
		AND DatePart(month,[Hire Date])=2	

	select 	mpp_id as [Driver ID],
			mpp_firstname as [First Name],
			mpp_lastname as [Last Name],
			[Hire Date],
			[Adjusted Hire Date],
			cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime) as [Anniversary Date],
			datediff(yyyy,[Adjusted Hire Date],cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) as [Upcoming Anniversary Year],
			EmailSend,
			mpp_terminal as [Terminal],
			mpp_division as [Driver]
 
	into #TempResultsStep1
	from #TempResultsStep1a
	WHERE 	
		  (
				(
					@Mode = 'Month'
						AND
			
					(
					dateadd(d,0,cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) >= getdate()
					AND dateadd(d,0,cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) < dateadd(d,30,getdate())
					)
				)
			OR
				(
					@Mode = 'Year'
				)
			OR
				(
					@Mode = 'Quarter'
						AND
			
					(
					dateadd(d,0,cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) >= getdate()
					AND dateadd(d,0,cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) < dateadd(d,90,getdate())
					)
				)

			)
	order by cast(cast(month([Adjusted Hire Date]) as varchar(2))+ '/' + cast(day([Adjusted Hire Date]) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)


	IF @MinThreshold <> -1
		DELETE from #TempResultsStep1 where [Upcoming Anniversary Year] <> @MinThreshold


		select * into #tempresults
		from #tempresultsstep1
		order by [Upcoming Anniversary Year] desc ,[Anniversary Date]

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
