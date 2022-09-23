SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[MapQ_ActiveLoadsToTrucks]
	(
	@LayerName Varchar(40) ='View1:ActiveOrders',  -- NAME OF LAYER for Map
	@OnlyOrd_status Varchar(40) =',AVL,DSP,STD,PLN,', --  NOTE ONLY ACTIVE, NON-COMPLETE ORDERS ARE SUPPORTED

	@OnlyOrdersWithAStopsWithInXMinutesOfNowYN Char(1)='Y', -- IF Y then a STOP on the order's move has 
								-- to have a planned or actual stop (stp_arrivaldate)
								-- with xMinutes of now
	@XMinutesOfNow  int=60,


	@MaxOrderCount int =99999,				-- Maps can be overload with icons
								-- Remember this proc returns a PIN
								-- Per Stop, so an order will always have at least 2 per order

	@MapImportance varchar(6) = '1',			-- Controls Map importance- consult ALK docs

	@RightNCharsOfOrderNumberTouse int =4,			-- Name/ID next to pin consumes Map screen realestate
								-- This allows to trim the displayed ID
								-- Example: Assume you order number like
								-- 1650123. If you set this to 4,
								-- This will change number of order digits
								-- displayed to  '0123'
								-- Note: The actual ID add the STP_event code
								-- to the ID. So '0123' become '0123LLD' 
								-- for the Live Load event on order 1650123

	@AirmilesPerHour int = 40,				-- Proc attempts to do a quick ETA calc
								-- to determine if Truck will make next stop


	@OnlyShowOrderStopsYN CHAR(1)='Y',			-- This will supress non order based stop
								-- Pins from being returned.
								-- If you have a move with 
								-- BMT (Begin MT) City A
								-- LLD (Live Load) City B
								-- LUL (Live Unload) City C
								-- The BMT stop will not be return if this 
								-- setting is Y


	@OnlyShowUncompletedStopsYN CHAR(1) ='Y',		-- IF Y only stp_status="OPN" will be returned



	@OnlyTrcTypeList1 Varchar(255) ='',			-- Retrict loads only assigned to listed tractor
	@OnlyTrcTypeList2 Varchar(255) ='',			-- Classes
	@OnlyTrcTypeList3 Varchar(255) ='',
	@OnlyTrcTypeList4 Varchar(255) ='',


	@OnlyRevTypeList1 Varchar(255) ='',			-- Retrict loads to specified revClasses
	@OnlyRevTypeList2 Varchar(255) ='',			
	@OnlyRevTypeList3 Varchar(255) ='',
	@OnlyRevTypeList4 Varchar(255) ='',


	--'@OnlyTrc_trc_ownerList Varchar(255) ='',
	@Onlytrc_companyList Varchar(255) ='',
	@Onlytrc_divisionList Varchar(255) ='',
	@Onlytrc_fleetList Varchar(255) ='',
	@Onlytrc_terminalList Varchar(255) =''
	)
AS


Declare @GetdateNow datetime
Declare @AirMilesPerMinute float
Declare @DummyCnt varchar(100)

SET NOCOUNT ON  -- PTS46367

--Set isolation level 
Set @DummyCnt='123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*'
Set @AirMilesPerMinute = convert(float,@AirmilesPerHour)/60.0

Set @GetdateNow =Getdate()
Set	@OnlyOrd_status = ',' + ISNULL(@OnlyOrd_status,'') + ','

Set	@OnlyTrcTypeList1 = ',' + ISNULL(@OnlyTrcTypeList1,'') + ','
Set	@OnlyTrcTypeList2 = ',' + ISNULL(@OnlyTrcTypeList2,'') + ','
Set	@OnlyTrcTypeList3 = ',' + ISNULL(@OnlyTrcTypeList3,'') + ','
Set	@OnlyTrcTypeList4 = ',' + ISNULL(@OnlyTrcTypeList4,'') + ','

Set	@OnlyRevTypeList1 = ',' + ISNULL(@OnlyRevTypeList1,'') + ','
Set	@OnlyRevTypeList2 = ',' + ISNULL(@OnlyRevTypeList2,'') + ','
Set	@OnlyRevTypeList3 = ',' + ISNULL(@OnlyRevTypeList3,'') + ','
Set	@OnlyRevTypeList4 = ',' + ISNULL(@OnlyRevTypeList4,'') + ','

--Set	@OnlyTrc_trc_ownerList = ',' + ISNULL(@OnlyTrc_trc_ownerList,'') + ','
Set	@Onlytrc_companyList = ',' + ISNULL(@Onlytrc_companyList,'') + ','
Set	@Onlytrc_divisionList = ',' + ISNULL(@Onlytrc_divisionList,'') + ','
Set	@Onlytrc_fleetList = ',' + ISNULL(@Onlytrc_fleetList,'') + ','
Set	@Onlytrc_terminalList = ',' + ISNULL(@Onlytrc_terminalList,'') + ','


