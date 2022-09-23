SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[StlPreCollect_OTbyState_Controller](	@pl_pyhnumber int, 
																@ps_asgn_type varchar(6),
																@ps_asgn_id varchar(13),									
																@pdt_payperiod datetime, 
																@psd_id int , 
																@ps_message varchar(255) OUT )
as

set nocount on


/**
 * 
 * NAME:
 * dbo.StlPreCollect_OTbyState_Controller	one week pay period
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
*  PTS 71874
 * CUSTOM. Used in FINAL SETTLEMENT Pre-Collect Process. 
 * For all trips in payperiod for the Asset Determine the Hours worked.
 * When Trip (PRIMARY TARIFF) is Paid by TIME (pyt_basisunit = 'TIM') use pyd_quantity.
 * When Trip (Primary Tariff) is NOT Time, CALCULATE the Time using ArrDep formula: {customer uses "OutSide" time => ARRDEP}
 * RETURNS:
 * 1 success -1 error
 *
 *
 * RESULT SETS: 
*   None *
 * PARAMETERS:
 * 001 - @pl_pyhnumber int			? for future use
 * 002 - @ps_asgn_type varchar(6)
 * 003 - @ps_asgn_id varchar(13)
 * 004 - @pdt_payperiod datetime
 * 005 - @psd_id int batch id		? for future use
 * 006 - @ps_returnmsg varchar(255) OUTPUT
 * REFERENCES:
 * none
 * 
 *
*	// FileMaint:Driver: State OT window:
		State => mpp_ot_state
		Distaince Rules (miles) ==>	mpp_ot_miles
		Total Work Week	Min Hrs/Week				// box1  Min Hrs/Week   mpp_day15_rt_min
						Min Days/Week [not used] 	// box1  Min Days/Week	mpp_day7_ot_min [NOT USED]
		Day 1-6 Regular OT				 
						After Hrs/Day				// box2  After Hrs/Day	mpp_day6_ot_min 	 
		Day 7 *Regular* OT		 
						Consecutive Days Prior		// box3  days prior		mpp_day15_ot_max
						Consecutive Days Hrs/Day	// box3  consc HRs/Day  mpp_day15_ot_max
						Pay OT Hrs Up to			// box3	 PayOT HRs UpTo mpp_day7_ot_max
		DBLT Hrs/Day (Day 7 Only)	
						Pay Dbl Time Hrs After		// box 4  Pay DBL Time Hrs After  mpp_day7_dblt_min
		[ not shown ]				
						// [ NOT USED ]  -- mpp_day6_ot_max
						// [ NOT USED ]  -- 'mpp_day16_dblt_min						
						
		LabelFileDefaults: DefHrsPerWeek //--> mpp_day15_rt_min  ==>  label_extrastring4
						   DefOTHrsDay 	 //--> mpp_day6_ot_min	==> label_extrastring3
						   DefDBLTHrs 	 //--> mpp_day15_ot_min	==>  label_extrastring5	 			
 **/
 
DECLARE @tmwuser varchar (255)		--07/21/2014;  Check for StateDefaults;	
exec gettmwuser @tmwuser output		--07/21/2014;  Check for StateDefaults;	
  
 DECLARE @rowcnt		INT
 DECLARE @loopcnt		INT
 DECLARE @leg			INT
 Declare @basisunit	    VARCHAR(6)
 Declare @StateOTRules	VARCHAR(60)
 Declare @CARuleFlag	CHAR(1)
 Declare @ORRuleFlag	CHAR(1)
 Declare @WARuleFlag	CHAR(1) 
 Declare @sum_stp_trip_mileage	INT
 Declare @DrvTypeForOTSettings  VARCHAR(20)
 Declare @DriverTerminalState	VARCHAR(6)
 Declare @MessageText			VARCHAR(255)
 Declare @MessageText1			Varchar(100)
 Declare @SpacesToAdd			INT
 DECLARE @li_ret				INT
 DECLARE @ps_ReturnVal			INT
 DECLARE @SubProcReturnVal		INT
 Declare @NonAgriculturalLoadsCount int
 Declare @mpp_OT_miles			float		-- ==> Distance value for Miles Flag 
 Declare @Constant_MilesFlag	INT
 Set	 @Constant_MilesFlag	= 150
 Set	 @ps_ReturnVal = 0
 Set	 @SubProcReturnVal = 0
 
 create table #temp_state_country
	(	state_code varchar(6) Null,
		state_name varchar(50) Null,
		state_COUNTRY varchar(50) NULL)
 
 select @StateOTRules = gi_string4  
 from generalinfo  
 where	UPPER(gi_name)		= 'HOURLYOTPAY' 
 and	Upper(gi_string1)	= 'Y' 
 and	UPPER(gi_string2)	= 'StlPreCollect_OTbyState_Controller' 
 
