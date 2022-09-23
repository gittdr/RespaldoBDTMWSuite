SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[CreateAvgFuelFormula_sp] @pl_aff_id  int, @processDate datetime, @ps_returnmsg varchar(255) Output 
AS
Set Nocount On
 
/**
 * *****************************************************************************************************************************
 * NAME:
 * dbo.CreateAvgFuelFormula_sp
 * TYPE:
 * StoredProcedure
 *
 *				Note:  SHOULD almost NEVER use getdate() in this proc;  use @processDate (if 'current' then @processDate = getdate() )
 * Arguments:	@pl_aff_id	int
 *					@pl_aff_id IS THE aff_id [KEY] of the AvgFuelFormulaCriteria table.
 *					Valid Values:   any integer > 0.  NULL = Error. 
 *						aff_id is used to pull the PARENT DOE TABLE ID: 
 *							( AvgFuelFormulaCriteria.afp_tableid  =  averagefuelprice.afp_tableid {afp_IsFormula = 0} )
 *							AND to get the [criteria based] CHILD/Formula Table id:
 *							( AvgFuelFormulaCriteria.aff_formula_tableid   =  averagefuelprice.afp_tableid {afp_IsFormula = 1} )
 *								NOTE:   averagefuelprice.afp_IsFormula is used to distinguish between PARENT and CHILD/Formula data:
 *								PARENT fuel-price data [ ==> manually entered and/or DOE Imported fuel prices:  afp_IsFormula = 0  ]
 *								CHILD/Formula fuel-price data [ COMPUTED based on AvgFuelFormulaCriteria criteria: afp_IsFormula = 1  ]
 *
 *				@processDate datetime
 *					@processDate used as a STARTING POINT to generate the Child-Formula's NEW EFFECTIVE DATE.					
 *					Valid Values:	any valid date <= 'today'.  NULL would reset to today (but will most likely error out on the PB side).
 *						Expected Values: EITHER 'today's date' (when computing a 'current' initial Child-Formula table entry) 
 *						OR a past date (when computing a 'backfill' Child-Formula table entry)
 *						
 *				@ps_returnmsg varchar(255) Output 
 *					@ps_returnmsg is RETURNED to the calling process to communicate process success or failure.
 *					Valid Values: previous to 75085; this was space(255); AFTER 75085; first 8 characters should contain an INPUT value.
 *						-- PTS75085:	@ps_returnmsg will now also have an INPUT value;  'BACKFILL' or 'CURRENT' (empty/null => Current)
 *						--				this was done to remove the need to maintain TWO seperate CREATE-Procs
 *						--				{we do still require a seperate scheduled-update proc which is run following new DOE imports.}
 *
 *
 * DESCRIPTION:	See \\tmwsystems\cle\DEV-Shared\DOE_AvgFuel_ClientDefinedPrice\Documentation\CORE_AvergeFuel.docx for full description.
 *				Process enabled when GI EnableAvgFuelFormulaCalc gi_string1 = 'Y'.
 *					Creates ONE NEW ROW in the averagefuelprice table based on averagefuelprice-data and CRITERIA from the AvgFuelFormulaCriteria table.  
 *					Compute a CHILD/Formula Fuel-PRICE and EFFECTIVE DATE;  when successful, data are written to averagefuelprice table. 
 *						Identify averagefuelprice Parent vs averagefuelprice child/formula data by the value of afp_IsFormula.
 *						CHILD  => averagefuelprice.afp_IsFormula = 1
 *						PARENT => averagefuelprice.afp_IsFormula = 0 [Null = 0]
 *					Data input values (raw-data) used in Calculations are drawn from PARENT averagefuelprice data.
 *					The (averagefuelprice) KEY of the 'PARENT' is identified by the value of AvgFuelFormulaCriteria.afp_tableid.
 *					The (averagefuelprice) KEY of the 'CHILD/Formula' is identified by the value of AvgFuelFormulaCriteria.aff_formula_tableid.
 *						Compuations for new-fuel-price and new-fuel-effective-date are based on the AvgFuelFormulaCriteria table criteria values.
 *						NEW [Current]  Effective Dates are usually greater than or equal to 'today' {if the Parent table-data is up-to-date}.
 *						New [BackFill] Effective Dates are usually greater than a specific past-Parent afp_date {because we are filling-in 'old' data}.
 *						New fuel-PRICES are computed using parent fuel-prices as raw-data.  
 *							Parent fuel-prices are chosen because they are the values associated to 
 *							a date or date-range we calculate based on the criteria {and now also based on gi column values}.
 *
 * ************** MODIFICATIONS **************
 *		9/07/2011:	PTS 56708:	JSwin	Initial Development.
 *		5/09/2012:	PTS 61286	JSwin	Added Validations for corrupt data that the 'old' PB window does not prevent.  
 *										Also account for 'old' data or data entered with new GI = OFF where afp_IsFormula is NULL (test for null)
 *										Add "Error:"  to beginning of Error messages so PB knows it is an error
 *	   11/29/2012:	PTS 63266:	JSwin	Add new formula
 *	   12/17/2013:	PTS 68003:	JSwin	Code-to-Core for (previously coded to ServicePack) INTRODUCE ADDITIONAL GI controls for Computation CUSTOMIZATION:
 *											Description of additional calculation controls based on GI columns:
 *											GeneralInfo 'EnableAvgFuelFormulaCalc'
 *												gi_string1 = Y/N  (Null = N) continues to enable/disable client-defined formula creation process.
 *											Settings for control of price and data calculations:
 *												gi_string3 = Null or 00, 01, 02, 03(default), 04  Defines the meaning of 'CURRENT'
 *														Understand these settings by first assuming that [getdate()] TODAY is the starting point.
 *														Assume first (for now) that a week begins on Monday and ends on the following Sunday.
 *														Find the DATE of the 'Current-MONDAY' (the Monday of the week that TODAY falls into).
 *															00:  Current = THIS Week's Monday as described above.
 *																 NEW Effective Date calculations use THIS Week's monday as the starting point.
 *																 NEW Fuel-Price calculations are computed parent prices associated to dates 
 *																		calculated using THIS Week's Monday as the starting point.
 *															01:	Current = 7 days less than THIS Week's Monday (monday - 7)
 *															02:	Current = 14 days less than THIS Week's Monday (monday - 14)
 *															03: *Current = the date of the Monday falling in same week as the Maximim Parent-DOE date.
 *																	* NOTE: This differs from original 56708 coding due to client observation after using the feature.
 *																	* Original coding: Max DOE value in table used for prices & TODAY + (formula) = new eff date
 *															04: Current = the date of the Monday falling in same week as the Maximim Parent-DOE date.
 *												gi_integer1 = Null or 1,2,3,4,5,6,7.  (Null or values less than zero or greater than 7 will = 1)
 *														Designates which day of the week the 'effective' WEEK begins: 1 = Sunday (so the week is Sunday through Saturday).
 *														2 = Monday (so the week is Monday through Sunday) ** this will probably be the most commonly desired value.
 *
 *											[Not used in Proc] gi_string2, gi_string4, gi_date1
 *												See \\tmwsystems\cle\DEV-Shared\DOE_AvgFuel_ClientDefinedPrice\Documentation\CORE_AvergeFuel.docx for full description.
 *													Settings for control of BackFill Default Date:
 *														gi_string4 = a value used to indicate how to set the default backfill date in the UI.
 *														gi_date1   = a hard coded date to use as a default backfill date in the UI. *												
 *													Settings for control association of tariffs to fuel formulas
 *														gi_string2 = Null or MULTI (Null = Not Set) *USED in UI Only; not used in procs. Allows association of formulas to multiple tariffs.
 *	
 *	   04/14/2014:	PTS 65765:	JSwin	65765, 68003, 65092 and 75085:	Code-to-Core for Consolidated PTS List (previously coded to various ServicePack's). 
 *	   06/11/2014:	PTS 66086:  JSwin	Formula: PREV MONTH / UI fixes / Account Any Day of the Week (raw-data) DOE values 
 *	   08/28/2014:  Fixes for issues identified by QA testing!
 *		
 * *****************************************************************************************************************************							
 **/
   
