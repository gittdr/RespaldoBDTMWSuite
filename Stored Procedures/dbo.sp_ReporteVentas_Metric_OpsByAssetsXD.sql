SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










-- Part 2
--drop Proc Metric_OpsByAssetsXD_ReporteVentas

CREATE  PROCEDURE [dbo].[sp_ReporteVentas_Metric_OpsByAssetsXD]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
	-- Additional / Optional Parameters
		@DateType varchar(50) = 'MoveStart',			-- MoveStart,MoveEnd,LegStart,LegEnd,OrderStart,OrderEnd,BookDate
		@Numerator varchar(20) = 'Margin',				-- Revenue,Cost,Margin,TravelMile,LoadedMile,EmptyMile,BillMile,LoadCount,OrderCount,Weight,Volume
		@Denominator varchar(20) = 'Revenue',			-- Revenue,Cost,TravelMile,LoadedMile,EmptyMile,BillMile,Day,LoadCount,OrderCount,Weight,Volume,TractorCount,DriverCount,TrailerCount
		@TypeOfTractorCount varchar(10) = 'Working',	-- Current, Seated, Unseated, Working, Total, OOS, Historical
		@TypeOfDriverCount varchar(10) = 'Working',		-- Current, Working, Total, OOS, Historical
		@TypeOfTrailerCount varchar(10) = 'Working',	-- Current, Working, Total, OOS, Historical
		@EliminateCarrierLoadsYN char(1) = 'Y',
		@UseTravelMilesForAllocationsYN char(1) = 'Y',	
	-- revenue related parameters
		@InvoiceStatusList varchar(128) = '',
		@DispatchStatusList varchar(255) = '',
		@IncludeMiscInvoicesYN char(1) = 'N',
		@ExcludeZeroRatedInvoicesYN char(1) = 'N',
		@BaseRevenueCategoryTLAFN char(1) ='T',
		@SubtractFuelSurchargeYN char(1) = 'N',
		@IncludeChargeTypeList varchar(255) = '', 
		@ExcludeChargeTypeList varchar(255)='',		 
	-- cost related parameters
		@PreTaxYN char(1) = NULL,
		@IncludePayTypeList varchar(255)='',
		@ExcludePayTypeList varchar(255) = '',
	-- freight related parameters
		@WeightUOM varchar(10) = 'TON',
		@VolumeUOM varchar(10) = 'GAL',
	-- filtering parameters: revtypes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
	-- filtering parameters: includes
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',

		@OnlyDrvType1List varchar(255) = '',
		@OnlyDrvType2List varchar(255) = '',
		@OnlyDrvType3List varchar(255) = '',
		@OnlyDrvType4List varchar(255) = '',
		@OnlyDrvCompanyList varchar(255) = '',
		@OnlyDrvDivisionList varchar(255) = '',
		@OnlyDrvTerminalList varchar(255) = '',
		@OnlyDrvFleetList varchar(255) = '',
		@OnlyDrvBranchList varchar(255) = '',
		@OnlyDrvDomicileList varchar(255) = '',
		@OnlyDrvTeamleaderList varchar(255) = '',

		@OnlyTrcType1List varchar(255) = '',
		@OnlyTrcType2List varchar(255) = '',
		@OnlyTrcType3List varchar(255) = '',
		@OnlyTrcType4List varchar(255) = '',
		@OnlyTrcCompanyList varchar(255) = '',
		@OnlyTrcDivisionList varchar(255) = '',
		@OnlyTrcTerminalList varchar(255) = '',
		@OnlyTrcFleetList varchar(255) = '',
		@OnlyTrcBranchList varchar(255) = '',

		@OnlyTrlType1List varchar(255) = '',
		@OnlyTrlType2List varchar(255) = '',
		@OnlyTrlType3List varchar(255) = '',
		@OnlyTrlType4List varchar(255) = '',
		@OnlyTrlCompanyList varchar(255) = '',
		@OnlyTrlDivisionList varchar(255) = '',
		@OnlyTrlTerminalList varchar(255) = '',
		@OnlyTrlFleetList varchar(255) = '',
		@OnlyTrlBranchList varchar(255) = '',

	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',
		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',

		@ExcludeDrvType1List varchar(255) = '',
		@ExcludeDrvType2List varchar(255) = '',
		@ExcludeDrvType3List varchar(255) = '',
		@ExcludeDrvType4List varchar(255) = '',
		@ExcludeDrvCompanyList varchar(255) = '',
		@ExcludeDrvDivisionList varchar(255) = '',
		@ExcludeDrvTerminalList varchar(255) = '',
		@ExcludeDrvFleetList varchar(255) = '',
		@ExcludeDrvBranchList varchar(255) = '',
		@ExcludeDrvDomicileList varchar(255) = '',
		@ExcludeDrvTeamleaderList varchar(255) = '',

		@ExcludeTrcType1List varchar(255) = '',
		@ExcludeTrcType2List varchar(255) = '',
		@ExcludeTrcType3List varchar(255) = '',
		@ExcludeTrcType4List varchar(255) = '',
		@ExcludeTrcCompanyList varchar(255) = '',
		@ExcludeTrcDivisionList varchar(255) = '',
		@ExcludeTrcTerminalList varchar(255) = '',
		@ExcludeTrcFleetList varchar(255) = '',
		@ExcludeTrcBranchList varchar(255) = '',

		@ExcludeTrlType1List varchar(255) = '',
		@ExcludeTrlType2List varchar(255) = '',
		@ExcludeTrlType3List varchar(255) = '',
		@ExcludeTrlType4List varchar(255) = '',
		@ExcludeTrlCompanyList varchar(255) = '',
		@ExcludeTrlDivisionList varchar(255) = '',
		@ExcludeTrlTerminalList varchar(255) = '',
		@ExcludeTrlFleetList varchar(255) = '',
		@ExcludeTrlBranchList varchar(255) = '',

	-- parameters for Tractor Count ONLY
		@TrcCountOnlyTrcType1List varchar(255) = '',
		@TrcCountOnlyTrcType2List varchar(255) = '',
		@TrcCountOnlyTrcType3List varchar(255) = '',
		@TrcCountOnlyTrcType4List varchar(255) = '',
		@TrcCountOnlyTrcCompanyList varchar(255) = '',
		@TrcCountOnlyTrcDivisionList varchar(255) = '',
		@TrcCountOnlyTrcTerminalList varchar(255) = '',
		@TrcCountOnlyTrcFleetList varchar(255) = '',
		@TrcCountOnlyTrcBranchList varchar(255) = '',

		@TrcCountExcludeTrcType1List varchar(255) = '',
		@TrcCountExcludeTrcType2List varchar(255) = '',
		@TrcCountExcludeTrcType3List varchar(255) = '',
		@TrcCountExcludeTrcType4List varchar(255) = '',
		@TrcCountExcludeTrcCompanyList varchar(255) = '',
		@TrcCountExcludeTrcDivisionList varchar(255) = '',
		@TrcCountExcludeTrcTerminalList varchar(255) = '',
		@TrcCountExcludeTrcFleetList varchar(255) = '',
		@TrcCountExcludeTrcBranchList varchar(255) = '',

	-- parameters for Driver Count ONLY
		@DrvCountOnlyDrvType1List varchar(255) = '',
		@DrvCountOnlyDrvType2List varchar(255) = '',
		@DrvCountOnlyDrvType3List varchar(255) = '',
		@DrvCountOnlyDrvType4List varchar(255) = '',
		@DrvCountOnlyDrvCompanyList varchar(255) = '',
		@DrvCountOnlyDrvDivisionList varchar(255) = '',
		@DrvCountOnlyDrvTerminalList varchar(255) = '',
		@DrvCountOnlyDrvFleetList varchar(255) = '',
		@DrvCountOnlyDrvBranchList varchar(255) = '',
		@DrvCountOnlyDrvDomicileList varchar(255) = '',
		@DrvCountOnlyDrvTeamleaderList varchar(255) = '',

		@DrvCountExcludeDrvType1List varchar(255) = '',
		@DrvCountExcludeDrvType2List varchar(255) = '',
		@DrvCountExcludeDrvType3List varchar(255) = '',
		@DrvCountExcludeDrvType4List varchar(255) = '',
		@DrvCountExcludeDrvCompanyList varchar(255) = '',
		@DrvCountExcludeDrvDivisionList varchar(255) = '',
		@DrvCountExcludeDrvTerminalList varchar(255) = '',
		@DrvCountExcludeDrvFleetList varchar(255) = '',
		@DrvCountExcludeDrvBranchList varchar(255) = '',
		@DrvCountExcludeDrvDomicileList varchar(255) = '',
		@DrvCountExcludeDrvTeamleaderList varchar(255) = '',

	-- parameters for Trailer Count ONLY
		@TrlCountOnlyTrlType1List varchar(255) = '',
		@TrlCountOnlyTrlType2List varchar(255) = '',
		@TrlCountOnlyTrlType3List varchar(255) = '',
		@TrlCountOnlyTrlType4List varchar(255) = '',
		@TrlCountOnlyTrlCompanyList varchar(255) = '',
		@TrlCountOnlyTrlDivisionList varchar(255) = '',
		@TrlCountOnlyTrlTerminalList varchar(255) = '',
		@TrlCountOnlyTrlFleetList varchar(255) = '',
		@TrlCountOnlyTrlBranchList varchar(255) = '',

		@TrlCountExcludeTrlType1List varchar(255) = '',
		@TrlCountExcludeTrlType2List varchar(255) = '',
		@TrlCountExcludeTrlType3List varchar(255) = '',
		@TrlCountExcludeTrlType4List varchar(255) = '',
		@TrlCountExcludeTrlCompanyList varchar(255) = '',
		@TrlCountExcludeTrlDivisionList varchar(255) = '',
		@TrlCountExcludeTrlTerminalList varchar(255) = '',
		@TrlCountExcludeTrlFleetList varchar(255) = '',
		@TrlCountExcludeTrlBranchList varchar(255) = '',

		@MetricCode varchar(255)= 'OpsByAssetsXD'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:CRN,2:Terminal,3:Proyecto,4:Division,5:Operador,6:Tractor,7:Viajes,8:Lider,9:Orden,10:RegionPromedio,11:Cliente,12:Flota

	--Populate DEFAULT currency and currency date types
	EXEC PopulateSessionIDParamatersInProc 'Revenue', @MetricCode  

	If DateDiff(mi,IsNull((Select MAX(DateLastRefresh) from ResNow_TripletsLastRefresh),'19500101'),GetDate()) > 65
		Begin
			exec ResNow_UpdateTripletsAssets
		End