IF  @StateOTRules is NULL Set @StateOTRules = SPACE(1) 
SET @CARuleFlag = 'N'
SET @ORRuleFlag = 'N'
SET @WARuleFlag = 'N' 

--====== Preliminary Validations START ======--
--			HourlyOTPay gi_string4 must be valid.
 --			Asset must be DRV;  DrvTypeForOTSettings gi_string1 MUST = DriType1,2,3 or 4; mpp_typex must = CA,OR,WA;
 --			Drivers Terminal state must be one of the list of valid OT States (gi_string4 for HourlyOTPay)

IF  ( LEN(LTRIM(RTRIM(@StateOTRules))) <= 0 )
 BEGIN
	Set @MessageText = '1_OTbyState:  The State Value(s) for GeneralInfoTable list for HOURLYOTPAY (gi_string4) is(are) missing. '
	Select @MessageText = @MessageText + 'Can not perform OT state-rules calculations.'
	raiserror(@MessageText, 16, 1)  	
	return -1
 END
 
 
 --#temp_state_country
  IF LEN(LTRIM(RTRIM(@StateOTRules))) > 0
  begin
	select @StateOTRules = UPPER(LTRIM(RTRIM(@StateOTRules)))
	declare @startlocation  INT
	declare @StateOTRulesLength INT
	declare @commafound			INT
	declare @loopCounter		INT
	declare @tmpstatecode		varchar(2)
	declare @st1				varchar(6)
	declare @st2				varchar(50)
	declare @st3				varchar(50)
	set @StateOTRulesLength = LEN(@StateOTRules)
	set @commafound = 0	
	set @startlocation = 1
	set @tmpstatecode = 'xx'
	set @loopCounter = 0
	set @MessageText1 = ''	
	SELECT @commafound = CHARINDEX(',', @StateOTRules, @startlocation)
	
		-- if only 1 entry
		IF @StateOTRulesLength = 2 AND @commafound = 0 
		begin
			select @tmpstatecode = SUBSTRING(@StateOTRules,1,2)						
				if ( select count(stc_state_c) from statecountry where stc_state_c = UPPER(@tmpstatecode) ) = 1
				begin
					Insert into #temp_state_country(state_code, state_name, state_COUNTRY)
					select stc_state_c, stc_state_desc, stc_country_c from statecountry where stc_state_c  = UPPER(@tmpstatecode) 
				end
		end
				
		-- if more than one entry & last character is NOT a comma, add one (so we are sure to get the LAST state code)
		IF @StateOTRulesLength > 2 
		begin
			IF SUBSTRING( @StateOTRules, @StateOTRulesLength, 1) <> ',' 
			begin
				select @StateOTRules = @StateOTRules + ','
				select @StateOTRulesLength = LEN(@StateOTRules)
				SELECT @commafound = CHARINDEX(',', @StateOTRules, @startlocation)
			end
		end		
	
		IF @commafound > 0 AND @StateOTRulesLength >=3
		begin
			while @startlocation <= @StateOTRulesLength
			begin
			
				set @loopCounter = @loopCounter + 1	
				IF @loopCounter > @StateOTRulesLength break	-- fail safe
						
				SELECT @commafound = CHARINDEX(',', @StateOTRules, @startlocation)
				IF @commafound -2 > 0
				begin
					select @tmpstatecode = SUBSTRING( @StateOTRules, (@commafound -2), 2) 
					
					if ( select count(stc_state_c) from statecountry where stc_state_c = UPPER(@tmpstatecode) ) = 1
						begin							
							select @st1 = stc_state_c, @st2 = stc_state_desc, @st3 = stc_country_c 
							from statecountry 
							where stc_state_c  = UPPER(@tmpstatecode) 	
							Insert into #temp_state_country(state_code, state_name, state_COUNTRY)							
							select @st1, @st2, @st3
							select @MessageText1 = @MessageText1 + LTrim(RTrim(@st1)) + ' ' + LTrim(RTrim(@st2)) + '; '
							set @st1 = ''
							set @st2 = ''
							set @st3 = ''							
							set @startlocation = @commafound + 2
							set @commafound = @commafound + 2							
						end
					else 
						begin
							Insert into #temp_state_country(state_code, state_name, state_COUNTRY)
							select @tmpstatecode, @tmpstatecode, @tmpstatecode
							set @startlocation = @commafound + 2
							set @commafound = @commafound + 2
						end	
					-- end if 					
				end		
				set @startlocation = @commafound + 1			
			end		-- end while		
		end
  end
     
 IF LEN(LTRIM(RTRIM(@StateOTRules))) > 0
 begin
	IF CHARINDEX('CA', @StateOTRules ) > 0 set @CARuleFlag = 'Y'
	IF CHARINDEX('OR', @StateOTRules ) > 0 set @ORRuleFlag = 'Y'
	IF CHARINDEX('WA', @StateOTRules ) > 0 set @WARuleFlag = 'Y'	
	
	IF @CARuleFlag = 'N'  AND @ORRuleFlag = 'N'  AND @WARuleFlag = 'N' 
	begin
		select @StateOTRules = UPPER(LTRIM(RTRIM(@StateOTRules)))
		Set @MessageText = '2_OTbyState: The State Value(s) indicated in GeneralInfoTable HOURLYOTPAY gi_string4 ['
		Select @MessageText = @MessageText + @StateOTRules + '] is(are) not currently supported.  Can not perform OT state-rules calculations.'			
		
		IF LEN(@MessageText) + LEN(@MessageText1) <= 255 
		begin
			select @MessageText = @MessageText + ' :: ' + @MessageText1
		end 		
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	end	
 end
  --Convert(varchar,@stp_arrivaldate) 
  
