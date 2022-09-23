SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MapQ_CurrentGPSProM_Update]
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
	@HighPrioritySymbol Varchar(30) = '',
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
	@ExcludeStopEventList varchar(255)= 'HPL',
	@BufferMinutes float = 60,
	@ExcludeRevType1 varchar(255) = '',
	@ExcludeRevType2 varchar(255) = '',
	@ExcludeRevType3 varchar(255) = '',
	@ExcludeRevType4 varchar(255) = '',
	@AdjustTimeZones char(1) = 'Y'
	)
AS

	IF @DateStart < DateAdd(d, -1, GetDate())
		RETURN

	Set nocount on
	Declare @trc_exp1_dateMustBeGreaterThan DateTime
	Declare @trc_exp2_dateMustBeGreaterThan DateTime
	Declare @PlainDate DateTime
	Declare @upd_Daily DateTime

	Declare @MaxDate Datetime
	Set @MaxDate='12/31/2050 23:59'
	
	Set	@OnlyTrcTypeList1 = ',' + ISNULL(@OnlyTrcTypeList1,'') + ','
	Set	@OnlyTrcTypeList2 = ',' + ISNULL(@OnlyTrcTypeList2,'') + ','
	Set	@OnlyTrcTypeList3 = ',' + ISNULL(@OnlyTrcTypeList3,'') + ','
	Set	@OnlyTrcTypeList4 = ',' + ISNULL(@OnlyTrcTypeList4,'') + ','
	
	Set	@OnlyTrc_avl_statusList = ',' + ISNULL(@OnlyTrc_avl_statusList,'') + ','
	Set	@OnlyTrc_trc_ownerList = ',' + ISNULL(@OnlyTrc_trc_ownerList,'') + ','
	Set	@Onlytrc_companyList = ',' + ISNULL(@Onlytrc_companyList,'') + ','
	Set	@Onlytrc_divisionList = ',' + ISNULL(@Onlytrc_divisionList,'') + ','
	Set	@Onlytrc_fleetList = ',' + ISNULL(@Onlytrc_fleetList,'') + ','
	Set	@Onlytrc_terminalList = ',' + ISNULL(@Onlytrc_terminalList,'') + ','
	Set	@OnlySymbolList	= ',' + ISNULL(@OnlySymbolList,'') + ','
	Set	@OnlyRevType1 = ',' + ISNULL(@OnlyRevType1,'') + ','	
	Set	@OnlyRevType2 = ',' + ISNULL(@OnlyRevType2,'') + ','	
	Set	@OnlyRevType3 = ',' + ISNULL(@OnlyRevType3,'') + ','	
	Set	@OnlyRevType4 = ',' + ISNULL(@OnlyRevType4,'') + ','	
	Set	@ExcludeRevType1 = ',' + ISNULL(@ExcludeRevType1,'') + ','	
	Set	@ExcludeRevType2 = ',' + ISNULL(@ExcludeRevType2,'') + ','	
	Set	@ExcludeRevType3 = ',' + ISNULL(@ExcludeRevType3,'') + ','	
	Set	@ExcludeRevType4 = ',' + ISNULL(@ExcludeRevType4,'') + ','	

	SET @OnlyStopEventList = ',' + ISNULL(@OnlyStopEventList,'') + ','
	SET @ExcludeStopEventList = ',' + ISNULL(@ExcludeStopEventList,'') + ','


	Set @trc_exp1_dateMustBeGreaterThan= @MaxDate
	IF @Onlytrc_exp1_dateGreaterThan_N_HoursFromNow>=0
	BEGIN
		Set @trc_exp1_dateMustBeGreaterThan=DateAdd(n, Convert(int,60.0* @Onlytrc_exp1_dateGreaterThan_N_HoursFromNow),GetDate())
	END
	Set @trc_exp2_dateMustBeGreaterThan= @MaxDate
	IF @Onlytrc_exp2_dateGreaterThan_N_HoursFromNow>=0
	BEGIN
		Set @trc_exp2_dateMustBeGreaterThan=DateAdd(n, Convert(int,60.0* @Onlytrc_exp2_dateGreaterThan_N_HoursFromNow),GetDate())
	END
		
 	Declare @R TABLE
	(LayerName Varchar(40),
	ItemID Varchar(8),
	Importance Varchar(1),
	Symbol Varchar(30),
	DataValue [varchar] (255),
	DataLabels [varchar] (100),
	trc_gps_latitude int,
	trc_gps_longitude int,
	trc_gps_date datetime,
	trc_avl_date datetime,
	lgh_enddate datetime,
	OrderHeaderNumber int,
	LegStartCityState varchar(50),
	LegEndCityState varchar(50),
	CurLgh int,
	LghStatus varchar(6),
	AirMilesToDest int,
	AirMPHNeeded int,
	DestCityCode int,
	LatSecondsOfDestCity int,
	LongSecondsOfDestCity int,
	Revtype1 varchar(8),
	Revtype2 varchar(8),
	Revtype3 varchar(8),
	Revtype4 varchar(8),
	FlashFlag char(1),
	cty_GMTDelta int,
	cty_DSTApplies char(1)
	)   