--	Else 
--		Select DateDiff(mi,IsNull((Select DateLastRefresh from ResNow_TripletsLastRefresh),'19500101'),GetDate())

	Declare @TractorCount int
	Declare @TrailerCount int
	Declare @DriverCount int

	SET @InvoiceStatusList = ',' + ISNULL(@InvoiceStatusList,'') + ','
	Set @DispatchStatusList= ',' + ISNULL(@DispatchStatusList,'') + ','

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','

	Set @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	Set @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	Set @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	Set @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','
	Set @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	Set @OnlyDrvDivisionList= ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	Set @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	Set @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	Set @OnlyDrvBranchList= ',' + ISNULL(@OnlyDrvBranchList,'') + ','
	Set @OnlyDrvDomicileList= ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	Set @OnlyDrvTeamLeaderList= ',' + ISNULL(@OnlyDrvTeamLeaderList,'') + ','

	Set @OnlyTrcType1List= ',' + ISNULL(@OnlyTrcType1List,'') + ','
	Set @OnlyTrcType2List= ',' + ISNULL(@OnlyTrcType2List,'') + ','
	Set @OnlyTrcType3List= ',' + ISNULL(@OnlyTrcType3List,'') + ','
	Set @OnlyTrcType4List= ',' + ISNULL(@OnlyTrcType4List,'') + ','
	Set @OnlyTrcCompanyList= ',' + ISNULL(@OnlyTrcCompanyList,'') + ','
	Set @OnlyTrcDivisionList= ',' + ISNULL(@OnlyTrcDivisionList,'') + ','
	Set @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	Set @OnlyTrcFleetList= ',' + ISNULL(@OnlyTrcFleetList,'') + ','
	Set @OnlyTrcBranchList= ',' + ISNULL(@OnlyTrcBranchList,'') + ','

	Set @OnlyTrlType1List= ',' + ISNULL(@OnlyTrlType1List,'') + ','
	Set @OnlyTrlType2List= ',' + ISNULL(@OnlyTrlType2List,'') + ','
	Set @OnlyTrlType3List= ',' + ISNULL(@OnlyTrlType3List,'') + ','
	Set @OnlyTrlType4List= ',' + ISNULL(@OnlyTrlType4List,'') + ','
	Set @OnlyTrlCompanyList= ',' + ISNULL(@OnlyTrlCompanyList,'') + ','
	Set @OnlyTrlDivisionList= ',' + ISNULL(@OnlyTrlDivisionList,'') + ','
	Set @OnlyTrlTerminalList= ',' + ISNULL(@OnlyTrlTerminalList,'') + ','
	Set @OnlyTrlFleetList= ',' + ISNULL(@OnlyTrlFleetList,'') + ','
	Set @OnlyTrlBranchList= ',' + ISNULL(@OnlyTrlBranchList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	Set @ExcludeDrvType1List= ',' + ISNULL(@ExcludeDrvType1List,'') + ','
	Set @ExcludeDrvType2List= ',' + ISNULL(@ExcludeDrvType2List,'') + ','
	Set @ExcludeDrvType3List= ',' + ISNULL(@ExcludeDrvType3List,'') + ','
	Set @ExcludeDrvType4List= ',' + ISNULL(@ExcludeDrvType4List,'') + ','
	Set @ExcludeDrvCompanyList= ',' + ISNULL(@ExcludeDrvCompanyList,'') + ','
	Set @ExcludeDrvDivisionList= ',' + ISNULL(@ExcludeDrvDivisionList,'') + ','
	Set @ExcludeDrvTerminalList= ',' + ISNULL(@ExcludeDrvTerminalList,'') + ','
	Set @ExcludeDrvFleetList= ',' + ISNULL(@ExcludeDrvFleetList,'') + ','
	Set @ExcludeDrvBranchList= ',' + ISNULL(@ExcludeDrvBranchList,'') + ','
	Set @ExcludeDrvDomicileList= ',' + ISNULL(@ExcludeDrvDomicileList,'') + ','
	Set @ExcludeDrvTeamLeaderList= ',' + ISNULL(@ExcludeDrvTeamLeaderList,'') + ','

	Set @ExcludeTrcType1List= ',' + ISNULL(@ExcludeTrcType1List,'') + ','
	Set @ExcludeTrcType2List= ',' + ISNULL(@ExcludeTrcType2List,'') + ','
	Set @ExcludeTrcType3List= ',' + ISNULL(@ExcludeTrcType3List,'') + ','
	Set @ExcludeTrcType4List= ',' + ISNULL(@ExcludeTrcType4List,'') + ','
	Set @ExcludeTrcCompanyList= ',' + ISNULL(@ExcludeTrcCompanyList,'') + ','
	Set @ExcludeTrcDivisionList= ',' + ISNULL(@ExcludeTrcDivisionList,'') + ','
	Set @ExcludeTrcTerminalList= ',' + ISNULL(@ExcludeTrcTerminalList,'') + ','
	Set @ExcludeTrcFleetList= ',' + ISNULL(@ExcludeTrcFleetList,'') + ','
	Set @ExcludeTrcBranchList= ',' + ISNULL(@ExcludeTrcBranchList,'') + ','

	Set @ExcludeTrlType1List= ',' + ISNULL(@ExcludeTrlType1List,'') + ','
	Set @ExcludeTrlType2List= ',' + ISNULL(@ExcludeTrlType2List,'') + ','
	Set @ExcludeTrlType3List= ',' + ISNULL(@ExcludeTrlType3List,'') + ','
	Set @ExcludeTrlType4List= ',' + ISNULL(@ExcludeTrlType4List,'') + ','
	Set @ExcludeTrlCompanyList= ',' + ISNULL(@ExcludeTrlCompanyList,'') + ','
	Set @ExcludeTrlDivisionList= ',' + ISNULL(@ExcludeTrlDivisionList,'') + ','
	Set @ExcludeTrlTerminalList= ',' + ISNULL(@ExcludeTrlTerminalList,'') + ','
	Set @ExcludeTrlFleetList= ',' + ISNULL(@ExcludeTrlFleetList,'') + ','
	Set @ExcludeTrlBranchList= ',' + ISNULL(@ExcludeTrlBranchList,'') + ','

	Set @TrcCountOnlyTrcType1List= ',' + ISNULL(@TrcCountOnlyTrcType1List,'') + ','
	Set @TrcCountOnlyTrcType2List= ',' + ISNULL(@TrcCountOnlyTrcType2List,'') + ','
	Set @TrcCountOnlyTrcType3List= ',' + ISNULL(@TrcCountOnlyTrcType3List,'') + ','
	Set @TrcCountOnlyTrcType4List= ',' + ISNULL(@TrcCountOnlyTrcType4List,'') + ','
	Set @TrcCountOnlyTrcCompanyList= ',' + ISNULL(@TrcCountOnlyTrcCompanyList,'') + ','
	Set @TrcCountOnlyTrcDivisionList= ',' + ISNULL(@TrcCountOnlyTrcDivisionList,'') + ','
	Set @TrcCountOnlyTrcTerminalList= ',' + ISNULL(@TrcCountOnlyTrcTerminalList,'') + ','
	Set @TrcCountOnlyTrcFleetList= ',' + ISNULL(@TrcCountOnlyTrcFleetList,'') + ','
	Set @TrcCountOnlyTrcBranchList= ',' + ISNULL(@TrcCountOnlyTrcBranchList,'') + ','

	Set @TrcCountExcludeTrcType1List= ',' + ISNULL(@TrcCountExcludeTrcType1List,'') + ','
	Set @TrcCountExcludeTrcType2List= ',' + ISNULL(@TrcCountExcludeTrcType2List,'') + ','
	Set @TrcCountExcludeTrcType3List= ',' + ISNULL(@TrcCountExcludeTrcType3List,'') + ','
	Set @TrcCountExcludeTrcType4List= ',' + ISNULL(@TrcCountExcludeTrcType4List,'') + ','
	Set @TrcCountExcludeTrcCompanyList= ',' + ISNULL(@TrcCountExcludeTrcCompanyList,'') + ','
	Set @TrcCountExcludeTrcDivisionList= ',' + ISNULL(@TrcCountExcludeTrcDivisionList,'') + ','
	Set @TrcCountExcludeTrcTerminalList= ',' + ISNULL(@TrcCountExcludeTrcTerminalList,'') + ','
	Set @TrcCountExcludeTrcFleetList= ',' + ISNULL(@TrcCountExcludeTrcFleetList,'') + ','
	Set @TrcCountExcludeTrcBranchList= ',' + ISNULL(@TrcCountExcludeTrcBranchList,'') + ','

	Set @DrvCountOnlyDrvType1List= ',' + ISNULL(@DrvCountOnlyDrvType1List,'') + ','
	Set @DrvCountOnlyDrvType2List= ',' + ISNULL(@DrvCountOnlyDrvType2List,'') + ','
	Set @DrvCountOnlyDrvType3List= ',' + ISNULL(@DrvCountOnlyDrvType3List,'') + ','
	Set @DrvCountOnlyDrvType4List= ',' + ISNULL(@DrvCountOnlyDrvType4List,'') + ','
	Set @DrvCountOnlyDrvCompanyList= ',' + ISNULL(@DrvCountOnlyDrvCompanyList,'') + ','
	Set @DrvCountOnlyDrvDivisionList= ',' + ISNULL(@DrvCountOnlyDrvDivisionList,'') + ','
	Set @DrvCountOnlyDrvTerminalList= ',' + ISNULL(@DrvCountOnlyDrvTerminalList,'') + ','
	Set @DrvCountOnlyDrvFleetList= ',' + ISNULL(@DrvCountOnlyDrvFleetList,'') + ','
	Set @DrvCountOnlyDrvBranchList= ',' + ISNULL(@DrvCountOnlyDrvBranchList,'') + ','
	Set @DrvCountOnlyDrvDomicileList= ',' + ISNULL(@DrvCountOnlyDrvDomicileList,'') + ','
	Set @DrvCountOnlyDrvTeamLeaderList= ',' + ISNULL(@DrvCountOnlyDrvTeamLeaderList,'') + ','

	Set @DrvCountExcludeDrvType1List= ',' + ISNULL(@DrvCountExcludeDrvType1List,'') + ','
	Set @DrvCountExcludeDrvType2List= ',' + ISNULL(@DrvCountExcludeDrvType2List,'') + ','
	Set @DrvCountExcludeDrvType3List= ',' + ISNULL(@DrvCountExcludeDrvType3List,'') + ','
	Set @DrvCountExcludeDrvType4List= ',' + ISNULL(@DrvCountExcludeDrvType4List,'') + ','
	Set @DrvCountExcludeDrvCompanyList= ',' + ISNULL(@DrvCountExcludeDrvCompanyList,'') + ','
	Set @DrvCountExcludeDrvDivisionList= ',' + ISNULL(@DrvCountExcludeDrvDivisionList,'') + ','
	Set @DrvCountExcludeDrvTerminalList= ',' + ISNULL(@DrvCountExcludeDrvTerminalList,'') + ','
	Set @DrvCountExcludeDrvFleetList= ',' + ISNULL(@DrvCountExcludeDrvFleetList,'') + ','
	Set @DrvCountExcludeDrvBranchList= ',' + ISNULL(@DrvCountExcludeDrvBranchList,'') + ','
	Set @DrvCountExcludeDrvDomicileList= ',' + ISNULL(@DrvCountExcludeDrvDomicileList,'') + ','
	Set @DrvCountExcludeDrvTeamLeaderList= ',' + ISNULL(@DrvCountExcludeDrvTeamLeaderList,'') + ','

	Set @TrlCountOnlyTrlType1List= ',' + ISNULL(@TrlCountOnlyTrlType1List,'') + ','
	Set @TrlCountOnlyTrlType2List= ',' + ISNULL(@TrlCountOnlyTrlType2List,'') + ','
	Set @TrlCountOnlyTrlType3List= ',' + ISNULL(@TrlCountOnlyTrlType3List,'') + ','
	Set @TrlCountOnlyTrlType4List= ',' + ISNULL(@TrlCountOnlyTrlType4List,'') + ','
	Set @TrlCountOnlyTrlCompanyList= ',' + ISNULL(@TrlCountOnlyTrlCompanyList,'') + ','
	Set @TrlCountOnlyTrlDivisionList= ',' + ISNULL(@TrlCountOnlyTrlDivisionList,'') + ','
	Set @TrlCountOnlyTrlTerminalList= ',' + ISNULL(@TrlCountOnlyTrlTerminalList,'') + ','
	Set @TrlCountOnlyTrlFleetList= ',' + ISNULL(@TrlCountOnlyTrlFleetList,'') + ','
	Set @TrlCountOnlyTrlBranchList= ',' + ISNULL(@TrlCountOnlyTrlBranchList,'') + ','

	Set @TrlCountExcludeTrlType1List= ',' + ISNULL(@TrlCountExcludeTrlType1List,'') + ','
	Set @TrlCountExcludeTrlType2List= ',' + ISNULL(@TrlCountExcludeTrlType2List,'') + ','
	Set @TrlCountExcludeTrlType3List= ',' + ISNULL(@TrlCountExcludeTrlType3List,'') + ','
	Set @TrlCountExcludeTrlType4List= ',' + ISNULL(@TrlCountExcludeTrlType4List,'') + ','
	Set @TrlCountExcludeTrlCompanyList= ',' + ISNULL(@TrlCountExcludeTrlCompanyList,'') + ','
	Set @TrlCountExcludeTrlDivisionList= ',' + ISNULL(@TrlCountExcludeTrlDivisionList,'') + ','
	Set @TrlCountExcludeTrlTerminalList= ',' + ISNULL(@TrlCountExcludeTrlTerminalList,'') + ','
	Set @TrlCountExcludeTrlFleetList= ',' + ISNULL(@TrlCountExcludeTrlFleetList,'') + ','
	Set @TrlCountExcludeTrlBranchList= ',' + ISNULL(@TrlCountExcludeTrlBranchList,'') + ','


	Declare @TempTriplets Table (mov_number int, lgh_number int, ord_hdrnumber int)

	If (@DateType = 'MoveStart')
		begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where MoveStartDate >= @DateStart AND MoveStartDate < @DateEnd
		end
	Else If (@DateType = 'MoveEnd')
		begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where MoveEndDate >= @DateStart AND MoveEndDate < @DateEnd
		end
	Else If (@DateType = 'LegStart')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where lgh_startdate >= @DateStart AND lgh_startdate < @DateEnd
		End
	Else If (@DateType = 'LegEnd')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd
		End
	Else If (@DateType = 'OrderStart')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_startdate >= @DateStart AND ord_startdate < @DateEnd
		End
	Else If (@DateType = 'OrderEnd')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
		End
	Else -- If (@DateType = 'BookDate')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
		End

-- new code here to apply @DateType specific status level filtering

Declare @TempDeleteMoves Table (mov_number int)
Declare @TempStartedMoves Table (mov_number int)
Declare @TempDeleteLegs Table (lgh_number int)
Declare @TempDeleteOrders Table (ord_hdrnumber int)

If @DispatchStatusList <> ',,'
	Begin
		If @DateType Like 'Move%'
			Begin
				Insert into @TempDeleteMoves (mov_number)
				Select TT.mov_number
				--into @TempDeleteMoves
				From @TempTriplets TT join legheader with (NOLOCK) on TT.mov_number = legheader.mov_number	
				-- select any moves that do NOT meet the dispatch criteria
				Where CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatusList) = 0

				-- this code because possible for one leg of split trip to be in AVL or PLN status
				-- while other leg in STD or CMP status.  In this case, move IS started so we need
				-- to remove from delete list
				If CHARINDEX(',' + 'STD' + ',', @DispatchStatusList) > 0
					Begin
						Insert into @TempStartedMoves (mov_number)
						select mov_number 
						--into @TempStartedMoves
						from legheader with (NOLOCK)
						where mov_number in (select mov_number from @TempDeleteMoves) 
						AND lgh_outstatus in ('STD','CMP')

						Delete from @TempDeleteMoves where mov_number in (select mov_number from @TempStartedMoves)
						--Drop Table @TempStartedMoves
					End

				Delete from @TempTriplets where mov_number in (select mov_number from @TempDeleteMoves)
				--Drop Table @TempDeleteMoves
			End
		Else If @DateType Like 'Leg%'
			Begin
				Insert into @TempDeleteLegs (lgh_number)
				Select TT.lgh_number
				--into @TempDeleteLegs
				From @TempTriplets TT join legheader with (NOLOCK) on TT.lgh_number = legheader.lgh_number	
				-- select any legs that do NOT meet the dispatch criteria
				Where CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatusList) = 0

				Delete from @TempTriplets where lgh_number in (select lgh_number from @TempDeleteLegs)
				--Drop Table @TempDeleteLegs
			End
		Else	-- one of the Order type dates
			Begin
				Insert into @TempDeleteOrders (ord_hdrnumber)
				Select TT.ord_hdrnumber
				--into @TempDeleteOrders
				From @TempTriplets TT join orderheader with (NOLOCK) on TT.ord_hdrnumber = orderheader.ord_hdrnumber	
				-- select any orders that do NOT meet the dispatch criteria
				Where CHARINDEX(',' + ord_status + ',', @DispatchStatusList) = 0

				Delete from @TempTriplets where ord_hdrnumber in (select ord_hdrnumber from @TempDeleteOrders)
				--Drop Table @TempDeleteOrders
			End
	End

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
	--into @TempAllTriplets
	from ResNow_Triplets with (NOLOCK)
	Where Exists 
		(
			Select * 
			from @TempTriplets TT 
			where TT.mov_number = ResNow_Triplets.mov_number
		)