if 	@ps_asgn_type <> 'DRV' 
begin
	Set @MessageText = '3_OTbyState: The only asset type of allowed for OT state-rules computation is DRIVER.'
	Set @SpacesToAdd = (255 - Len(@MessageText) )
	select @MessageText = @MessageText + SPACE(@SpacesToAdd)
	raiserror(@MessageText, 16, 1)
	return -1
end
 
 select @DrvTypeForOTSettings  = gi_string1 from generalinfo where gi_name = 'DrvTypeForOTSettings'
 IF @DrvTypeForOTSettings Is Null OR LEN(LTrim(RTrim(@DrvTypeForOTSettings))) <= 0 
 begin
	Set @MessageText = '4_OTbyState: GeneralInfo gi_string1 for DrvTypeForOTSettings is missing; Can not perform OT state-rules calculations.'
	Set @SpacesToAdd = (255 - Len(@MessageText) )
	select @MessageText = @MessageText + SPACE(@SpacesToAdd)
	raiserror(@MessageText, 16, 1)
	return -1
 end
 
IF ( UPPER(@DrvTypeForOTSettings) <> 'DRVTYPE1' AND UPPER(@DrvTypeForOTSettings) <> 'DRVTYPE2' 
		AND UPPER(@DrvTypeForOTSettings) <> 'DRVTYPE3' AND UPPER(@DrvTypeForOTSettings) <> 'DRVTYPE4' ) 
begin
	Set @DrvTypeForOTSettings = LTRIM(RTRIM(@DrvTypeForOTSettings))
	Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
	Set @MessageText = '5_OTbyState: Driver Terminal State (' + @DrvTypeForOTSettings + ') for Driver ('
	Select @MessageText = @MessageText + @ps_asgn_id + ') Must be DrvType1,2,3 or 4; It is set to: ' 
	Select @MessageText = @MessageText + 'Can not perform OT state-rules calculations.'
	Set @SpacesToAdd = (255 - Len(@MessageText) )
	select @MessageText = @MessageText + SPACE(@SpacesToAdd)
	raiserror(@MessageText, 16, 1)  	
	return -1
end

IF			 CHARINDEX('1', @DrvTypeForOTSettings ) > 0 
	begin
		select  @DriverTerminalState = mpp_type1 from manpowerprofile where mpp_id = @ps_asgn_id
	end
ELSE IF 	 CHARINDEX('2', @DrvTypeForOTSettings ) > 0 
	begin
		select  @DriverTerminalState = mpp_type2 from manpowerprofile where mpp_id = @ps_asgn_id
	end
