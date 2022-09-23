SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[MapQ_OOR_Trucks]
	(
	@LayerName Varchar(40) ='OORTrucks',
	@MilesPerHourPassedIN			Float =45,
		--@MininmumHrsLate			FLOAT = 1,
		@MininmumMilesOOR			FLOAT = 50,
		@OnlyRevClass1List varchar(128) ='',
		@OnlyRevClass2List varchar(128) ='',
		@OnlyRevClass3List varchar(128) ='',
		@OnlyRevClass4List varchar(128) ='',
	

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
	@OnlyTrc_numberList Varchar(500)='',

	@DaysBackFromNow int =0,
	@DebugOn int =0
	)
AS

Declare @trc_exp1_dateMustBeGreaterThan DateTime
Declare @trc_exp2_dateMustBeGreaterThan DateTime
Declare @DateStart datetime
	Declare @LowDate datetime
	Declare @HighDate datetime
	Declare @MilesPerHour float
Declare @ETALateReportYN Char(1)
Declare @OORReportYN Char(1)
	SET @OORReportYN='Y'
	SET @ETALateReportYN ='N'

Declare @MaxDate Datetime

SET NOCOUNT ON  -- PTS46367

Set @MaxDate='12/31/2050 23:59'
Set @DateStart= Convert(dateTime, convert(varchar(8),Getdate(),1)) -- Floor of the day

if @DaysBackFromNow<>0  -- Really only added so I run tests on old data
BEGIN
	Set @DateStart=DateAdd(d,-@DaysBackFromNow,GetDate())
	Set @HighDate=DateAdd(D,3,@DateStart)
END

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
Set	@OnlyTrc_numberList = ',' + ISNULL(@OnlyTrc_numberList,'') + ','


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
--========================================

--	Set nocount on	
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @LowDate =@DateStart
	Set @HighDate =ISNULL(@HighDate, DateAdd(d, 3,Getdate()) ) -- May set above if doing old data testing

	iF upper(@ETALateReportYN)='Y' SET @OORReportYN='N'
	IF UPPER(@OORReportYN)='Y' 	SET @ETALateReportYN ='N'



	Set @MilesPerHour =@MilesPerHourPassedIN

	Create Table #R (
	Ord_ord_number 		Varchar(10)	NULL Default '',
	Ord_Mov_number 		int		NULL Default 0,
	ord_ord_company		Varchar(8)	NULL Default '',


	cmp_ord_customer_name	Varchar(30) 	NULL Default '',
	ord_revtype1		Varchar(6) 	NULL Default '',
	ord_priority		Varchar(6) 	NULL Default '',
	ord_bookedby		Varchar(20) 	NULL Default '',

	stp_stp_event		Varchar(6) 	NULL Default '',
	Stp_stp_schdtlatest	Datetime	NULL,
	mpp_mpp_terminal	Varchar(6) 	NULL Default '',
	mpp_mpp_teamleader	Varchar(6) 	NULL Default '',
	lgh_lgh_driver1		Varchar(8) 	NULL Default '',
	lgh_lgh_tractor		Varchar(8) 	NULL Default '',
