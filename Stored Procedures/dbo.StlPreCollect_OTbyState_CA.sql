SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[StlPreCollect_OTbyState_CA](	@pl_pyhnumber int, 
																	@ps_asgn_type varchar(6),
																	@ps_asgn_id varchar(13),
																	@pdt_payperiod datetime, 
																	@psd_id int, 
																	@ps_ReturnVal INT OUT)
as

set nocount on


/**
 * 
 * NAME:
 * dbo.StlPreCollect_OTbyState_CA
 *  PTS 71874
 * CUSTOM PROC
 * Returns @ps_ReturnVal = 1 success OR -1 error
 * CUSTOM California OverTime Rules
 * [ Agricultural loads vs. Non-Agricultural loads DO NOT APPLY for CA Rules ]
 * [ Rule 1 => "Less-than-150-Miles-flag";  rule 2 => Hours.
 * [ *** Rule #1 test is done in the settlement_OTbyState PROC!
 * [
 * [ Rule 1: Drivers are eligible for OT ONLY if DRV has at least ONE trip that has *LESS* THAN 150 miles.  
 * [		1a: Miles based on "actual" miles. [ "actual miles" = stp_trip_mileage ]  
 * [        1c: Trip Segments *COMPLTED* In the Pay Period (1 week schedule) are eligible for consideration.
 * [ Rule 2: Daily OT: Driver eligible for OT after 10 hours (>= 10.01) of driving EACH DAY.
 * [        2a: Day 7 OT: Eligible for OT on 7th work day {for hours up to 8.00} 
 * [            IF on each of the previous SIX days they drove >= 6.01 hours 
 * [              AND they worked MORE than 30 hours during that work week *Client clarification: 30 hrs in FIRST 6 DAYS.
 * [        2b: Day 7 DOUBLE TIME: Same as Day 7 OT  PLUS Any Hours worked IN EXCESS of EIGHT (>=8.01) HOURS on DAY 7 get Double Time.
 * { see also ...OROTRules; WAOTRules)
 * 
 * REVISION HISTORY:
 * Date ? 			PTS#	Revision Description
 * 03/05/2014		74955	Correct calculation for RATE.
 * 03/07/2014		74955	Additional Correction; originally assuming pyd_ot_flag is populated; it might NOT be. Account for that.
 * 06/17/2014		n/a		do not call paydetail update proc if nothing to write.
 **/
 
 Declare @OTPayisSummaryOrDetail	Varchar(10)
 SELECT @OTPayisSummaryOrDetail = 'SUMMARY'		
 -- might need to make this a setting; for now custom rules are 'one OT paydetail per payweek per paytype' i.e. 'SUMMARY'
 -- if rules were create OT paydetails per paytype per eligible leg; then we would set this to 'DETAIL'
 
 DECLARE @rowcnt		INT
 DECLARE @loopcnt		INT
 DECLARE @leg			INT
 Declare @pyd_number	INT
 Declare @Prev_pydnumber INT
 declare @Prev_DOWdate	datetime
 Declare @MinTmpTrip_id	INT
 Declare @multiDay		int 
 Declare @basisunit	    VARCHAR(6) 
 