ELSE IF 	 CHARINDEX('3', @DrvTypeForOTSettings ) > 0 
	begin
		select  @DriverTerminalState = mpp_type3 from manpowerprofile where mpp_id = @ps_asgn_id
	end
ELSE IF 	 CHARINDEX('4', @DrvTypeForOTSettings ) > 0 
	begin
		select  @DriverTerminalState = mpp_type4 from manpowerprofile where mpp_id = @ps_asgn_id
	end		

 IF @DriverTerminalState Is Null 
	OR LEN(LTrim(RTrim(@DriverTerminalState))) <= 0  
		OR LTrim(RTrim(@DriverTerminalState)) = 'UNK' 
			OR LTrim(RTrim(@DriverTerminalState)) = 'UNKNOWN'
 begin
	Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
	set @DrvTypeForOTSettings = UPPER(LTRIM(RTRIM(@DrvTypeForOTSettings)))
	Set @MessageText = '6_OTbyState: Driver Terminal State from (' + @DrvTypeForOTSettings + ') for Driver '
	Select @MessageText = @MessageText + @ps_asgn_id + ' is missing or Unknown; Can not perform OT state-rules calculations.'
	Set @SpacesToAdd = (255 - Len(@MessageText) )
	select @MessageText = @MessageText + SPACE(@SpacesToAdd)
	raiserror(@MessageText, 16, 1)  	
	return -1
 end
  
 Select @DriverTerminalState = UPPER(LTRIM(RTRIM(@DriverTerminalState)))
	IF (  @DriverTerminalState <> 'CA' AND @DriverTerminalState <> 'OR' AND @DriverTerminalState <> 'WA' )
	BEGIN
		Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
		set @DrvTypeForOTSettings = UPPER(LTRIM(RTRIM(@DrvTypeForOTSettings)))
		Set @MessageText = '7_OTbyState: Driver Terminal State (' 
		Select @MessageText = @MessageText + @DriverTerminalState + ' from ' + @DrvTypeForOTSettings + ') for Driver '
		Select @MessageText = @MessageText + @ps_asgn_id + ' is either not supported or is not a valid state.  Must be one of this list (' 
		Select @MessageText = @MessageText + @StateOTRules + '). Can not perform OT state-rules calculations.'
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	END	
	
	IF ( ( @DriverTerminalState = 'CA' and  @CARuleFlag <> 'Y' ) 
			OR ( @DriverTerminalState = 'OR' and  @ORRuleFlag <> 'Y' )  
				OR ( @DriverTerminalState = 'WA' and  @WARuleFlag <> 'Y' ) ) 
	BEGIN		
		Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
		Set @MessageText = '8_OTbyState: Driver Terminal State for Driver ' 
		Select @MessageText = @MessageText + @ps_asgn_id + ' is set to ' + @DriverTerminalState + '. '
		Select @MessageText = @MessageText + 'This value is not part of the GeneralInfoTable list for HOURLYOTPAY which includes('
		Select @MessageText = @MessageText + @StateOTRules + ').  Can not perform OT state-rules calculations.'
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	END		
	
--07/21/2014.start:   Add check for StateDefaults;	
IF  ( (select count(mpp_id) from manpowerprofile_CA_OT_rules 
						 where	mpp_id = 'STATEDEF' 
						 AND mpp_ot_state = @DriverTerminalState 
						 AND mpp_SetDefaultForState = 1 ) = 1 
	AND (select count(mpp_id)	from manpowerprofile_CA_OT_rules 
								where	mpp_id = @ps_asgn_id 
								AND	@DriverTerminalState = mpp_OT_state) = 0 ) 
	BEGIN			
		INSERT INTO [manpowerprofile_CA_OT_rules]
		(	mpp_id 
           ,mpp_updatedby
           ,mpp_updatedon
           ,mpp_day15_ot_min
           ,mpp_day15_ot_max 
           ,mpp_day6_ot_min
           ,mpp_day6_ot_max 
           ,mpp_day7_ot_min 
           ,mpp_day7_ot_max 
           ,mpp_day16_dblt_min 
           ,mpp_day7_dblt_min 
           ,mpp_day15_rt_min 
           ,mpp_OT_state
           ,mpp_OT_miles
		)	
		SELECT @ps_asgn_id
           ,@tmwuser 
           ,GETDATE()
           ,mpp_day15_ot_min
           ,mpp_day15_ot_max 
           ,mpp_day6_ot_min
           ,mpp_day6_ot_max 
           ,mpp_day7_ot_min 
           ,mpp_day7_ot_max 
           ,mpp_day16_dblt_min 
           ,mpp_day7_dblt_min 
           ,mpp_day15_rt_min 
           ,@DriverTerminalState
           ,mpp_OT_miles
           from manpowerprofile_CA_OT_rules where mpp_id = 'STATEDEF'  AND mpp_ot_state = @DriverTerminalState AND mpp_SetDefaultForState = 1
         
	END		
