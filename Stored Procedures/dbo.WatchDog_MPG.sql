SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_MPG] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalMilesPerGallon',
	@WatchName varchar(255)='MPG',
	@ThresholdFieldName varchar(255) = 'MPG',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@BeginDate datetime = Null,
	@EndDate datetime = Null,
	@BeginDateDaysBack int = Null,
	@EndDateDaysBack int = Null,
	@TrcType1 varchar(140)='',
	@TrcType2 varchar(140)='',
	@TrcType3 varchar(140)='',
	@TrcType4 varchar(140)='',
	@DispatchStatus varchar(140)='CMP',
	@DateType varchar(40) ='Start',
	@UnitofMeasure varchar(150) = 'GAL'	 
	)
						
As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_MPG
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   
	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
	Set @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
	Set @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
	Set @TrcType4= ',' + ISNULL(@TrcType4,'') + ','
	Set @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','

	--Resolve the Begin and End Dates if they are not passed in
	If @BeginDate Is Null
	Begin
		Set @BeginDate = cast(floor(cast(getdate() as float)) as datetime)
		If @BeginDateDaysBack Is Null
		Begin
			--go back to previous month
			Set @BeginDate = dateadd(month,-1,getdate())
			--and set date to first day of the month
			Set @BeginDate =	cast(cast(DatePart(yyyy,@BeginDate) as char(4)) + 
								Case When len(cast(DatePart(mm,@BeginDate) as varchar(2))) < 2 
									Then '0' + cast(DatePart(mm,@BeginDate) as char(1)) 
								Else cast(DatePart(mm,@BeginDate) as char(2)) 
								End + '01' as datetime)						
		End
		Else
		Begin
		 	Set @BeginDate = @BeginDate - @BeginDateDaysBack
	    End
	End

	If @EndDate Is Null
	Begin
		Set @EndDate = cast(floor(cast(getdate() as float)) as datetime)
		If @EndDateDaysBack Is Null
		Begin
			--set to first day of current month	
			--will just pull everything prior to this date
			--in the where clause
			Set @EndDate =	cast(cast(DatePart(yyyy,@EndDate) as char(4)) + 
							Case When len(cast(DatePart(mm,@EndDate) as varchar(2))) < 2 
								Then '0' + cast(DatePart(mm,@EndDate) as char(1)) 
							Else cast(DatePart(mm,@EndDate) as char(2)) 
							End + '01' as datetime)
		End
		Else
		Begin
			Set @EndDate = @EndDate - @EndDateDaysBack
		End
	End
	Else
	Begin
		Set @EndDate = @EndDate + 1 --Set the End Date to be the next day
						--Are Date Restriction
						--says < @EndDate
	End
	
	--Create SQL and return results into #TempResults
	Select	lgh_tractor as Tractor,
			sum(IsNull(stp_lgh_mileage,0)) as Miles   
	into   #TempTractors
	From   legheader (NOLOCK),stops (NOLOCK)
	Where stops.lgh_number = legheader.lgh_number
		And (@TrcType1 =',,' or CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
		AND (@TrcType2 =',,' or CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
		AND (@TrcType3 =',,' or CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
		AND (@TrcType4 =',,' or CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
		And (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0)
		And (
				(@DateType='Start'  and  lgh_startdate >= @begindate and lgh_startdate < @enddate )
				OR
				(@DateType='Arrival' and stp_arrivaldate >= @begindate and stp_arrivaldate < @enddate )
			)           
		And (
				(@ColumnNamesOnly = 1 And 1=0)
				OR
				(@ColumnNamesOnly = 0)
			)
	group by lgh_tractor

	--Store the fuel gallons purchased
	select   trc_number,
			Convert(Decimal(7,2), (sum((IsNull(fp_quantity,0) * IsNull(unc_factor,1))))) as FuelQuantity
	into     #TempFuelPurchased
	from     fuelpurchased (NOLOCK) Left Join unitconversion (NOLOCK) On fp_uom = unc_from and @UnitOfMeasure = unc_to and unc_convflag = 'Q'
	where fp_date >= @begindate and fp_date < @enddate
		And fp_fueltype = 'DSL'
	Group By trc_number

	Select TempMPG.*
	into   #TempResults
	From	(	select Tractor,
				Miles,
				FuelQuantity,
				Convert(Decimal(4,2), (Case When FuelQuantity = 0 Then 0 Else Miles/FuelQuantity End)) as MPG
				From   #TempFuelPurchased,#TempTractors
				Where  [Tractor] = trc_number
			) as TempMPG
	Where MPG < @MinThreshold
	Order By Tractor

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
GRANT EXECUTE ON  [dbo].[WatchDog_MPG] TO [public]
GO