--	OR Exists (Select ord_hdrnumber from @TempTriplets TT where TT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber)
--	Where mov_number in (Select mov_number from @TempTriplets)
--	OR ord_hdrnumber in (Select ord_hdrnumber from @TempTriplets)

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
		,Fechaini datetime
		,Fechafin datetime   
       
	)

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
		,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
		,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
		,orderheader.ord_origincity
		,ShipDate = IsNull(orderheader.ord_startdate,L.lgh_startdate)
		,Consignee = IsNull(orderheader.ord_consignee,L.cmp_id_end)
		,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
		,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
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
		,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Order',0,DEFAULT,DEFAULT,TT.ord_hdrnumber,DEFAULT,DEFAULT,DEFAULT,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
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
		,WeightUOM = 'TON'
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
		,CurrentStatus = 
			Case 
				when @DateType like 'Move%' then L.lgh_outstatus 
				when @DateType like 'Leg%' then L.lgh_outstatus
			Else
				IsNull(orderheader.ord_status,L.lgh_outstatus)
			End	
      ,Region = Convert(varchar(255),'')
      ,Rorigen = Convert(varchar(255),'')
      ,Rdestino =  Convert(varchar(255),'')
      ,Flota = (Select  upper(name)  from  labelfile  where abbr  = (Select trc_fleet from tractorprofile where trc_number = TAT.lgh_tractor ) and labeldefinition = 'Fleet')
       	
	--Into @LegList
	FROM @TempTriplets TT inner Join @TempAllTriplets TAT on TT.lgh_number = TAT.lgh_number AND TT.ord_hdrnumber = TAT.ord_hdrnumber
		inner join Legheader L with (NOLOCK) on TT.lgh_number = L.lgh_number
		inner join ResNow_DriverCache_Final DCF with (NOLOCK) on TAT.lgh_driver1 = DCF.driver_id AND TAT.lgh_startdate >= DCF.driver_DateStart AND TAT.lgh_startdate < DCF.driver_DateEnd
		inner join ResNow_TrailerCache_Final TDF with (NOLOCK) on TAT.lgh_trailer1 = TDF.trailer_id AND TAT.lgh_startdate >= TDF.trailer_DateStart AND TAT.lgh_startdate < TDF.trailer_DateEnd
		inner join ResNow_TractorCache_Final TCF with (NOLOCK) on TAT.lgh_tractor = TCF.tractor_id AND TAT.lgh_startdate >= TCF.tractor_DateStart AND TAT.lgh_startdate < TCF.tractor_DateEnd
		left Join orderheader with (NOLOCK) ON TT.ord_hdrnumber = orderheader.ord_hdrnumber
		left Join company BillToCompany with (NOLOCK) on orderheader.ord_billto = BillToCompany.cmp_id
