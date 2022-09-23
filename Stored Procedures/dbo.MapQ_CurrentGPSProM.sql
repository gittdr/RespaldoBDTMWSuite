SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MapQ_CurrentGPSProM]
	(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL, 
	@UseMetricParms int = 1, 
	@ShowDetail int = 1,
	@MetricCode varchar(200) = 'Trucks',
	@LayerName Varchar(40) ='View1:Current GPS',
	@OnlyTrcTypeList1 Varchar(255) ='',
	@OnlyTrcTypeList2 Varchar(255) ='',
	@OnlyTrcTypeList3 Varchar(255) ='',
	@OnlyTrcTypeList4 Varchar(255) ='',
	@OnlyTrc_avl_statusList Varchar(255) ='',
	@OnlyTrc_trc_ownerList Varchar(255) ='',
	@Onlytrc_companyList Varchar(255) ='',
	@Onlytrc_divisionList Varchar(255) ='',
	@Onlytrc_fleetList Varchar(255) ='',
	@Onlytrc_terminalList Varchar(255) ='',
	@Onlytrc_exp1_dateGreaterThan_N_HoursFromNow Float =-1,
	@Onlytrc_exp2_dateGreaterThan_N_HoursFromNow Float =-1,
	@AirMPHSpeed float=40,
	@AvailableSymbol Varchar(30) = 'BLUE TRUCK',
	@LateSymbol Varchar(30) = 'RED TRUCK',
	@ActiveSymbol Varchar(30) = 'GREEN TRUCK',
	@UnassignedSymbol Varchar(30) = 'YellowTruckPin',
	@HighPrioritySymbol Varchar(30) = 'RedTruckPin.gif',
	@OnlySymbolList Varchar(50) = '',
	@OnlyRevType1 varchar(255) = '',
	@OnlyRevType2 varchar(255) = '',
	@OnlyRevType3 varchar(255) = '',
	@OnlyRevType4 varchar(255) = '',
	@CustomUnassignedYN char(1) = 'N',
	@UseScheduleLatestYN char(1) = 'N',
	@ExcludeLastStopYN CHAR(1)='N',
	@ExcludeFirstStopYN CHAR(1) = 'N',
	@OnlyStopEventList varchar(255)= '',
	@ExcludeStopEventList varchar(255)= '',
	@BufferMinutes float = 60,
	@ExcludeRevType1 varchar(255) = '',
	@ExcludeRevType2 varchar(255) = '',
	@ExcludeRevType3 varchar(255) = '',
	@ExcludeRevType4 varchar(255) = '',
	@AdjustTimeZones char(1) = 'Y'
	)
AS
--If called by MetricRun, just grab Cache. 
--If called by MetricTrucksMapProcessing or update button on trucks map, call MapQ_CurrentGPSProm_Update
	SET NOCOUNT ON  -- PTS46367

	If @ShowDetail = -1 --update cache
		EXEC MapQ_CurrentGPSProM_Update 
			@Result OUTPUT , 
			@ThisCount OUTPUT , 
			@ThisTotal OUTPUT , 
			@DateStart, 
			@DateEnd, 
			@UseMetricParms, 
			@ShowDetail, 
			@MetricCode,
			@LayerName, 
			@OnlyTrcTypeList1, 
			@OnlyTrcTypeList2, 
			@OnlyTrcTypeList3, 
			@OnlyTrcTypeList4, 
			@OnlyTrc_avl_statusList, 
			@OnlyTrc_trc_ownerList, 
			@Onlytrc_companyList, 
			@Onlytrc_divisionList, 
			@Onlytrc_fleetList, 
			@Onlytrc_terminalList, 
			@Onlytrc_exp1_dateGreaterThan_N_HoursFromNow, 
			@Onlytrc_exp2_dateGreaterThan_N_HoursFromNow, 
			@AirMPHSpeed, 
			@AvailableSymbol, 
			@LateSymbol, 
			@ActiveSymbol,
			@UnassignedSymbol,
			@HighPrioritySymbol,
			@OnlySymbolList, 
			@OnlyRevType1, 
			@OnlyRevType2, 
			@OnlyRevType3, 
			@OnlyRevType4,
			@CustomUnassignedYN,
			@UseScheduleLatestYN,
			@ExcludeLastStopYN,
			@ExcludeFirstStopYN,
			@OnlyStopEventList,
			@ExcludeStopEventList,
			@BufferMinutes,
			@ExcludeRevType1,
			@ExcludeRevType2,
			@ExcludeRevType3,
			@ExcludeRevType4,
			@AdjustTimeZones


	Select 
		ItemID,
		Symbol,
		gps_latitude,
		gps_longitude,
		gps_date,
		displayText=replace(displaytext,'''',' '),
		ShowCheckcallHistoryPromptYN = 'Y',
		Cast (Upd_Daily AS Varchar(25)) as Upd_Daily,
		FlashFlag,
		ord_hdrnumber
From ResNowGPSMapCache (NOLOCK)
		WHERE PlainDate = @DateStart and MetricCode = @MetricCode

GO
GRANT EXECUTE ON  [dbo].[MapQ_CurrentGPSProM] TO [public]
GO
