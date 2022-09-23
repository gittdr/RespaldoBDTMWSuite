SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_CarrierLoads] 
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalCarrierLoads',
	@WatchName varchar(255)='WatchCarrierLoads',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@RevType1 varchar(255)='',
	@RevType2 varchar(255)='',
	@RevType3 varchar(255)='',
	@RevType4 varchar(255)='',
	@DispatchStatus varchar(140)='PLN,AVL,STD,DSP,CMP',
	@ThresholdLevel varchar(140) = 'Movement',
	@OnlyOriginRegion1List varchar(255) = '',
	@OnlyDestinationRegion1List varchar(255) = '',
	@ExcludeOriginRegion1List varchar(255) = '',
	@ExcludeDestinationRegion1List varchar(255) = '',
	@ExcludeBillToIDList varchar(255)='',
	@ExcludeShipperIDList varchar(255)='',
	@OnlyOriginStateList varchar(255) = '',
	@OnlyDestinationStateList varchar(255) = '',
	@ExcludeOriginStateList varchar(255) = '',
	@ExcludeDestinationStateList varchar(255) = ''
)
						

As

	Set NoCount On
	
	
	/*
	Procedure Name:    WatchDog_CarrierLoads
	Author/CreateDate: Lori Brickley / 8-8-2005
	Purpose: 	   Returns all legs which were hauled by a carrier
	Revision History:
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
	Set @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','
	Set @OnlyOriginRegion1List= ',' + ISNULL(@OnlyOriginRegion1List,'') + ','
	Set @OnlyDestinationRegion1List= ',' + ISNULL(@OnlyDestinationRegion1List,'') + ','
	Set @ExcludeOriginRegion1List= ',' + ISNULL( @ExcludeOriginRegion1List,'') + ','
	Set @ExcludeBillToIDList= ',' + ISNULL( @ExcludeBillToIDList,'') + ','
	Set @ExcludeShipperIDList= ',' + ISNULL( @ExcludeShipperIDList,'') + ','
	Set @ExcludeDestinationRegion1List= ',' + ISNULL(@ExcludeDestinationRegion1List,'') + ','
	Set @OnlyOriginStateList= ',' + ISNULL(@OnlyOriginStateList,'') + ','
	Set @OnlyDestinationStateList= ',' + ISNULL(@OnlyDestinationStateList,'') + ','
	Set @ExcludeOriginStateList= ',' + ISNULL( @ExcludeOriginStateList,'') + ','
	Set @ExcludeDestinationStateList= ',' + ISNULL(@ExcludeDestinationStateList,'') + ','
	
	Select 	legheader.ord_hdrnumber as [Order Number],
			legheader.lgh_number as [Leg Number],
	       	legheader.mov_number as [Move Number],
	       	lgh_carrier as [Carrier ID],
			lgh_tractor as [Tractor ID],
			lgh_primary_trailer as [Trailer ID],
	       	lgh_outstatus as [Status],
			c1.cty_state as [Origin State],
			c2.cty_state as [Destination State],
	       	c1.cty_region1 as [Origin Region1],
	       	c2.cty_region1 as [Destination Region1],
	       	cast((select sum(IsNull(stp_lgh_mileage,0)) from stops (NOLOCK) where stops.mov_number = legheader.mov_number) as float) as MoveMiles
	--into #LegList
	into #TempResults
	From legheader (NOLOCK) Left Join  orderheader(NOLOCK) On orderheader.ord_hdrnumber = legheader.ord_hdrnumber
		Left Join  city c1 (NOLOCK) On c1.cty_code = orderheader.ord_origincity
		Left Join  city c2 (NOLOCK) On c2.cty_code = orderheader.ord_destcity
	Where lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate())
		AND lgh_carrier <> 'UNKNOWN'
		And (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
		AND	(@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
		And (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0)
		And (@OnlyOriginRegion1List =',,' or CHARINDEX(',' + c1.cty_region1 + ',', @OnlyOriginRegion1List) >0)			
		And (@OnlyDestinationRegion1List =',,' or CHARINDEX(',' + c2.cty_region1 + ',', @OnlyDestinationRegion1List) >0)			
		And (@ExcludeOriginRegion1List = ',,' OR Not (CHARINDEX(',' + c1.cty_region1 + ',', @ExcludeOriginRegion1List) > 0)) 
		And (@ExcludeDestinationRegion1List = ',,' OR Not (CHARINDEX(',' + c2.cty_region1 + ',', @ExcludeDestinationRegion1List) > 0)) 
		And (@OnlyOriginStateList =',,' or CHARINDEX(',' + ord_originstate + ',', @OnlyOriginStateList) >0)			
		And (@OnlyDestinationStateList =',,' or CHARINDEX(',' +ord_deststate + ',', @OnlyDestinationStateList) >0)			
		And (@ExcludeOriginStateList = ',,' OR Not (CHARINDEX(',' + ord_originstate + ',', @ExcludeOriginStateList) > 0)) 
		And (@ExcludeDestinationStateList = ',,' OR Not (CHARINDEX(',' + ord_deststate + ',', @ExcludeDestinationStateList) > 0)) 
		And	(@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + orderheader.ord_billto + ',', @ExcludeBillToIDList) > 0))
		And (@ExcludeShipperIDList = ',,' OR Not (CHARINDEX(',' + orderheader.ord_shipper + ',', @ExcludeShipperIDList) > 0))
	
	
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
