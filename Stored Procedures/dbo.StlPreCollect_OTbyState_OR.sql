SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[StlPreCollect_OTbyState_OR](	@pl_pyhnumber int, 
																	@ps_asgn_type varchar(6),
																	@ps_asgn_id varchar(13),
																	@pdt_payperiod datetime, 
																	@psd_id int, 
																	@ps_ReturnVal INT OUT)
as

set nocount on
declare @SetDebugON INT
set @SetDebugON = 0	-- if = 1, we will SEE debug messages.
--set @SetDebugON = 1

/**
 * 
 * NAME:
 *  PTS 71874
 * dbo.StlPreCollect_OTbyState_OR
 * CUSTOM PROC
 * Returns @ps_ReturnVal = 1 success OR -1 error
 * CUSTOM OREGON OverTime Rules
 * manpowerprofile mpp_typex (mpp_type4 in this case) used to determine WHICH State to calc for.
 * Orderheader orderheader.ord_revtypex (ord_revtype3 in this case) used to determine if the order
 *	is Agricultural or Non-Agricultural. revtype3 = BRK (Broker) indicates Non-Agricultural 
 *	and any other value will be considered Agricultural.  
 *  NON-Agricultural loads are eligible for overtime (purly Agricultural loades are not eligible
 *	UNLESS the driver has at least ONE NON-Agricultural load during the payperiod.  IF this is the case
 *  then ALL loads will become eligible for OverTime.
 *  
  * [ *** Rule #1 and 2 test is done in the settlement_OTbyState PROC!
 *  Rule 1:	Trip Segments *COMPLTED* In the Pay Period (1 week schedule) are eligible for consideration.
 *	Rule 2: Must have at least one NON-Agricultural load during the payperiod to be eligible for OT.
 *
 *  Rule 3: Driver is eligible for OT After 40 hours (>=40.01).
 *  %% Assuming:  'one OT paydetail per payweek'
 *		-- *  PER SR 71874:
 *		-- *  Custom Client RATES:   Overtime is **one half** of avgpay (totalpay / total hrs) { NOT time + one-half }
 *		-- *						 DoubleTime does not apply for Oregon or Washington
  *
 * { see also ...WAOTRules; CAOTRules)
 *
 * REVISION HISTORY:
 * Date ? 			PTS#	Revision Description
 * 03/05/2014		74955	Correct calculation for RATE.
 * 03/07/2014		74955	Additional Correction; originally assuming pyd_ot_flag is populated; it might NOT be. Account for that.
 * 06/13/2014	StandAlone	Fix (subquery returned...) sql error ~~ line 385 (while loop)
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
 declare @tmpKeepKey	int		-- 06/13/2014:StandAlone fix
 
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
 
 --PTS84140 JJF 20141112 - SQL2K5 compatibility does not allow assigning defaults to local variables.
 -- if the table data is missing, default to '40'
 -- Total Work Week	Min Hrs/Week				// box1  Min Hrs/Week   mpp_day15_rt_min
 Declare @Constant_WeeklyHrs			DECIMAL(8,2)	--= 40.00 
 SET @Constant_WeeklyHrs = 40.00 
 Declare @mpp_day15_rt_min				float	-- this where Constant_WeeklyHrs stored in table.
			Select @mpp_day15_rt_min = 	  IsNull(mpp_day15_rt_min,0) 	from	manpowerprofile_CA_OT_rules 
												where   mpp_id = @ps_asgn_id
												AND		mpp_OT_state = 'OR'	-- we are IN the Oregon proc
			IF 	@mpp_day15_rt_min > 0.0 
				begin				
					set @Constant_WeeklyHrs = CONVERT(DECIMAL(8,2), @mpp_day15_rt_min )	
				end 	
 
 Declare @RegularOT						DECIMAL(8,2) 
 Declare @DailyHrs						DECIMAL(8,2)
 Declare @paydetailCount				INT
 Declare @payDetLoop					INT
 Declare @Tmp_id						INT
 Declare @Pyt_ItemCode					VARCHAR(6)
 Declare @OvertimePayType				VARCHAR(6) 
 declare @type_pay						VARCHAR(30)
 Declare @New_pyd_sequence				INT
 Declare @newDailyHrs					FLOAT	
 Declare @newRegularOT					FLOAT
 Declare @newDay7OT						FLOAT
 Declare @newDay7DblTime				FLOAT 
 Declare @wrkVariable_sum_hrs			FLOAT
 Declare @wrkVariable_remaining_hrs		FLOAT
 Declare @wrkVariable_regularHrs		FLOAT
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
	  DailyHrsOT		FLOAT		NULL		  
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
		,pyd_Reg_updated   FLOAT		NULL
		,pyd_Reg_New       FLOAT		NULL
		,pyd_DailyOT       FLOAT        NULL
		,pyd_7dayOT        FLOAT        NULL
		,pyd_7dayDbl       FLOAT        NULL)
		
	  	  		
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
Insert into #tmp_Trips	(pyt_basisunit, pyt_otflag, lgh_number, ord_hdrnumber, mov_number, pyd_quantity, OutSideTime, 
			pyd_number, pyd_sequence, pyt_itemcode, pyd_paid_amount)
	SELECT  paytype.pyt_basisunit, IsNull(paytype.pyt_otflag, 'N'), 
			paydetail.lgh_number, paydetail.ord_hdrnumber, paydetail.mov_number, 
			CASE paytype.pyt_basisunit when 'TIM' then paydetail.pyd_quantity
											  else 0.0 end 
			,CASE paytype.pyt_basisunit when 'TIM' then Cast(paydetail.pyd_quantity as DECIMAL(8,2))
												  else  Cast(0.0 as DECIMAL(8,2)) end,
			paydetail.pyd_number, 
			paydetail.pyd_sequence,
			paydetail.pyt_itemcode,	
			paydetail.pyd_amount									    							      
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
	
	Set @InsideHrs = 0
	  Set @OutsideHrs = 0
	  IF @basisunit <> 'TIM' 
		 begin 
			exec gettimecalc_sp 0, @leg, @InsideHrs OUT, @OutsideHrs OUT
			Update #tmp_Trips set OutSideTime = @OutsideHrs 
				where @leg = #tmp_Trips.lgh_number and @MinTmpTrip_id = #tmp_Trips.TmpTrip_id
		 end 
		 
		 set @typesMustMatch = ( select top 1  pyd_quantity + Convert(float,outsidetime) from  #tmp_Trips where lgh_number = @leg)
		 select @SumTotalOutsideTime = @SumTotalOutsideTime + @typesMustMatch
		 
    Select @loopcnt = @loopcnt + 1
  END
 --=================================  Compute OverTime =========================================   
  	Set	   @sumOutsideTimeperday = 0.0	
	select @sumOutsideTimeperday =  SUM(IsNull(outsidetime, 0) ) from #tmp_Trips 
	
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
	
	-- 03/07/2014 (Correct the calculation) 
	Insert Into #TmpPayWeek (DOWDate, CalcedDayNbr, TotalDailyHrs, sumPydQuantity, sumPydPaidAmount, averageHRRate, effectiveRateOT) 
		Select @pdt_payperiod, 99, @sumOutsideTimeperday,  @effectiveRateWrk, @SumStraightPay,
				CONVERT(Money, (Round(@typesMustMatch / @sumOutsideTimeperday, 2)) ),			--averageHRRate
				 Round(((@typesMustMatch / @sumOutsideTimeperday) * .5),2)						--effectiveRateOT
				--Round(@effectiveRateWrk / @sumOutsideTimeperday,2),
				--Round(@effectiveRateWrk / @sumOutsideTimeperday,2)
	-- 3/5/14.end	
		
	select @Tmp_id = MIN(#TmpPW_id)  from #TmpPayWeek
	
		-------
		update #TmpPayWeek set DailyHrsReg	= CASE	When @sumOutsideTimeperday <= @Constant_WeeklyHrs then	 @sumOutsideTimeperday
													else @Constant_WeeklyHrs
													end,
							   DailyHrsOT	= CASE	When @sumOutsideTimeperday > @Constant_WeeklyHrs  
														then	Round(@sumOutsideTimeperday - @Constant_WeeklyHrs ,2)
													else 0
													end	
		where #TmpPW_id	= @Tmp_id
		------- 	
			
		-- 3/5/14 (add pyd_paid_amount)				 
		Insert Into #tmp_XrefPydDow ( pyd_number, DOWDate, pyt_basisunit, pyt_itemcode, 
										lgh_number ,ord_hdrnumber, pyd_quantity, pyd_paid_amount, OutSideTime, lgh_startdate, lgh_enddate, pyd_7dayOT)
		select pyd_number, @DowDate, pyt_basisunit, pyt_itemcode, lgh_number ,ord_hdrnumber, pyd_quantity, pyd_paid_amount,
				OutSideTime, lgh_startdate, lgh_enddate, pyd_quantity
		from #tmp_Trips 
		where OutSideTime > 0.0
				 
				 
		-- insert #tmp_XrefPydDow Summary Row	
		select @wrkVariable_sum_hrs = sum(pyd_quantity) from #tmp_Trips where pyt_basisunit = 'TIM' 
		select @wrkVariable_remaining_hrs = @wrkVariable_sum_hrs - @Constant_WeeklyHrs	
		Insert Into #tmp_XrefPydDow ( pyd_number, DOWDate, pyt_basisunit, pyt_itemcode, 
										lgh_number ,ord_hdrnumber, pyd_quantity, OutSideTime)	
		select 99, '2049-12-31 23:59:59.000', 'SUMMRY', 'N/A', 0,0, @wrkVariable_sum_hrs, @wrkVariable_remaining_hrs			 
		

 --=================================  PrePare Collect-Process 'New' PayDetails =========================================
-- the only paydetails that will need to be UPDATED are those with
--		pyt_basisunit = 'TIM' and pay quantity <> outsidetime (if <> then OT probably exists)
--		IF multiDay contains rows matching a single pyd_number then 
--			we need to update one (for basis=Time) and ADD new ones for regular & OT
--		@DoubleTimePayType is NULL {does not apply} for the OR/WA process.

select 	@OvertimePayType = IsNull(gi_string1, 'OT')	
from 	generalinfo 
where 	gi_name = 'OTPayCode'
		
 IF @OTPayisSummaryOrDetail = 'SUMMARY'	
 begin		
		select @DailyHrs		= SUM(DailyHrsReg) from #TmpPayWeek
		select @RegularOT		= SUM(DailyHrsOT) from #TmpPayWeek	
		select @sumOutsideTimeperday = SUM(TotalDailyHrs) from  #TmpPayWeek
		select @pyd_number = MAX(pyd_number) from #tmp_Trips where lgh_number > 0
		select @New_pyd_sequence = 1 + MAX(pyd_sequence) from  #tmp_Trips
		
		select  @type_pay = 'SUMMARY New Insert'			
		Select  @newDailyHrs	= 0		-- not updating right now
		Select  @newRegularOT	= Convert(float, @RegularOT)		
		
		select	@effectiveRateOT = effectiveRateOT,  
				@effectiveRateDbl =  effectiveRateDbl 
		from	#TmpPayWeek
		where	CalcedDayNbr = 99			
		
		----------------------------------------------------------------------  update OT pay
		 --@DoubleTimePayType is NULL {does not apply} for the OR/WA process.
		 
		 select @newRegularOT = IsNull(DailyHrsOT,0)  FROM #TmpPayWeek	
		  
			  -- debug.start
			  IF  @SetDebugON = 1
			  begin
				if @newRegularOT > 0
					begin
						Print 'Debug ON: (Oregon OT) OROTRules Proc:  SUMMARY New Insert'  + space(1) +
							'NEW OT Hours:' + space(1) + Convert(varchar(10),@newRegularOT)
					end
				else
					begin
						Print 'Debug ON: (Oregon OT) OROTRules Proc:  SUMMARY New Insert'  + space(1) +
							'NO DATA FOR new OVERTIME'
					end
				-- end if	
			  end
			 -- debug.end	
		 
		 if @newRegularOT > 0 
		 begin
			exec StlPreCollect_OTbyState_Updates @pyd_number,	
			@OvertimePayType, NULL, 
			@type_pay,
			0, @newRegularOT, NULL, NULL, 
			@New_pyd_sequence, Null, Null, @effectiveRateOT,  NULL
		end
		
		update #tmp_XrefPydDow  set pyd_Reg_updated = 0
		update #tmp_XrefPydDow  set pyd_Reg_updated =  pyd_quantity  where pyt_basisunit = 'TIM' 	
				
		select @wrkVariable_sum_hrs = sum(pyd_Reg_updated) from #tmp_XrefPydDow  where pyt_basisunit = 'TIM' 
			
		update #tmp_XrefPydDow 
			set pyd_Reg_updated = @wrkVariable_sum_hrs, 
				OutSideTime = (@wrkVariable_sum_hrs - @Constant_WeeklyHrs ) where pyt_basisunit = 'SUMMRY'
		 
		 
		select @wrkVariable_sum_hrs = sum(pyd_Reg_updated) from #tmp_XrefPydDow  where pyt_basisunit = 'TIM' 		
		select @wrkVariable_remaining_hrs = @wrkVariable_sum_hrs - @Constant_WeeklyHrs 
		
		set @tmpKeepKey = 0		-- 06/13/2014:StandAlone fix
		WHILE @wrkVariable_remaining_hrs > @Constant_WeeklyHrs 
		begin
				select @newDailyHrs	= MAX(pyd_Reg_updated) from #tmp_XrefPydDow where pyt_basisunit = 'TIM' 
				
				-- 06/13/2014:StandAlone fix
				select @tmpKeepKey = min(TmpXref_id) from #tmp_XrefPydDow 
										where pyt_basisunit = 'TIM' 
										and pyd_Reg_updated = @newDailyHrs 
										and TmpXref_id > @tmpKeepKey
				
				-- 06/13/2014:StandAlone fix						
				set    @pyd_number = (select pyd_number from #tmp_XrefPydDow 
									where pyt_basisunit = 'TIM' 
									and pyd_Reg_updated = @newDailyHrs 
									and TmpXref_id = @tmpKeepKey	)
				
				-- set @pyd_number = (select pyd_number from #tmp_XrefPydDow where pyt_basisunit = 'TIM' and pyd_Reg_updated = @newDailyHrs	)	-- 06/13/2014:StandAlone fix			
				set @Tmp_id = (select TmpXref_ID from #tmp_XrefPydDow where pyt_basisunit = 'TIM' and pyd_number = @pyd_number )
				
				select @DailyHrs = CONVERT(DECIMAL(8,2), @newDailyHrs )
				if @DailyHrs >= @Constant_WeeklyHrs 
					begin
						-- @DailyHrs were >=  40 
						WHILE @DailyHrs >= @Constant_WeeklyHrs 
							BEGIN	
								-- keep removing 40 until we have less than 40							
								select @wrkVariable_regularHrs = 0
								if @newDailyHrs >= @wrkVariable_remaining_hrs
									begin	
										select @wrkVariable_regularHrs = 0							
										select @wrkVariable_regularHrs = @newDailyHrs - @wrkVariable_remaining_hrs
										update #tmp_XrefPydDow  set pyd_Reg_updated = round(@wrkVariable_regularHrs,2)  where TmpXref_ID = @Tmp_id 	
										--select @wrkVariable_remaining_hrs = @wrkVariable_remaining_hrs - @wrkVariable_remaining_hrs
									end
								else if @newDailyHrs < @wrkVariable_remaining_hrs	
									begin
										select @wrkVariable_regularHrs = 0
										select @typesMustMatch = CONVERT(FLOAT, @Constant_WeeklyHrs )							
										select @wrkVariable_regularHrs = @newDailyHrs - @typesMustMatch
										update #tmp_XrefPydDow  set pyd_Reg_updated = round(@wrkVariable_regularHrs,2)  where TmpXref_ID = @Tmp_id 	
									end
								-- end if
							select @newDailyHrs = round(@wrkVariable_regularHrs,2)									
							select @DailyHrs = CONVERT(DECIMAL(8,2), @newDailyHrs )
							END
						end		
					else 
						BEGIN
							-- else @DailyHrs were less than 40 
							select @wrkVariable_regularHrs = 0
								if @newDailyHrs >= @wrkVariable_remaining_hrs
									begin	
										select @wrkVariable_regularHrs = 0							
										select @wrkVariable_regularHrs = @newDailyHrs - @wrkVariable_remaining_hrs
										update #tmp_XrefPydDow  set pyd_Reg_updated = round(@wrkVariable_regularHrs,2)  where TmpXref_ID = @Tmp_id 	
									end
								--  4/22/2014.start
								else
									begin									
										select @wrkVariable_regularHrs = 0
										select @typesMustMatch = CONVERT(FLOAT, @Constant_WeeklyHrs )							
										select @wrkVariable_regularHrs = @newDailyHrs - @typesMustMatch
										update #tmp_XrefPydDow  set pyd_Reg_updated = round(@wrkVariable_regularHrs,2)  where TmpXref_ID = @Tmp_id 	
									end	
									--  4/22/2014.end	
								-- else @DailyHrs , 40 AND @DailyHrs < remaingin hours so done now with that row.
							select @newDailyHrs = round(@wrkVariable_regularHrs,2)									
							select @DailyHrs = CONVERT(DECIMAL(8,2), @newDailyHrs )
						END
					-- end if
					
					
			select @wrkVariable_sum_hrs = sum(pyd_Reg_updated) from #tmp_XrefPydDow  where pyt_basisunit = 'TIM' 		
			select @wrkVariable_remaining_hrs = @wrkVariable_sum_hrs - @Constant_WeeklyHrs
			update #tmp_XrefPydDow set pyd_Reg_updated = @wrkVariable_sum_hrs where pyt_basisunit = 'SUMMRY'							
		end			
		
		---- Update  REGULAR Time if needed.				
	select @loopcnt = 0	
	select @rowcnt = count(TmpXref_ID) 	from #tmp_XrefPydDow where 	pyd_Reg_updated <> pyd_quantity	and pyt_basisunit <> 'SUMMRY'	-- if we need updates
			
	 -- debug.start
		  IF  @SetDebugON = 1
		  begin
			if @rowcnt > 0
				begin
					Print 'Debug ON: (Oregon OT) OROTRules Proc:  SUMMARY UPDATE EXISTING BasePay Hours'  + space(1) +
						'Number of PayDetail records to Update:' + space(1) + Convert(varchar(10),@rowcnt )
				end
			else
				begin
					Print 'Debug ON: (Oregon OT) OROTRules Proc:  SUMMARY NO updates needed for existing BasePay hours. '  						
				end
			-- end if	
		  end
	-- debug.end			
			
	if @rowcnt > 0 
	begin	
			
		select @rowcnt = count(TmpXref_ID) from #tmp_XrefPydDow where  pyt_basisunit <> 'SUMMRY'	
		
		set	@loopcnt = 0
			While @loopcnt <= @rowcnt 
				begin
					select @loopcnt = @loopcnt + 1
					select @basisunit	= pyt_basisunit from #tmp_XrefPydDow where TmpXref_ID = @loopcnt
					if @basisunit <> 'TIM' CONTINUE					
				
					select @newDailyHrs = 0
					select @typesMustMatch = 0
					select @typesMustMatch = pyd_quantity, @newDailyHrs	= pyd_Reg_updated from #tmp_XrefPydDow where TmpXref_ID = @loopcnt
					if @typesMustMatch  = @newDailyHrs  CONTINUE
					
					select  @pyd_number = pyd_number from #tmp_XrefPydDow where TmpXref_ID = @loopcnt					
					Select  @newRegularOT	= 0
					Select	@newDay7OT		= 0
					Select  @newDay7DblTime	= 0					
					select	@New_pyd_sequence = 0
					select  @type_pay = 'SUMMARY UPDATE-EXISTS-REGULAR'
					----------------------------------------------------------------------  update pay	
					if @newDailyHrs > 0 
						begin				
							exec StlPreCollect_OTbyState_Updates @pyd_number,
								'N/A', 'N/A',
							@type_pay,
							@newDailyHrs, NULL, NULL, NULL,  
							@New_pyd_sequence, NULL, NULL, NULL,  NULL	
						end	
				end
		
	end 		
			
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
GRANT EXECUTE ON  [dbo].[StlPreCollect_OTbyState_OR] TO [public]
GO