-- List of orders & their moves
Create table #oList
	(

	Ord_hdrnumber int,
	mov_number int,
	ord_number varchar(12),
	Ord_startDate datetime,
	ord_completiondate datetime
	)
-- Create  a List of Stops for the Moves associated with that order
Create table #Stops
	(
	stp_number int,
	stp_event varchar(6),	
	Ord_hdrnumber int,
	mov_number int,
	EarlyDt datetime,

	LatestDt DateTime,
	ScheduleOrActualTime DateTime,
	ScheduleOrActualDepartTime DateTime,
	Status varchar (6),
	AssignTruck varchar(12),
	AssignedDriverID varchar(12),

	IsNextStopYN char(1),
	TruckLatSeconds int,
	TruckLongSeconds Int,
	ckc_number int,
	TruckLocationString varchar(25),
	lgh_number int,
	stp_city int,

	Seq int,
	AirMilesFromLastCheckCall float,
	ETA Datetime,
	ckc_date datetime,
	stp_type Varchar(6),
	CheckCallcomment Varchar(60)	
	)

-- Checks associated with Legheaders on the stops
Create table #ckc
	(
	ckc_number int,
	lgh_number int,
	stp_number int,
	MilestoStop Float,
	ckc_comment varchar(60)

	)	
-- Table of returned pins for mapping	
Create table #L -- 
	(
	LayerName varchar(25),
	
	ID varchar(20),
	Importance varchar(6),
	Symbol varchar(20),
	Location varchar(25),
	PinData varchar(200),
	DataLabels Varchar(200),
	CityRoute Varchar(200),
	mov_number int,
	Seq int,
	stp_type varchar(6),
	Status varchar(6)
	)
	
Set rowcount @MaxOrderCount
Insert into #oList
	Select 
		ord_hdrnumber,
		mov_number,
		Ord_number,
		Ord_startDate,
		Ord_completiondate
	From
		Orderheader (NOLOCK)
	where 	
		--ord_hdrnumber=1128689		AND
		(@OnlyOrd_status =',,' or CHARINDEX(',' + RTRIM( ISNULL(ord_status,'') ) + ',', @OnlyOrd_status) >0)

		AND ord_status<>'CMP' -- No complete loads
		
		AND
		(
			@OnlyOrdersWithAStopsWithInXMinutesOfNowYN<>'Y'	
			OR
			(
				EXISTS (Select * from stops s (NOLOCK)
					where s.mov_number=Orderheader.mov_number		
					AND ABS( DateDiff(n,stp_arrivaldate,@GetdateNow) )<@XMinutesOfNow
					)

			)
		)
		AND -- Secondary test on loads being complete-- must have an OPEN stop
		EXISTS(SELECT * from stops s (NOLOCK) where orderheader.mov_number=s.mov_number and s.stp_status='OPN')

		AND (@OnlyRevTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(ord_revtype1,'') ) + ',', @OnlyRevTypeList1) >0)
		AND (@OnlyRevTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(ord_revtype2,'')  ) + ',', @OnlyRevTypeList2) >0)
		AND (@OnlyRevTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(ord_revtype3,'')  ) + ',', @OnlyRevTypeList3) >0)
		AND (@OnlyRevTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(ord_revtype4,'')  ) + ',', @OnlyRevTypeList4) >0)


Set rowcount 0
Insert into #Stops
	Select 
		stp_number,
		stp_event,	
		#oList.Ord_hdrnumber ,
		#oList.mov_number ,
		stp_schdtearliest EarlyDt , 

		stp_schdtlatest LatestDt ,
		stp_arrivaldate	ScheduleOrActualTime, 
		stp_departuredate	ScheduleOrActualDepartTime,
		Stp_status Status ,
		L.lgh_tractor AssignTruck, 
		L.lgh_Driver1 AssignedDriverID, 

		'N' IsNextStopYN ,
		0 TruckLatSeconds ,
		0 TruckLongSeconds ,
		0 ckc_number,
		'?' TruckLocationString,
		s.lgh_number,
		stp_city,

		stp_mfh_sequence SEQ,
		0 AirMilesFromLastCheckCall,
		'1/1/01' ETA,
		'1/1/01' ckc_date ,	
		stp_type,
		'' CheckCallcomment

	From 	#oList,
		Stops s (NOLOCK),
		Legheader L (NOLOCK)
	Where 
		#oList.Mov_number=S.mov_number
		AND 
		(
			@OnlyShowOrderStopsYN='N'
			OR
			(
			Stp_type in ('PUP','DRP')

			)
		)
		AND
		L.lgh_number=S.lgh_number
		AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
		AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
		AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
		AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)