DECLARE @WrkStartDt datetime
DECLARE @WrkEndDt datetime
DECLARE @typesMustMatch	float
 
 DECLARE @OutTime		DECIMAL(8,2)
 declare @InsideHrs		DECIMAL(8,2)	-- DEPARR {NOT currently used by this proc}
 declare @OutsideHrs	DECIMAL(8,2)	-- ARRDEP
 Declare @StateOTRules	VARCHAR(60) 
 Declare @SumTotalOutsideTime  FLOAT
 declare @sumOutsideTimeperday decimal(8,2)
 DECLARE @arr			datetime
 DECLARE @dep			datetime
 Declare @DowDate		datetime
 
 -- box1  total week  min hrs/week		== mpp_day15_rt_min [ CA > 30 ]
 -- box2  reg Hrs/Day					== mpp_day6_ot_min 	[ CA > 10 ]
 -- box3  Consecutive Days Prior		== mpp_day15_ot_max	[ CA = 6  ]
 -- box3  Consecutive Days Hrs/Day		== mpp_day15_ot_min	[ CA > 6  ]
 -- box3  Pay OT Hrs Up to				== mpp_day7_ot_max	[ CA <= 8 ]
 -- box4  Pay DBL Time Hrs After		== mpp_day7_dblt_min[ CA = >8 ]
 
 --PTS84140 JJF 20141112 - SQL2K5 compatibility does not allow assigning defaults to local variables.
 Declare @Constant_Day1_to_6MinTotalHrs Decimal(8,2)	--= 30.00 -- box1
 SET @Constant_Day1_to_6MinTotalHrs = 30.00 -- box1
	Declare @mpp_day15_rt_min			float 	 
 Declare @Constant_DailyHrs				DECIMAL(8,2)	--= 10.00	-- box2
 SET @Constant_DailyHrs = 10.00	-- box2
	 Declare @mpp_day6_ot_min			float	 
 Declare @Constant_Day7NbrDaysPrior		INT				--= 6		-- box3(1)
 SET @Constant_Day7NbrDaysPrior = 6		-- box3(1)
	 Declare @mpp_day15_ot_max			float	 
 Declare @Constant_Day1_to_6MinDailyHrs	DECIMAL(8,2)	--= 6.00	-- box3(2)
 SET @Constant_Day1_to_6MinDailyHrs = 6.00	-- box3(2)
	 Declare @mpp_day15_ot_min 			float	 
 Declare @Constant_Day7_MinHrsWorked    Decimal(8,2)	--= 8.00	-- box3(3)
 SET @Constant_Day7_MinHrsWorked = 8.00	-- box3(3)
 	 Declare @mpp_day7_ot_max			float 	 
 Declare @Constannt_day7_DblT_HRS_After	Decimal(8,2)	--= 8.00	-- box4 
 SET @Constannt_day7_DblT_HRS_After	= 8.00	-- box4 
	Declare @mpp_day7_dblt_min			float
 
 Declare @PriorDaysWorkedCount			INT
 Declare @PriorDaysHoursCount			Decimal(8,2)
 
  -- Table Values -----------------------------------	
 Select @mpp_day15_rt_min = IsNull(mpp_day15_rt_min,0) ,
		@mpp_day6_ot_min  = ISNULL(mpp_day6_ot_min,0) ,
		@mpp_day15_ot_max = ISNULL(mpp_day15_ot_max,0) , 	
		@mpp_day15_ot_min  = ISNULL(mpp_day15_ot_min,0) ,
		@mpp_day7_ot_max   = IsNull(mpp_day7_ot_max,0)	,
		@mpp_day7_dblt_min = ISNULL(mpp_day7_dblt_min,0)
		from	manpowerprofile_CA_OT_rules 
		where   mpp_id = @ps_asgn_id
		AND		mpp_OT_state = 'CA'		-- we are in the Calif. proc...
			
 IF @mpp_day15_rt_min > 0.0		set	@Constant_Day1_to_6MinTotalHrs = CONVERT(DECIMAL(8,2), @mpp_day15_rt_min )	-- box1  [30]
 IF @mpp_day6_ot_min  > 0.0		set	@Constant_DailyHrs			   = CONVERT(DECIMAL(8,2), @mpp_day6_ot_min)	-- box2	 [10]
 IF @mpp_day15_ot_max  > 0.0     set @Constant_Day7NbrDaysPrior	   = CONVERT(DECIMAL(8,2), @mpp_day15_ot_max )	-- box3(1) [6]
 IF @mpp_day15_ot_min  > 0.0		set @Constant_Day1_to_6MinDailyHrs = CONVERT(DECIMAL(8,2), @mpp_day15_ot_min )	-- box3(2) [6]
 IF @mpp_day7_ot_max  > 0.0		set	@Constant_Day7_MinHrsWorked	   = CONVERT(DECIMAL(8,2), @mpp_day7_ot_max )	-- box3(3) [8]
 IF @mpp_day7_dblt_min > 0.0     set	@Constannt_day7_DblT_HRS_After = CONVERT(DECIMAL(8,2), @mpp_day7_dblt_min )	-- box3(3) [8] 
 
 Declare @RegularOT						DECIMAL(8,2)
 Declare @Day7OT						DECIMAL(8,2)
 Declare @Day7DblTime					DECIMAL(8,2)
 Declare @DailyHrs						DECIMAL(8,2)
 Declare @paydetailCount				INT
 Declare @payDetLoop					INT
 Declare @Tmp_id						INT
 Declare @Pyt_ItemCode					VARCHAR(6)
 Declare @OvertimePayType				VARCHAR(6)
 Declare @DoubleTimePayType				VARCHAR(6)
 declare @type_pay						VARCHAR(30)
 Declare @New_pyd_sequence				INT
 Declare @newDailyHrs					FLOAT	
 Declare @newRegularOT					FLOAT
 Declare @newDay7OT						FLOAT
 Declare @newDay7DblTime				FLOAT 
 Declare @wrkVariable_sum_hrs			FLOAT
 Declare @wrkVariable_remaining_hrs		FLOAT
 Declare @effectiveRateOT				FLOAT
 Declare @effectiveRateDbl				FLOAT													
 
 Declare @effectiveRateWrk				FLOAT
 Declare @SumStraightPay				Money		-- 3/5/14
 
 create table #TmpPayWeek
	( #TmpPW_id         INT			IDENTITY,
	  DOWDate			datetime	null,
	  CalcedDayNbr	    int			NULL,
	  TotalDailyHrs	    FLOAT		NULL,
	  DailyHrsReg		FLOAT		NULL,
	  DailyHrsOT		FLOAT		NULL,		
	  DOW_7_OTHrs		FLOAT		NULL,
	  DOW_7_Double		FLOAT		NULL
	  ,sumPydQuantity	FLOAT		NULL
	  ,sumPydPaidAmount money		NULL		-- 3/5/14
	  ,averageHRRate	FLOAT		NULL
	  ,effectiveRateOT   FLOAT		NULL
	  ,effectiveRateDbl  FLOAT		NULL)
	  	  		