If not exists (select 1 from generalinfo Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' ) Return


--====== Preliminary Process start    ========================================================================

Declare @gi_integer1				int				-- 75085 et al;
Declare	@gi_string3 				varchar(2)
declare	@RunBackFill				varchar(8)
declare	@TableMaxParentDate			datetime
declare	@MondayMonday				datetime
declare @maxParentDate				datetime
declare	@minBackFillDate			datetime
declare	@PREV_WEEK_ParentDate		datetime
declare	@maxParentDate_dayofweek	int
declare	@ccFirstofMonth datetime
declare @chosenDate int 
declare @afpIdProcessed int	--92303 nloke

select @RunBackFill = SUBSTRING(@ps_returnmsg, 1, 8)
if @RunBackFill is null OR Len(LTRIM(RTRIM(@RunBackFill))) = 0  select @RunBackFill = 'CURRENT'
select @RunBackFill = LTRIM(RTRIM(@RunBackFill))
select @RunBackFill = UPPER(@RunBackFill )
set @ps_returnmsg = SPACE(255)

IF  @processDate is null set @processDate = GETDATE()
Set @processDate = Cast(CONVERT(VARCHAR(10), @processDate, 101) + ' 00:00:00' as datetime) 

		select  @gi_string3  =  IsNull(gi_string3, '03'),
				@gi_integer1 = IsNull(gi_integer1, 1) 
				from generalinfo 
				Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' 		
		IF LTrim(RTrim(@gi_string3)) = '' Set @gi_string3 = '03'
		IF @gi_string3 = '0' set @gi_string3 = '00'
		IF @gi_string3 = '1' set @gi_string3 = '01'
		IF @gi_string3 = '2' set @gi_string3 = '02'
		IF @gi_string3 = '3' set @gi_string3 = '03'
		IF @gi_string3 = '4' set @gi_string3 = '04'
		
		IF @gi_string3 <> '00' and 
				@gi_string3 <> '01' and 
					@gi_string3 <> '02' and 
						@gi_string3 <> '03' and 
							@gi_string3 <> '04' Set @gi_string3 = '03'

--===================================================================
create table #tmp_DistinctAvgFuelTableList
(		tempListID int	identity,	
		afp_tableid varchar(8) null,
		afp_description varchar(30) null,		
		afp_date datetime null, 				
		sortOrder int null	
)

Insert Into #tmp_DistinctAvgFuelTableList( afp_tableid, afp_description, afp_date, sortOrder)
Select 	distinct  afp_tableid, afp_description,	
		( select MAX(a1.afp_date) from averagefuelprice a1 where a1.afp_date < '2049-12-31 00:00:00.000' AND a1.afp_tableid = averagefuelprice.afp_tableid ) 'maxdt',
		cast(afp_tableid as integer) 'sortOrder'
		from  		averagefuelprice 
		where 	afp_IsFormula = 0
		AND		 afp_tableid in (  select Distinct(afp_tableid) 
                                    from AvgFuelFormulaCriteria 
                                    where aff_formula_tableid in ( select distinct      (afp_tableid)     
                                                                                 from averagefuelprice  
                                                                                 where afp_IsFormula = 1 )   )
		order by cast(afp_tableid as integer)
--===================================================================

-- everything begins with MONDAY of THIS week
set @MondayMonday = ( select DateAdd(DD, - ( Datepart(dw, @processDate  ) - 1 ) , @processDate  ) + 1  ) 

if @gi_string3 = '00'	select @MondayMonday	= @MondayMonday		-- PTS66086 6-11-14
if @gi_string3 = '01'   select @MondayMonday	= DateAdd(DD, -7, @MondayMonday )		-- fuel & effective dates from monday - 7
if @gi_string3 = '02'   select @MondayMonday	= DateAdd(DD, -14, @MondayMonday )		-- fuel & effective dates from monday - 14
Set @MondayMonday = CONVERT(VARCHAR(10), @MondayMonday, 101) + ' 00:00:00'

IF @RunBackFill = 'CURRENT' 
	begin
			-- PTS66086 6-11-14
			select @minBackFillDate = min(afp_date)
			from	averagefuelprice 
			where	ISNULL(afp_IsFormula, 0) = 0
			and afp_tableid = (select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			if @minBackFillDate is null 
			begin 
				Set @minBackFillDate = Cast(CONVERT(VARCHAR(10), '1950-01-01 00:00:00.000', 101) + ' 00:00:00' as datetime)
			end		
	end
else
	begin
		Set @minBackFillDate = @processDate ----DATEADD( mm, -1 , @MondayMonday)	
		Set @minBackFillDate = Cast(CONVERT(VARCHAR(10), @minBackFillDate, 101) + ' 00:00:00' as datetime)		
	end	

-- find afp-date EQUAL TO the desired 'current-monday' setting. [if current is null, get max monday for table id]
if @gi_string3 = '00' OR @gi_string3 = '01'	OR @gi_string3 = '02'		
begin
	select	@maxParentDate = afp_date, @afpIdProcessed = afp_id		--92303 
	from	averagefuelprice 
	where	ISNULL(afp_IsFormula, 0) = 0
	and		afp_date  = @MondayMonday	
	and afp_tableid = (select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )		-- 92303
	
	if @maxParentDate is null 
		begin
			-- PTS66086 6-11-14
			select	@maxParentDate =  min(afp_date), @afpIdProcessed = afp_id		--92303
			from	averagefuelprice 
			where	ISNULL(afp_IsFormula, 0) = 0
			and afp_tableid = (select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			and ( afp_date >= DateAdd(DD, -1, @MondayMonday)  AND afp_date <= DateAdd(DD, +5, @MondayMonday)   )
			group by afp_id		-- 92303
		end
	
		IF @maxParentDate is NULL 
		begin
				-- PTS66086 6-11-14
				select @ps_returnmsg = 'Error: GI string3 set to ' + 
				@gi_string3 + ': Department of Energy data is not available for the week of ( ' +  cast(@MondayMonday as Varchar(12) ) + ') '	
				SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
				Return
		end 
		
	-- PTS66086 6-11-14	
	if @maxParentDate is null 
		begin
			select	@maxParentDate =  max(afp_date), @afpIdProcessed = afp_id		--92303
			from	averagefuelprice 
			where	ISNULL(afp_IsFormula, 0) = 0
			and afp_tableid = (select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			group by afp_id		-- 92303
			--and Datepart(dw, averagefuelprice.afp_date  ) = 2			
			set @MondayMonday = ( select DateAdd(DD, - ( Datepart(dw, @maxParentDate  ) - 1 ) ,@maxParentDate  ) + 1  ) 			
		end 		
end		
	

-- find max afp-date not greater than 'today'
if @gi_string3 = '03'  
begin
	select	@maxParentDate = max(afp_date), @afpIdProcessed = afp_id		--92303 
	from	averagefuelprice 
	where	ISNULL(afp_IsFormula, 0) = 0
	and		afp_date  <= @MondayMonday
	and		afp_date	>=	@minBackFillDate
	and		afp_tableid = ( Select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
	group by afp_id		-- 92303
end	

-- PTS66086 6-11-14	[re-worked string = 04 for correct backfill processing]
if  @gi_string3 = '04'	 
begin
	IF @RunBackFill = 'CURRENT' 
		begin
			select	@maxParentDate = max(afp_date), @afpIdProcessed = afp_id		--92303 
			from	averagefuelprice 
			where	ISNULL(afp_IsFormula, 0) = 0
			and		afp_date  <= @processDate
			and		afp_date	>=	@minBackFillDate
			and		afp_tableid = ( Select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			group by afp_id		-- 92303
		end
	else
		begin	
			-- computing the BACKFILL we ALWAYS WANT @processDate		
			if @processDate = @minBackFillDate
			begin 
				select	@minBackFillDate = min(afp_date) 
				from	averagefuelprice 
				where	ISNULL(afp_IsFormula, 0) = 0
				and		afp_tableid = ( Select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			end
			
			select @processDate = Cast(CONVERT(VARCHAR(10), @processDate, 101) + ' 23:59:59' as datetime)
			select @minBackFillDate = Cast(CONVERT(VARCHAR(10), @minBackFillDate, 101) + ' 00:00:00' as datetime)
			
			select	@maxParentDate = max(afp_date), @afpIdProcessed = afp_id		--92303  
			from	averagefuelprice 
			where	ISNULL(afp_IsFormula, 0) = 0
			and		afp_date  <= @processDate
			and		afp_date	>=	@minBackFillDate
			and		afp_tableid = ( Select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
			group by afp_id		-- 92303
		end
end									

select @TableMaxParentDate = max(afp_date) 
	from	averagefuelprice 
	where	ISNULL(afp_IsFormula, 0) = 0
	and		afp_date  <= @processDate
	and		afp_date	>=	@minBackFillDate
	and		afp_tableid = ( Select min(afp_tableid) from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )

-- reset @maxParentDate to be the Monday of the week of @maxParentDate
set @maxParentDate = ( select DateAdd(DD, - ( Datepart(dw, @maxParentDate ) - 1 ) , @maxParentDate  ) + 1  ) 
if @gi_string3 = '04'	set @MondayMonday = @maxParentDate

IF @maxParentDate is NULL 
begin
	IF @gi_string3 <> '03' and @gi_string3 <> '04' 
		begin
			select @ps_returnmsg = 'Error: GI string3 set to ' + 
			@gi_string3 + ': Department of Energy data is not available for this date.' 	
			SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
			Return
		End
end 	


--====== Preliminary Criteria Setup start    =================================================================	 	
	 		 	
select	@PREV_WEEK_ParentDate = DateAdd(dd, -7, @maxParentDate)
select  @maxParentDate_dayofweek  = Datepart(dw, @maxParentDate)	-- should always = 2 (monday)

Declare	@afp_tableid 			varchar(8) 	
Declare	@aff_formula_tableid	varchar(8) 
Declare	@aff_Interval 			varchar(8) 
Declare	@aff_CycleDay			varchar(8) 
Declare	@aff_Formula 			varchar(8) 	
Declare	@aff_effective_day1 	int 
Declare	@aff_effective_day2 	int
Declare @aff_formula_Acronym	varchar(12) 
Declare @afp_CalcPriceUsingDOW	int
-----------
Declare @New_AFP				money
Declare @daycode				int			-- PTS 66086; use @daycode for MNTH calcs
declare @affCycleDayCode		int			-- PTS66086 6-11-14 (replaced @daycode w/ @affCycleDayCode )
Declare @todaydaycode			int
Declare @previousdate			datetime
declare @maxdatefortableid		datetime
declare @maxseconds				int
declare @formulacount			int
declare @new_description		varchar(30)
declare @rowsec_rsrv_id			int
declare @afp_revtype1			varchar(6)
-----------
declare @TestDate1				datetime
declare @TestDate2				datetime
declare @TestDate3				datetime
declare @TestDate4				datetime
declare	@PREMNDate1				datetime
declare	@PREMNDate2				datetime
declare @CountZed				int
declare @Count1					int
declare @Count2					int
declare @Count3					int
declare @Count4					int
-----------
-- Constants & Validations (due to QA testing/able to create corrupt data:) PTS 61286/5-9-12
DECLARE @g_genesis				DATETIME
DECLARE @g_apocalypse			DATETIME
declare @badidCount				int
declare @afp_tableid_Count		int
declare @String_afp_tableid		varchar(10)
declare @minbad					int
declare	@maxbad					int
declare @mindescr				varchar(40)
declare @maxdescr				varchar(40)
declare @msg1					varchar(140)
declare @msg2					varchar(140)
declare @msg3					varchar(140)
-----------

declare	@DoW1					datetime	-- Day Of Week 1-6 (for PreMonth - Day of Week) for additional formula similar to PTS 61286
declare	@DoW2					datetime	
declare	@DoW3					datetime 
declare	@DoW4					datetime
declare	@DoW5					datetime
declare	@DoW6					datetime
declare	@p1						money
declare	@p2						money
declare	@p3						money
declare	@p4						money
declare	@p5						money
declare	@p6						money
declare	@p7						money
declare	@div					money
declare	@pCnt					money
-----------

SELECT	@g_genesis    = Convert(DateTime,'1950-01-01 00:00:00')
SELECT	@g_apocalypse = Convert(DateTime,'2049-12-31 23:59:59')

Select 	@afp_tableid 			= afp_tableid, 
		@aff_formula_tableid 	= aff_formula_tableid,
		@aff_Interval 			= aff_Interval, 
		@aff_CycleDay 			= aff_CycleDay, 
		@aff_Formula 			= aff_Formula,
		@aff_effective_day1 	= aff_effective_day1,
		@aff_effective_day2		= aff_effective_day2,
		@afp_CalcPriceUsingDOW  = afp_CalcPriceUsingDOW,
		@new_description		= afp_Description + ': ' + aff_formula_Acronym	
from  AvgFuelFormulaCriteria  
where aff_id =  @pl_aff_id 

set @ps_returnmsg = ''

select	@rowsec_rsrv_id	= 	rowsec_rsrv_id,  
		@afp_revtype1   =   afp_revtype1		
from	averagefuelprice  
where	afp_tableid = @afp_tableid

--====== Preliminary Validations start       =================================================================
-- PTS 61286/5-9-12.start
-- Validation#1
If @pl_aff_id Is Null set @pl_aff_id = 0
IF @pl_aff_id = 0
begin
	select @ps_returnmsg = 'Error: Data Not Valid!  CreateAvgFuelFormula_sp Proc received parameter: AverageFuelPrice TableId = Null or Zero.' 
		SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
		Return
end  	

Set @afp_tableid_Count = (select count(afp_tableid) 
							from	averagefuelprice 	
							where	afp_tableid = @afp_tableid
							and ISNULL(afp_IsFormula, 0) = 0 ) 								
-- Validation#2.1					
IF @afp_tableid_Count < 2 
	begin
		set @String_afp_tableid = CAST(@afp_tableid as varchar(10))
		--set @msg1 = 'Error:  input param = ' + CAST(@pl_aff_id as varchar(10))  + ' @SAVEpl_aff_id = ' + CAST(@SAVEpl_aff_id as varchar(10))
		set @msg1 = 'Error: Data Not Valid!  CreateAvgFuelFormula_sp Proc finds Less than TWO AverageFuelPrice Entries for TableId=' 
		set @msg2 = 'A MINIMUM of TWO AverageFuelPrice Entries must exist to create a Formula! '		
		SET @ps_returnmsg = LTrim(RTrim(@msg1)) + @String_afp_tableid + '.  ' +  LTrim(RTrim(@msg2))
		Return			
	end  

-- Validation#2.2
--  Don't allow formula/description duplicates.

if @RunBackFill <> 'BACKFILL'
begin
	Set @formulacount = (select count(afp_tableid) 
							from averagefuelprice  
							where afp_tableid   = @aff_formula_tableid
							and afp_Description = @new_description )						
	if @formulacount > 0 
		begin	
			select @ps_returnmsg = 'Error: Averagefuelprice.afp_tableid =' + 
						cast(@aff_formula_tableid as varchar(5)) + ', Formula "' + 
						@new_description + '" already exists in the Average Fuel Price Table.'
			SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
			Return
		end
end		

-- Validation#3	(formula's exist but there is no matching avg fuel table entry: {deleted data with sql from only 1 table!} )
	select @badidCount = count(AvgFuelFormulaCriteria.aff_id) 
		from AvgFuelFormulaCriteria
		where AvgFuelFormulaCriteria.afp_tableid 
		Not in (select Distinct(averagefuelprice.afp_tableid) 
		from averagefuelprice where IsNull(averagefuelprice.afp_IsFormula, 0)  = 0 ) 
			
	IF @badidCount > 0 
		begin
			select AvgFuelFormulaCriteria.aff_id 'aff_id', CAST(SPACE(40) as varchar(40)) 'descr'
				into #tmpbaddata 
				from AvgFuelFormulaCriteria
				where AvgFuelFormulaCriteria.afp_tableid 
				Not in (select Distinct(averagefuelprice.afp_tableid) 
				from averagefuelprice where IsNull(averagefuelprice.afp_IsFormula, 0)  = 0 ) 

			update #tmpbaddata  
				set #tmpbaddata.descr = (select AvgFuelFormulaCriteria.afp_description 
										 from AvgFuelFormulaCriteria 
										 where #tmpbaddata.aff_id = AvgFuelFormulaCriteria.aff_id )  
			select @minbad =  MIN(aff_id) from #tmpbaddata 
			select @maxbad =  MAX(aff_id) from #tmpbaddata 
			set @mindescr = ( select min(descr) from  #tmpbaddata  where aff_id = @minbad )
			set @maxdescr = ( select max(descr) from  #tmpbaddata  where aff_id = @maxbad )
									
			select @msg1 = 'Error: Data Not Valid!  ' 
				+ CAST(@badidCount as varchar(10)) 
				+ ' AvgFuelFormulaCriteria Entries exist With NO Matching AverageFuelPrice ID!' 					
				
			select @msg2 = 'First Bad Record: ' + RTRIM(CAST(@minbad as varchar(10))) + ' ' + LTRIM(RTRIM(@mindescr))
			select @msg3 = 'Last Bad Record: ' + RTRIM(CAST(@maxbad as varchar(10))) + ' ' + LTRIM(RTRIM(@maxdescr))
			SET @ps_returnmsg = SUBSTRING( (@msg1 + ' ' + @msg2 + ', ' + @msg3 ) , 1, 200) 
			
				IF OBJECT_ID(N'tempdb..#tmpbaddata', N'U') IS NOT NULL 
				DROP TABLE #tmpbaddata			
			Return	
		end
-- PTS 61286/5-9-12.end

--====== Primary Date SetUp start            =================================================================
-- using today as startpoint - get the begin/end dates of THIS week (& lastwk)
declare @BeginWeekTHIS				datetime
declare @EndWeekTHIS				datetime
declare @BeginWeekLAST				datetime
declare @EndWeekLAST				datetime
declare @BeginLastMonth				datetime		-- PTS 63266
declare @EndLastMonth				datetime		-- PTS 63266
declare @NewFormulaEffectiveDate	datetime
declare @BeginMonthNEXT				datetime		-- PTS 75085
declare @EndMonthNEXT				datetime		-- PTS 75085
declare @BeginMonthTHIS				datetime		-- PTS 75085
declare @EndMonthTHIS				datetime		-- PTS 75085
declare @MaxParentMonthStart		datetime		-- PTS 66086
declare @MaxParentMonthEnd			datetime		-- PTS 66086

declare @daysaddnbr					int
Declare @maxParent_dow_name			varchar(6)
Declare @specificMessage			varchar(200)
declare @2NewFormulaEffectiveDate	datetime

--------------------- { gi setting }
IF @gi_string3 = '03' 
BEGIN		-- PTS66086 6-11-14 [ fix ]
			-- handle as ORIGINALLY WRITTEN  (run calculations with WHATEVER the max parent date is in the tables).
			--  oops.  MAX parent date = @maxParentDate  not '@processDate' 
			--	effective dates are set as  today + (formula)
			--if (Select Datepart(dw, @processDate ) ) > 1 
	if (Select Datepart(dw, @maxParentDate ) ) > 1 
	begin	
				--Select @BeginWeekTHIS =   DateAdd(DD, -( Datepart(dw, @processDate ) - 1 ) , @processDate )	-- last Sunday
		Select @BeginWeekTHIS =   DateAdd(DD, -( Datepart(dw, @maxParentDate ) - 1 ) , @maxParentDate )				
		Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 												-- next Saturday
		Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
		Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)	
	end

				--if (Select Datepart(dw, @processDate ) ) = 1  ---- PTS66086 6-11-14 [ fix ]
	if (Select Datepart(dw, @maxParentDate ) ) = 1
	begin		
				--Select @BeginWeekTHIS =   DATEADD(dd, -7, @processDate )				-- last Sunday  -- PTS66086 6-11-14 [ fix ]
		Select @BeginWeekTHIS =   DATEADD(dd, -7, @maxParentDate )		
		Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
		Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
		Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)
	end 

	Select @BeginWeekTHIS		= CONVERT(VARCHAR(10), @BeginWeekTHIS, 101) + ' 00:00:00'
	Select @EndWeekTHIS			= CONVERT(VARCHAR(10), @EndWeekTHIS, 101) + ' 23:59:59'
	Select @BeginWeekLAST		= CONVERT(VARCHAR(10), @BeginWeekLAST, 101) + ' 00:00:00'
	Select @EndWeekLAST			= CONVERT(VARCHAR(10), @EndWeekLAST, 101) + ' 23:59:59'	
	
	-- PTS 63266.start
	select @todaydaycode	= Datepart(dd, @processDate ) 	
	select @BeginLastMonth	= DATEADD( dd, -( @todaydaycode -1 ) , @processDate)	-- get 1st of the month. 
	select @EndLastMonth	= DATEADD( dd, -1, @BeginLastMonth)						-- get End of PREV month.
	select @BeginLastMonth	= DATEADD( mm, -1 , @BeginLastMonth)					-- reset to 1st of PREV month. 
	select @BeginLastMonth	= CONVERT(VARCHAR(10), @BeginLastMonth, 101) + ' 00:00:00'					
	select @EndLastMonth	= CONVERT(VARCHAR(10), @EndLastMonth, 101) + ' 23:59:59'					 
	-- PTS 63266.end
End

--------------------- { new gi setting }
IF @gi_string3 <> '03' 
BEGIN	
	if @maxParentDate_dayofweek > 1 
	begin
		Select @BeginWeekTHIS =   DateAdd(DD, -( Datepart(dw, @MondayMonday ) - 1 ) , @MondayMonday )	-- last Sunday
		Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
		Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
		Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)	
	end

	if @maxParentDate_dayofweek = 1
	begin
		Select @BeginWeekTHIS =   DateAdd(DD, -( Datepart(dw, @MondayMonday ) - 1 ) , @MondayMonday )	-- last Sunday
		Select @BeginWeekTHIS =   DATEADD(dd, -7, @BeginWeekTHIS )									-- week ago Sunday
		Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
		Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
		Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)
	end
	
	-- 75085 et al; adjust for User-defined 'effective' week.  1 (sun-sat); 2 (mon-sun)*; if something else, so be it.
	if @gi_integer1 <> 1  
	begin 
		Select @BeginWeekTHIS = DateAdd(DD, + ( @gi_integer1 - 1 ) , @BeginWeekTHIS ) -- reset to whatever the user wants as FirstDayOfWeek.
		Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 
		Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
		Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)
	end
		
	Select @BeginWeekTHIS		= CONVERT(VARCHAR(10), @BeginWeekTHIS, 101) + ' 00:00:00'
	Select @EndWeekTHIS			= CONVERT(VARCHAR(10), @EndWeekTHIS, 101) + ' 23:59:59'
	Select @BeginWeekLAST		= CONVERT(VARCHAR(10), @BeginWeekLAST, 101) + ' 00:00:00'
	Select @EndWeekLAST			= CONVERT(VARCHAR(10), @EndWeekLAST, 101) + ' 23:59:59'	
		
	-- PTS 63266.start
	select @todaydaycode	= Datepart(dd, @MondayMonday ) 
	select @BeginLastMonth	= DATEADD( dd, -( @todaydaycode -1 ) , @MondayMonday )	-- gets the 1st of THIS(max date) month.	 
	select @EndLastMonth	= DATEADD( dd, -1, @BeginLastMonth)						-- get End of PREV month.
	select @BeginLastMonth	= DATEADD( mm, -1 , @BeginLastMonth)					-- reset to 1st of PREV month. 
	select @BeginLastMonth	= CONVERT(VARCHAR(10), @BeginLastMonth, 101) + ' 00:00:00'					
	select @EndLastMonth	= CONVERT(VARCHAR(10), @EndLastMonth, 101) + ' 23:59:59'					 
	-- PTS 63266.end
End
 

--============================================================================================================
--============================================  Calc Next Eff Date  ==========================================
--============================================================================================================

-- Validation#4	Test for Missing data as required by most @gi_string3 setting values.
if @aff_CycleDay is not NULL 
begin	
	if @gi_integer1 = 1 
	begin 
		select @affCycleDayCode = code from labelfile where labeldefinition = 'affCycleDay' and abbr = ( @aff_CycleDay )
		select @todaydaycode = Datepart(dw, @BeginWeekTHIS) -- [no longer] always SUNDAY.
		select @daysaddnbr = ( @affCycleDayCode - @todaydaycode ) 	
		Select @NewFormulaEffectiveDate = DATEADD(dd, @daysaddnbr, @BeginWeekTHIS)
		Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'	
		select @maxParent_dow_name	 = abbr from labelfile where labeldefinition = 'affCycleDay' and code = @maxParentDate_dayofweek	
	end 	
	
	-- 75085 et al;
	if @gi_integer1 <> 1 
	begin 
		select @affCycleDayCode = code from labelfile where labeldefinition = 'affCycleDay' and abbr = ( @aff_CycleDay )
		select @todaydaycode = Datepart(dw, @BeginWeekTHIS) -- [no longer] always SUNDAY.
		select @daysaddnbr = ( ( @affCycleDayCode + 7 )  - @todaydaycode ) 	
		Select @NewFormulaEffectiveDate = DATEADD(dd, @daysaddnbr, @BeginWeekTHIS)
		Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'	
		select @maxParent_dow_name	 = abbr from labelfile where labeldefinition = 'affCycleDay' and code = @maxParentDate_dayofweek	
	end 
	
	if DATEADD(dd, -7, @NewFormulaEffectiveDate) > @TableMaxParentDate
		begin
			select	@NewFormulaEffectiveDate = DATEADD(dd, -7, @NewFormulaEffectiveDate)
		end 
end 

-----------------------

IF @aff_Formula = 'AVG2WK'   OR @aff_Formula = 'AVG4WK'  OR @aff_Formula = 'PREWK' OR @aff_Formula = 'CURWK'
	BEGIN
		--  'current' week
		select @CountZed = count(afp_date) from averagefuelprice 
			where afp_tableid = @afp_tableid
			and		ISNULL(afp_IsFormula, 0) = 0
			and 	afp_date >=   CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00'
			and 	afp_date <=  dateadd( dd, +6, (CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00'))
			
		select @Count1 = count(afp_date) from averagefuelprice 
			where afp_tableid = @afp_tableid
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and 	afp_date <=  dateadd( dd, +6, (dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )
	
		select @Count2 = count(afp_date) from averagefuelprice 
					where afp_tableid = @afp_tableid
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and		afp_date <= dateadd( dd, +6, (dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) ) 	
							
		select @Count3 = count(afp_date) from averagefuelprice 
					where afp_tableid = @afp_tableid
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -3, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and		afp_date <= dateadd( dd, +6, (dateadd(ww, -3, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) ) 							
		select @Count4 = count(afp_date) from averagefuelprice 
					where afp_tableid = @afp_tableid
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and		afp_date <= dateadd( dd, +6, (dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) ) 				
		
		if @CountZed > 1 select @CountZed = 1
		if @Count1 > 1 select @Count1 = 1	
		if @Count2 > 1 select @Count2 = 1	
		if @Count3 > 1 select @Count3 = 1	
		if @Count4 > 1 select @Count4 = 1		
			
	END

-- do the data exists validation regardless of which string3 is selected!
--IF @gi_string3 <> '03'		
	IF @aff_Formula = 'AVG2WK' 
		Begin
		
		IF @Count1 + @Count2 < 2 
			BEGIN
				select @New_AFP = NULL	
				select @specificMessage='Error for AVG2WK Effective on: ' + @aff_CycleDay + ' '  
							+ CONVERT(varchar(14), @NewFormulaEffectiveDate, 101) + 
					'!  One or more AverageFuelPrice dates needed for this calculation were not found during the week(s) of: ' + 
					CONVERT(varchar(14), dateadd(ww, -2, @maxParentDate), 101) + ' , ' + 
					CONVERT(varchar(14), dateadd(ww, -1, @maxParentDate), 101) 
				SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
				Return	
			END	
		End
	Else IF @aff_Formula = 'AVG4WK'
		Begin		
			IF @Count1 + @Count2 + @Count3 + @Count4 < 4		
			BEGIN
				select @New_AFP = NULL	
				select @specificMessage='Error for AVG4WK Effective on: ' + @aff_CycleDay + ' '  
						+ CONVERT(varchar(14), @NewFormulaEffectiveDate, 101) + 
					'!  One or more AverageFuelPrice dates needed for this calculation were not found during the week(s) of: ' + 
						CONVERT(varchar(14), dateadd(ww, -4, @maxParentDate), 101) + ' , ' + 
						CONVERT(varchar(14), dateadd(ww, -3, @maxParentDate), 101) + ' , ' + 
						CONVERT(varchar(14), dateadd(ww, -2, @maxParentDate), 101) + ' , ' + 
						CONVERT(varchar(14), dateadd(ww, -1, @maxParentDate), 101) 						
					SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
					Return			
			END	
		End
	Else IF @aff_Formula = 'PREWK'		
		Begin
			IF @Count1 < 1					
				BEGIN
					select @New_AFP = NULL	
					select @specificMessage='Error for PREWK Effective on: ' + @aff_CycleDay + ' '  
							+ CONVERT(varchar(14), @NewFormulaEffectiveDate, 101) + 
						'!   AverageFuelPrice date needed for this calculation was not found for the week of: ' + 						
						CONVERT(varchar(14), dateadd(ww, -1, @maxParentDate), 101) 
					SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
					Return	
				END	
		End		
	Else IF @aff_Formula = 'CURWK'
		Begin
			IF @CountZed < 1
				BEGIN
					select @New_AFP = NULL	
					select @specificMessage='Error for CURWK Effective on: ' + @aff_CycleDay + ' '  
					+ CONVERT(varchar(14), @NewFormulaEffectiveDate, 101) + 
						'!   AverageFuelPrice date needed to calculate this formula was not found for the week of: ' + 						
						Convert(varchar(10), @maxParentDate, 101)
					SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
					Return	
				END	
		End		

--============================================================================================================
--====== Primary Formula Criteria SetUp Start ================================================================
--============================================================================================================

--====== Formula 'PREMN' (Previous Month; ALL days) for **ALL** non-formula values found in the previous month.  ======
-- PTS 75085
-- PTS 63266 New formula
IF @aff_Interval = 'MNTH'  OR @aff_Interval = 'BIMNTH'

begin
	------------------    -- PTS 63266	
	select @daycode				= Datepart(dd, @TableMaxParentDate ) --DATEPART(MM, @TableMaxParentDate )	-- PTS 66086	
	select @MaxParentMonthStart	= DATEADD( dd, -( @daycode -1 ) , @TableMaxParentDate)						-- PTS 66086
	select @MaxParentMonthEnd	= DATEADD( mm, +1 , @MaxParentMonthStart )									-- PTS 66086
	select @MaxParentMonthEnd	= DATEADD( dd, -1,  @MaxParentMonthEnd )									-- PTS 66086
	select @MaxParentMonthStart	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthStart, 101) + ' 00:00:00'	as datetime)	-- PTS 66086
	select @MaxParentMonthEnd	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthEnd, 101) + ' 23:59:59' as datetime)		-- PTS 66086
	
	------------------
	--select @todaydaycode	= Datepart(dd, GETDATE() ) 	 @processDate
	select @todaydaycode	= Datepart(dd, @processDate )
	------------------ 
	--select @BeginMonthTHIS	= DATEADD( dd, -( @todaydaycode -1 ) , getdate())		-- get 1st of *THIS* month. -- PTS 63266
	select @BeginMonthTHIS	= DATEADD( dd, -( @todaydaycode -1 ) , @processDate)		-- get 1st of *THIS* month. -- PTS 63266
	select @EndMonthTHIS	= DATEADD( mm, +1 , @BeginMonthTHIS )
	select @EndMonthTHIS	= DATEADD( dd, -1,  @EndMonthTHIS ) 
	select @BeginMonthTHIS	= Cast(CONVERT(VARCHAR(10), @BeginMonthTHIS, 101) + ' 00:00:00'	as datetime)				  
	select @EndMonthTHIS	= Cast(CONVERT(VARCHAR(10), @EndMonthTHIS, 101) + ' 23:59:59' as datetime)	
	------------------
	select @BeginLastMonth	= DATEADD( mm, -1, @BeginMonthTHIS )
	select @EndLastMonth	= DATEADD( dd, -1, @BeginMonthTHIS)
	select @BeginLastMonth	= Cast(CONVERT(VARCHAR(10), @BeginLastMonth, 101) + ' 00:00:00'	as datetime)				  -- PTS 63266
	select @EndLastMonth	= Cast(CONVERT(VARCHAR(10), @EndLastMonth, 101) + ' 23:59:59' as datetime)					  -- PTS 63266
			
	------------------
	select @BeginMonthNEXT  = DATEADD( mm, +1 , @BeginMonthTHIS )				----- grab the 1st of NEXT Month
	select @EndMonthNEXT	= DATEADD( mm, +2 , @BeginMonthTHIS )				----- grab the 1st of 2 months from now;
	select @EndMonthNEXT	= DATEADD( dd, -1, @EndMonthNEXT )					----- minus 1 gives us the END of NEXT month.
	select @BeginMonthNEXT	= Cast(CONVERT(VARCHAR(10), @BeginMonthNEXT, 101) + ' 00:00:00'	as datetime)				  
	select @EndMonthNEXT	= Cast(CONVERT(VARCHAR(10), @EndMonthNEXT, 101) + ' 23:59:59' as datetime)	
	------------------
		
	select	@ps_returnmsg = 'Criteria Formula= ' + @aff_Formula + ';  Criteria Interval= ' + @aff_Interval + ';  PROCESS DATE is: ' + CONVERT(VARCHAR(10), @processDate, 110)
	
	--  choose if we are far enough into THIS MONTH to create a 'next month' eff date. Else base it on MaxParent.
	--	@TableMaxParentDate CONTAINS the most recent DOE PRICE; so use that as the pivot;	
			
	--  IF MaxParent falls in the LAST week of the current month and our most recent DOE price/date available is in THIS week...		
	IF 	@TableMaxParentDate >= @EndMonthTHIS  OR ( @TableMaxParentDate <= @EndMonthTHIS  AND @TableMaxParentDate >= DateAdd( dd, - 7 , @EndMonthTHIS ) )
		begin		 			
			if @aff_effective_day1 Is Not Null
				begin
					select @NewFormulaEffectiveDate = DateAdd( dd, +(@aff_effective_day1 - 1), @BeginMonthNEXT )
					Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate , 101) + ' 00:00:00'	
				end 	
			if @aff_effective_day2 Is Not Null
				begin
					select @2NewFormulaEffectiveDate = DateAdd( dd, +(@aff_effective_day2 - 1), @BeginMonthNEXT )
					Select @2NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @2NewFormulaEffectiveDate , 101) + ' 00:00:00'	
				end 
				
			select	@ps_returnmsg =	@ps_returnmsg  + 
					';  Will attempt to create New Formula with an Effective Date for ' + DATENAME(MM, @BeginMonthNEXT ) + '.'							
		end
	ELSE
		begin 
			--  ' else use LAST month '						
			if @aff_effective_day1 Is Not Null
			begin
				select @NewFormulaEffectiveDate = DateAdd( dd, +(@aff_effective_day1 - 1), @BeginMonthTHIS )
				Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate , 101) + ' 00:00:00'	
			end 	
			if @aff_effective_day2 Is Not Null
			begin
				select @2NewFormulaEffectiveDate = DateAdd( dd, +(@aff_effective_day2 - 1), @BeginMonthTHIS )
				Select @2NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @2NewFormulaEffectiveDate , 101) + ' 00:00:00'	
			end 
			
			select	@ps_returnmsg =	@ps_returnmsg  + 
				';  Will attempt to create New Formula with an Effective Date for ' + DATENAME(MM, @BeginMonthTHIS ) + '.'
		end 
	
	--if @aff_Formula =  'BIMNTH'  -- make this more generic in case other formulas use date2 at some point...
	if ( @aff_effective_day1 Is Not Null AND @aff_effective_day2 Is Not Null) 
		begin  		
			-- 'todaycode' should be the 'current-day' value relative to user-settings
			-- we have both aff_effective_day1 & aff_effective_day2 / choose which one to use.
			-- if NewFormulaDate-2 is not null & it is appropriate to do so, use it, else keep NewFormulaDate-ONE			
			select @chosenDate = @aff_effective_day1			
			if @todaydaycode >= @aff_effective_day2 
				begin				
					select @chosenDate = @aff_effective_day2
					if @NewFormulaEffectiveDate IS NOT NULL 
					begin
						select @NewFormulaEffectiveDate	= @2NewFormulaEffectiveDate		
					end	
				end		
		end		
					
	------------- using the next effective date we just calculated...  @NewFormulaEffectiveDate
	--------  NOW;  if the formula is <> 'PREMN' then the calcs we already did are FINE; else, calc! @aff_Formula = 'PREMN' 	
	IF @aff_Formula = 'PREMN' AND ( @NewFormulaEffectiveDate IS NOT NULL )
	begin 
		select @daycode				= Datepart(dd, @NewFormulaEffectiveDate )									-- PTS 66086	
		select @MaxParentMonthStart	= DATEADD( dd, -( @daycode -1 ) , @NewFormulaEffectiveDate)					-- PTS 66086
		select @MaxParentMonthStart	= DATEADD( mm, -1 , @MaxParentMonthStart )	-- Month PREVIOUS to eff date	-- PTS 66086
		select @MaxParentMonthEnd	= DATEADD( mm, +1 , @MaxParentMonthStart )									-- PTS 66086
		select @MaxParentMonthEnd	= DATEADD( dd, -1,  @MaxParentMonthEnd )									-- PTS 66086
		select @MaxParentMonthStart	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthStart, 101) + ' 00:00:00'	as datetime)	-- PTS 66086
		select @MaxParentMonthEnd	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthEnd, 101) + ' 23:59:59' as datetime)		-- PTS 66086		
		
		select @PREMNDate1 = @MaxParentMonthStart			
				
		--*** Set the first test date to the DayOfWeek the user indicates; but if the reset changes the month or the YEAR - add 7 days.
		set @PREMNDate1 = ( select DateAdd(DD, - ( Datepart(dw, @PREMNDate1  ) - 1 ) , @PREMNDate1  ) + 1  ) -- set this to Monday
		set @PREMNDate1 = DateAdd(DD, - 1  , @PREMNDate1 ) -- Reset to SUNDAY
		Select @PREMNDate1 = DateAdd(DD, + ( @gi_integer1 - 1 ), @PREMNDate1 ) -- reset to whatever the user wants as FirstDayOfWeek.
		
		if ( Datepart(mm, @PREMNDate1 ) <> Datepart(mm, @MaxParentMonthStart )   OR  Datepart(yyyy, @PREMNDate1 ) <> Datepart(yyyy, @MaxParentMonthStart )  )
			Begin
				select @PREMNDate1 = DATEADD( DD, +7, CONVERT(VARCHAR(10), @PREMNDate1, 101) + ' 00:00:00')
			end				
		
		-- any doe data between 1st DayofMonth and the first-day-of-week (per user definition) ?		
		select @DoW1 = min(afp_date)
		from averagefuelprice
		where afp_tableid = @afp_tableid 
		and ISNULL(afp_IsFormula, 0) = 0	
		and ( afp_date >= @MaxParentMonthStart  and afp_date < @PREMNDate1  )

		select @DoW2 = @PREMNDate1			
		select @DoW3 = DATEADD( DD, +7,  @PREMNDate1 )
		select @DoW4 = DATEADD( DD, +14, @PREMNDate1 )
		select @DoW5 = DATEADD( DD, +21, @PREMNDate1 )
		select @DoW6 = DATEADD( DD, +28, @PREMNDate1 )
		
		if ( Datepart(mm, @DoW4 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW4 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW4 = DateAdd(dd, +1, @MaxParentMonthEnd)
			end 
		if ( Datepart(mm, @DoW5 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW5 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW5 = DateAdd(dd, +1, @MaxParentMonthEnd)
			end 
		if ( Datepart(mm, @DoW6 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW6 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW6 = DateAdd(dd, +1, @MaxParentMonthEnd)
			end 
		
		select @p1 = 0, @p2 = 0, @p3 = 0, @p4 = 0, @p5 = 0, @p6 = 0
		select @pCnt = 0
		select @div = 0		
					
		-- Look for prices that fall between 1st day of month and 1st (user defined) day of week
		--	if no data - that is OK.					
		if @DoW1 is not null
			begin
				select @p1  = afp_price
				from averagefuelprice
				where afp_tableid = @afp_tableid 
				and ISNULL(afp_IsFormula, 0) = 0	
				and afp_date = @DoW1
			end
			if @p1 is null select @p1 = 0
			if @p1 > 0 select @pCnt = @pCnt + 1	
			if @p1 > 0 select @div =  @div + 1


		-- look for 1st FULL WEEK
		select @PREMNDate2 = DATEADD(DD, +6, @PREMNDate1)	-- get end of 1st user defined week	
		
		select @pCnt = @pCnt + 1													
		if ( @DoW2 between @PREMNDate1 and @PREMNDate2) 
			begin 								
				select	@p2 = IsNull(afp_price, 0)
				from	averagefuelprice
				where	afp_tableid = @afp_tableid 
				and		ISNULL(afp_IsFormula, 0) = 0	
				and		afp_date = ( select min(afp_date) 
									from averagefuelprice
									where afp_tableid = @afp_tableid 
									and ISNULL(afp_IsFormula, 0) = 0	
									and ( afp_date >= @DoW2  and afp_date <= @PREMNDate2  )  )	
			end

			if @p2 is null select @p1 = 0			
			if @p2 > 0 select @div =  @div + 1
					
		-- look for 2nd FULL WEEK							
		select @PREMNDate1 = DATEADD(DD, +7, @PREMNDate1)
		select @PREMNDate2 = DATEADD(DD, +6, @PREMNDate2)
		
		select @pCnt = @pCnt + 1
		if ( @DoW3 between @PREMNDate1 and @PREMNDate2 ) 
			begin 	
				select	@p3 = IsNull(afp_price, 0)
				from	averagefuelprice
				where	afp_tableid = @afp_tableid 
				and		ISNULL(afp_IsFormula, 0) = 0	
				and		afp_date = ( select min(afp_date) 
									from averagefuelprice
									where afp_tableid = @afp_tableid 
									and ISNULL(afp_IsFormula, 0) = 0	
									and ( afp_date >= @DoW3  and afp_date <= @PREMNDate2 ) )
			end					
			if @p3 is null select @p3 = 0	
			if @p3 > 0 select @div = @div + 1	
					
		-- look for 3rd FULL WEEK						
		select @PREMNDate1 = DATEADD(DD, +7, @PREMNDate1)
		select @PREMNDate2 = DATEADD(DD, +6, @PREMNDate2)
	
		select @pCnt = @pCnt + 1
		if ( @DoW4 between @PREMNDate1 and @PREMNDate2 ) 
			begin 		
				select	@p4 = IsNull(afp_price, 0)
				from	averagefuelprice
				where	afp_tableid = @afp_tableid 
				and		ISNULL(afp_IsFormula, 0) = 0	
				and		afp_date = ( select min(afp_date) 
									from averagefuelprice
									where afp_tableid = @afp_tableid 
									and ISNULL(afp_IsFormula, 0) = 0	
									and ( afp_date >= @DoW4  and afp_date <= @PREMNDate2  )  ) 
			end	
			if @p4 is null select @p4 = 0	
			if @p4 > 0 select @div = @div + 1		
								
			-- look for 4th FULL WEEK ( might not have data if February & the days fall weird. )						
			select @PREMNDate1 = DATEADD(DD, +7, @PREMNDate1)			
			select @PREMNDate2 = DATEADD(DD, +6, @PREMNDate2)	
	
			if @PREMNDate1 > @MaxParentMonthEnd select @PREMNDate1 = @MaxParentMonthEnd			
			if @PREMNDate2 > @MaxParentMonthEnd select @PREMNDate2 = @MaxParentMonthEnd
									
				if @Dow5 <= @PREMNDate1 and DateAdd(dd, +7, @Dow5) > @MaxParentMonthEnd
					begin 
						select @Dow5 = min(afp_date)
						from averagefuelprice
						where afp_tableid = @afp_tableid 
						and ISNULL(afp_IsFormula, 0) = 0	
						and ( afp_date >= @PREMNDate1  and afp_date <= @MaxParentMonthEnd  )
						
						IF @Dow5 is not null
						begin 
							select @p5  = afp_price
							from averagefuelprice
							where afp_tableid = @afp_tableid 
							and ISNULL(afp_IsFormula, 0) = 0	
							and afp_date = @Dow5	
						end 
						
					end
				ELSE
					begin 
						if ( @Dow5 between @PREMNDate1 and @PREMNDate2 ) 
						begin 	
							select	@p5 = IsNull(afp_price, 0)
							from	averagefuelprice
							where	afp_tableid = @afp_tableid 
							and		ISNULL(afp_IsFormula, 0) = 0	
							and		afp_date = ( select min(afp_date) 
												from averagefuelprice
												where afp_tableid = @afp_tableid 
												and ISNULL(afp_IsFormula, 0) = 0	
												and ( afp_date >= @Dow5  and afp_date <= @PREMNDate2  )  ) 
							-- 8/28/14 FIX --select @pCnt = @pCnt  + 1			-- if afp_date exists, we should have a price too.
						end		
					end								
			if @p5 is null select @p5 = 0				
			if @p5 > 0 select @div = @div + 1
			if @p5 > 0 select @pCnt = @pCnt  + 1		-- 8/28/14 FIX;  this line was in the wrong place.
			-- end of 4th week		
						
							
			-- look for 5th WEEK or extra days before end of month.			
			select @PREMNDate1 = DATEADD(DD, +7, @PREMNDate1)
			if @PREMNDate1 > @MaxParentMonthEnd select @PREMNDate1 = @MaxParentMonthEnd
			select @PREMNDate2 = DATEADD(DD, +6, @PREMNDate2)
			if @PREMNDate2 > @MaxParentMonthEnd select @PREMNDate2 = @MaxParentMonthEnd
			
			if @Dow6 <= @PREMNDate1 and DateAdd(dd, +7, @Dow6) > @MaxParentMonthEnd
				begin 
					select @Dow6 = min(afp_date)
					from averagefuelprice
					where afp_tableid = @afp_tableid 
					and ISNULL(afp_IsFormula, 0) = 0	
					and ( afp_date >= @PREMNDate1  and afp_date <= @MaxParentMonthEnd  )
					
					IF @Dow6 is not null
					begin 
						select @p6  = afp_price
						from averagefuelprice
						where afp_tableid = @afp_tableid 
						and ISNULL(afp_IsFormula, 0) = 0	
						and afp_date = @Dow6							
						select @pCnt = @pCnt  + 1	-- if afp_date exists, we should have a price too.
				
					end 
				end
			ELSE
				begin 
					if ( @Dow6 between @PREMNDate1 and @PREMNDate2 ) 
					begin 
				
						select	@p6 = IsNull(afp_price, 0)
						from	averagefuelprice
						where	afp_tableid = @afp_tableid 
						and		ISNULL(afp_IsFormula, 0) = 0	
						and		afp_date = ( select min(afp_date) 
											from averagefuelprice
											where afp_tableid = @afp_tableid 
											and ISNULL(afp_IsFormula, 0) = 0	
											and ( afp_date >= @Dow6  and afp_date <= @PREMNDate2  )  ) 
						select @pCnt = @pCnt  + 1	-- if afp_date exists, we should have a price too.							
					end		
				end	
			if @p6 is null select @p6 =0
			if @p6 > 0 select @div = @div + 1	
			-- end of 5th week	
				
			--if @div <= 0 select @div = 1	
			--Select @New_AFP	= ( @p1 + @p2 + @p3 + @p4 + @p5 + @p6 ) / @div
			
			--if  @div < @pCnt							
			--	Begin
			--		select @specificMessage='Error: Avg Previous Month(PREMN): No Parent AverageFuelPrice found for date range: ' + 
			--		CONVERT(varchar(14),@BeginLastMonth, 101) + ' to ' 
			--		+ CONVERT(varchar(14),@EndLastMonth, 101)
			--		SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
			--		Return	@ps_returnmsg	 					
			--	end 
			-- PTS 75085.end
				
			-- if the number of mondays (days-of-week) found is not equal to the number of prices found, we have missing data; error.
			-- 8/28/14 FIX; (the variables were reversed in the message below;  changed the message).
			IF ( @div <= 0 ) OR (  @div <> @pCnt ) 
				BEGIN
					select @New_AFP = NULL				
					select @specificMessage = 'Error: Avg Previous Month(PREMN):' + 
							' Price data needed to calculate Avg Previous Month(PREMN) is missing. ' +
							' New Effective Date should be: ' +  CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 110) +
							'. Price data is needed for each week of ' + Datename(mm, @BeginLastMonth ) + '. '
					
					--select @specificMessage = 'Error: Avg Previous Month:' + 
					--		' Cannot calculate Avg Previous Month(PREMN) Formula: ' + 
					--		Datename(mm, @BeginLastMonth ) + ' has ' + 																
					--		Cast( CONVERT(int, ISNULL(@div, 0)  ) as varchar(6)) + ' Weeks, but only ' + 
					--		Cast( CONVERT(int, ISNULL(@pCnt, 0 )   ) as varchar(6)) + 
					--		' AverageFuelPrice value(s) were found.'							
					SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
					Return				
				END	
		ELSE
			begin 	
				-- 8/28/14 FIX; (include the @p6 value also).		
				select @New_AFP = ( ISNULL(@p1, 0 ) + ISNULL(@p2, 0) + ISNULL(@p3, 0) + ISNULL(@p4, 0) + ISNULL(@p5, 0) + ISNULL(@p6, 0) ) / @div
			end 	
						
	
		END		-- End of 'PREMN' 		
END	--  @aff_Interval = 'MNTH' / 'BiMnth' 
		

--====== Formula 'PMMON' (Previous Month; Mondays) for ONLY non-formula MONDAY values found in the previous month. ====== 
		 -- additional 'previous month' formula similar to PTS 61286
		 
if @aff_Formula = 'PMMON' OR @aff_Formula = 'PMDOW'
begin	
			
	IF @aff_Formula = 'PMMON' 
		begin			
			select @afp_CalcPriceUsingDOW = 2
		end 
	Else
		begin
			-- @aff_Formula = 'PMDOW' so @afp_CalcPriceUsingDOW  should be set; if missing; default it to "monday"
			if ( @afp_CalcPriceUsingDOW is NULL OR @afp_CalcPriceUsingDOW <1  OR @afp_CalcPriceUsingDOW >7 ) select @afp_CalcPriceUsingDOW = 2				
		end	
			
		select @daycode				= Datepart(dd, @NewFormulaEffectiveDate )									-- PTS 66086	
		select @MaxParentMonthStart	= DATEADD( dd, -( @daycode -1 ) , @NewFormulaEffectiveDate)					-- PTS 66086
		select @MaxParentMonthStart	= DATEADD( mm, -1 , @MaxParentMonthStart )	-- Month PREVIOUS to eff date	-- PTS 66086
		select @MaxParentMonthEnd	= DATEADD( mm, +1 , @MaxParentMonthStart )									-- PTS 66086
		select @MaxParentMonthEnd	= DATEADD( dd, -1,  @MaxParentMonthEnd )									-- PTS 66086
		select @MaxParentMonthStart	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthStart, 101) + ' 00:00:00'	as datetime)	-- PTS 66086
		select @MaxParentMonthEnd	= Cast(CONVERT(VARCHAR(10), @MaxParentMonthEnd, 101) + ' 23:59:59' as datetime)		-- PTS 66086
		
		Select @PREMNDate1 =   DateAdd(DD, -( Datepart(dw, @MaxParentMonthStart ) - 1 ) , @MaxParentMonthStart )	-- set this to prev Month's Sunday
		if @afp_CalcPriceUsingDOW = 1  
			begin 
				select @PREMNDate1 = DATEADD( DD, +7, CONVERT(VARCHAR(10), @PREMNDate1, 101) + ' 00:00:00')			-- set to first sunday of the desired month.
			end 
		else
			begin
				select @PREMNDate1 = DATEADD( DD, + (@afp_CalcPriceUsingDOW -1 ), CONVERT(VARCHAR(10), @PREMNDate1, 101) + ' 00:00:00')	
			end	
		
		if ( Datepart(mm, @PREMNDate1 ) <> Datepart(mm, @MaxParentMonthStart )   OR  Datepart(yyyy, @PREMNDate1 ) <> Datepart(yyyy, @MaxParentMonthStart )  )
			Begin
				select @PREMNDate1 = DATEADD( DD, +7, CONVERT(VARCHAR(10), @PREMNDate1, 101) + ' 00:00:00')
			end		
	
		select @DoW1	= @PREMNDate1	-- 1st (desired day)
		select @DoW2 = DATEADD( DD, +7,  @DoW1 )		
		select @DoW3 = DATEADD( DD, +14, @DoW1 )
		select @DoW4 = DATEADD( DD, +21, @DoW1 )
		select @DoW5 = DATEADD( DD, +28, @DoW1 )
		select @DoW6 = null
				
		if ( Datepart(mm, @DoW4 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW4 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW4 = null
			end 
		if ( Datepart(mm, @DoW5 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW5 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW5 = null
			end 
		if ( Datepart(mm, @DoW6 ) > Datepart(mm, @MaxParentMonthStart ) ) OR ( Datepart(yyyy, @DoW6 ) > Datepart(yyyy, @MaxParentMonthStart ) ) 
			begin
				select @DoW6 = null
			end 
	
		if  Datepart(dw, @DoW1) <> @afp_CalcPriceUsingDOW select @DoW1 = null
		if  Datepart(dw, @Dow2) <> @afp_CalcPriceUsingDOW select @Dow2 = null
		if  Datepart(dw, @Dow3) <> @afp_CalcPriceUsingDOW select @Dow3 = null
		if  @Dow4 is NOT NULL AND Datepart(dw, @Dow4) <> @afp_CalcPriceUsingDOW select @Dow4 = null
		if  @Dow5 is NOT NULL AND Datepart(dw, @Dow5) <> @afp_CalcPriceUsingDOW select @Dow5 = null
		if  @Dow6 is NOT NULL AND Datepart(dw, @Dow6) <> @afp_CalcPriceUsingDOW select @Dow6 = null
		
		select @p1 = 0, @p2 = 0, @p3 = 0, @p4 = 0, @p5 = 0, @p6 = 0
		select @pCnt = 0
		select @div = 0	
	
		select @pCnt = @pCnt  + 1		
		if @DoW1 is NOT NULL
		begin 
			select	@p1 = IsNull(afp_price, 0)
						from	averagefuelprice
						where	afp_tableid = @afp_tableid 
						and		ISNULL(afp_IsFormula, 0) = 0	
						and		afp_date = @DoW1 
			if @p1 is NULL select @p1 = 0			
			if @p1 > 0 select @div =  @div + 1			
		end	
				
		select @pCnt = @pCnt  + 1	
		if @DoW2 is not null
		begin
			select @p2 = IsNull(afp_price, 0)
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						AND ISNULL(afp_IsFormula, 0) = 0 
						and afp_date = @DoW2					
			if @p2 is NULL select @p2 = 0
			if @p2 > 0 select @div =  @div + 1
		end 	
		
		select @pCnt = @pCnt  + 1	
		if @Dow3 is not null
		begin
			select @p3 = IsNull(afp_price, 0)
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						AND ISNULL(afp_IsFormula, 0) = 0 
						and afp_date = @Dow3					
			if @p3 is NULL select @p3 = 0
			if @p3 > 0 select @div =  @div + 1
		end 	
		
		-- now the possibility exists for null dates so don't incrememt pCnt
		if @Dow4 is not null
		begin
			select @pCnt = @pCnt  + 1	
			select @p4 = IsNull(afp_price, 0)
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						AND ISNULL(afp_IsFormula, 0) = 0 
						and afp_date = @Dow4					
			if @p4 is NULL select @p4 = 0
			if @p4 > 0 select @div =  @div + 1
		end 	
		
		if @Dow5 is not null
		begin
			select @pCnt = @pCnt  + 1	
			select @p5 = IsNull(afp_price, 0)
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						AND ISNULL(afp_IsFormula, 0) = 0 
						and afp_date = @Dow5					
			if @p5 is NULL select @p5 = 0
			if @p5 > 0 select @div =  @div + 1
		end 
		
		if @Dow6 is not null
		begin
			select @pCnt = @pCnt  + 1	
			select @p6 = IsNull(afp_price, 0)
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						AND ISNULL(afp_IsFormula, 0) = 0 
						and afp_date = @Dow6					
			if @p6 is NULL select @p6 = 0
			if @p6 > 0 select @div =  @div + 1
		end 		
		
		--@pCnt, @div
		
		-- if the number of mondays (days-of-week) found is not equal to the number of prices found, we have missing data; error.
		-- 8/28/14 FIX; (the variables were reversed in the message below;  changed the message).	
		IF ( @div <= 0 ) OR (  @div <> @pCnt ) 
				BEGIN
					select @New_AFP = NULL	
					
					if @aff_Formula = 'PMMON'
						begin
							select @specificMessage = 'Error: (PMMON) Avg Prev Month-Mondays:' + 
									' Price data needed to calculate Avg Prev Month-Mondays(PMMON) is missing.' + 
									' New Effective Date should be: ' +  CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 110) +
									'. Price data is needed for each week of ' + Datename(mm, @BeginLastMonth ) + '. '	
						end 
					ELSE	
						begin
							-- @aff_Formula = 'PMDOW'
							select @specificMessage = 'Error: (PMDOW) Avg Prev Month-DayOfWeek/' + datename(dw, @Dow1) + ':' + 
									' Price data needed to calculate Avg Prev Month-DayOfWeek(PMDOW) is missing.' + 
									' New Effective Date should be: ' +  CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 110) +
									'. Price data is needed for each week of ' + Datename(mm, @BeginLastMonth ) + '. '	
						end 		
					
					--select @specificMessage = 'Error for Previous Month ' + datename(dw, @Dow1) + 
					--		' ). Cannot calculate Previous Month; Mondays(PMMON)Formula: ' + 
					--		Datename(mm, @BeginLastMonth ) + ' has ' + 																
					--		Cast( CONVERT(int, ISNULL(@pCnt, 0)  ) as varchar(6)) + ' ' + datename(dw, @Dow1) + 's, but only ' + 
					--		Cast( CONVERT(int, ISNULL(@div, 0 )   ) as varchar(6)) + 
					--		' values were found in the AverageFuelPrice table.  '
							
					SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
					Return			
				END	
		ELSE
			begin 	
				-- 8/28/14 FIX; (include the @p6 value also).			
				select @New_AFP = ( ISNULL(@p1, 0 ) + ISNULL(@p2, 0) + ISNULL(@p3, 0) + ISNULL(@p4, 0) + ISNULL(@p5, 0) + ISNULL(@p6, 0) ) / @div
			end 			
end						
	
		
		select @Count1 = count(afp_date) from averagefuelprice 
			where afp_tableid = @afp_tableid 
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and 	afp_date <=  dateadd( dd, +6, (dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )
	
		select @Count2 = count(afp_date) from averagefuelprice 
					where afp_tableid = @afp_tableid 
			and		ISNULL(afp_IsFormula, 0) = 0	
			and 	afp_date >=   dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and		afp_date <= dateadd( dd, +6, (dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) ) 	
			
	
--====== Formula 'AVG2WK' (Average of DOE for PREVIOUS 2 weeks)  ======
if @aff_Formula = 'AVG2WK'
begin		
	--Select @TestDateBOD = dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
	--Select @TestDateEOD = dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59') 	
	
	select  @TestDate1 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )
			
	Select @TestDate2 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )	

	Select  @New_AFP	 = avg(afp_price)
					from averagefuelprice 
					where afp_tableid = @afp_tableid 
					and		ISNULL(afp_IsFormula, 0) = 0
					and	( afp_date = @TestDate1 OR afp_date = @TestDate2 ) 
	
					--IF @gi_string3 <> '03' 
					--	Begin				
					--		Select  @New_AFP	 = avg(afp_price)
					--				from averagefuelprice 
					--				where afp_tableid = @afp_tableid 
					--				and		ISNULL(afp_IsFormula, 0) = 0
					--				and		(	afp_date =	dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--						OR	afp_date =  dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') )	
					--	End
					--Else
					--	Begin			
					--		Select	@New_AFP	 = avg(afp_price)
					--				from averagefuelprice 
					--				where afp_tableid = @afp_tableid 
					--				and		ISNULL(afp_IsFormula, 0) = 0
					--				and		afp_date >=	dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--				and		afp_date <=	dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59')
					--	End

end

--====== Formula 'AVG4WK' (Average of DOE for PREVIOUS 4 weeks)  ======
if @aff_Formula = 'AVG4WK'  
begin
	--Select @TestDateBOD = dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
	--Select @TestDateEOD = dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59')	
	
	select  @TestDate1 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )
			
	Select @TestDate2 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )	
			
	select  @TestDate3 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -3, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -3, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )
			
	Select @TestDate4 = min(afp_date) from averagefuelprice 	where afp_tableid = @afp_tableid and ISNULL(afp_IsFormula, 0) = 0
			and afp_date >=   dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')  
			and	afp_date <=   dateadd( dd, +6, (dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') ) )			
	
	Select  @New_AFP	 = avg(afp_price)
					from averagefuelprice 
					where afp_tableid = @afp_tableid 
					and		ISNULL(afp_IsFormula, 0) = 0
					and	( afp_date = @TestDate1 OR afp_date = @TestDate2 OR afp_date = @TestDate3 OR afp_date = @TestDate4 )
						
					--IF @gi_string3 <> '03' 
					--	Begin				
					--		Select  @New_AFP	 = avg(afp_price)
					--					from averagefuelprice 
					--					where afp_tableid = @afp_tableid 
					--					and		ISNULL(afp_IsFormula, 0) = 0
					--					and		(	afp_date =	dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--							OR	afp_date =  dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--							OR	afp_date =  dateadd(ww, -3, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--							OR	afp_date =  dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00') )
																			
					--	End
					--Else
					--	Begin			 
					--		Select @New_AFP	 = avg(afp_price) 
					--			from averagefuelprice 
					--				where afp_tableid = @afp_tableid 
					--				and		ISNULL(afp_IsFormula, 0) = 0
					--				and		afp_date >=	dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					--				and		afp_date >=	dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59')
					--	End	

end

--====== Formula 'PREWK' (Use DOE value for PREVIOUS Monday)  ======
if @aff_Formula = 'PREWK'
begin						
			--Select  @New_AFP	 = avg(afp_price)
			--		from averagefuelprice 
			--		where afp_tableid = @afp_tableid 
			--		and		ISNULL(afp_IsFormula, 0) = 0
			--		and		afp_date =	dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
					
			Select @New_AFP	 = afp_price
					from averagefuelprice 
					where afp_tableid = @afp_tableid
					and		ISNULL(afp_IsFormula, 0) = 0
					and afp_date = ( select min(afp_date) from  averagefuelprice 
											where afp_tableid = @afp_tableid
											and		ISNULL(afp_IsFormula, 0) = 0
											and ( afp_date >= @BeginWeekLAST  and afp_date <= @EndWeekLAST ) ) 	
end 

--====== Formula 'PREWK' (Use DOE value for CURRENT Monday)  ======
if @aff_Formula = 'CURWK'
begin			
				--Select @New_AFP	 = afp_price
				--		from averagefuelprice 
				--		where afp_tableid = @afp_tableid
				--		and		ISNULL(afp_IsFormula, 0) = 0
				--		and		afp_date =	cast(Convert(varchar(10), @maxParentDate, 101) + ' 00:00:00' as DATETime)
						
					Select @New_AFP	 = afp_price
					from averagefuelprice 
					where afp_tableid = @afp_tableid
					and		ISNULL(afp_IsFormula, 0) = 0
					and afp_date = ( select min(afp_date) from  averagefuelprice 
											where afp_tableid = @afp_tableid
											and		ISNULL(afp_IsFormula, 0) = 0
											and ( afp_date >= @BeginWeekTHIS  and afp_date <= @EndWeekTHIS ) ) 
end		
		
if @New_AFP is null 
begin	
	if LEN( ISNULL(@specificMessage,'') ) <=0 
		begin
			set @specificMessage = 'Error: could not calculate formula for ' + @new_description + '. '	
			SET @ps_returnmsg = LTRIM(RTRIM(@specificMessage))	
			Return
		end
	else
		begin
			select @ps_returnmsg = 'Error: Formula ' + @new_description +  ' not created due to: ' + RTrim(LTrim(@specificMessage))
		end
		
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
	Return
end

--============================================================================================================
select @formulacount = count(afp_tableid) from averagefuelprice  
			where afp_tableid = @aff_formula_tableid 										
			and ISNULL(afp_IsFormula, 0) = 0
			and Cast(@NewFormulaEffectiveDate as DATETime) = cast( Convert(varchar(10), afp_date, 101) + ' 00:00:00' as DATETime)
																
if @formulacount > 0 
	begin	
		select @maxdatefortableid = max(afp_date) from averagefuelprice  where afp_tableid = @aff_formula_tableid 
				and ISNULL(afp_IsFormula, 0) = 0
				and Cast(@NewFormulaEffectiveDate as DATETime) = cast( Convert(varchar(10), afp_date, 101) + ' 00:00:00' as DATETime)
			begin
				select @maxseconds = DATEPART(ss, @maxdatefortableid)from averagefuelprice 
							where  afp_tableid = @aff_formula_tableid  
							and ISNULL(afp_IsFormula, 0) = 0
							--and afp_IsFormula = 0  --PTS 61286/5-9-12							
				select @maxseconds = @maxseconds + 10			
				select @maxdatefortableid = 	DATEADD (ss, @maxseconds, @maxdatefortableid) 
			end		
	end
else
--if @formulacount = 0 
	begin	
		select @maxdatefortableid = @NewFormulaEffectiveDate
	end
	
		
If Not Exists ( select afp_tableid, afp_date from averagefuelprice where afp_tableid = @aff_formula_tableid and afp_date = @maxdatefortableid ) 
Begin
	Insert into averagefuelprice(afp_tableid, afp_date, afp_description, afp_price,  afp_IsFormula, rowsec_rsrv_id, afp_revtype1)
	values(@aff_formula_tableid, @maxdatefortableid, @new_description, @New_AFP, 1, @rowsec_rsrv_id	, @afp_revtype1)
	
	select	@ps_returnmsg = 'Formula ' + @new_description + ' successfully created for Effective Date ' +  CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 110) +'. '
	
end
else
begin
	select	@ps_returnmsg = 'Formula/date already exist in Fuel Price Table: ' + @new_description + ' ' + cast(@NewFormulaEffectiveDate as Varchar(12) )
end 

-- 92303 nloke
update averagefuelprice
set afp_IsProcessed = @maxParentDate
where averagefuelprice.afp_id = @afpIdProcessed

SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
RETURN



GO
GRANT EXECUTE ON  [dbo].[CreateAvgFuelFormula_sp] TO [public]
GO