--	evt_evt_trailer1	Varchar(13) 	NULL Default '',
		cmd_cmd_hazardous	int 		NULL Default 0,
		ckc_ckc_comment		Varchar(254) 	NULL Default '',
		AirMilestoNext		float		NULL Default 0,
		EtaToNext		Datetime	NULL,
		MinutesVarianceToAppt	Int		NULL Default 0,
		RunningLateYN		Char(1) 	NULL Default 'N',
		OOR_mi			Float	 	NULL Default 0,
		OOR_Percentage		Float 		NULL Default 0,

		ckc_ckc_number		int		NULL Default 0,
		ckc_ckc_city		int		NULL Default 0,
		cty_ckc_city_cty_nmstct	varchar(25) 	NULL Default '',
		ckc_ckc_commentlarge	Varchar(254) 	NULL Default '',
		ckc_ckc_minutes_to_final	int 		NULL Default 0,
		ckc_ckc_latseconds		int 		NULL Default 0,
		ckc_ckc_longseconds		int 		NULL Default 0,
		ckc_ckc_date		Datetime 	NULL,
		ckc_ckc_miles_to_final	float 		NULL Default 0,

		stp_Last_actual_stp_number int 		NULL Default 0,

	stp_Next_actual_stp_number int 		NULL Default 0,
	lgh_lgh_number		int  		NULL Default 0,

	ord_status		Varchar(6)	NULL Default '',
	stp_Next_actual_stp_arrivaldate Datetime 		NULL,

		lgh_Last_Lgh_numberForTractorwithUnfinishedStop int Null Default 0,		
	lgh_lgh_startdate Datetime NULL,
	Ord_ord_hdrnumber 		int NULL Default 0,

	AirMilesFromLastStopToCurrent FLOAT NULL Default 0,
	AirMilesFromLastStopToCheckCall FLOAT NULL Default 0,
	AirMilesFromCheckCallToNext FLOAT NULL Default 0,

	lgh_lgh_endDate Datetime,
	NextStop_stp_city int
	)

	Create table #Ckc
		(
		ckc_ckc_number int,
		ckc_ckc_date datetime,
		ckc_ckc_tractor varchar(8),
		ckc_ckc_lghnumber int,
		ckc_ckc_city int,
		NextStopCityCode int,
		AirMilesToCity Float
		)


	Insert into #R (
		lgh_lgh_number,
		Ord_ord_number, 		
		Ord_Mov_number,
		
		ord_ord_company,	--Varchar(8)	NULL Default '',
		cmp_ord_customer_name,	--Varchar(30) 	NULL Default '',
		ord_revtype1,		--Varchar(6) 	NULL Default '',
		ord_priority,		--Varchar(6) 	NULL Default '',
		ord_bookedby,		--Varchar(20) 	NULL Default '',


		stp_stp_event,		--Varchar(6) 	NULL Default '',
		Stp_stp_schdtlatest,	--Datetime	NULL,
		mpp_mpp_terminal,	--Varchar(6) 	NULL Default '',
		mpp_mpp_teamleader,	--Varchar(6) 	NULL Default '',

		lgh_lgh_driver1,	--	Varchar(8) 	NULL Default '',
		lgh_lgh_tractor,		--	Varchar(8) 	NULL Default '',
--		evt_evt_trailer1,	--Varchar(13) 	NULL Default '',

		--stp_Last_actual_stp_number,-- int 		NULL Default 0,
		stp_Next_actual_stp_number,-- int 		NULL Default 0,
		-- ABOVE lgh_lgh_number,		--int  		NULL Default 0,

		ord_status,		--Varchar(6)	NULL Default ''	
		stp_Next_actual_stp_arrivaldate,

		lgh_lgh_startdate,
		Ord_ord_hdrnumber,
		lgh_lgh_endDate,
		NextStop_stp_city	
		)
	Select 
		L.lgh_number,
		L.ord_hdrnumber,
		L.mov_number,
		o.ord_company,	--Varchar(8)	NULL Default '',
		CompanyOrd_customer.cmp_name,	--Varchar(30) 	NULL Default '',
		o.ord_revtype1,		--Varchar(6) 	NULL Default '',
		o.ord_priority,		--Varchar(6) 	NULL Default '',
		o.ord_bookedby,		--Varchar(20) 	NULL Default '',

		Nextstop.stp_event,		--Varchar(6) 	NULL Default '',
		Nextstop.stp_schdtlatest,	--Datetime	NULL,
		L.mpp_terminal,			--Varchar(6) 	NULL Default '',
		L.mpp_teamleader,		--Varchar(6) 	NULL Default '',

		L.lgh_driver1,			--	Varchar(8) 	NULL Default '',
		L.lgh_tractor,		--	Varchar(8) 	NULL Default '',