--		inner join ResNow_DriverCache_Final DCF with (NOLOCK) on TAT.lgh_driver1 = DCF.driver_id
	WHERE 
--	TAT.lgh_startdate >= TDF.trailer_DateStart AND TAT.lgh_startdate < TDF.trailer_DateEnd
--	AND TAT.lgh_startdate >= TCF.tractor_DateStart AND TAT.lgh_startdate < TCF.tractor_DateEnd
--	AND TAT.lgh_startdate >= DCF.driver_DateStart AND TAT.lgh_startdate < DCF.driver_DateEnd
	-- transaction-grain filters
--	AND 
	(@OnlyRevType1List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype1,L.lgh_class1) + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype2,L.lgh_class2) + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype3,L.lgh_class3) + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype4,L.lgh_class4) + ',', @OnlyRevType4List) > 0)

	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype1,L.lgh_class1) + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype2,L.lgh_class2) + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype3,L.lgh_class3) + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype4,L.lgh_class4) + ',', @ExcludeRevType4List) = 0)

	AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
	AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
	AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
	AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

	AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
	AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
	AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
	AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

	AND (@InvoiceStatusList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_invoicestatus,'') + ',', @InvoiceStatusList) > 0)		 

	-- operations-grain filters
	AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @OnlyDrvType1List) > 0)
	AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @OnlyDrvType2List) > 0)
	AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @OnlyDrvType3List) > 0)
	AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @OnlyDrvType4List) > 0)
	AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @OnlyDrvCompanyList) > 0)
	AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @OnlyDrvDivisionList) > 0)
	AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @OnlyDrvTerminalList) > 0)
	AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @OnlyDrvFleetList) > 0)
	AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @OnlyDrvDomicileList) > 0)
	AND (@OnlyDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @OnlyDrvTeamLeaderList) > 0)
	AND (@OnlyDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @OnlyDrvBranchList) > 0)

	AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @ExcludeDrvType1List) = 0)
	AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @ExcludeDrvType2List) = 0)
	AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @ExcludeDrvType3List) = 0)
	AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @ExcludeDrvType4List) = 0)
	AND (@ExcludeDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @ExcludeDrvCompanyList) = 0)
	AND (@ExcludeDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @ExcludeDrvDivisionList) = 0)
	AND (@ExcludeDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @ExcludeDrvTerminalList) = 0)
	AND (@ExcludeDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @ExcludeDrvFleetList) = 0)
	AND (@ExcludeDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @ExcludeDrvDomicileList) = 0)
	AND (@ExcludeDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0)
	AND (@ExcludeDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @ExcludeDrvBranchList) = 0)

	AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @OnlyTrcType1List) > 0)
	AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @OnlyTrcType2List) > 0)
	AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @OnlyTrcType3List) > 0)
	AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @OnlyTrcType4List) > 0)
	AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @OnlyTrcCompanyList) > 0)
	AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @OnlyTrcDivisionList) > 0)
	AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
	AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @OnlyTrcFleetList) > 0)
	AND (@OnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @OnlyTrcBranchList) > 0)

	AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @ExcludeTrcType1List) = 0)
	AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @ExcludeTrcType2List) = 0)
	AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @ExcludeTrcType3List) = 0)
	AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @ExcludeTrcType4List) = 0)
	AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @ExcludeTrcCompanyList) = 0)
	AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @ExcludeTrcDivisionList) = 0)
	AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
	AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
	AND (@ExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @ExcludeTrcBranchList) = 0)

	AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @OnlyTrlType1List) > 0)
	AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @OnlyTrlType2List) > 0)
	AND (@OnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @OnlyTrlType3List) > 0)
	AND (@OnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @OnlyTrlType4List) > 0)
	AND (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @OnlyTrlCompanyList) > 0)
	AND (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @OnlyTrlDivisionList) > 0)
	AND (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @OnlyTrlTerminalList) > 0)
	AND (@OnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @OnlyTrlFleetList) > 0)
	AND (@OnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @OnlyTrlBranchList) > 0)

	AND (@ExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @ExcludeTrlType1List) = 0)
	AND (@ExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @ExcludeTrlType2List) = 0)
	AND (@ExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @ExcludeTrlType3List) = 0)
	AND (@ExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @ExcludeTrlType4List) = 0)
	AND (@ExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @ExcludeTrlCompanyList) = 0)
	AND (@ExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @ExcludeTrlDivisionList) = 0)
	AND (@ExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @ExcludeTrlTerminalList) = 0)
	AND (@ExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @ExcludeTrlFleetList) = 0)
	AND (@ExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @ExcludeTrlBranchList) = 0)