Create Table	#tmp_XrefPydDow ( 
		TmpXref_id         INT          IDENTITY
		,pyd_number		   INT		    NULL
		,DOWDate		   DATETIME		NULL
		,pyt_basisunit	   VARCHAR(6)	NULL
		,pyt_itemcode	   VARCHAR(6)	NULL
		,lgh_number		   INT			NULL
		,ord_hdrnumber	   INT			NULL
		,pyd_quantity	   FLOAT		NULL
		,pyd_paid_amount   money		NULL	-- 3/5/14
		,OutSideTime	   DECIMAL(8,2) NULL
		,lgh_startdate	   DATETIME     NULL
		,lgh_enddate	   DATETIME     NULL
		,pyd_Reg_updated   INT			NULL
		,pyd_Reg_New       INT			NULL
		,pyd_DailyOT       INT          NULL
		,pyd_7dayOT        INT          NULL
		,pyd_7dayDbl       INT          NULL)
		
	  	  		
 Create Table   #tmp_Trips
	(	 TmpTrip_id        INT         IDENTITY
		,pyt_basisunit	   VARCHAR(6)	NULL
		,pyt_otflag		   CHAR(1)		NULL
		,lgh_number		   INT			NULL
		,ord_hdrnumber	   INT			NULL
		,mov_number		   INT			NULL			   
		,pyd_quantity	   FLOAT		NULL
		,pyd_paid_amount   money		NULL	-- 3/5/14
		,OutSideTime	   DECIMAL(8,2) NULL
		,pyd_transdate	   DateTime		NULL			
		,lgh_startdate	   DATETIME     NULL
		,lgh_enddate	   DATETIME     NULL
		,lgh_miles		   INT			NULL 
		,lgh_driver1	   VARCHAR(8)	NULL 
		,lgh_driver2	   VARCHAR(8)	NULL
		,lgh_split_flag	   CHAR(1)		NULL
		,pyd_number		   INT			NULL
		,pyd_sequence	   INT			NULL
		,pyt_itemcode	   VARCHAR(6)	NULL)
 
 Create Table #tmp_multiDay 
 (			 TmpMultiDay_id    INT          IDENTITY
			 ,pyt_basisunit	   VARCHAR(6)	NULL
			 ,lgh_number	   INT			NULL
			 ,lgh_startdate	   DATETIME     NULL
			 ,lgh_enddate	   DATETIME     NULL
			 ,OutSideTime	   DECIMAL(8,2) NULL
			 ,pyd_number	   INT			NULL)			
 
 Create Table #TmpDistinctLeg
 (	 TmpLeg_id				INT         IDENTITY
	,lgh_number				INT			NULL
	,sum_stp_trip_mileage   INT			NULL
	,pyt_basisunit			VARCHAR(6)	NULL)			
   
      -- 3/5/14 added pyd_amount to insert statements
Insert into #tmp_Trips	(pyt_basisunit, pyt_otflag, lgh_number, ord_hdrnumber, mov_number, pyd_quantity, 
				OutSideTime, pyd_number, pyd_sequence, pyt_itemcode, pyd_paid_amount, pyd_transdate)
	SELECT  paytype.pyt_basisunit, IsNull(paytype.pyt_otflag, 'N'), 
			paydetail.lgh_number, paydetail.ord_hdrnumber, paydetail.mov_number, 
			CASE paytype.pyt_basisunit when 'TIM' then paydetail.pyd_quantity
											  else 0.0 end 
			,CASE paytype.pyt_basisunit when 'TIM' then Cast(paydetail.pyd_quantity as DECIMAL(8,2))
												  else  Cast(0.0 as DECIMAL(8,2)) end,
			paydetail.pyd_number, 
			paydetail.pyd_sequence,
			paydetail.pyt_itemcode,
			paydetail.pyd_amount,
			paydetail.pyd_transdate									    							      
	from	paydetail
			left join paytype	on paydetail.pyt_itemcode = paytype.pyt_itemcode
			left join tariffkey on paydetail.tar_tarriffnumber = tariffkey.tar_number
	where 	(asgn_type = @ps_asgn_type AND asgn_id = @ps_asgn_id AND pyh_payperiod = @pdt_payperiod)
	AND		( IsNull(tariffkey.trk_primary,'N') = 'Y'   OR   ( IsNull(tariffkey.trk_primary,'N') <> 'Y'  and paytype.pyt_basisunit = 'TIM') ) 
	
Insert into #TmpDistinctLeg (lgh_number, pyt_basisunit ) select Distinct lgh_number, pyt_basisunit from #tmp_Trips where lgh_number > 0	--3/5/14