IF @UseScheduleLatestYN = 'N'
	Insert @R 
	Select 
		@LayerName Layer,
		trc_Number ItemID,
		Importance = Substring(IsNull((select ord_priority from orderheader o (nolock) where o.ord_hdrnumber = legheader.ord_hdrnumber),'2'),1,1),
		@ActiveSymbol Symbol,
		-- dbo.Fnc_ConvertLatLongSecondsToALKFormat(trc_gps_latitude,trc_gps_longitude) Location, 
		trc_Number +'|' + t.Trc_type1 + '|' + t.Trc_type2 + '|' + t.Trc_type3 + '|' + t.Trc_type4 + '|' + Trc_owner +'|'
			+ Convert(Varchar(5),trc_gps_date,1) + ' '+Convert(Varchar(5),trc_gps_date,8)  +'|' +
			+ ISNULL((select cty_name +',' + cty_state from city (NOLOCK) where trc_avl_city=cty_code),'UNK') 
		DataValue,
		'ID|TrcType1|TrcType2|TrcType3|TrcType4|TrcOwner|trc_gps_date|AvlCity' DataLabels,
		trc_gps_latitude,
		trc_gps_longitude,
		trc_gps_date,
		trc_avl_date,
		lgh_enddate,
		-- AvlCity=(select cty_name from city where lgh_endcity=cty_code),
		-- AvlState=(select cty_state from city where lgh_endcity=cty_code),
		ISNULL(ord_hdrnumber,0) OrderHeaderNumber,
		LegStartCityState=ISNULL((select cty_name + ', ' + cty_state from city (NOLOCK) where lgh_startcity=cty_code),''),
		LegEndCityState=ISNULL((select cty_name + ', ' + cty_state from city (NOLOCK) where lgh_endcity=cty_code),''),
		trc_pln_lgh CurLgh,
		IsNull(lgh_outstatus,'CMP') LghStatus,
		convert(float,0) AirMilesToDest,
		convert(float,0) AirMPHNeeded,
		lgh_endCity DestCityCode,
		0 LatSecondsOfDestCity,
		0 LongSecondsOfDestCity,
		lgh_Class1,
		lgh_Class2,
		lgh_Class3,
		lgh_Class4,
		'N' as FlashFlag,
		0 cty_GMTDelta,
		null cty_DSTApplies
	from 	tractorprofile T (NOLOCK) Left Join	Legheader (NOLOCK) on t.trc_pln_lgh = legheader.lgh_number
	where 	trc_retiredate>Getdate()
		AND Trc_number<>'UNKNOWN'
		
		AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
		AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
		AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
		AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)
		AND (@OnlyTrc_avl_statusList =',,' or CHARINDEX(',' + RTRIM( ISNULL(Trc_avl_status,'')  ) + ',', @OnlyTrc_avl_statusList) >0)
		AND (@OnlyTrc_trc_ownerList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_owner,'')  ) + ',', @OnlyTrc_trc_ownerList) >0)
		AND (@Onlytrc_companyList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_company,'')  ) + ',', @Onlytrc_companyList) >0)
		
		AND (@Onlytrc_divisionList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_division,'')  ) + ',', @Onlytrc_divisionList) >0)
		
		AND (@Onlytrc_fleetList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_fleet,'')  ) + ',', @Onlytrc_fleetList) >0)
		AND (@Onlytrc_terminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t.trc_terminal,'')  ) + ',', @Onlytrc_terminalList) >0)
		
		AND ISNULL(@trc_exp1_dateMustBeGreaterThan,@MaxDate) > ISNULL(t.trc_exp1_date,'1/1/1950')
		AND ISNULL(@trc_exp2_dateMustBeGreaterThan,@MaxDate) > ISNULL(t.trc_exp2_date,'1/1/1950')