-- adjust the @LegList result set as required
	If @EliminateCarrierLoadsYN = 'Y'
		Delete from @LegList Where CurrentStatus <> 'AVL' AND Tractor = 'UNKNOWN'

	If @ExcludeZeroRatedInvoicesYN = 'Y'
		DELETE FROM @LegList where SelectedRevenue = 0

	If @IncludeMiscInvoicesYN = 'Y'
		begin
			Declare @MiscInvoices Table (ivh_hdrnumber int)
		
			If (@DateType in ('MoveStart','LegStart','OrderStart','Bookdate'))
				begin
					Insert into @MiscInvoices (ivh_hdrnumber)
						Select ivh_hdrnumber
						From invoiceheader with (NOLOCK)
						where ivh_shipdate >= @DateStart AND ivh_shipdate < @DateEnd
						AND ord_hdrnumber = 0
				end
			Else	-- (@DateType in ('MoveEnd','LegEnd','OrderEnd'))
				begin
					Insert into @MiscInvoices (ivh_hdrnumber)
						Select ivh_hdrnumber
						From invoiceheader with (NOLOCK)
						where ivh_deliverydate >= @DateStart AND ivh_deliverydate < @DateEnd
						AND ord_hdrnumber = 0
				end
		
			Insert into @LegList
				(
					ord_hdrnumber,OrderNumber,MoveNumber,LegNumber,OrderedBy,BillTo,BillToName,Shipper,ShipperName,ShipperLocation,ord_origincity
					,ShipDate,Consignee,ConsigneeName,ConsigneeLocation,ord_destcity,DeliveryDate,MoveStartDate,LegStartDate,LegEndDate,MoveEndDate
					,DriverID,Lider,Tractor,Trailer,RevType1,RevType2,RevType3,RevType4,SelectedRevenue,SelectedPay,TravelMiles,LoadedMiles,EmptyMiles
					,BillMiles,LoadCount,OrderCount,InvoiceStatus,Weight,WeightUOM,Volume,VolumeUOM,PkgCount,PkgCountUOM,LegPct,OrderPct,CurrentStatus
				)

			SELECT (IH.ivh_hdrnumber) * -1 as ord_hdrnumber
				,OrderNumber = IH.ivh_invoicenumber
				,MoveNumber = 0
				,LegNumber = 0
				,OrderedBy = IsNull(IH.ivh_order_by,'')
				,BillTo = IsNull(IH.ivh_billto,'')
				,BillToName = IsNull(BillToCompany.cmp_name,'')
				,Shipper = IsNull(IH.ivh_shipper,'')
				,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
				,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
				,IH.ivh_origincity
				,ShipDate = IH.ivh_shipdate
				,Consignee = IsNull(IH.ivh_consignee,'')
				,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
				,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
				,IH.ivh_destcity
				,DeliveryDate = IH.ivh_deliverydate
				,MoveStartDate = IH.ivh_shipdate
				,LegStartDate = IH.ivh_shipdate
				,LegEndDate = ivh_deliverydate
				,MoveEndDate = ivh_deliverydate
				,DriverID = IH.ivh_driver
                ,Lider = (Select  name  from  labelfile  where abbr  = ( Select mpp_teamleader from manpowerprofile where mpp_id = IH.ivh_driver) and labeldefinition = 'Teamleader')
				,Tractor = IH.ivh_tractor
				,Trailer = IH.ivh_trailer	--= Convert(varchar(15),'')
				,RevType1 = Convert(varchar(20),IH.ivh_revtype1)
				,RevType2 = Convert(varchar(20),IH.ivh_revtype2)
				,RevType3 = Convert(varchar(20),IH.ivh_revtype3)
				,RevType4 = Convert(varchar(20),IH.ivh_revtype4)
		-- revenue
				,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Invoice',0,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,IH.ivh_hdrnumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
		-- cost
				,SelectedPay = 0.00
		-- miles
				,TravelMiles = 0
				,LoadedMiles = 0
				,EmptyMiles = 0
				,BillMiles = IH.ivh_totalmiles -- IsNull((select sum(stp_lgh_mileage) from stops with (NOLOCK) where stops.lgh_number = l.lgh_number),0)
				,LoadCount = 0
				,OrderCount = 0
				,InvoiceStatus = IH.ivh_invoicestatus
				,Weight = Convert(float,0.0)
				,WeightUOM = 'TON'
				,Volume = Convert(float,0.0)
				,VolumeUOM = 'GAL'
				,PkgCount = Convert(float,0.0)
				,PkgCountUOM = Convert(varchar(10),'')
				,LegPct = 1
				,OrderPct = 1
				,CurrentStatus = 'CMP'
			from @MiscInvoices MI join invoiceheader IH with (NOLOCK) on MI.ivh_hdrnumber = IH.ivh_hdrnumber
				inner Join company BillToCompany with (NOLOCK) on IH.ivh_billto = BillToCompany.cmp_id
			WHERE 
			-- transaction-grain filters
			(@OnlyRevType1List =',,' or CHARINDEX(',' + IH.ivh_revtype1 + ',', @OnlyRevType1List) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IH.ivh_revtype2 + ',', @OnlyRevType2list) > 0)
			AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IH.ivh_revtype3 + ',', @OnlyRevType3List) > 0)
			AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IH.ivh_revtype4 + ',', @OnlyRevType4List) > 0)
			AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @OnlyBillToList) > 0)
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @OnlyShipperList) > 0)
			AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @OnlyConsigneeList) > 0)
			AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @OnlyOrderedByList) > 0)

			AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IH.ivh_revtype1 + ',', @ExcludeRevType1List) = 0)
			AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IH.ivh_revtype2 + ',', @ExcludeRevType2List) = 0)
			AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IH.ivh_revtype3 + ',', @ExcludeRevType3List) = 0)
			AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IH.ivh_revtype4 + ',', @ExcludeRevType4List) = 0)
			AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @ExcludeBillToList) = 0)                  
			AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @ExcludeShipperList) = 0)                  
			AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @ExcludeConsigneeList) = 0)
			AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @ExcludeOrderedByList) = 0)                  

		end

	-- set @TractorCount
	If @Numerator = 'TractorCount' OR @Denominator = 'TractorCount'
		Begin
			If @TypeOfTractorCount = 'Working'
				Begin
					Set @TractorCount = 
						(
							select count(distinct RNT.lgh_tractor)
							from ResNow_Triplets RNT with (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
								inner join ResNow_DriverCache_Final DCF with (NOLOCK) on RNT.lgh_driver1 = DCF.driver_id AND RNT.lgh_startdate >= DCF.driver_DateStart AND RNT.lgh_startdate < DCF.driver_DateEnd
								inner join ResNow_TractorCache_Final TCF with (NOLOCK) on RNT.lgh_tractor = TCF.tractor_id AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
								inner join ResNow_TrailerCache_Final TDF with (NOLOCK) on RNT.lgh_trailer1 = TDF.trailer_id AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
								left join orderheader with (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
							where RNT.lgh_enddate > @DateStart AND RNT.lgh_startdate < @DateEnd
							AND RNT.lgh_tractor <> 'UNKNOWN'
--							AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
--							AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
							-- transaction-grain filters
							AND (@OnlyRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @OnlyRevType1List) > 0)
							AND (@OnlyRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @OnlyRevType2list) > 0)
							AND (@OnlyRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @OnlyRevType3List) > 0)
							AND (@OnlyRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @OnlyRevType4List) > 0)

							AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @ExcludeRevType1List) = 0)
							AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @ExcludeRevType2List) = 0)
							AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @ExcludeRevType3List) = 0)
							AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @ExcludeRevType4List) = 0)

							AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
							AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
							AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
							AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

							AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
							AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
							AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
							AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

							-- operations-grain filters
							AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @OnlyDrvType1List) > 0)
							AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @OnlyDrvType2List) > 0)
							AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @OnlyDrvType3List) > 0)
							AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @OnlyDrvType4List) > 0)
							AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @OnlyDrvCompanyList) > 0)
							AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @OnlyDrvDivisionList) > 0)
							AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @OnlyDrvTerminalList) > 0)
							AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @OnlyDrvFleetList) > 0)
							AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @OnlyDrvDomicileList) > 0)
							AND (@OnlyDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @OnlyDrvTeamLeaderList) > 0)
							AND (@OnlyDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @OnlyDrvBranchList) > 0)

							AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @ExcludeDrvType1List) = 0)
							AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @ExcludeDrvType2List) = 0)
							AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @ExcludeDrvType3List) = 0)
							AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @ExcludeDrvType4List) = 0)
							AND (@ExcludeDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @ExcludeDrvCompanyList) = 0)
							AND (@ExcludeDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @ExcludeDrvDivisionList) = 0)
							AND (@ExcludeDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @ExcludeDrvTerminalList) = 0)
							AND (@ExcludeDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @ExcludeDrvFleetList) = 0)
							AND (@ExcludeDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @ExcludeDrvDomicileList) = 0)
							AND (@ExcludeDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0)
							AND (@ExcludeDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @ExcludeDrvBranchList) = 0)

							AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @OnlyTrcType1List) > 0)
							AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @OnlyTrcType2List) > 0)
							AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @OnlyTrcType3List) > 0)
							AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @OnlyTrcType4List) > 0)
							AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @OnlyTrcCompanyList) > 0)
							AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @OnlyTrcDivisionList) > 0)
							AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
							AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @OnlyTrcFleetList) > 0)
							AND (@OnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @OnlyTrcBranchList) > 0)

							AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @ExcludeTrcType1List) = 0)
							AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @ExcludeTrcType2List) = 0)
							AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @ExcludeTrcType3List) = 0)
							AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @ExcludeTrcType4List) = 0)
							AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @ExcludeTrcCompanyList) = 0)
							AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @ExcludeTrcDivisionList) = 0)
							AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
							AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
							AND (@ExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @ExcludeTrcBranchList) = 0)

							AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @OnlyTrlType1List) > 0)
							AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @OnlyTrlType2List) > 0)
							AND (@OnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @OnlyTrlType3List) > 0)
							AND (@OnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @OnlyTrlType4List) > 0)
							AND (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @OnlyTrlCompanyList) > 0)
							AND (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @OnlyTrlDivisionList) > 0)
							AND (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @OnlyTrlTerminalList) > 0)
							AND (@OnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @OnlyTrlFleetList) > 0)
							AND (@OnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @OnlyTrlBranchList) > 0)

							AND (@ExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @ExcludeTrlType1List) = 0)
							AND (@ExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @ExcludeTrlType2List) = 0)
							AND (@ExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @ExcludeTrlType3List) = 0)
							AND (@ExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @ExcludeTrlType4List) = 0)
							AND (@ExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @ExcludeTrlCompanyList) = 0)
							AND (@ExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @ExcludeTrlDivisionList) = 0)
							AND (@ExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @ExcludeTrlTerminalList) = 0)
							AND (@ExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @ExcludeTrlFleetList) = 0)
							AND (@ExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @ExcludeTrlBranchList) = 0)
						)
				End
			Else -- @TypeOfTractorCount <> 'Working'
				Begin
					Set @TractorCount = 
						(
							Select Count(Tractor)
							from dbo.fnc_TMWRN_TractorCount3 
									(
										@TypeOfTractorCount,@TrcCountOnlyTrcType1List,@TrcCountOnlyTrcType2List
										,@TrcCountOnlyTrcType3List,@TrcCountOnlyTrcType4List
										,@TrcCountOnlyTrcCompanyList,@TrcCountOnlyTrcDivisionList
										,@TrcCountOnlyTrcTerminalList,@TrcCountOnlyTrcFleetList
										,@TrcCountOnlyTrcBranchList,@TrcCountExcludeTrcType1List
										,@TrcCountExcludeTrcType2List,@TrcCountExcludeTrcType3List
										,@TrcCountExcludeTrcType4List,@TrcCountExcludeTrcCompanyList
										,@TrcCountExcludeTrcDivisionList,@TrcCountExcludeTrcTerminalList
										,@TrcCountExcludeTrcFleetList,@TrcCountExcludeTrcBranchList,@DateStart
									)
						)
				End
		End


	-- Driver Count
	If @Numerator = 'DriverCount' OR @Denominator = 'DriverCount'
		Begin
			If @TypeOfDriverCount = 'Working'
				Begin
					Set @DriverCount = 
						(
							select count(distinct RNT.lgh_driver1)
							from ResNow_Triplets RNT with (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
								inner join orderheader with (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
								inner join ResNow_DriverCache_Final DCF with (NOLOCK) on RNT.lgh_driver1 = DCF.driver_id AND RNT.lgh_startdate >= DCF.driver_DateStart AND RNT.lgh_startdate < DCF.driver_DateEnd
								inner join ResNow_TractorCache_Final TCF with (NOLOCK) on RNT.lgh_tractor = TCF.tractor_id AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
								inner join ResNow_TrailerCache_Final TDF with (NOLOCK) on RNT.lgh_trailer1 = TDF.trailer_id AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
							where RNT.lgh_enddate > @DateStart AND RNT.lgh_startdate < @DateEnd
							AND RNT.lgh_driver1 <> 'UNKNOWN'
--							AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
--							AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
							-- transaction-grain filters
							AND (@OnlyRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @OnlyRevType1List) > 0)
							AND (@OnlyRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @OnlyRevType2list) > 0)
							AND (@OnlyRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @OnlyRevType3List) > 0)
							AND (@OnlyRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @OnlyRevType4List) > 0)

							AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @ExcludeRevType1List) = 0)
							AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @ExcludeRevType2List) = 0)
							AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @ExcludeRevType3List) = 0)
							AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @ExcludeRevType4List) = 0)

							AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
							AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
							AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
							AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

							AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
							AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
							AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
							AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

							-- operations-grain filters
							AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @OnlyDrvType1List) > 0)
							AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @OnlyDrvType2List) > 0)
							AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @OnlyDrvType3List) > 0)
							AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @OnlyDrvType4List) > 0)
							AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @OnlyDrvCompanyList) > 0)
							AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @OnlyDrvDivisionList) > 0)
							AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @OnlyDrvTerminalList) > 0)
							AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @OnlyDrvFleetList) > 0)
							AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @OnlyDrvDomicileList) > 0)
							AND (@OnlyDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @OnlyDrvTeamLeaderList) > 0)
							AND (@OnlyDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @OnlyDrvBranchList) > 0)

							AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @ExcludeDrvType1List) = 0)
							AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @ExcludeDrvType2List) = 0)
							AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @ExcludeDrvType3List) = 0)
							AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @ExcludeDrvType4List) = 0)
							AND (@ExcludeDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @ExcludeDrvCompanyList) = 0)
							AND (@ExcludeDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @ExcludeDrvDivisionList) = 0)
							AND (@ExcludeDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @ExcludeDrvTerminalList) = 0)
							AND (@ExcludeDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @ExcludeDrvFleetList) = 0)
							AND (@ExcludeDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @ExcludeDrvDomicileList) = 0)
							AND (@ExcludeDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0)
							AND (@ExcludeDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @ExcludeDrvBranchList) = 0)

							AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @OnlyTrcType1List) > 0)
							AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @OnlyTrcType2List) > 0)
							AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @OnlyTrcType3List) > 0)
							AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @OnlyTrcType4List) > 0)
							AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @OnlyTrcCompanyList) > 0)
							AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @OnlyTrcDivisionList) > 0)
							AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
							AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @OnlyTrcFleetList) > 0)
							AND (@OnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @OnlyTrcBranchList) > 0)

							AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @ExcludeTrcType1List) = 0)
							AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @ExcludeTrcType2List) = 0)
							AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @ExcludeTrcType3List) = 0)
							AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @ExcludeTrcType4List) = 0)
							AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @ExcludeTrcCompanyList) = 0)
							AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @ExcludeTrcDivisionList) = 0)
							AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
							AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
							AND (@ExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @ExcludeTrcBranchList) = 0)

							AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @OnlyTrlType1List) > 0)
							AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @OnlyTrlType2List) > 0)
							AND (@OnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @OnlyTrlType3List) > 0)
							AND (@OnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @OnlyTrlType4List) > 0)
							AND (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @OnlyTrlCompanyList) > 0)
							AND (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @OnlyTrlDivisionList) > 0)
							AND (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @OnlyTrlTerminalList) > 0)
							AND (@OnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @OnlyTrlFleetList) > 0)
							AND (@OnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @OnlyTrlBranchList) > 0)

							AND (@ExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @ExcludeTrlType1List) = 0)
							AND (@ExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @ExcludeTrlType2List) = 0)
							AND (@ExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @ExcludeTrlType3List) = 0)
							AND (@ExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @ExcludeTrlType4List) = 0)
							AND (@ExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @ExcludeTrlCompanyList) = 0)
							AND (@ExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @ExcludeTrlDivisionList) = 0)
							AND (@ExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @ExcludeTrlTerminalList) = 0)
							AND (@ExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @ExcludeTrlFleetList) = 0)
							AND (@ExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @ExcludeTrlBranchList) = 0)
						)
				End
			Else -- @TypeOfDriverCount <> 'Working'
				Begin
					Set @DriverCount = 
						(
							Select Count(Driver)
							from dbo.fnc_TMWRN_DriverCount3 
									(
										@TypeOfDriverCount,@DrvCountOnlyDrvType1List,@DrvCountOnlyDrvType2List
										,@DrvCountOnlyDrvType3List,@DrvCountOnlyDrvType4List
										,@DrvCountOnlyDrvCompanyList,@DrvCountOnlyDrvDivisionList
										,@DrvCountOnlyDrvTerminalList,@DrvCountOnlyDrvFleetList
										,@DrvCountOnlyDrvBranchList,@DrvCountOnlyDrvDomicileList
										,@DrvCountOnlyDrvTeamLeaderList,@DrvCountExcludeDrvType1List
										,@DrvCountExcludeDrvType2List,@DrvCountExcludeDrvType3List
										,@DrvCountExcludeDrvType4List,@DrvCountExcludeDrvCompanyList
										,@DrvCountExcludeDrvDivisionList,@DrvCountExcludeDrvTerminalList
										,@DrvCountExcludeDrvFleetList,@DrvCountExcludeDrvBranchList
										,@DrvCountExcludeDrvDomicileList,@DrvCountExcludeDrvTeamLeaderList,@DateStart
									)
						)
				End
		End


	-- Trailer Count
	If @Numerator = 'TrailerCount' OR @Denominator = 'TrailerCount'
		Begin
			If @TypeOfTrailerCount = 'Working'
				Begin
					Set @TrailerCount = 
						(
							select count(distinct RNT.lgh_trailer1)
							from ResNow_Triplets RNT with (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
								inner join orderheader with (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
								inner join ResNow_DriverCache_Final DCF with (NOLOCK) on RNT.lgh_driver1 = DCF.driver_id AND RNT.lgh_startdate >= DCF.driver_DateStart AND RNT.lgh_startdate < DCF.driver_DateEnd
								inner join ResNow_TractorCache_Final TCF with (NOLOCK) on RNT.lgh_tractor = TCF.tractor_id AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
								inner join ResNow_TrailerCache_Final TDF with (NOLOCK) on RNT.lgh_trailer1 = TDF.trailer_id AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
							where RNT.lgh_enddate > @DateStart AND RNT.lgh_startdate < @DateEnd
							AND RNT.lgh_trailer1 <> 'UNKNOWN'
--							AND RNT.lgh_startdate >= TDF.trailer_DateStart AND RNT.lgh_startdate < TDF.trailer_DateEnd
--							AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
							-- transaction-grain filters
							AND (@OnlyRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @OnlyRevType1List) > 0)
							AND (@OnlyRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @OnlyRevType2list) > 0)
							AND (@OnlyRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @OnlyRevType3List) > 0)
							AND (@OnlyRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @OnlyRevType4List) > 0)

							AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + L.lgh_class1 + ',', @ExcludeRevType1List) = 0)
							AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + L.lgh_class2 + ',', @ExcludeRevType2List) = 0)
							AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + L.lgh_class3 + ',', @ExcludeRevType3List) = 0)
							AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + L.lgh_class4 + ',', @ExcludeRevType4List) = 0)

							AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
							AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
							AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
							AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

							AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
							AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
							AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
							AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

							-- operations-grain filters
							AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @OnlyDrvType1List) > 0)
							AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @OnlyDrvType2List) > 0)
							AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @OnlyDrvType3List) > 0)
							AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @OnlyDrvType4List) > 0)
							AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @OnlyDrvCompanyList) > 0)
							AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @OnlyDrvDivisionList) > 0)
							AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @OnlyDrvTerminalList) > 0)
							AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @OnlyDrvFleetList) > 0)
							AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @OnlyDrvDomicileList) > 0)
							AND (@OnlyDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @OnlyDrvTeamLeaderList) > 0)
							AND (@OnlyDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @OnlyDrvBranchList) > 0)

							AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + L.mpp_type1 + ',', @ExcludeDrvType1List) = 0)
							AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + L.mpp_type2 + ',', @ExcludeDrvType2List) = 0)
							AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + L.mpp_type3 + ',', @ExcludeDrvType3List) = 0)
							AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + L.mpp_type4 + ',', @ExcludeDrvType4List) = 0)
							AND (@ExcludeDrvCompanyList =',,' or CHARINDEX(',' + L.mpp_company + ',', @ExcludeDrvCompanyList) = 0)
							AND (@ExcludeDrvDivisionList =',,' or CHARINDEX(',' + L.mpp_division + ',', @ExcludeDrvDivisionList) = 0)
							AND (@ExcludeDrvTerminalList =',,' or CHARINDEX(',' + L.mpp_terminal + ',', @ExcludeDrvTerminalList) = 0)
							AND (@ExcludeDrvFleetList =',,' or CHARINDEX(',' + L.mpp_fleet + ',', @ExcludeDrvFleetList) = 0)
							AND (@ExcludeDrvDomicileList =',,' or CHARINDEX(',' + L.mpp_domicile + ',', @ExcludeDrvDomicileList) = 0)
							AND (@ExcludeDrvTeamLeaderList =',,' or CHARINDEX(',' + L.mpp_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0)
							AND (@ExcludeDrvBranchList =',,' or CHARINDEX(',' + DCF.driver_branch + ',', @ExcludeDrvBranchList) = 0)

							AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @OnlyTrcType1List) > 0)
							AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @OnlyTrcType2List) > 0)
							AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @OnlyTrcType3List) > 0)
							AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @OnlyTrcType4List) > 0)
							AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @OnlyTrcCompanyList) > 0)
							AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @OnlyTrcDivisionList) > 0)
							AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
							AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @OnlyTrcFleetList) > 0)
							AND (@OnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @OnlyTrcBranchList) > 0)

							AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @ExcludeTrcType1List) = 0)
							AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @ExcludeTrcType2List) = 0)
							AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @ExcludeTrcType3List) = 0)
							AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @ExcludeTrcType4List) = 0)
							AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @ExcludeTrcCompanyList) = 0)
							AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @ExcludeTrcDivisionList) = 0)
							AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
							AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
							AND (@ExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @ExcludeTrcBranchList) = 0)

							AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @OnlyTrlType1List) > 0)
							AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @OnlyTrlType2List) > 0)
							AND (@OnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @OnlyTrlType3List) > 0)
							AND (@OnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @OnlyTrlType4List) > 0)
							AND (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @OnlyTrlCompanyList) > 0)
							AND (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @OnlyTrlDivisionList) > 0)
							AND (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @OnlyTrlTerminalList) > 0)
							AND (@OnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @OnlyTrlFleetList) > 0)
							AND (@OnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @OnlyTrlBranchList) > 0)

							AND (@ExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @ExcludeTrlType1List) = 0)
							AND (@ExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @ExcludeTrlType2List) = 0)
							AND (@ExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @ExcludeTrlType3List) = 0)
							AND (@ExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @ExcludeTrlType4List) = 0)
							AND (@ExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @ExcludeTrlCompanyList) = 0)
							AND (@ExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @ExcludeTrlDivisionList) = 0)
							AND (@ExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @ExcludeTrlTerminalList) = 0)
							AND (@ExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @ExcludeTrlFleetList) = 0)
							AND (@ExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @ExcludeTrlBranchList) = 0)
						)
				End
			Else -- @TypeOfTrailerCount <> 'Working'
				Begin
					Set @TrailerCount = 
						(
							Select Count(Trailer)
							from dbo.fnc_TMWRN_TrailerCount3 
									(
										@TypeOfTrailerCount,@TrlCountOnlyTrlType1List,@TrlCountOnlyTrlType2List
										,@TrlCountOnlyTrlType3List,@TrlCountOnlyTrlType4List
										,@TrlCountOnlyTrlCompanyList,@TrlCountOnlyTrlDivisionList
										,@TrlCountOnlyTrlTerminalList,@TrlCountOnlyTrlFleetList
										,@TrlCountOnlyTrlBranchList,@TrlCountExcludeTrlType1List
										,@TrlCountExcludeTrlType2List,@TrlCountExcludeTrlType3List
										,@TrlCountExcludeTrlType4List,@TrlCountExcludeTrlCompanyList
										,@TrlCountExcludeTrlDivisionList,@TrlCountExcludeTrlTerminalList
										,@TrlCountExcludeTrlFleetList,@TrlCountExcludeTrlBranchList,@DateStart
									)
						)
				End
		End



	-- do fact allocations
	Update @LegList set OrderCount = Round(OrderPct,5,0)
	,BillMiles = Round(BillMiles * OrderPct,4,0)
	,SelectedRevenue = Round(SelectedRevenue * OrderPct,5,0)

	Update @LegList set TravelMiles = Round(TravelMiles * LegPct,4,0)
	,LoadedMiles = Round(LoadedMiles * LegPct,4,0)
	,EmptyMiles = Round(EmptyMiles * LegPct,4,0)
	,SelectedPay = Round(SelectedPay * LegPct,5,0)

	-- set LoadCount; by Leg COUNT to account for zero mile moves
	
	--Declare @TempCalcTriplets Table (mov_number int, lgh_number int, LegTravelMiles float)
	
	--Insert into @TempCalcTriplets (mov_number,lgh_number,LegTravelMiles)
	--Select distinct mov_number
	--,lgh_number
	--,LegTravelMiles
	----into @TempCalcTriplets
	--from @TempAllTriplets

	Declare @TempLegCount Table (mov_number int, LegCount float, MoveMiles float)
	
	Insert into @TempLegCount (mov_number,LegCount,MoveMiles)
	Select mov_number
	,count(distinct lgh_number) as LegCount
	,sum(LegTravelMiles / CountOfOrdersOnThisLeg) as MoveMiles
	--into @TempLegCount
	from @TempAllTriplets
	group by mov_number

	Update @LegList set LoadCount = Round(1.0 / Convert(float,LegCount),4,0)
	from @TempLegCount TLC INNER JOIN @LegList LL on LL.MoveNumber = TLC.mov_number

	-- set LoadCount; by Miles if miles not zero
	Update @LegList set LoadCount = Round(Convert(float,TravelMiles) / Convert(float,MoveMiles),4,0)
	from @TempLegCount TLC INNER JOIN @LegList LL on LL.MoveNumber = TLC.mov_number
	where TLC.MoveMiles > 0

	-- set Weight
	If @Numerator = 'Weight' OR @Denominator = 'Weight' OR @ShowDetail > 0
		Begin
			Update @LegList set Weight = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_weightunit,@WeightUOM,IsNull(fgt_weight,0)))
							from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = LL.LegNumber
							AND stops.ord_hdrnumber = LL.ord_hdrnumber
							AND stops.stp_type = 'DRP'
						),0)
			From @LegList LL
		End

	-- set Volume
	If @Numerator = 'Volume' OR @Denominator = 'Volume' OR @ShowDetail > 0
		Begin
			Update @LegList set Volume = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_volumeunit,@VolumeUOM,IsNull(fgt_volume,0)))
							from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = LL.LegNumber
							AND stops.ord_hdrnumber = LL.ord_hdrnumber