--		E.evt_trailer1,	
		--LastStop.stp_number,-- int 		NULL Default 0,
		Nextstop.stp_number,-- int 		NULL Default 0,
		-- ABOVE L.lgh_number,		--int  		NULL Default 0,

		o.ord_status,		--Varchar(6)	NULL Default ''	

		NextStop.stp_arrivaldate,

		L.lgh_startdate,
		o.ord_hdrnumber,
		L.lgh_Enddate,
		NextStop.stp_city 
	from 
		legheader_active L (NOLOCK),
		Orderheader o(NOLOCK),
		Company CompanyOrd_customer(NOLOCK),
		stops Nextstop(NOLOCK),
		TractorProfile T (NOLOCK)
--		,Event E (NOLOCK)


	where 
		lgh_outstatus<> 'CMP'

		AND EXISTS(Select * from stops s (NOLOCK) where s.lgh_number=l.lgh_number and s.stp_status='DNE')

		-- ANd there exists a check call for the legh with matching equipment
		AND EXISTS(	Select * 
				from 	checkcall (NOLOCK)
				where 	ckc_lghnumber=l.lgh_number 
					and
					lgh_tractor=ckc_tractor
					AND
					(
						(
							ckc_asgntype='DRV'	
							AND 
							ckc_asgnID=lgh_driver1
						)
						OR
						ckc_asgntype='TRC'	

					)
			)
						
		AND lgh_tractor<>'UNKNOWN'

		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
		AND
		Nextstop.lgh_number=L.lgh_number
		and
		Nextstop.stp_mfh_sequence=
			(Select min(stp_mfh_sequence)
			From stops s (NOLOCK)
			where
				s.lgh_number=l.lgh_number
				and	
				s.stp_status<>'DNE'
				and
				ISNULL(s.ord_hdrnumber,0)> 0
			)
		AND
		o.ord_hdrnumber=l.ord_hdrnumber
		AND
		o.ord_hdrnumber>0
		and
		CompanyOrd_customer.cmp_id=o.ord_company

		AND

		T.trc_Number=lgh_tractor

		AND
	trc_retiredate>Getdate()
	AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
	AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
	AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
	AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)

	AND (@OnlyTrc_avl_statusList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.Trc_avl_status,'')  ) + ',', @OnlyTrc_avl_statusList) >0)
	AND (@OnlyTrc_trc_ownerList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_owner,'')  ) + ',', @OnlyTrc_trc_ownerList) >0)
	AND (@Onlytrc_companyList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_company,'')  ) + ',', @Onlytrc_companyList) >0)
	AND (@Onlytrc_divisionList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_division,'')  ) + ',', @Onlytrc_divisionList) >0)
	AND (@Onlytrc_fleetList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_fleet,'')  ) + ',', @Onlytrc_fleetList) >0)
	AND (@Onlytrc_terminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_terminal,'')  ) + ',', @Onlytrc_terminalList) >0)

	AND ISNULL(@trc_exp1_dateMustBeGreaterThan,@MaxDate) > ISNULL(T.trc_exp1_date,'1/1/1950')
	AND ISNULL(@trc_exp2_dateMustBeGreaterThan,@MaxDate) > ISNULL(T.trc_exp2_date,'1/1/1950')
	
	AND (@OnlyTrc_numberList =',,' or CHARINDEX(',' + RTRIM( ISNULL(T.trc_number,'')  ) + ',', @OnlyTrc_numberList) >0)


	


--=========================================================================================================
-- Find the last completed stop on this legheader, if it exists
	Update #R
	Set lgh_Last_Lgh_numberForTractorwithUnfinishedStop=
	ISNULL(	
		(
		Select 	Min(l1.lgh_number)
		From 	Legheader l1 (NOLOCK), stops s1 (NOLOCK)
		where 	L1.lgh_number=#R.lgh_lgh_number
			and
			s1.lgh_number=L1.lgh_number
			and
			s1.stp_status='DNE'
		)
		
		,0)
	where lgh_lgh_tractor <> 'UNKNOWN'