ELSE
	Insert @R 
	Select 
		@LayerName Layer,
		trc_Number ItemID,
		Importance = Substring(IsNull((select ord_priority from orderheader o (nolock) where o.ord_hdrnumber = t1.ord_hdrnumber),'2'),1,1),
		@ActiveSymbol Symbol,
		-- dbo.Fnc_ConvertLatLongSecondsToALKFormat(trc_gps_latitude,trc_gps_longitude) Location, 
		trc_Number +'|' + t3.Trc_type1 + '|' + t3.Trc_type2 + '|' + t3.Trc_type3 + '|' + t3.Trc_type4 + '|' + Trc_owner +'|'
			+ Convert(Varchar(5),trc_gps_date,1) + ' '+Convert(Varchar(5),trc_gps_date,8)  +'|' +
			+ ISNULL((select cty_name +',' + cty_state from city (NOLOCK) where trc_avl_city=cty_code),'UNK') 
		DataValue,
		'ID|TrcType1|TrcType2|TrcType3|TrcType4|TrcOwner|trc_gps_date|AvlCity' DataLabels,
		trc_gps_latitude,
		trc_gps_longitude,
		trc_gps_date,
		trc_avl_date,
		ISNULL(t2.stp_schdtlatest,'20491231'),
		-- AvlCity=(select cty_name from city where lgh_endcity=cty_code),
		-- AvlState=(select cty_state from city where lgh_endcity=cty_code),
		ISNULL(t1.ord_hdrnumber,0) OrderHeaderNumber,
		LegStartCityState=ISNULL((select cty_name + ', ' + cty_state from city (NOLOCK) where lgh_startcity=cty_code),''),
		LegEndCityState=ISNULL((select cty_name + ', ' + cty_state from city (NOLOCK) where t2.stp_city=cty_code),''),
		trc_pln_lgh CurLgh,
		IsNull(lgh_outstatus,'CMP') LghStatus,
		convert(float,0) AirMilesToDest,
		convert(float,0) AirMPHNeeded,
		t2.stp_city DestCityCode,
		0 LatSecondsOfDestCity,
		0 LongSecondsOfDestCity,
		lgh_Class1,
		lgh_Class2,
		lgh_Class3,
		lgh_Class4,
		'N' as FlashFlag,
		0 cty_GMTDelta,
		null cty_DSTApplies
		FROM tractorprofile t3 (NOLOCK)
		Left Join	Legheader_active t1 (NOLOCK) on t3.trc_pln_lgh = t1.lgh_number
		Left Join stops t2 (NOLOCK) on  t1.lgh_number = t2.lgh_number 
					AND (
										(@ExcludeFirstStopYN ='Y' 
											AND stp_mfh_sequence = (									
																	SELECT MIN(stops.stp_mfh_sequence) 
																	FROM legheader (NOLOCK), stops (NOLOCK)
																	WHERE legheader.lgh_number = stops.lgh_number
																		AND legheader.lgh_number = t2.lgh_number
																		AND stp_status = 'OPN' 
																		AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @OnlyStopEventList) >0)
																		AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @ExcludeStopEventList) =0)
																		AND stops.stp_mfh_sequence >1
										 							)
										)
									OR
										(@ExcludeFirstStopYN ='N' 
											AND stp_mfh_sequence = (									
																		SELECT MIN(stops.stp_mfh_sequence) 
																		FROM legheader (NOLOCK), stops (NOLOCK)
																		WHERE legheader.lgh_number = stops.lgh_number
																			AND legheader.lgh_number = t2.lgh_number
																			AND stp_status = 'OPN' 
																			AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @OnlyStopEventList) >0)
																			AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @ExcludeStopEventList) =0)
											 						)
										)
									)
								
								AND (
										(@ExcludeLastStopYN = 'Y' AND stp_mfh_sequence <> (
																							SELECT MAX(stops.stp_mfh_sequence) 
																							FROM legheader (NOLOCK), stops (NOLOCK)
																							WHERE legheader.lgh_number = stops.lgh_number
																								AND legheader.lgh_number = t2.lgh_number
																								AND stp_status = 'OPN' 
																								AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @OnlyStopEventList) >0)
																								AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + RTRIM( stp_event ) + ',', @ExcludeStopEventList) =0)
																								AND stops.stp_mfh_sequence >1
																 						)
										)
									 OR @ExcludeLastStopYN <> 'Y'
									)
		WHERE ISNULL(t1.lgh_tractor, 'UNKNOWN') <> 'UNKNOWN'
		AND trc_retiredate>Getdate()
		AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
		AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
		AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
		AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)
		AND (@OnlyTrc_avl_statusList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.Trc_avl_status,'')  ) + ',', @OnlyTrc_avl_statusList) >0)
		AND (@OnlyTrc_trc_ownerList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_owner,'')  ) + ',', @OnlyTrc_trc_ownerList) >0)
		AND (@Onlytrc_companyList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_company,'')  ) + ',', @Onlytrc_companyList) >0)
		AND (@Onlytrc_divisionList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_division,'')  ) + ',', @Onlytrc_divisionList) >0)
		AND (@Onlytrc_fleetList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_fleet,'')  ) + ',', @Onlytrc_fleetList) >0)
		AND (@Onlytrc_terminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL(t3.trc_terminal,'')  ) + ',', @Onlytrc_terminalList) >0)
		AND ISNULL(@trc_exp1_dateMustBeGreaterThan,@MaxDate) > ISNULL(t3.trc_exp1_date,'1/1/1950')
		AND ISNULL(@trc_exp2_dateMustBeGreaterThan,@MaxDate) > ISNULL(t3.trc_exp2_date,'1/1/1950')


	Delete from @r 
		WHERE (@OnlyRevType1 >',,' and  CHARINDEX(',' + RTRIM( ISNULL(RevType1,'')  ) + ',', @OnlyRevType1) =0)
		OR (@OnlyRevType2 >',,' and  CHARINDEX(',' + RTRIM( ISNULL(RevType2,'')  ) + ',', @OnlyRevType2) =0)
		OR (@OnlyRevType3 >',,' and CHARINDEX(',' + RTRIM( ISNULL(RevType3,'')  ) + ',', @OnlyRevType3) =0)
		OR (@OnlyRevType4 >',,' and CHARINDEX(',' + RTRIM( ISNULL(RevType4,'')  ) + ',', @OnlyRevType4) =0)

	Delete from @r 
		WHERE (@ExcludeRevType1 >',,' and  CHARINDEX(',' + RTRIM( ISNULL(RevType1,'')  ) + ',', @ExcludeRevType1) >0)
		OR (@ExcludeRevType2 >',,' and  CHARINDEX(',' + RTRIM( ISNULL(RevType2,'')  ) + ',', @ExcludeRevType2) >0)
		OR (@ExcludeRevType3 >',,' and CHARINDEX(',' + RTRIM( ISNULL(RevType3,'')  ) + ',', @ExcludeRevType3) >0)
		OR (@ExcludeRevType4 >',,' and CHARINDEX(',' + RTRIM( ISNULL(RevType4,'')  ) + ',', @ExcludeRevType4) >0)

	
	Update @r 
		Set 	LatSecondsOfDestCity 	=ISNULL(cty_latitude,0) * 3600,
			LongSecondsOfDestCity	=IsNull(cty_longitude,0) * 3600,
			cty_GMTDelta = 	city.cty_GMTDelta,
			cty_DSTApplies = city.cty_DSTApplies
		From city (NOLOCK) 
		where DestCityCode =cty_code	   	
	Update @r 
		Set AirMilesToDest =
		dbo.fnc_AirMilesBetweenLatLongSeconds(trc_gps_latitude,LatSecondsOfDestCity,trc_gps_longitude,LongSecondsOfDestCity)
		where  LatSecondsOfDestCity>0 and trc_gps_latitude>0

	If @AdjustTimeZones = 'Y'
	Begin
		declare @OfficeGMTDelta int
		set @OfficeGMTDelta = DATEDIFF(Hour, GETDATE(), GETUTCDATE())

		-- find out if DST is in effect (this will not work if dispatch office is in Arizona)
		declare @ActiveTimeBias int
		declare @Bias int
		exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
		'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
		'ActiveTimeBias', @ActiveTimeBias OUT
		exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
		'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
		'Bias', @Bias OUT

		If @Bias <> @ActiveTimeBias -- DST in affect at this time
			BEGIN
			Update @r 
				Set lgh_enddate = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, lgh_enddate)
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
				and cty_DSTApplies = 'N'
			SET @OfficeGMTDelta = @OfficeGMTDelta + 1
			Update @r 
				Set lgh_enddate = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, lgh_enddate)
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
				and cty_DSTApplies = 'Y'
			END
		ELSE   -- DST not in affect at this time 
			Update @r 
				Set lgh_enddate = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, lgh_enddate)
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
	END
	
	--Select DateDiff(n,'11/15/04',Getdate())
	Update @r 
		Set AirMPHNeeded
		=( convert(float,AirMilesToDest) /
		(convert(float,DateDiff(n,trc_gps_date,lgh_enddate))/60.0 ) - @BufferMinutes )
		Where LghStatus<>'CMP' and AirMilesToDest>1 
		and DateDiff(n,trc_gps_date,lgh_enddate) - @BufferMinutes > 0



	Update @R
		Set Symbol = @LateSymbol
		where (AirMPHNeeded>@AirMPHSpeed		
		or  DateDiff(n,trc_gps_date,lgh_enddate) - @BufferMinutes < 0)
		and AirMilesToDest > 0