--							AND freightdetail.cmd_code = @LegList.CommodityID
							AND stops.stp_type = 'DRP'
						),0)
			From @LegList LL
		End

	-- set PkgCount
	If @Numerator = 'PkgCount' OR @Denominator = 'PkgCount' OR @ShowDetail > 0
		Begin
			Update @LegList set 
				PkgCount = 
					IsNull(	(
								Select Sum(IsNull(fgt_count,0))
								from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = LL.LegNumber
								AND stops.ord_hdrnumber = LL.ord_hdrnumber
--								AND freightdetail.cmd_code = @LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),0)
				,PkgCountUOM = 
					IsNull(	(
								Select Top 1 fgt_countunit
								from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = LL.LegNumber
								AND stops.ord_hdrnumber = LL.ord_hdrnumber
--								AND freightdetail.cmd_code = @LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),'Each')
			From @LegList LL
		End

	Set @ThisCount = 
		Case 
			When @Numerator = 'Revenue' then (Select sum(SelectedRevenue) from @LegList)
			When @Numerator = 'Cost' then (Select sum(SelectedPay) from @LegList)
			When @Numerator = 'Margin' then (Select sum(SelectedRevenue) - sum(SelectedPay) from @LegList)
			When @Numerator = 'LoadCount' then (Select sum(LoadCount) from @LegList)
			When @Numerator = 'OrderCount' then (Select sum(OrderCount) from @LegList)
			When @Numerator = 'Weight' then (Select sum(Weight) from @LegList)
			When @Numerator = 'Volume' then (Select sum(Volume) from @LegList)
			When @Numerator = 'LoadedMile' then (Select sum(LoadedMiles) from @LegList)
			When @Numerator = 'EmptyMile' then (Select sum(EmptyMiles) from @LegList)
			When @Numerator = 'BillMile' then (Select sum(BillMiles) from @LegList)
		Else -- @Numerator = 'TravelMile'
			(Select sum(TravelMiles) From @LegList) -- When @Numerator = 'Mile'
		End

	Set @ThisTotal =
		Case
			When @Denominator = 'Revenue' then (Select sum(SelectedRevenue) from @LegList)
			When @Denominator = 'Cost' then (Select sum(SelectedPay) from @LegList)
			When @Denominator = 'TravelMile' then (Select sum(TravelMiles) From @LegList)
			When @Denominator = 'LoadedMile' then (Select sum(LoadedMiles) From @LegList)
			When @Denominator = 'EmptyMile' then (Select sum(EmptyMiles) From @LegList)
			When @Denominator = 'BillMile' then (Select sum(BillMiles) from @LegList)
			When @Denominator = 'LoadCount' then (Select sum(LoadCount) From @LegList)
			When @Denominator = 'OrderCount' then (Select sum(OrderCount) from @LegList)
			When @Denominator = 'Weight' then (Select sum(Weight) from @LegList)
			When @Denominator = 'Volume' then (Select sum(Volume) from @LegList)
			When @Denominator = 'TractorCount' then @TractorCount
			When @Denominator = 'DriverCount' then @DriverCount
			When @Denominator = 'TrailerCount' then @TrailerCount
		Else -- @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End



	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 


	If @ShowDetail > 0	-- get textual information we need for good data display
		Begin
			Update @LegList set ShipperName = company.cmp_name
			From company with (NOLOCK) INNER JOIN @LegList LL ON LL.Shipper = company.cmp_id 

			Update @LegList set ConsigneeName = company.cmp_name
			From company with (NOLOCK) INNER JOIN @LegList LL ON LL.Consignee = company.cmp_id 

			Update @LegList set ShipperLocation = city.cty_nmstct
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_origincity = city.cty_code

			Update @LegList set ConsigneeLocation = city.cty_nmstct
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_destcity = city.cty_code

 
--- Asignamos el valor a las variables que contendran la region de origen y de destino en base a shipper y consignee
            
            Update @LegList set Rorigen =  

         cty_region1
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_origincity = city.cty_code

                
            
            Update @Leglist set Rdestino = 

            cty_region1
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_destcity = city.cty_code