--07/21/2014.end:  Check for StateDefaults;
	
IF (select count(mpp_id) from manpowerprofile_CA_OT_rules 
				where	mpp_id = @ps_asgn_id 
				AND		@DriverTerminalState = mpp_OT_state) <= 0
	begin
			Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
			Set @MessageText = '9_OTbyState: State OT rules are not set up for Driver '
			Select @MessageText = @MessageText + @ps_asgn_id + ' for ' + @DriverTerminalState + '. '
			Select @MessageText = @MessageText + ' Can not perform OT state-rules calculations.'
			Set @SpacesToAdd = (255 - Len(@MessageText) )
			select @MessageText = @MessageText + SPACE(@SpacesToAdd)
			raiserror(@MessageText, 16, 1)
			return -1
	end
	
	-- check table values
	--IF mpp_day15_rt_min > 0.0		--	@Constant_Day1_to_6MinTotalHrs 	-- box1  [30 or 40]
	--IF mpp_day6_ot_min  > 0.0		--	@Constant_DailyHrs			  	-- box2	 [10]
	--IF mpp_day15_ot_max  > 0.0     -- @Constant_Day7NbrDaysPrior	   	-- box3(1) [6]
	--IF mpp_day15_ot_min  > 0.0	--	@Constant_Day1_to_6MinDailyHrs 	-- box3(2) [6]
	--IF mpp_day7_ot_max  > 0.0		--  @Constant_Day7_MinHrsWorked	   	-- box3(3) [8]
	--IF mpp_day7_dblt_min > 0.0    --  @Constannt_day7_DblT_HRS_After 	-- box3(3) [8]
	
	IF ( Select IsNull(mpp_day15_rt_min,0) + ISNULL(mpp_day6_ot_min,0) + ISNULL(mpp_day15_ot_max,0) +
				ISNULL(mpp_day15_ot_min,0) + IsNull(mpp_day7_ot_max,0) + ISNULL(mpp_day7_dblt_min,0)
				 from	manpowerprofile_CA_OT_rules 
				 where  mpp_id = @ps_asgn_id
				 AND	@DriverTerminalState = mpp_OT_state)  = 0 
	begin
			Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))
			Set @MessageText = '10_OTbyState: State OT rules are all set to ZERO for Driver '
			Select @MessageText = @MessageText + @ps_asgn_id + ' for ' + @DriverTerminalState + '. '
			Select @MessageText = @MessageText + ' Can not perform OT state-rules calculations.'
			Set @SpacesToAdd = (255 - Len(@MessageText) )
			select @MessageText = @MessageText + SPACE(@SpacesToAdd)
			raiserror(@MessageText, 16, 1)
			return -1
	end 
		
	
--====== Preliminary Validations END ======--
	
Select @li_ret = 0	 
 
 Create Table #TmpDistinctLeg
 (	 TmpLeg_id				INT         IDENTITY
	,lgh_number				INT			NULL
	,sum_stp_trip_mileage   INT			NULL
	,pyt_basisunit			VARCHAR(6)	NULL	
 )
 
 insert into #TmpDistinctLeg (lgh_number, pyt_basisunit ) 
 select Distinct lgh_number, pyt_basisunit 
 from	paydetail
			left join paytype	on paydetail.pyt_itemcode = paytype.pyt_itemcode
			left join tariffkey on paydetail.tar_tarriffnumber = tariffkey.tar_number
	where 	asgn_type = @ps_asgn_type 
	and 	asgn_id = @ps_asgn_id 
	and 	pyh_payperiod = @pdt_payperiod
	and		tariffkey.trk_primary = 'Y'
 
 -- 4/22/2014.start
 Create Table #TmpDistinctMove
  (	 TmpMov_id				INT         IDENTITY
	,mov_number				INT			NULL
	,ord_revtype3			varchar(6)	NULL
 )