--=========================================================================================================
-- Find the last completed stop on the previous legheader, if it exists

	Update #R
	Set lgh_Last_Lgh_numberForTractorwithUnfinishedStop=
	ISNULL(	
		(
		Select 	
			Min(s1.lgh_number)
		From 	stops s1(NOLOCK),
			AssetAssignment a(NOLOCK)
		where 	
			a.asgn_id=lgh_lgh_tractor
			and
			a.asgn_type='TRC'
			and 
			a.asgn_date=
				(Select max(a2.asgn_date) 
				From assetassignment a2 (NOLOCK)
				where
					a2.asgn_id=lgh_lgh_tractor
					and
					a2.asgn_type='TRC'
					and
					a2.Asgn_date < #r.lgh_lgh_startdate
					and
					a2.asgn_status='CMP'
				)
			AND
			s1.lgh_number=a.lgh_number
			and
			s1.stp_status='DNE'
		)
		
		,0)
	where 
		lgh_lgh_tractor <> 'UNKNOWN'
		AND
		lgh_Last_Lgh_numberForTractorwithUnfinishedStop=0
		


--=========================================================================================================

	Update #R
	Set stp_Last_actual_stp_number=
		(select s1.stp_number
		From 
			stops s1(NOLOCK)
			
		where 
			s1.lgh_number=lgh_Last_Lgh_numberForTractorwithUnfinishedStop
			And
			s1.stp_mfh_sequence=
			(Select max(s2.stp_mfh_sequence)
			From 	Stops s2 (NOLOCK)
			where s2.lgh_number=s1.lgh_number
				and 
				s2.stp_status='DNE'
			)
		)
	where 
		lgh_Last_Lgh_numberForTractorwithUnfinishedStop>0
--=========================================================================================================
	
	Update #r
	Set cmd_cmd_hazardous
	= (	Select max(isNull(cmd_hazardous,0))
		From 	
			orderheader o(NOLOCK),
			stops s(NOLOCK),
			Freightdetail f(NOLOCK),
			Commodity c(NOLOCK)
		where
			o.ord_hdrnumber=ord_ord_hdrnumber
			and
			s.mov_number=o.mov_number
			and
			s.ord_hdrnumber=o.ord_hdrnumber
			and
			s.stp_number=F.stp_number
			and
			c.cmd_code=F.cmd_code
	)
--=========================================================================================================
-- NEW- 
Insert into #Ckc
		(
		ckc_ckc_number ,
		ckc_ckc_date ,
		ckc_ckc_tractor ,
		ckc_ckc_lghnumber ,
		ckc_ckc_city ,
		NextStopCityCode ,
		AirMilesToCity 
		)
SELECT
		ckc_number ,
		ckc_date ,
		ckc_tractor ,
		ckc_lghnumber ,
		ckc_city ,
		#r.NextStop_stp_city,
		0 AirMilesToCity 
From 
	Checkcall c (NOLOCK),
	#r (Nolock)
	
where 
	c.ckc_lghnumber =#r.lgh_lgh_number
	and
	c.ckc_latseconds>0