--	AND (@OnlyTrc_trc_ownerList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_owner,'')  ) + ',', @OnlyTrc_trc_ownerList) >0)
	AND (@Onlytrc_companyList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_company,'')  ) + ',', @Onlytrc_companyList) >0)
	AND (@Onlytrc_divisionList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_division,'')  ) + ',', @Onlytrc_divisionList) >0)
	AND (@Onlytrc_fleetList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_fleet,'')  ) + ',', @Onlytrc_fleetList) >0)
	AND (@Onlytrc_terminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_terminal,'')  ) + ',', @Onlytrc_terminalList) >0)

	AND 
	(
		@OnlyShowUncompletedStopsYN='Y'
		OR
		(
		stp_status='OPN'
		)
		
	)

Update #Stops
	Set 	IsNextStopYN='Y', 
		TruckLocationString= cty_name +','+cty_state -- We'll looked the closest Checkcall later...
	From Stops (NOLOCK), city (NOLOCK)
	where 	stops.mov_number = #Stops.mov_number
		and 
		stops.stp_mfh_sequence= #Stops.seq-1
		AND
		#Stops.status='OPN'
		AND 
		stops.stp_status<>'OPN'
		and
		Stops.stp_city=cty_code

Update #Stops
	Set IsNextStopYN='Y'
	where 	
		#Stops.seq=1
		AND
		#Stops.status='OPN'