insert into #TmpDistinctMove (mov_number, ord_revtype3)
select distinct orderheader.mov_number, orderheader.ord_revtype3  
from orderheader 
where UPPER(orderheader.ord_revtype3) = 'BRK' 
AND mov_number in ( select distinct(mov_number)
					from legheader 
					where ( lgh_driver1 =  @ps_asgn_id OR lgh_driver2   = @ps_asgn_id )
					and lgh_number > 0 
					and lgh_number in (select lgh_number from #TmpDistinctLeg where lgh_number > 0 ) ) 
 -- 4/22/2014.end

 --============= RealWork:   The 'real' work starts here =============-- 
 select @rowcnt = count(*) from #TmpDistinctLeg  
 set	@loopcnt = 1
 
 While @loopcnt <= @rowcnt 
 BEGIN	
	select @leg = lgh_number from #TmpDistinctLeg where TmpLeg_id = @loopcnt
	select @basisunit = pyt_basisunit from #TmpDistinctLeg where TmpLeg_id = @loopcnt
	
	select @sum_stp_trip_mileage = SUM(IsNull(stops.stp_trip_mileage,0))									
								   FROM stops 
								   WHERE stops.lgh_number = @leg
								   group by stops.lgh_number 	
	Update #TmpDistinctLeg 
	set		sum_stp_trip_mileage = @sum_stp_trip_mileage 
	where	#TmpDistinctLeg.lgh_number = @leg	
	 
	select @loopcnt = @loopcnt + 1
 END   
     
 IF @DriverTerminalState = 'CA'  AND  @CARuleFlag = 'Y'
 BEGIN
	-- @Constant_MilesFlag is initalized at 150 miles Per SR.
	Select @mpp_OT_miles	 = 	  IsNull(mpp_OT_miles,0) 	from	manpowerprofile_CA_OT_rules 
												where   mpp_id = @ps_asgn_id
												AND		mpp_OT_state = 'CA'
	IF 	@mpp_OT_miles > 0.0 
				begin
					set @Constant_MilesFlag = CONVERT(INT, @mpp_OT_miles)		
				end	
	
	
	--IF ( Select count(lgh_number) from #TmpDistinctLeg where sum_stp_trip_mileage < 150 ) = 0 
	IF ( Select count(lgh_number) from #TmpDistinctLeg where sum_stp_trip_mileage < @Constant_MilesFlag ) = 0 
	begin
		Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))		
		Set @MessageText = 'CA-1_OTbyState: Driver ' + @ps_asgn_id 
		--Select @MessageText = @MessageText + ' has zero trips LESS THAN 150 Miles; Driver is not eligible for CA-OT for this payperiod.'
		Select @MessageText = @MessageText + ' has zero trips LESS THAN ' +
				 Convert(varchar(5),@Constant_MilesFlag) + ' Driver is not eligible for CA-OT for this payperiod.'
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	end
 
	--  * StlPreCollect_OTbyState_CA RETURNS  1 success -1 error 
		exec dbo.StlPreCollect_OTbyState_CA @pl_pyhnumber, 
													@ps_asgn_type,
													@ps_asgn_id,									
													@pdt_payperiod, 
													@psd_id, 
													@ps_ReturnVal OUTPUT 
		
	Set	 @SubProcReturnVal = @ps_ReturnVal
	IF @SubProcReturnVal = 1
		begin
			select @ps_message = 'Precollect for California OT Rules processed successfully for Driver: ' + @ps_asgn_id	
		end 
	Else
		begin
			select @ps_message = 'Precollect process using California OT Rules Failed for Driver: ' + @ps_asgn_id	
		end		
	-- end if
 END
    
  
 -- Note:  for the moment, Oregon and Washington OT rules are the SAME. 
IF @DriverTerminalState = 'OR'  AND @ORRuleFlag = 'Y'
BEGIN
	select @NonAgriculturalLoadsCount = count(IsNull(ord_revtype3, 'UNK') ) 
	from orderheader 
	where ord_hdrnumber in (select distinct(ord_hdrnumber) 
											 from legheader 
											 where ord_hdrnumber > 0 
											 and lgh_number in (select lgh_number 
													from #TmpDistinctLeg where lgh_number > 0 ) ) 
	AND UPPER(orderheader.ord_revtype3) = 'BRK'											
	
	if @NonAgriculturalLoadsCount is null select @NonAgriculturalLoadsCount = 0	
	--4/22/2014.start		
	if @NonAgriculturalLoadsCount = 0 
	begin	
		set @NonAgriculturalLoadsCount = (select count(*) from #TmpDistinctMove)
		if @NonAgriculturalLoadsCount is null select @NonAgriculturalLoadsCount = 0	
	end
	--4/22/2014.end
	if @NonAgriculturalLoadsCount <= 0 
	begin
		Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))		
		Set @MessageText = 'OR-1_OTbyState: Driver ' + @ps_asgn_id 
		Select @MessageText = @MessageText + ' has zero Non-Agricultural trips in this payperiod; Driver is not eligible for OR-OT.'
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	end
	
	--  * StlPreCollect_OTbyState_OR RETURNS  1 success -1 error 
		exec dbo.StlPreCollect_OTbyState_OR @pl_pyhnumber, 
													@ps_asgn_type,
													@ps_asgn_id,									
													@pdt_payperiod, 
													@psd_id, 
													@ps_ReturnVal OUTPUT 
		
	Set	 @SubProcReturnVal = @ps_ReturnVal
	IF @SubProcReturnVal = 1
		begin
			select @ps_message = 'Precollect for Oregon OT Rules processed successfully for Driver: ' + @ps_asgn_id	
		end 
	Else
		begin
			select @ps_message = 'Precollect process using Oregon OT Rules Failed for Driver: ' + @ps_asgn_id	
		end		
	-- end if
	
	
END

IF  @DriverTerminalState = 'WA' AND @WARuleFlag = 'Y'
BEGIN
	select @NonAgriculturalLoadsCount = count(IsNull(ord_revtype3, 'UNK') ) 
	from orderheader 
	where ord_hdrnumber in (select distinct(ord_hdrnumber) 
											 from legheader 
											 where ord_hdrnumber > 0 
											 and lgh_number in (select lgh_number 
													from #TmpDistinctLeg where lgh_number > 0 ) ) 
	AND UPPER(orderheader.ord_revtype3) = 'BRK'											
	
	if @NonAgriculturalLoadsCount is null select @NonAgriculturalLoadsCount = 0	
	--4/22/2014.start		
	if @NonAgriculturalLoadsCount = 0 
	begin	
		set @NonAgriculturalLoadsCount = (select count(*) from #TmpDistinctMove)
		if @NonAgriculturalLoadsCount is null select @NonAgriculturalLoadsCount = 0	
	end
	--4/22/2014.end
	if @NonAgriculturalLoadsCount <= 0 
	begin
		Set @ps_asgn_id = UPPER(LTRIM(RTRIM(@ps_asgn_id)))		
		Set @MessageText = 'WA-1_OTbyState: Driver ' + @ps_asgn_id 
		Select @MessageText = @MessageText + ' has zero Non-Agricultural trips in this payperiod; Driver is not eligible for WA-OT.'
		Set @SpacesToAdd = (255 - Len(@MessageText) )
		select @MessageText = @MessageText + SPACE(@SpacesToAdd)
		raiserror(@MessageText, 16, 1)  	
		return -1
	end
	
	--  * StlPreCollect_OTbyState_WA RETURNS  1 success -1 error 
		exec dbo.StlPreCollect_OTbyState_WA @pl_pyhnumber, 
													@ps_asgn_type,
													@ps_asgn_id,									
													@pdt_payperiod, 
													@psd_id, 
													@ps_ReturnVal OUTPUT 
		
	Set	 @SubProcReturnVal = @ps_ReturnVal
	IF @SubProcReturnVal = 1
		begin
			select @ps_message = 'Precollect for Washington OT Rules processed successfully for Driver: ' + @ps_asgn_id	
		end 
	Else
		begin
			select @ps_message = 'Precollect process using Washington OT Rules Failed for Driver: ' + @ps_asgn_id	
		end		
	-- end if
	
	
END
   
IF OBJECT_ID(N'tempdb.. #temp_state_country', N'U') IS NOT NULL 
DROP TABLE  #temp_state_country

IF OBJECT_ID(N'tempdb.. #tmp_Trips', N'U') IS NOT NULL 
DROP TABLE  #tmp_Trips

IF OBJECT_ID(N'tempdb.. #TmpDistinctLeg', N'U') IS NOT NULL 
DROP TABLE  #TmpDistinctLeg


GO
GRANT EXECUTE ON  [dbo].[StlPreCollect_OTbyState_Controller] TO [public]
GO