if @DebugOn<>0 (select * from #ckc)
Update  #Ckc
	Set AirMilesToCity=dbo.fnc_AirMilesBetweenCityCodes(ckc_ckc_city,NextStopCityCode)
if @DebugOn<>0 (select * from #ckc)	
	
Update #r
	Set ckc_ckc_number=
	ISNULL(
		(
		Select 	Max(#Ckc.ckc_ckc_number)
		From 	#ckc
		WHERE
			#ckc.ckc_ckc_lghnumber=#r.lgh_lgh_number
			AND
			#ckc.AirMilesToCity=
			(select min(c2.AirMilesToCity) 
			From #ckc c2 
			where c2.ckc_ckc_lghnumber=#ckc.ckc_ckc_lghnumber
			)
		)
	,0)



--END NEW
--==========================================================================
--ckc_ckc_number -- first find any for the current Lgh_nubmer
	Update #r
	Set ckc_ckc_number=
	ISNULL(
		(select max(ckc_number) 
		from checkcall(NOLOCK)
		where 
			ckc_lghnumber=lgh_lgh_number
			
			
		)
		,0)

	where ckc_ckc_number=0
--=========================================================================================================

	Update #r
	Set ckc_ckc_number=
	ISNULL(
		(select max(ckc_number) 
		from checkcall(NOLOCK)
		where 
			ckc_tractor=lgh_lgh_tractor
			and 
			ckc_date=
			(select max(c2.ckc_date)
			from checkcall c2 (NOLOCK)
			where c2.ckc_tractor=lgh_lgh_tractor
			)
		)
		,0)

	where 	ckc_ckc_number=0
		and
		lgh_lgh_tractor<>'UNKNOWN'
--=========================================================================================================

	Update #r 
	Set
		ckc_ckc_comment		=ckc_comment,
		ckc_ckc_city		=ckc_city,
		--cty_ckc_city_cty_nmstct	varchar(25) 	NULL Default '',
		ckc_ckc_commentlarge	= ckc_commentlarge,	
		ckc_ckc_minutes_to_final=ckc_minutes_to_final,
		ckc_ckc_latseconds	=ckc_latseconds,
		Ckc_ckc_longseconds	=ckc_longseconds,
		Ckc_ckc_date		=ckc_date,
		Ckc_ckc_miles_to_final	=ckc_miles_to_final
	From 
		Checkcall(NOLOCK)
	where 
		#r.ckc_ckc_number=ckc_number
		and
		#r.ckc_ckc_number>0
--=========================================================================================================

Update #r 
	Set cty_ckc_city_cty_nmstct =cty_nmstct
	from city(NOLOCK)
	where city.cty_code=ckc_ckc_city
	and 
	ckc_ckc_city>0	
--=========================================================================================================
Update #r 
	Set AirMilestoNext=
	Convert(float,
 ISNULL(	
			-- Convert values from degrees to radians 
	(
	Select 
	Acos(
		
		cos(	(
				Convert(decimal(6,2),(convert(float,ckc_ckc_latseconds)/3600))
				* 3.14159265358979 / 180)  )  *
		cos(	(cityNext.cty_latitude * 3.14159265358979 / 180)  )  *
		
                cos (  
			(
				Convert(decimal(6,2),(convert(float,ckc_ckc_longseconds)/3600))
			* 3.14159265358979 / 180) - 
			(cityNext.cty_longitude * 3.14159265358979 / 180)
		    )	+
		Sin (	(
				Convert(decimal(6,2),(convert(float,ckc_ckc_latseconds)/3600))
			* 3.14159265358979 / 180) ) *
		Sin (	(cityNext.cty_latitude * 3.14159265358979 / 180) ) 	
	    ) * 3956.5
	)
,9999)
)
	From 
		city cityNext(NOLOCK),
		stops(NOLOCK) 
	where 
		Stops.stp_number=stp_Next_actual_stp_number
		and
		stops.stp_city=cityNext.cty_code
		and
		#R.ckc_ckc_latseconds>0
		and
		cityNext.cty_latitude>0
--=========================================================================================================
Update #r 
	Set EtaToNext =
		DateAdd(mi,
			( (AirMilestoNext/@MilesPerHour)/60.0   ),  -- Miles/milesPer hour converted to minutes
			ckc_ckc_date
		        )
					
	Where	
		AirMilestoNext>0

Update #r 
	Set MinutesVarianceToAppt=
		DateDiff(	mi,
				Stp_stp_schdtlatest,	
				EtaToNext
				
			)
	where
		AirMilestoNext>0		
Update #r 
	Set RunningLateYN =
		(Case When MinutesVarianceToAppt>0 then 'Y'
		else 'N'
		END)
		
--============================================================================================================

Update #R
	Set 	AirMilesFromLastStopToCurrent =
	Convert(decimal(6,1),
 ISNULL(	
			-- Convert values from degrees to radians 
	(
	Select 
	Acos(
		
		cos(	(
				cityPrev.cty_latitude
				* 3.14159265358979 / 180)  )  *
		cos(	(cityNext.cty_latitude * 3.14159265358979 / 180)  )  *
		
                cos (  
			(
				cityPrev.cty_longitude
			* 3.14159265358979 / 180) - 
			(cityNext.cty_longitude * 3.14159265358979 / 180)
		    )	+
		Sin (	(
				cityPrev.cty_latitude
			* 3.14159265358979 / 180) ) *
		Sin (	(cityNext.cty_latitude * 3.14159265358979 / 180) ) 	
	    ) * 3956.5
	)
,9999)
)	
	From 
		city cityNext(NOLOCK),
		city cityPrev(NOLOCK),
		stops StopsNext(NOLOCK),
		stops StopsPrev(NOLOCK)
	where 
		StopsNext.stp_number=stp_Next_actual_stp_number
		and
		StopsNext.stp_city=cityNext.cty_code
		and
		StopsPrev.stp_number=stp_Last_actual_stp_number
		and
		StopsPrev.stp_city=cityPrev.cty_code
		and
		cityNext.cty_latitude>0
		and
		cityPrev.cty_latitude>0
		and
		stp_Last_actual_stp_number>0		
		and
		lgh_lgh_tractor<>'UNKNOWN'
		and 
		cityNext.cty_code<> cityPrev.cty_code
		and 
		(cityNext.cty_latitude * 1000 +  cityNext.cty_longitude)
		<>
		(cityPrev.cty_latitude * 1000 +  cityPrev.cty_longitude)
--END


--========================================================================================
--AirMilesFromLastStopToCheckCall
Update #r 
	Set AirMilesFromLastStopToCheckCall=
	Convert(float,
 ISNULL(	
			-- Convert values from degrees to radians 
	(
	Select 
	Acos(
		
		cos(	(
				Convert(decimal(6,2),(convert(float,ckc_ckc_latseconds)/3600))
				* 3.14159265358979 / 180)  )  *
		cos(	(cityPrev.cty_latitude * 3.14159265358979 / 180)  )  *
		
                cos (  
			(
				Convert(decimal(6,2),(convert(float,ckc_ckc_longseconds)/3600))
			* 3.14159265358979 / 180) - 
			(cityPrev.cty_longitude * 3.14159265358979 / 180)
		    )	+
		Sin (	(
				Convert(decimal(6,2),(convert(float,ckc_ckc_latseconds)/3600))
			* 3.14159265358979 / 180) ) *
		Sin (	(cityPrev.cty_latitude * 3.14159265358979 / 180) ) 	
	    ) * 3956.5
	)
,9999)
)
	From 
		city cityPrev(NOLOCK),
		stops(NOLOCK)
	where 
		Stops.stp_number=stp_Last_actual_stp_number
		and
		stops.stp_city=cityPrev.cty_code
		and
		#R.ckc_ckc_latseconds>0
		and
		cityPrev.cty_latitude>0

--=========================
Update #r
	Set AirMilesFromCheckCallToNext =AirMilestoNext
	
--=========================
update #r 
	Set OOR_mi =
		(AirMilesFromLastStopToCheckCall + AirMilesFromCheckCallToNext)
			-
		(AirMilesFromLastStopToCurrent)
	where
		AirMilesFromLastStopToCheckCall>0 and
		AirMilesFromCheckCallToNext>0		and
		AirMilesFromLastStopToCurrent>0
		and 
		((AirMilesFromLastStopToCheckCall + AirMilesFromCheckCallToNext)	-(AirMilesFromLastStopToCurrent))
		>
		0
--=========================
update #r 
	Set OOR_Percentage =
		OOR_mi/AirMilesFromLastStopToCurrent
	where OOR_mi>0

--=========================
/*
if @OORReportYN<> 'Y'  -- LATE REPORT
	BEGIN
	IF (@ShowDetail=1)
		Select 
			--MinutesVarianceToAppt [Minutes Late],	
			(CASE WHEN MinutesVarianceToAppt > 24 * 60 THEN '>1 day'
			ELSE ' '+ convert(varchar(5),convert( datetime, (MinutesVarianceToAppt/60.0)/24),8) +' '
			END) Late,

			Ord_ord_number [Order #],
			stp_stp_event [Event],	
				Convert(varchar(5),Stp_stp_schdtlatest,1)+ ' ' + Convert(varchar(5),Stp_stp_schdtlatest,8) 
			[Latest Dt],	
				convert(decimal(10,2),AirMilestoNext) 
			[Miles to Next],	
				Convert(varchar(5),EtaToNext,1)+ ' ' + Convert(varchar(5),EtaToNext,8) 
			[Current ETA],	

			City=(select Left(cty_name,18) + ',' + cty_state from  city where cty_code=stp_city),
			s.cmp_id CompanyID,
			lgh_lgh_driver1 [Driver #],	
			lgh_lgh_tractor [Power #],	
--			evt_evt_trailer1 [Trailer #],	
			left(ckc_ckc_comment,40) [Last GPS location],	

			Ord_Mov_number [Move #],	
			ord_priority [Order Priority],	
			ord_revtype1 [Rev Type 1],	

			mpp_mpp_terminal [Driver terminal],	
			mpp_mpp_teamleader [Driver team leader],	
			(Case when cmd_cmd_hazardous>0 then 'Y'
			ELSE 'N'
			END) [Commod HazMat Y/N],	
			--RunningLateYN [Running Late Y/N],	
			--OOR_mi [OOR mi],	
			--OOR_Percentage [OOR %]

			[Order booked by user]= ISNULL( (Select rtrim(usr_lname)+',' + rtrim(usr_fname) from ttsusers where ord_bookedby=usr_userid),'UNKNOWN')


		from 
			#R (NOLOCK),
			Stops s
	
		where 
			S.stp_number = stp_Next_actual_stp_number
			AND
			(convert(float,MinutesVarianceToAppt)/60.0)> @MininmumHrsLate

		Order by MinutesVarianceToAppt DESC

		SELECT @ThisCount = (Select count(*) from #r where  (convert(float,MinutesVarianceToAppt)/60.0)> @MininmumHrsLate )
		SELECT @ThisTotal = (Select count(*) from #r)		

		SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


END
*/
Set nocount off	
if @OORReportYN= 'Y' 
BEGIN
	
	Select 
		@LayerName Layer,
		lgh_lgh_tractor TractorID,
		'1' Importance,

	(CASE WHEN RunningLateYN <>'Y' then 'GREEN TRUCK' ELSE 'RED TRUCK' END) Symbol,
	--dbo.Fnc_ConvertLatLongSecondsToALKFormat(trc_gps_latitude,trc_gps_longitude) Location, 
	dbo.Fnc_ConvertLatLongSecondsToALKFormat(ckc_ckc_latseconds,ckc_ckc_longseconds) Location, 


		lgh_lgh_tractor +'|' + 
		Ord_ord_number + '|' + 
		lgh_lgh_driver1 + '|' + 
		Convert(varchar(8),OOR_mi) + 	'|' + 
		Convert(varchar(8),AirMilestoNext) + 	'|' + 
		Convert(varchar(8),EtaToNext,1) +' '+Convert(varchar(5),EtaToNext,8)+ 	'|' + 
		Convert(Varchar(8),MinutesVarianceToAppt) + '|'  
	DataValues,

	'ID|OrderNo|DriverID|OOR_MI|AirMilesToNext|ETAToNext|MinutesVarianceToAppt' DataLabels,


		convert(int,OOR_mi) [OOR mi],	
		--OOR_Percentage [OOR %],
		lgh_lgh_driver1 [Driver #],	
		lgh_lgh_tractor [Power #],	
		[Next Stop City]=(select Left(cty_name,18) + ',' + cty_state from  city (NOLOCK) where cty_code=stp_city),
			left(ckc_ckc_comment,40) 
		[Last GPS location],	

		Ord_ord_number [OrderNumber],	
		Ord_Mov_number [Move #],	

		stp_stp_event [Event],	
		s.cmp_id CompanyID,
		
		mpp_mpp_terminal [Driver terminal],	
		mpp_mpp_teamleader [Driver team leader],	
		AirMilestoNext [Air Miles to event location],	
		EtaToNext [ETA @ 45 MPH],	
		MinutesVarianceToAppt [Time variance to appt],	
		RunningLateYN [Running Late Y/N]	

	from #R,
			Stops s (NOLOCK)
	
	where 
			S.stp_number = stp_Next_actual_stp_number
			AND
			OOR_mi> @MininmumMilesOOR

	Order by OOR_mi DESC


END




ENDE:

Drop table #R



	
GO
GRANT EXECUTE ON  [dbo].[MapQ_OOR_Trucks] TO [public]
GO
