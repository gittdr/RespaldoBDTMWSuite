SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewCarriers] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewCarriers',
	@WatchName varchar(255) = 'NewCarriers',
	@ThresholdFieldName varchar(255) = 'NewCarriers',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@CarType1 varchar(140)='',
	@CarType2 varchar(140)='',
	@CarType3 varchar(140)='',
	@CarType4 varchar(140)='',
	@CarrierID varchar(140)=''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_NewCarriers
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	    

	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @CarType1= ',' + RTrim(ISNULL(@CarType1,'')) + ','
	Set @CarType2= ',' + RTrim(ISNULL(@CarType2,'')) + ','
	Set @CarType3= ',' + RTrim(ISNULL(@CarType3,'')) + ','
	Set @CarType4= ',' + RTrim(ISNULL(@CarType4,'')) + ','
	Set @CarrierID= ',' + RTrim(ISNULL(@CarrierID,'')) + ','

	select car_id as [Carrier ID],
		car_name as [Carrier],
		car_updatedby as [Updated By],
		car_createdate as [Date Created],
		car_type1 as [CarType1],
		car_type2 as [CarType2],
		car_type3 as [CarType3],
		car_type4 as [CarType4]
	into   #TempResults	
	From   carrier (NOLOCK)
	where  car_createdate >= DateAdd(mi,@MinsBack,GetDate())
		And (@CarType1 =',,' or CHARINDEX(',' + car_type1 + ',', @CarType1) >0)
		AND (@CarType2 =',,' or CHARINDEX(',' + car_type2 + ',', @CarType2) >0)
		AND (@CarType3 =',,' or CHARINDEX(',' + car_type3 + ',', @CarType3) >0)
		AND (@CarType4 =',,' or CHARINDEX(',' + car_type4 + ',', @CarType4) >0)
		And (@CarrierID =',,' or CHARINDEX(',' + car_id + ',', @CarrierID) >0)
		  
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