-- Build List of Checkcall for Legheaders in Stops list
insert into #ckc
	Select 
		ckc_number,
		ckc_lghnumber,
		stp_number,
		0 miles,
		Left(ckc_comment,60) --sp_help checkcall
	From
		checkcall (NOLOCK),
		(Select lgh_number,stp_number from #stops where IsNextStopYN='Y') LegList
	where
		checkcall.ckc_lghnumber=lgh_number

-- Find the closest Checkcall to the stop
Update #ckc
	Set MilestoStop = 
	(Select 
		dbo.fnc_AirMilesBetweenLatLongSeconds(c2.ckc_latseconds,cty_latitude *3600, c2.ckc_longseconds,cty_longitude*3600)
	From 
		checkcall c2 (NOLOCK),
		stops (NOLOCK),
		city  (NOLOCK)
	where 
		c2.ckc_number=#ckc.ckc_number
		and
		stops.stp_number=#ckc.stp_number
		and
		city.cty_code=stp_city
	)

-- Set the TruckLatSeconds etc based on closest checkcall
Update #Stops
	Set 
		TruckLatSeconds =ckc_latseconds,
		TruckLongSeconds = ckc_longseconds,
		ckc_number=C.ckc_number,
		AirMilesFromLastCheckCall= MilestoStop,
		ckc_date=c.ckc_date,
		CheckCallcomment= #ckc.ckc_comment
	From 
		#ckc,
		checkcall c (NOLOCK)

	where 
		IsNextStopYN='Y'
		AND
		#ckc.stp_number=#stops.stp_number	
		AND
		#ckc.MilestoStop=
		(select min(c2.MilestoStop) from #ckc c2 where c2.stp_number=#stops.stp_number)
		and
		c.ckc_number=#ckc.ckc_number

Update #Stops
	Set TruckLocationString= dbo.Fnc_ConvertLatLongSecondsToALKFormat(TruckLatSeconds,TruckLongSeconds)
	where TruckLatSeconds>0 and TruckLongSeconds>0

Update #Stops
	Set ETA =DateAdd(n,AirMilesFromLastCheckCall/@AirMilesPerMinute ,ckc_date)
	where AirMilesFromLastCheckCall>0

-- Build final list of pins
-- 2 steps-- first the pins for the loads, then further below the pins for the trucks
insert into #L 
	Select 
		@LayerName LayerName ,
	Right(ord_hdrnumber, @RightNCharsOfOrderNumberTouse) + rtrim(stp_event) ID,
	@MapImportance Importance ,
	
	Case 
		WHEN Status='DNE' AND stp_type='PUP' then 'BLUE BOX'
		WHEN Status='DNE' AND stp_type='DRP' then 'BLUE Circle'
		When Status='OPN' and IsNextStopYN='Y' AND ETA>LatestDT  and stp_type='PUP'THEN 'RED BOX'
		When Status='OPN' and IsNextStopYN='Y' AND ETA>LatestDT  and stp_type='DRP'THEN 'RED Circle'
		When Status='OPN' and IsNextStopYN='Y' AND ETA<=LatestDT  and stp_type='PUP'THEN 'GREEN BOX'
		When Status='OPN' and IsNextStopYN='Y' AND ETA<=LatestDT  and stp_type='DRP'THEN 'GREEN Circle'
		When Status='OPN' and IsNextStopYN='Y' AND ETA> LatestDT  and stp_type not in('DRP','PUP') THEN 'RED PUSHPIN'

		WHEN Status='OPN' AND stp_type='PUP' AND ASSIGNTRUCK='UNKNOWN'then 'YELLOW BOX'
		WHEN Status='OPN' AND stp_type='DRP' AND ASSIGNTRUCK='UNKNOWN'then 'YELLOW Circle'
		WHEN Status='OPN' AND stp_type NOT IN ('DRP','PUP') AND ASSIGNTRUCK='UNKNOWN'then 'YELLOW PUSHPIN'

		WHEN Status='OPN' AND stp_type ='DRP' then 'Green Circle'
		WHEN Status='OPN' AND stp_type ='PUP' then 'GREEN BOX'
		WHEN Status='DNE' then 'BLUE PUSHPIN'
		ELSE 'GREEN PUSHPIN' END
	Symbol ,
	Location= (Select cty_name +',' +cty_state from city (NOLOCK) where cty_code=stp_city),
		Right(ord_hdrnumber, @RightNCharsOfOrderNumberTouse) + rtrim(stp_event)
		+'|' +
		convert(varchar(12),mov_number)
		+'|' +
		convert(varchar(5),EarlyDt,1)+' ' +convert(varchar(5),EarlyDt,8)
		+' to ' +
		convert(varchar(5),LatestDt,1)+' ' +convert(varchar(5),LatestDt,8)
		+'|' +
		convert(varchar(5),ScheduleOrActualTime,1)+' ' +convert(varchar(5),ScheduleOrActualTime,8)
		+'|' + 
		(CASE WHEN ETA>'1/1/03' THEN convert(varchar(5),ETA,1)+' ' +convert(varchar(5),ETA,8)
		ELSE '-' END)
		+'|' + 
		AssignTruck 
		+'|' + 
		REPLACE(left(dbo.fnc_StopsListForMovNumber(mov_number),80),'|','-')
	PinData,
		'ID|Move#|TimeWindow|SchedActualDt|BestETA|Truck|Route'
	DataLabels ,
	CityRoute =CASE WHEN SEQ=(Select min(S2.SEQ) from #stops s2 where s2.mov_number=#stops.mov_number)  then dbo.fnc_StopsListForMovNumber(mov_number) ELSE'' END,
	mov_number ,
	Seq ,
	stp_type,
	Status

From #stops

-- Next add trucks
Insert into #L
	Select 
		@LayerName+'TRK' LayerName ,
	AssignTruck ID,
	@MapImportance Importance ,
	
	Case 
		When Status='OPN' and IsNextStopYN='Y' AND ETA>LatestDT  THEN 'Red Truck'
		ELSE 'GREEN TRUCK' END
	Symbol ,
	Location= TruckLocationString,
		Right(ord_hdrnumber, @RightNCharsOfOrderNumberTouse) + rtrim(stp_event)
		+'|' +
		convert(varchar(12),mov_number)
		+'|' +
		convert(varchar(5),ckc_date,1)+' ' +convert(varchar(5),ckc_date,8) + ' CheckCall date'
		+'|' +
		convert(varchar(5),ScheduleOrActualTime,1)+' ' +convert(varchar(5),ScheduleOrActualTime,8)
		+'|' + 
		(CASE WHEN ETA>'1/1/03' THEN convert(varchar(5),ETA,1)+' ' +convert(varchar(5),ETA,8)
		ELSE '-' END)
		+'|' + 
		CheckCallcomment
		+'|' + 
		REPLACE(left(dbo.fnc_StopsListForMovNumber(mov_number),80),'|','-')
	PinData,
		'ID|Move#|TimeWindow|SchedActualDt|BestETA|Truck|Route'
	DataLabels ,
	CityRoute ='',--CASE WHEN SEQ=(Select min(S2.SEQ) from #stops s2 where s2.mov_number=#stops.mov_number)  then dbo.fnc_StopsListForMovNumber(mov_number) ELSE'' END,
	mov_number ,
	Seq ,
	stp_type,
	Status
From #stops
where 	Len(TruckLocationString)>1 and 	AssignTruck<>'UNKNOWN'

Select * from #L order by Mov_number, seq

GO
GRANT EXECUTE ON  [dbo].[MapQ_ActiveLoadsToTrucks] TO [public]
GO
