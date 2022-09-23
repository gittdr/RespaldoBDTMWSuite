SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrdersNotStartedAndLate] 
(
	--Standard Parameters
	@MinThreshold float = 0,
	@MinsBack int=0,
	@TempTableName varchar(255)='##WatchDogGlobalOrdersNotStartedAndLate',
	@WatchName varchar(255) = 'OrdersNotStartedAndLate',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@LegOutStatus VARCHAR(255)='PLN,DSP',
	@RevType1 varchar(140)='',
    @RevType2 varchar(140)='',
    @RevType3 varchar(140)='',
    @RevType4 varchar(140)='',
	@DrvType1 varchar(140)='',
	@DrvType2 varchar(140)='',
	@DrvType3 varchar(140)='',
	@DrvType4 varchar(140)='',
	@OnlyDrvAtDomicileYN varchar(140)='N',
	@ParameterToUseForDynamicEmail varchar(255)=''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_OrdersNotStartedAndLate
	Author/CreateDate: Lori Brickley / 10-20-2005
	Purpose: 	   Returns All Orders which are not started and 
					are beyond the start date/time by more than
					x minutes
	Revision History:
	*/


	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @DrvType1= ',' + RTrim(ISNULL(@DrvType1,'')) + ','
	Set @DrvType2= ',' + RTrim(ISNULL(@DrvType2,'')) + ','
	Set @DrvType3= ',' + RTrim(ISNULL(@DrvType3,'')) + ','
	Set @DrvType4 = ',' + RTrim(ISNULL(@DrvType4 ,'')) + ','

	Set @LegOutStatus = ',' + RTRIM(ISNULL(@LegOutStatus, '')) + ','
	
	select t1.ord_number as [Order #],
		t1.mov_number as [Move #],
		t2.cmp_id_start as [Leg Start Company],
		t1.ord_startdate as [Ship Date],
		t2.lgh_startdate as [Leg Start Date],
		t2.lgh_outstatus as [Leg Out Status],
		t1.ord_completiondate as [Est Delivery Date],
		t1.ord_shipper as [Shipper ID],
		t1.ord_originregion1 as [Origin Region],
		IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin City],
		IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin State],
		t1.ord_consignee as [Consignee ID],
		IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination City],
		IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination State],
		IsNull((select cmp_name from company (NOLOCK) Where cmp_id = t1.ord_billto),'') as [BillTo],
		t1.ord_billto as [BillTo ID],
		t1.ord_tractor as [Tractor ID],
		t2.lgh_driver1 as [Driver ID],
		t1.ord_revtype1 as RevType1,
		t1.ord_revtype2 as RevType2,
		t1.ord_revtype3 as RevType3,
		t1.ord_revtype4 as RevType4,
		t1.ord_priority,
		ord_status AS OrderStatus,
		t1.ord_bookedby as BookedBy,
		EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,t1.ord_bookedby),''),
		[Driver Name]= (select left(mpp_lastname,10) + ',' + ISNULL(mpp_firstname,'') from manpowerprofile (NOLOCK) Where mpp_id = t2.lgh_driver1) 
	INTO   #TempResults3
	From  Legheader t2 (NOLOCK)
	JOIN orderheader t1 (NOLOCK) ON  t1.ord_hdrnumber = t2.ord_hdrnumber
	JOIN Manpowerprofile t3 (NOLOCK) ON t2.lgh_driver1 = t3.mpp_id
	where   dateadd(mi,@MinThreshold,t2.lgh_startdate) <= getdate()
		AND t2.lgh_startdate < getdate()
		AND (@LegOutStatus =',,' or CHARINDEX(',' + t2.lgh_outstatus + ',', @LegOutStatus) >0)
		AND (@RevType1 =',,' or CHARINDEX(',' + t1.ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + t1.ord_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + t1.ord_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + t1.ord_revtype4 + ',', @RevType4) >0)
		AND (@DrvType1 =',,' or CHARINDEX(',' + t3.Mpp_Type1 + ',', @DrvType1) >0)
		AND (@DrvType2 =',,' or CHARINDEX(',' + t3.Mpp_Type2 + ',', @DrvType2) >0)
		AND (@DrvType3 =',,' or CHARINDEX(',' + t3.Mpp_Type3 + ',', @DrvType3) >0)
		AND (@DrvType4 =',,' or CHARINDEX(',' + t3.Mpp_Type4 + ',', @DrvType4) >0)
		--AND (ISNULL(t2.lgh_tractor, 'UNKNOWN') = 'UNKNOWN' OR ISNULL(t2.lgh_driver1, 'UNKNOWN') = 'UNKNOWN')
	order by t1.ord_startdate
		

		SELECT * 
		INTO #TempResults
		from #TempResults3
		WHERE 	(
					@OnlyDrvAtDomicileYN ='Y'
					AND 
					[Leg Start Company] = (select mpp_type1 from manpowerprofile (nolock) where mpp_id = [Driver ID])
				)
				OR
				(@OnlyDrvAtDomicileYN ='N')

	
		
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	BEGIN
			Set @SQL = 'Select * from #TempResults'
	END
	ELSE
	BEGIN
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End

	Exec (@SQL)

	Set NoCount Off

GO
GRANT EXECUTE ON  [dbo].[WatchDog_OrdersNotStartedAndLate] TO [public]
GO