----Juntamos las dos varibles en un sólo contenido

           Update @LegList set Rorigen = rgh_name from regionheader where rgh_id = Rorigen
           Update @LegList set Rdestino =  rgh_name from regionheader where rgh_id = Rdestino
 


           Update @Leglist set Region = Rorigen +' a ' + Rdestino

             

/*
			Update @LegList set Trailer = 
				(
					select top 1 evt_trailer1
					from event with (NOLOCK)
					where @LegList.ord_hdrnumber = event.ord_hdrnumber
					AND evt_pu_dr = 'PUP'
				)
*/

			Update @LegList set RevType1 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType1 = LF.ABBR
			Where LF.labeldefinition = 'RevType1'

			Update @LegList set RevType2 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType2 = LF.ABBR
			Where LF.labeldefinition = 'RevType2'

			Update @LegList set RevType3 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType3 = LF.ABBR
			Where LF.labeldefinition = 'RevType3'

			Update @LegList set RevType4 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType4 = LF.ABBR
			Where LF.labeldefinition = 'RevType4'
/*
			Update @LegList Set ReportingHierarchy = RowID
			From dbo.fnc_BranchHierarchyForRN() 
			where (brn_id_1 = @LegList.Branch AND brn_id_2 is NULL)
			OR (brn_id_2 = @LegList.Branch AND brn_id_3 is NULL)
			OR (brn_id_3 = @LegList.Branch AND brn_id_4 is NULL)
			OR (brn_id_4 = @LegList.Branch AND brn_id_5 is NULL)
*/
		End

	If @ShowDetail = 1
		BEGIN
			SELECT RevType1
			,Ingreso = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,Costo = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margen = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,CuentaCargas = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2)
			,CuentaOrdenes = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),2)
			,Peso = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volumen = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,KmsCargados = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,KmsVacios = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
            ,VaciosPorCiento = dbo.fnc_TMWRN_FormatNumbers(Case When Sum(TravelMiles) > 0 then
            100*(Sum(EmptyMiles)/ Sum(TravelMiles))
              Else 0 
              End,2)+ '%'
			,KmsTotales = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,IngresoXkm = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,CostoPorCiento = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MargenPorCiento = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MargenPorCarga = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM @LegList
			Group by RevType1
			order by RevType1
		END
	
	     
	
Else If @ShowDetail = 9
		BEGIN
			SELECT  *
			FROM @LegList
			--Group by OrderNumber 
			order by OrderNumber 
		END
	



	SET NOCOUNT OFF





GO