If @HighPrioritySymbol > ''
BEGIN
	Update @R
		Set FlashFlag = 'Y'
	where Importance = '1'
	and Symbol = @LateSymbol

	Update @R
		Set Symbol = @HighPrioritySymbol
	where Importance = '1'
END


			 
		Update @r 
		Set Symbol =@AvailableSymbol  
		where LghStatus='CMP'

IF @CustomUnassignedYN = 'Y'
BEGIN
-- Unassigned tractors
		Update @r 
		Set Symbol =@UnassignedSymbol  
		where ItemID In 

(Select [Tractor ID]

From   

(
	
Select
	TempTractors.*,
	[lgh_number] = (select min(lgh_number) from AssetAssignment (NOLOCK) where asgn_number = MaxAssignmentNumber)
From

(


select trc_number as [Tractor ID],
     
         'MaxAssignmentNumber'=
	(select 
		Max(asgn_number) 
	from assetassignment a (NOLOCK)
	where 
		trc_number=asgn_id
		AND
		asgn_type = 'TRC'
		and 
                (asgn_status='CMP')
	        and
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b (NOLOCK)
		where
     			(b.asgn_type = 'TRC'
			and
                	(asgn_status='CMP') 
			and
			a.asgn_id = b.asgn_id)))
     
	

From   tractorprofile (NOLOCK)
Where  trc_number <> 'UNKNOWN'
       And
       (
       trc_driver Is Null
       Or
       RTrim(LTrim(trc_driver)) = ''
       Or
       trc_driver = 'UNKNOWN'
       )
       And
       trc_status <> 'OUT'
       And
       trc_type2 Not In ('LOADER','LOAD','YARD','TBTU')
       And
       trc_terminal <> 'PC'

) as TempTractors

) as TempTractors2
)
END
	