UPDATE #tmp_Trips
set  lgh_startdate  = legheader.lgh_startdate 
	,lgh_enddate	= legheader.lgh_enddate 
	,lgh_miles		= legheader.lgh_miles 
	,lgh_driver1	= legheader.lgh_driver1
	,lgh_driver2	= legheader.lgh_driver2
	,lgh_split_flag = legheader.lgh_split_flag
 from legheader 
 left join #TmpDistinctLeg on #TmpDistinctLeg.lgh_number = legheader.lgh_number
 where #tmp_Trips.lgh_number = legheader.lgh_number
 
 Update #tmp_Trips set lgh_enddate = CAST(FLOOR(CAST(pyd_transdate AS FLOAT)) AS DATETIME)   WHERE lgh_enddate is NULL
 UPDATE #tmp_Trips set  pyd_transdate = CAST(FLOOR(CAST(pyd_transdate AS FLOAT)) AS DATETIME)  

 --=================================  Prepare Trip data/ Compute TIME =========================================
 
select @SumTotalOutsideTime = 0.0
select @rowcnt = count(*) from #TmpDistinctLeg  
set	@loopcnt = 1 
While @loopcnt <= @rowcnt 
  BEGIN	
	select @leg = lgh_number from #TmpDistinctLeg where TmpLeg_id = @loopcnt	
	select @basisunit = pyt_basisunit from #TmpDistinctLeg where TmpLeg_id = @loopcnt
	select @MinTmpTrip_id = MIN(TmpTrip_id) from #tmp_Trips where @leg = #tmp_Trips.lgh_number	
	select @pyd_number = pyd_number from #tmp_Trips where @leg = #tmp_Trips.lgh_number and #tmp_Trips.pyt_basisunit = 'TIM'
	if @pyd_number is null select @pyd_number = 0
	
	select @multiDay = 0
	set @multiDay = ( select TOP 1 DATEDIFF(DD, lgh_startdate, lgh_enddate ) from #tmp_Trips where @leg = #tmp_Trips.lgh_number )
	if @multiDay > 0
	begin		
		select @WrkStartDt = MIN(lgh_startdate) from #tmp_Trips where @leg = #tmp_Trips.lgh_number		
		select @WrkEndDt = cast(Convert(varchar(10), @WrkStartDt, 101) + ' 23:59:59' as DATETime)
		
		Insert into #tmp_multiDay (pyt_basisunit, lgh_number, lgh_startdate, lgh_enddate, OutSideTime, pyd_number )
		select @basisunit, @leg,  @WrkStartDt, @WrkEndDt, 0, @pyd_number
		select @WrkStartDt = cast(Convert(varchar(10), @WrkStartDt, 101) + ' 00:00:00' as DATETime)
		
		While @multiDay > 0
			BEGIN
				Select @multiDay = @multiDay - 1
						
				select @WrkStartDt = DATEADD(DD, 1, @WrkStartDt)
				select @WrkEndDt =  DATEADD(DD, 1, @WrkEndDt )				
				if @multiDay  = 0 select @WrkEndDt = MAX(lgh_enddate) from #tmp_Trips where @leg = #tmp_Trips.lgh_number	
				Insert into #tmp_multiDay (pyt_basisunit, lgh_number, lgh_startdate, lgh_enddate, OutSideTime, pyd_number )
				select @basisunit, @leg,  @WrkStartDt, @WrkEndDt, 0, @pyd_number
			END
	end	
	
	  -- calc hours for ONLY non "time" segments	
	  Set @InsideHrs = 0
	  Set @OutsideHrs = 0
	  IF @basisunit <> 'TIM' 
		 begin 
			exec gettimecalc_sp 0, @leg, @InsideHrs OUT, @OutsideHrs OUT
			Update #tmp_Trips set OutSideTime = @OutsideHrs where @leg = #tmp_Trips.lgh_number and @MinTmpTrip_id = #tmp_Trips.TmpTrip_id
		 end 
		 
		 set @typesMustMatch = ( select top 1  pyd_quantity + Convert(float,outsidetime) from  #tmp_Trips where lgh_number = @leg)
		 select @SumTotalOutsideTime = @SumTotalOutsideTime + @typesMustMatch
		 
    Select @loopcnt = @loopcnt + 1
  END

IF (select count(*) from #tmp_multiDay) > 0 
begin
	select @rowcnt = count(*) from #tmp_multiDay  
	set	@loopcnt = 1 
	While @loopcnt <= @rowcnt 
		BEGIN	
			select @InsideHrs = 0.0
			select @OutsideHrs = 0.0
			select @leg = lgh_number, @arr = lgh_startdate, @dep = lgh_enddate from #tmp_multiDay where TmpMultiDay_id = @loopcnt			
			exec get_Inside_Outside_time_STOPS_sp @leg, @arr, @dep, @InsideHrs output, @OutsideHrs output
			Update #tmp_multiDay set OutSideTime = @OutsideHrs where TmpMultiDay_id = @loopcnt
			
		 Select @loopcnt = @loopcnt + 1	
		END
		
	Update #tmp_Trips set OutSideTime = 0.0 where lgh_number IN (select Distinct(lgh_number) from 	#tmp_multiDay )
end

Insert Into #TmpPayWeek (DOWDate, CalcedDayNbr) Select @pdt_payperiod, 7
set @loopcnt = 0
while @loopcnt < 6
begin	
	select @loopcnt = @loopcnt +1 		
	if @loopcnt <= 0 break
	Insert Into #TmpPayWeek (DOWDate, CalcedDayNbr) select DATEADD(DD, -(@loopcnt), @pdt_payperiod ), 7-@loopcnt
end

select @rowcnt = count(DOWDate) from #TmpPayWeek
set @loopcnt = 1
While @loopcnt <= @rowcnt 
BEGIN
	Set @sumOutsideTimeperday = 0.0
	select @DowDate =  DowDate from #TmpPayWeek where @loopcnt = CalcedDayNbr		
	select @sumOutsideTimeperday =  SUM(outsidetime) 
									from #tmp_Trips 
									where OutSideTime > 0.0
									AND pyd_transdate >= @DowDate 
									AND pyd_transdate <= cast(Convert(varchar(10), @DowDate, 101) + ' 23:59:59' as DATETime)
									group by pyd_transdate
									--AND   lgh_enddate >= @DowDate  
									--AND	  lgh_enddate <= cast(Convert(varchar(10), @DowDate, 101) + ' 23:59:59' as DATETime)								
									--group by lgh_number, lgh_enddate
									
	if @sumOutsideTimeperday = NULL select @sumOutsideTimeperday = 0.0	
	
	if @sumOutsideTimeperday > 0 
	begin
		-- 3/5/14 (add pyd_paid_amount)	
		Insert Into #tmp_XrefPydDow ( pyd_number, DOWDate, pyt_basisunit, pyt_itemcode, 
										lgh_number ,ord_hdrnumber, pyd_quantity, pyd_paid_amount, OutSideTime, lgh_startdate, lgh_enddate)
		select pyd_number, @DowDate, pyt_basisunit, pyt_itemcode, lgh_number ,ord_hdrnumber, 
					pyd_quantity, pyd_paid_amount, OutSideTime, lgh_startdate, lgh_enddate
		from #tmp_Trips 
		where OutSideTime > 0.0
		AND   lgh_enddate >= @DowDate  
		AND	  lgh_enddate <= cast(Convert(varchar(10), @DowDate, 101) + ' 23:59:59' as DATETime)
	END
									
	select @sumOutsideTimeperday =  @sumOutsideTimeperday + IsNull(SUM(outsidetime) , 0)
									from #tmp_multiDay 
									where OutSideTime > 0.0
									AND lgh_enddate >= @DowDate  
									AND	  lgh_enddate <= cast(Convert(varchar(10), @DowDate, 101) + ' 23:59:59' as DATETime)
									group by lgh_enddate								
	
	if @sumOutsideTimeperday = NULL select @sumOutsideTimeperday = 0.0	
	
	update #TmpPayWeek set TotalDailyHrs = 	@sumOutsideTimeperday	where CalcedDayNbr = @loopcnt	
	select @loopcnt = @loopcnt +1 	 	
END

Insert Into #tmp_XrefPydDow ( pyd_number, DOWDate, pyt_basisunit ,lgh_number,  OutSideTime, lgh_startdate, lgh_enddate)
select pyd_number, cast(Convert(varchar(10), #tmp_multiDay.lgh_startdate, 101) + ' 00:00:00' as DATETime), 
			pyt_basisunit, lgh_number, 	OutSideTime, lgh_startdate, lgh_enddate  
from #tmp_multiDay 

-- 3/5/14 add payamount
update #tmp_XrefPydDow
set ord_hdrnumber = #tmp_Trips.ord_hdrnumber , pyd_quantity = #tmp_Trips.pyd_quantity, pyt_itemcode = #tmp_Trips.pyt_itemcode, pyd_paid_amount = #tmp_Trips.pyd_paid_amount
from  #tmp_Trips where #tmp_Trips.pyd_number = #tmp_XrefPydDow.pyd_number
AND #tmp_XrefPydDow.ord_hdrnumber is null

	
 --=================================  Compute OverTime/ DoubleTime =========================================	
	select @PriorDaysWorkedCount = count(*) from #TmpPayWeek where CalcedDayNbr < 7 AND TotalDailyHrs > @Constant_Day1_to_6MinDailyHrs
	select @PriorDaysHoursCount = SUM(TotalDailyHrs) from #TmpPayWeek where CalcedDayNbr < 7

	update #TmpPayWeek set DailyHrsReg	= CASE	When CalcedDayNbr < 7 And TotalDailyHrs <= @Constant_DailyHrs then TotalDailyHrs
												When CalcedDayNbr < 7  And TotalDailyHrs > @Constant_DailyHrs then @Constant_DailyHrs
												WHEN CalcedDayNbr = 7 
														AND ( @PriorDaysHoursCount <= @Constant_Day1_to_6MinTotalHrs OR @PriorDaysWorkedCount < 6 ) 
														AND TotalDailyHrs <= @Constant_DailyHrs 														
														then TotalDailyHrs
												WHEN CalcedDayNbr = 7 
														AND ( @PriorDaysHoursCount <= @Constant_Day1_to_6MinTotalHrs OR @PriorDaysWorkedCount < 6 ) 
														AND TotalDailyHrs > @Constant_DailyHrs  														
														then @Constant_DailyHrs 
												else 0
												end,
					       DailyHrsOT	=  CASE When CalcedDayNbr < 7  And TotalDailyHrs > @Constant_DailyHrs 
													then Round(TotalDailyHrs - @Constant_DailyHrs,2)	
												else 0
												end,	
				 
					DOW_7_OTHrs			= CASE	WHEN CalcedDayNbr = 7 And  @PriorDaysWorkedCount = 6 
													 And @PriorDaysHoursCount > @Constant_Day1_to_6MinTotalHrs 
													 AND TotalDailyHrs <= @Constant_Day7_MinHrsWorked
													 then TotalDailyHrs 
												WHEN CalcedDayNbr = 7 And  @PriorDaysWorkedCount = 6 
													 And @PriorDaysHoursCount > @Constant_Day1_to_6MinTotalHrs 
													 AND TotalDailyHrs > @Constant_Day7_MinHrsWorked
													 then @Constant_Day7_MinHrsWorked	
												WHEN CalcedDayNbr = 7 
														AND ( @PriorDaysHoursCount <= @Constant_Day1_to_6MinTotalHrs OR @PriorDaysWorkedCount < 6 ) 
														AND TotalDailyHrs > @Constant_DailyHrs 
														then Round(TotalDailyHrs -  @Constant_DailyHrs, 2 )  														  
												else 0
												end,
					DOW_7_Double		= CASE  WHEN  CalcedDayNbr = 7 And @PriorDaysWorkedCount = 6 
														And @PriorDaysHoursCount > @Constant_Day1_to_6MinTotalHrs 
														AND TotalDailyHrs > @Constant_Day7_MinHrsWorked
												then 	Round(TotalDailyHrs - @Constant_Day7_MinHrsWorked, 2)
												else 0
												end	

 --=================================  PrePare Collect-Process 'New' PayDetails =========================================

-- the only paydetails that will need to be UPDATED are those with
--		pyt_basisunit = 'TIM' and pay quantity <> outsidetime (if <> then OT probably exists)
--		IF multiDay contains rows matching a single pyd_number then 
--			we need to update one (for basis=Time) and ADD new ones for regular & OT

select 	@OvertimePayType = IsNull(gi_string1, 'OT')	
from 	generalinfo 
where 	gi_name = 'OTPayCode'

select 	@DoubleTimePayType = IsNull(gi_string1, 'DBLTIM')	
from 	generalinfo 
where 	gi_name = 'DoubleTimePayType'	
		
 IF @OTPayisSummaryOrDetail = 'SUMMARY'	
 begin
		-- we need ONE OT row per valid OT-paytype & need to update any basis = TIME paydetails if quantity is too high.
		select @DailyHrs		= SUM(DailyHrsReg) from #TmpPayWeek
		select @RegularOT		= SUM(DailyHrsOT) from #TmpPayWeek
		select @Day7OT			= SUM(DOW_7_OTHrs)  from #TmpPayWeek
		select @Day7DblTime	= SUM(DOW_7_Double)  from #TmpPayWeek
		select @sumOutsideTimeperday = SUM(TotalDailyHrs) from  #TmpPayWeek
		select @pyd_number = MAX(pyd_number) from #tmp_Trips where lgh_number > 0
		select @New_pyd_sequence = 1 + MAX(pyd_sequence) from  #tmp_Trips		
				
			-- 03/07/2014 (remmove next 2 selects) 
			--select @effectiveRateWrk = sum(pyd_quantity) from paydetail 
			--			where 	asgn_type	= @ps_asgn_type 
			--			and 	asgn_id		= @ps_asgn_id 
			--			and 	pyh_payperiod = @pdt_payperiod
			
			---- 3/5/14.start
			--select @SumStraightPay = sum(pyd_amount) from paydetail 
			--			where 	asgn_type	= @ps_asgn_type 
			--			and 	asgn_id		= @ps_asgn_id 
			--			and 	pyh_payperiod = @pdt_payperiod					
	
			-- 03/07/2014 (replaced above) 
			select @effectiveRateWrk = sum(pyd_quantity) , @SumStraightPay  = sum(pyd_amount)  
				from paydetail 
				left join paytype on paydetail.pyt_itemcode = paytype.pyt_itemcode
						where 	asgn_type	= @ps_asgn_type 
						and 	asgn_id		= @ps_asgn_id 
						and 	pyh_payperiod = @pdt_payperiod
						and		IsNull(paytype.pyt_otflag, 'N') = 'Y'	
			
			select @typesMustMatch = CONVERT(FLOAT, @SumStraightPay )	
			

		-- this insert is the 'summary' line
		-- *  PER SR 71874:
		-- *  Custom Client RATES:   Overtime is **one half** of avgpay (totalpay / total hrs) { NOT time + one-half }
		-- *						 DoubleTime is avgpay  { NOT avgpay X 2 }
		insert into #TmpPayWeek (DOWDate, CalcedDayNbr, TotalDailyHrs, DailyHrsReg, 
								 DailyHrsOT, DOW_7_OTHrs, DOW_7_Double, sumPydQuantity, sumPydPaidAmount, averageHRRate,
								 effectiveRateOT, effectiveRateDbl )
		select		'2049-12-31 23:59:59.000', 99, @sumOutsideTimeperday, @DailyHrs, 
					@RegularOT, @Day7OT, @Day7DblTime, @effectiveRateWrk, @SumStraightPay,
					CONVERT(Money, (Round(@typesMustMatch / @sumOutsideTimeperday, 2)) ),			--averageHRRate
					Round(((@typesMustMatch / @sumOutsideTimeperday) * .5),2),						--effectiveRateOT
					Round((@typesMustMatch / @sumOutsideTimeperday),2)								--effectiveRateDoubletime
		
					-- 03/07/2014 (Correct the calculation) 
					--Round(@effectiveRateWrk / @sumOutsideTimeperday,2),
					--Round(((@effectiveRateWrk / @sumOutsideTimeperday) *.5),2) , 
					--Round(@effectiveRateWrk / @sumOutsideTimeperday,2)  
			-- 3/5/14.end			
					
		select  @type_pay = 'SUMMARY New Insert'			
		Select  @newDailyHrs	= 0		-- not updating right now
		Select  @newRegularOT	= Convert(float, @RegularOT)
		Select	@newDay7OT		= Convert(float, @Day7OT)
		Select  @newDay7DblTime	= Convert(float, @Day7DblTime)
		
		select	@effectiveRateOT = effectiveRateOT,  
				@effectiveRateDbl =  effectiveRateDbl 
		from	#TmpPayWeek
		where	CalcedDayNbr = 99			
		
		----------------------------------------------------------------------  update pay
		if @newRegularOT > 0 OR @newDay7OT > 0 OR  @newDay7DblTime > 0
		 begin 
			exec StlPreCollect_OTbyState_Updates @pyd_number,	
			@OvertimePayType, @DoubleTimePayType, 
			@type_pay,
			@newDailyHrs, @newRegularOT, @newDay7OT, @newDay7DblTime, 
			@New_pyd_sequence, Null, Null, @effectiveRateOT,  @effectiveRateDbl
		end			
		
		-- Update or Insert (new) REGULAR Time if needed.
		-- determine if we have ANY 'duplicate' pyd_number rows (needed to create 'additional' regular time rows)
		SET @multiDay = ( select TOP 1 COUNT(#tmp_XrefPydDow.pyd_number)
		from #tmp_XrefPydDow 
		left join #TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
		where #tmp_XrefPydDow.pyt_basisunit = 'TIM' 
		and #tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg
		GROUP BY  #tmp_XrefPydDow.pyd_number
		HAVING COUNT(#tmp_XrefPydDow.pyd_number) > 1 )
		
		IF @multiDay > 1 
		begin
			select @loopcnt = 0	
			select @rowcnt = count(*) 
			from 		#tmp_XrefPydDow 
			left join	#TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
			where		#tmp_XrefPydDow.pyt_basisunit = 'TIM' 
			and			#tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg	
			
			select @pyd_number = 0
			select @Prev_pydnumber = 0
			select @Prev_DOWdate = '1950-01-01'	
			
			select		@Tmp_id = MIN(#tmp_XrefPydDow.TmpXref_id) 
							from		#tmp_XrefPydDow 
							left join	#TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
							where		#tmp_XrefPydDow.pyt_basisunit = 'TIM' 
							and			#tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg		
							and			( #tmp_XrefPydDow.pyd_number >= @Prev_pydnumber and #tmp_XrefPydDow.DOWDate > @Prev_DOWdate )
							
			While	@loopcnt < @rowcnt 
			BEGIN	
					select @loopcnt = @loopcnt + 1
					
					select		@pyd_number = #tmp_XrefPydDow.pyd_number, 
								@DowDate  = #tmp_XrefPydDow.DOWDate,
								@DailyHrs = #TmpPayWeek.dailyHrsReg,
								@OvertimePayType = 	#tmp_XrefPydDow.pyt_itemcode								
																	
					from		#tmp_XrefPydDow 
					left join	#TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
					where		#tmp_XrefPydDow.pyt_basisunit = 'TIM' 
					and			#tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg	
					and			#tmp_XrefPydDow.TmpXref_id >= @Tmp_id	
					and			( #tmp_XrefPydDow.pyd_number >= @Prev_pydnumber and #tmp_XrefPydDow.DOWDate > @Prev_DOWdate )
					order by	#tmp_XrefPydDow.pyd_number, #tmp_XrefPydDow.DOWDate	
							
					Select  @newDailyHrs	= Convert(float, @DailyHrs)	-- not updating right now
					Select  @newRegularOT	= 0
					Select	@newDay7OT		= 0
					Select  @newDay7DblTime	= 0
					
					IF @pyd_number > @Prev_pydnumber 	
						begin					
							select  @type_pay = 'SUMMARY Update-Exists-Regular'								
						end	
					else
						begin						
							select  @type_pay = 'SUMMARY Insert-NEW-Regular'
							select @New_pyd_sequence = @New_pyd_sequence + 1	
						end	
							
					select @DowDate =  Min(#tmp_XrefPydDow.DOWDate) from 	#tmp_XrefPydDow where #tmp_XrefPydDow.TmpXref_id >=  @Tmp_id
							
					select	@effectiveRateOT = effectiveRateOT,  
							@effectiveRateDbl =  effectiveRateDbl 
					from	#TmpPayWeek
					where	CalcedDayNbr = 99
						
					----------------------------------------------------------------------  update pay	
					if @newRegularOT > 0 OR @newDay7OT > 0 OR  @newDay7DblTime > 0
					begin 					
						exec StlPreCollect_OTbyState_Updates @pyd_number,
						'N/A', 'N/A',
						@type_pay,
						@newDailyHrs, @newRegularOT, @newDay7OT, @newDay7DblTime, 
						@New_pyd_sequence, @OvertimePayType , @DowDate,  
						@effectiveRateOT, @effectiveRateDbl 
					end
					
					select @Prev_pydnumber = @pyd_number 
					select @Prev_DOWdate = @DowDate	
					
					select	@Tmp_id = MIN(#tmp_XrefPydDow.TmpXref_id) 
							from		#tmp_XrefPydDow 
							left join	#TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
							where		#tmp_XrefPydDow.pyt_basisunit = 'TIM' 
							and			#tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg		
							and			( #tmp_XrefPydDow.pyd_number >= @Prev_pydnumber and #tmp_XrefPydDow.DOWDate > @Prev_DOWdate )
							and			#tmp_XrefPydDow.TmpXref_id >= @Tmp_id	
			END	-- end the while loop				
		end  -- end of IF @multiDay > 1 
		ELSE 
			Begin
				--	so then @multiDay <= 1  (no duplicate pyd_numbers)
						
				select @loopcnt = 0	
				select @rowcnt = count(*) 	from 		#tmp_XrefPydDow 
				
				select			@pyd_number = #tmp_XrefPydDow.pyd_number, 
								@DowDate  = #tmp_XrefPydDow.DOWDate,
								@DailyHrs = #TmpPayWeek.dailyHrsReg
					from		#tmp_XrefPydDow 
					left join	#TmpPayWeek on #tmp_XrefPydDow.DOWDate =  #TmpPayWeek.DOWDate
					where		#tmp_XrefPydDow.pyt_basisunit = 'TIM' 
					and			#tmp_XrefPydDow.outsidetime > 	#TmpPayWeek.dailyHrsReg	
					and			#tmp_XrefPydDow.TmpXref_id >= @loopcnt	
																
					Select  @newDailyHrs	= Convert(float, @DailyHrs)	-- not updating right now
					Select  @newRegularOT	= 0
					Select	@newDay7OT		= 0
					Select  @newDay7DblTime	= 0
					select  @type_pay = 'SUMMARY Update-Exists-Regular'								
						
					select	@effectiveRateOT = effectiveRateOT,  
							@effectiveRateDbl =  effectiveRateDbl 
					from	#TmpPayWeek
					where	CalcedDayNbr = 99						
										
					----------------------------------------------------------------------  update pay
					if @newRegularOT > 0 OR @newDay7OT > 0 OR  @newDay7DblTime > 0
					begin 					
						exec StlPreCollect_OTbyState_Updates @pyd_number,
						'N/A', 'N/A',
						@type_pay,
						@newDailyHrs, @newRegularOT, @newDay7OT, @newDay7DblTime, 
						@New_pyd_sequence, NULL , NULL, @effectiveRateOT,  @effectiveRateDbl
					end
			End 
end
	
--  ** IF client ever wants  @OTPayisSummaryOrDetail = 'DETAIL' rather than 'SUMMARY'; add that code here.
 
 
 --================================= End of processing =======================================================================

IF OBJECT_ID(N'tempdb.. #TmpPayWeek ', N'U') IS NOT NULL 
Drop Table #TmpPayWeek

IF OBJECT_ID(N'tempdb.. #tmp_XrefPydDow ', N'U') IS NOT NULL 
Drop Table #tmp_XrefPydDow 

IF OBJECT_ID(N'tempdb.. #tmp_Trips', N'U') IS NOT NULL 
Drop Table #tmp_Trips

IF OBJECT_ID(N'tempdb.. #tmp_multiDay ', N'U') IS NOT NULL 
Drop Table #tmp_multiDay 

IF OBJECT_ID(N'tempdb.. #TmpDistinctLeg', N'U') IS NOT NULL 
Drop Table #TmpDistinctLeg

--Returns @ps_ReturnVal = 1 success OR -1 error
set @ps_ReturnVal = 1
Return @ps_ReturnVal



GO
GRANT EXECUTE ON  [dbo].[StlPreCollect_OTbyState_CA] TO [public]
GO
