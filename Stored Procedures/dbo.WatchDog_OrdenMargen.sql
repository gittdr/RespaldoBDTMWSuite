SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_OrdenMargen] 
(
    @Modo varchar (50) = 'Margen',
    @MinThreshold float = 1,
	@MinsBack int=-20,
    @MinPorcentaje int=40,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='OrdenMargen',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@Shipper varchar(140)='',
	@Consignee varchar(140)='',
	@OrderedBy varchar(140)='',
	@BillTo varchar(140)='',
	@OrderStatus varchar(140)='',
    @BaseRevenueCategoryTLAFN char(1) ='T',
	@SubtractFuelSurchargeYN char(1) = 'N',
	@IncludeChargeTypeList varchar(255) = '', 
	@ExcludeChargeTypeList varchar(255)='',
    @PreTaxYN char(1) = NULL,
	@IncludePayTypeList varchar(255)='',
	@ExcludePayTypeList varchar(255) = '',
    @UseTravelMilesForAllocationsYN char(1) = 'Y'		
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
Set @BillTo= ',' + ISNULL(@BillTo,'') + ','
Set @Shipper= ',' + ISNULL(@Shipper,'') + ','
Set @Consignee= ',' + ISNULL(@Consignee,'') + ','
Set @OrderedBy= ',' + ISNULL(@OrderedBy,'') + ','
Set @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','


--Create SQL and return results into #TempResults


Declare @TempTriplets Table (mov_number int, lgh_number int, ord_hdrnumber int)

--Tomamos la fecha de inicio de la orden para llenar la tabla temporal de triplets
	Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
               where DateDiff(mi,ord_startdate,GetDate())>= @MinThreshold
	            AND DateDiff(mi,ord_startdate,getdate())<= -@MinsBack

--creamos tabla temporal para hacer el filtro por orden      
Declare @TempDeleteOrders Table (ord_hdrnumber int)

--le insertamos los datos que filtraremos
Insert into @TempDeleteOrders (ord_hdrnumber)
				Select TT.ord_hdrnumber
				--into @TempDeleteOrders
				From @TempTriplets TT join orderheader with (NOLOCK) on TT.ord_hdrnumber = orderheader.ord_hdrnumber	
				-- select any orders that do NOT meet the dispatch criteria
				Where CHARINDEX(',' + ord_status + ',', @OrderStatus ) = 0

				Delete from @TempTriplets where ord_hdrnumber in (select ord_hdrnumber from @TempDeleteOrders)
				--Drop Table @TempDeleteOrders

--creamos tabla temporal que tendra todos los triplets

Declare @TempAllTriplets Table
	(
		mov_number int
		,lgh_number int
		,ord_hdrnumber int
		,lgh_tractor varchar(20)
		,lgh_driver1 varchar(20)
		,lgh_driver2 varchar(20)
		,lgh_trailer1 varchar(20)
		,lgh_trailer2 varchar(20)
		,ord_totalmiles float
		,ord_startdate datetime
		,ord_completiondate datetime
		,lgh_startdate datetime
		,lgh_enddate datetime
		,LegTravelMiles float
		,LegLoadedMiles float
		,LegEmptyMiles float
		,MoveStartDate datetime
		,MoveEndDate datetime
		,CountOfOrdersOnThisLeg float
		,CountOfLegsForThisOrder float
		,GrossLegMilesForOrder float
		,GrossLDLegMilesForOrder float
		,GrossBillMilesForLeg float
	)

--insertamos los datos en la tabla temporal que tendra todos los triplets, filtrados por el exist del numero de orden

Insert into @TempAllTriplets
	(
		mov_number,lgh_number,ord_hdrnumber,lgh_tractor,lgh_driver1,lgh_driver2,lgh_trailer1,lgh_trailer2,ord_totalmiles,ord_startdate
		,ord_completiondate,lgh_startdate,lgh_enddate,LegTravelMiles,LegLoadedMiles,LegEmptyMiles,MoveStartDate,MoveEndDate,CountOfOrdersOnThisLeg
		,CountOfLegsForThisOrder,GrossLegMilesForOrder,GrossLDLegMilesForOrder,GrossBillMilesForLeg
	)
		Select mov_number
		,lgh_number
		,ord_hdrnumber
		,lgh_tractor
		,lgh_driver1
		,lgh_driver2
		,lgh_trailer1
		,lgh_trailer2
		,ord_totalmiles
		,ord_startdate
		,ord_completiondate
		,lgh_startdate
		,lgh_enddate
		,LegTravelMiles
		,LegLoadedMiles
		,LegEmptyMiles
		,MoveStartDate
		,MoveEndDate
		,CountOfOrdersOnThisLeg
		,CountOfLegsForThisOrder
		,GrossLegMilesForOrder
		,GrossLDLegMilesForOrder
		,GrossBillMilesForLeg
	from ResNow_Triplets with (NOLOCK)
	Where Exists 
		(
			Select * 
			from @TempTriplets TT 
			where TT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
		)
	-- not ALREADY in the @TempAllTriplets table
	AND NOT Exists 
		(
			Select * 
			from @TempAllTriplets TAT 
			where TAT.lgh_number = ResNow_Triplets.lgh_number
			AND TAT.mov_number = ResNow_Triplets.mov_number
			AND TAT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
		)
--Creamos la tabla temporal final leglist table de donde leeremos los datos

Declare @LegList Table
	(
		ord_hdrnumber int 
		,OrderNumber char (12)
		,MoveNumber int 
		,LegNumber int 
		,OrderedBy varchar (8)
		,BillTo varchar (8)
		,BillToName varchar (100)
		,Shipper varchar (8)
		,ShipperName varchar (100)
		,ShipperLocation varchar (30)
		,ord_origincity int 
		,ShipDate datetime 
		,Consignee varchar (8)
		,ConsigneeName varchar (100)
		,ConsigneeLocation varchar (30)
		,ord_destcity int 
		,DeliveryDate datetime
		,MoveStartDate datetime
		,LegStartDate datetime
		,LegEndDate datetime
		,MoveEndDate datetime
		,DriverID varchar (15)
        ,Lider varchar(50)
		,Tractor varchar (15)
		,Trailer varchar (15)
		,RevType1 varchar (20)
		,RevType2 varchar (20)
		,RevType3 varchar (20)
		,RevType4 varchar (20)
		,SelectedRevenue float 
		,SelectedPay float 
		,TravelMiles float 
		,LoadedMiles float
		,EmptyMiles float 
		,BillMiles float 
		,LoadCount float 
		,OrderCount float 
		,InvoiceStatus varchar (10)
		,Weight float 
		,WeightUOM varchar (10)
		,Volume float 
		,VolumeUOM varchar (10)
		,PkgCount float 
		,PkgCountUOM varchar (10)
		,LegPct float 
		,OrderPct float 
		,CurrentStatus varchar (10)
        ,Region varchar (255)
        ,Rorigen varchar (40)
        ,Rdestino varchar(40)
        ,Flota varchar (40)   
    
       
	)

-- LE insertarmos los datos a la tabla temporal final leglist

Insert into @LegList
	(
		ord_hdrnumber,OrderNumber,MoveNumber,LegNumber,OrderedBy,BillTo,BillToName,Shipper,ShipperName,ShipperLocation,ord_origincity
		,ShipDate,Consignee,ConsigneeName,ConsigneeLocation,ord_destcity,DeliveryDate,MoveStartDate,LegStartDate,LegEndDate,MoveEndDate
		,DriverID,Lider,Tractor,Trailer,RevType1,RevType2,RevType3,RevType4,SelectedRevenue,SelectedPay,TravelMiles,LoadedMiles,EmptyMiles
		,BillMiles,LoadCount,OrderCount,InvoiceStatus,Weight,WeightUOM,Volume,VolumeUOM,PkgCount,PkgCountUOM,LegPct,OrderPct,CurrentStatus,Region,Rorigen,Rdestino,Flota
	)

SELECT TT.ord_hdrnumber 
		,OrderNumber = IsNull(orderheader.ord_number,TT.ord_hdrnumber)
		,MoveNumber = TT.mov_number
		,LegNumber = TT.Lgh_number
		,OrderedBy = IsNull(orderheader.ord_company,'')
		,BillTo = IsNull(orderheader.ord_billto,'')
		,BillToName = IsNull(BillToCompany.cmp_name,'')
		,Shipper = IsNull(orderheader.ord_shipper,L.cmp_id_start)
		,ShipperName =(select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
		,ShipperLocation = IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
		,orderheader.ord_origincity
		,ShipDate = IsNull(orderheader.ord_startdate,L.lgh_startdate)
		,Consignee = IsNull(orderheader.ord_consignee,L.cmp_id_end)
		,ConsigneeName = (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
		,ConsigneeLocation = IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
		,orderheader.ord_destcity
		,DeliveryDate = IsNull(orderheader.ord_completiondate,L.lgh_enddate)
		,TAT.MoveStartDate
		,LegStartDate = TAT.lgh_startdate
		,LegEndDate = TAT.lgh_enddate
		,TAT.MoveEndDate
		,DriverID = TAT.lgh_driver1
        ,Lider = (Select  name  from  labelfile  where abbr  = (Select mpp_teamleader from manpowerprofile where mpp_id =  TAT.lgh_driver1) and labeldefinition = 'Teamleader')
		,Tractor = TAT.lgh_tractor
		,Trailer = TAT.lgh_trailer1		--= Convert(varchar(15),'')
		,RevType1 = Convert(varchar(20),IsNull(orderheader.ord_revtype1,L.lgh_class1))
		,RevType2 = Convert(varchar(20),IsNull(orderheader.ord_revtype2,L.lgh_class2))
		,RevType3 = Convert(varchar(20),IsNull(orderheader.ord_revtype3,L.lgh_class3))
		,RevType4 = Convert(varchar(20),IsNull(orderheader.ord_revtype4,L.lgh_class4))
-- revenue


		,SelectedRevenue =
         case orderheader.ord_currency when 'US$' then
         (select cex_rate from currency_exchange where cex_from_curr = 'US$'  and cex_to_curr = 'MX$' and  
         cex_date = (select max(cex_date) from currency_exchange where cex_from_curr = 'US$'  and cex_to_curr = 'MX$' ))*
         (ISNULL(dbo.fnc_TMWRN_XDRevenue('Order',0,DEFAULT,DEFAULT,TT.ord_hdrnumber,DEFAULT,DEFAULT,DEFAULT,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0))
         else
         ISNULL(dbo.fnc_TMWRN_XDRevenue('Order',0,DEFAULT,DEFAULT,TT.ord_hdrnumber,DEFAULT,DEFAULT,DEFAULT,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
         END
-- cost
		,SelectedPay = IsNull(dbo.fnc_TMWRN_Pay('Segment',default,default,L.mov_number,default,L.lgh_number,@IncludePayTypeList,@ExcludePayTypeList,@PreTaxYN,default),0.00)
-- miles
		,TravelMiles = Convert(float, LegTravelMiles) 
		,LoadedMiles = Convert(float, LegLoadedMiles)
		,EmptyMiles = Convert(float, LegEmptyMiles)
		,BillMiles = Convert(float, TAT.ord_totalmiles) -- IsNull((select sum(stp_lgh_mileage) from stops with (NOLOCK) where stops.lgh_number = l.lgh_number),0)
		,LoadCount = Convert(float,0.0)
		,OrderCount = Convert(float,1.0)
		,InvoiceStatus = ord_invoicestatus
		,Weight = Convert(float,0.0)
		,WeightUOM = 'LBS'
		,Volume = Convert(float,0.0)
		,VolumeUOM = 'GAL'
		,PkgCount = Convert(float,0.0)
		,PkgCountUOM = Convert(varchar(10),'')
		,LegPct = 
			Case when GrossBillMilesForLeg > 0 Then
				TAT.ord_totalmiles / GrossBillMilesForLeg
			Else
				Convert(float,1 / CountOfOrdersOnThisLeg)
			End
		,OrderPct = 
			Case when TT.ord_hdrnumber < 0 then
				0
			Else
				Case when @UseTravelMilesForAllocationsYN = 'Y' then
					Case when GrossLegMilesForOrder > 0 Then
						LegTravelMiles / GrossLegMilesForOrder
					Else
						Convert(float,1 / CountOfLegsForThisOrder)
					End
				Else
					Case when GrossLDLegMilesForOrder > 0 Then
						LegLoadedMiles / GrossLDLegMilesForOrder
					Else
						Convert(float,1 / CountOfLegsForThisOrder)
					End
				End
			End
		,CurrentStatus = IsNull(orderheader.ord_status,L.lgh_outstatus)
		
      ,Region = Convert(varchar(255),'')
      ,Rorigen = Convert(varchar(255),'')
      ,Rdestino =  Convert(varchar(255),'')
      ,Flota = (Select  name  from  labelfile  where abbr  = (Select trc_fleet from tractorprofile where trc_number = TAT.lgh_tractor ) and labeldefinition = 'Fleet')
   
       	
	--Into @LegList
	FROM @TempTriplets TT inner Join @TempAllTriplets TAT on TT.lgh_number = TAT.lgh_number AND TT.ord_hdrnumber = TAT.ord_hdrnumber
		inner join Legheader L with (NOLOCK) on TT.lgh_number = L.lgh_number
		inner join ResNow_DriverCache_Final DCF with (NOLOCK) on TAT.lgh_driver1 = DCF.driver_id AND TAT.lgh_startdate >= DCF.driver_DateStart AND TAT.lgh_startdate < DCF.driver_DateEnd
		inner join ResNow_TrailerCache_Final TDF with (NOLOCK) on TAT.lgh_trailer1 = TDF.trailer_id AND TAT.lgh_startdate >= TDF.trailer_DateStart AND TAT.lgh_startdate < TDF.trailer_DateEnd
		inner join ResNow_TractorCache_Final TCF with (NOLOCK) on TAT.lgh_tractor = TCF.tractor_id AND TAT.lgh_startdate >= TCF.tractor_DateStart AND TAT.lgh_startdate < TCF.tractor_DateEnd
		left Join orderheader with (NOLOCK) ON TT.ord_hdrnumber = orderheader.ord_hdrnumber
		left Join company BillToCompany with (NOLOCK) on orderheader.ord_billto = BillToCompany.cmp_id


	
 If @Modo = 'Margen'
 BEGIN

    DELETE FROM @LegList where SelectedRevenue = 0
    DELETE FROM @LegList where (100 * (((SelectedRevenue) - (SelectedPay)) /  (SelectedRevenue)) ) > @MinPorcentaje 
    
	
	if @BillTo <> ',TODOS,'
	 begin 
	  delete from @LegList where billto <>  replace(@Billto,',','')
	  	 end


     Select 	Orden = OrderNumber
       	,Cliente = BillTo
        ,Ingreso = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
		,Costo = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
		,Margen = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
        ,MargenPorCiento = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
        ,Origen = ShipperName
        ,DirOrigen = ShipperLocation
        ,Destino = ConsigneeName
        ,DirDestino = ConsigneeLocation
        
  
       into   	#TempResults
       FROM @LegList
       group by OrderNumber,BillTo,ShipperName,ShipperLocation,ConsigneeName,ConsigneeLocation
       order by OrderNumber 



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

END


 If @Modo = 'Vacios'
 BEGIN

    DELETE FROM @LegList where  substring(OrderNumber,1,1) <> '-'


     Select 	

         Orden = OrderNumber
        ,Unidad = tractor
		,Costo = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
        ,Origen = ShipperName
        ,Destino = ConsigneeName
        ,CreadoPor = Lider
        
  
       into   	#TempResults2
       FROM @LegList
       group by OrderNumber,tractor,ShipperName,ShipperLocation,ConsigneeName,ConsigneeLocation,Lider
       order by OrderNumber 


	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
	Set @SQL = 'Select * from #TempResults2'
	End
		Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults2'
	End

	Exec (@SQL)

	Set NoCount Off

END



GO