Set @PlainDate = CAST(CONVERT(char(8),dateadd(d,0,@DateStart),112) as datetime)
Set @upd_Daily = GetDate()
DELETE FROM ResNowGPSMapCache  WHERE MetricCode = @MetricCode and PlainDate = @PlainDate
		
Insert Into ResNowGPSMapCache 
	Select 
		@MetricCode,
		@PlainDate, 
		ItemID,
		Symbol,
		trc_gps_latitude/3600.0 AS gps_latitude ,
		trc_gps_longitude/-3600.0 AS gps_longitude,
		trc_gps_date AS gps_date,
		displayText = '  Order # ' + CAST(OrderHeaderNumber AS VARCHAR(10)) + CHAR(10) 
			+ '  Origin: ' + LegStartCityState + CHAR(10) 
			+ '  Destination: ' + LegEndCityState,
		@upd_Daily,
		FlashFlag,
		OrderHeaderNumber
	From @r
		WHERE (@OnlySymbolList =',,' or CHARINDEX(',' + RTRIM( ISNULL(Symbol,'')  ) + ',', @OnlySymbolList) >0)
		and trc_gps_latitude is not null
		and trc_gps_longitude is not null

GO
GRANT EXECUTE ON  [dbo].[MapQ_CurrentGPSProM_Update] TO [public]
GO
