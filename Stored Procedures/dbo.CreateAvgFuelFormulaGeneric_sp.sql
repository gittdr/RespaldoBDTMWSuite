SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[CreateAvgFuelFormulaGeneric_sp] @pl_aff_id  int, @processDate datetime, @ps_returnmsg varchar(255) Output 
AS
Set Nocount On
 
/**
 *
 * NAME:
 * dbo.CreateAvgFuelFormulaGeneric_sp
 * TYPE:
 * StoredProcedure
 *
  * DESCRIPTION:
 * Creates new entrie(s) in averagefuelprice table based on criteria from AvgFuelFormulaCriteria table.  Created for PTS 56708.
 * Assumption:   When we are dealing with  "Previous" anything - that means the row just prior to the max table entry matching the critera.
 * Assumption:   If we are dealing with "current" anything - that means the max row matching the critera.
 * Example:      If, for parent-table X we are looking to create a Weekly - Thursday - Previous-week value ==> 
 *				 'current' value will be the max date for table X having a DAYOFWEEK = Thursday.  (if none exists, proc fails)
 *               then we find 'previous' which is equal the the most recent value prior to the 'current' value also having a dayofweek = Thursday.
 *				 Again - if none exists - proc fails.
 *				 The calculation proceeds then using the price for that 'previous' week.	
 *
 *  5-9-12	JSwin Added Validations for corrupt data that the 'old' PB window does not prevent.  PTS 61286
 *			Also account for 'old' data or data entered with new GI = OFF where afp_IsFormula is NULL (test for null)
 *			add "Error:"  to beginning of Error messages so PB knows it is an error
 *  11-29-12	PTS 63266:  new formula
 * -- PTS 75085  3/10/2014 Proc adjusted to account for 'raw-data' variations (Handle mix & match any-day-of-week DOE values)
 **/

Declare	@afp_tableid 			varchar(8) 	
Declare	@aff_formula_tableid	varchar(8) 
Declare	@aff_Interval 			varchar(8) 
Declare	@aff_CycleDay			varchar(8) 
Declare	@aff_Formula 			varchar(8) 	
Declare	@aff_effective_day1 	int 
Declare	@aff_effective_day2 	int
Declare @aff_formula_Acronym	varchar(12) 
-----------
Declare @New_AFP				money
declare @affCycleDayCode		int
Declare @todaydaycode			int
Declare @previousdate			datetime
declare @maxdatefortableid		datetime
declare @maxseconds				int
declare @formulacount			int
declare @new_description		varchar(30)
declare @rowsec_rsrv_id			int
declare @afp_revtype1			varchar(6)
-----------
-- Constants & Validations (due to QA testing/able to create corrupt data:) PTS 61286/5-9-12
DECLARE @g_genesis               DATETIME
DECLARE @g_apocalypse            DATETIME
SELECT	@g_genesis    = Convert(DateTime,'1950-01-01 00:00:00')
SELECT	@g_apocalypse = Convert(DateTime,'2049-12-31 23:59:59')
declare @badidCount int
declare @afp_tableid_Count as int
declare @String_afp_tableid varchar(10)
declare @minbad int
declare	@maxbad int
declare @mindescr varchar(40)
declare @maxdescr varchar(40)
declare @msg1 varchar(140)
declare @msg2 varchar(140)
declare @msg3 varchar(140)
declare @SAVEpl_aff_id			int

declare @NewFormulaEffectiveDate datetime

--PTS 75085.start
declare @NewFormulaEffectiveDate2 datetime
declare	@ccFirstofMonth datetime 				
declare @MinDoeNeededforEffDay1	datetime
declare @MinDoeNeededforEffDay2	datetime			
--PTS 75085.end				
		

set @SAVEpl_aff_id	= @pl_aff_id 
---------------------------------------------

Select 	@afp_tableid 			= afp_tableid, 
		@aff_formula_tableid 	= aff_formula_tableid,
		@aff_Interval 			= aff_Interval, 
		@aff_CycleDay 			= aff_CycleDay, 
		@aff_Formula 			= aff_Formula,
		@aff_effective_day1 	= aff_effective_day1,
		@aff_effective_day2		= aff_effective_day2,
		@new_description		= afp_Description + ': ' + aff_formula_Acronym	
from  AvgFuelFormulaCriteria  
where aff_id =  @pl_aff_id 

set @ps_returnmsg = ''

select	@rowsec_rsrv_id	= 	rowsec_rsrv_id,  
		@afp_revtype1   =   afp_revtype1		
from	averagefuelprice  
where	afp_tableid = @afp_tableid

--PTS 61286/5-9-12.start
-- QA Fix	Weaknesses in the original AFP window to create corrupt afp data, add code to catch it.
-- Validations.start 

-- Validation#1
If @pl_aff_id Is Null set @pl_aff_id = 0
IF @pl_aff_id = 0
begin
	select @ps_returnmsg = 'Error: Data Not Valid!  CreateAvgFuelFormulaGeneric_sp Proc received parameter: AverageFuelPrice TableId = Null or Zero.' 
		SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
		Return
end  	

Set @afp_tableid_Count = (select count(afp_tableid) 
							from	averagefuelprice 	
							where	afp_tableid = @afp_tableid
							and ISNULL(afp_IsFormula, 0) = 0 ) 	
														
-- Validation#2					
IF @afp_tableid_Count < 2 
	begin
		set @String_afp_tableid = CAST(@afp_tableid as varchar(10))
		--set @msg1 = 'Error:  input param = ' + CAST(@pl_aff_id as varchar(10))  + ' @SAVEpl_aff_id = ' + CAST(@SAVEpl_aff_id as varchar(10))
		set @msg1 = 'Error: Data Not Valid!  CreateAvgFuelFormulaGeneric_sp Proc finds Less than TWO AverageFuelPrice Entries for TableId=' 
		set @msg2 = 'A MINIMUM of TWO AverageFuelPrice Entries must exist to create a Formula! '		
		SET @ps_returnmsg = LTrim(RTrim(@msg1)) + @String_afp_tableid + '.  ' +  LTrim(RTrim(@msg2))		
		Return			
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
									
			select @msg1 = 'Error: Data Not Valid!  ' + CAST(@badidCount as varchar(10)) + ' AvgFuelFormulaCriteria Entries exist With NO Matching AverageFuelPrice ID!' 					select @msg2 = 'First Bad Record: ' + RTRIM(CAST(@minbad as varchar(10))) + ' ' + LTRIM(RTRIM(@mindescr))
			select @msg3 = 'Last Bad Record: ' + RTRIM(CAST(@maxbad as varchar(10))) + ' ' + LTRIM(RTRIM(@maxdescr))
			SET @ps_returnmsg = SUBSTRING( (@msg1 + ' ' + @msg2 + ', ' + @msg3 ) , 1, 200) 
			
				IF OBJECT_ID(N'tempdb..#tmpbaddata', N'U') IS NOT NULL 
				DROP TABLE #tmpbaddata
			
			Return	
		end
-- Validations.end -- PTS 61286/5-9-12.end

---------------------------------- 9-30-2011 FIX.
-- using today as startpoint - get the begin/end dates of THIS week (& lastwk)
declare @BeginWeekTHIS				datetime
declare @EndWeekTHIS				datetime
declare @BeginWeekLAST				datetime
declare @EndWeekLAST				datetime
declare	@maxParentDate				datetime 
declare	@PREV_WEEK_ParentDate		datetime
declare @maxParentDate_dayofweek    int
Declare @maxParent_dow_name			varchar(6)
declare @TestDateBOD				datetime
Declare @TestDateEOD				datetime
Declare @specificMessage			varchar(200)
declare @BeginLastMonth				datetime		-- PTS 63266
declare @EndLastMonth				datetime		-- PTS 63266

-- PTS 75085.start
select	@maxParentDate = MAX(afp_date)
		from	averagefuelprice 	
		where	afp_tableid = @afp_tableid
		and ISNULL(afp_IsFormula, 0) = 0	
		
Declare		@MaxSaturday			datetime	
select @MaxSaturday = dateadd(dd, ( 7 - DatePart(Dw, GETDATE() ) ) , GETDATE() ) 		
		
create table #tmp_maxDate(	tempMaxDtID int	identity, afp_tableid varchar(8) null, 
ActualMaxDOE datetime null,  MaxMondayDOE datetime null,
BeginWeekTHIS datetime null, EndWeekTHIS datetime null, 
BeginWeekLAST datetime null, EndWeekLAST datetime null,
Prev2WksStart datetime null, Prev4WksStart datetime null,
PrevMonthFirst datetime null, PrevMonthLast datetime null)

insert into #tmp_maxDate (afp_tableid) 
select Distinct(afp_tableid) 
                from AvgFuelFormulaCriteria 
                where aff_id = @pl_aff_id                
                
update #tmp_maxDate 
set ActualMaxDOE = ( select max(afp_date) from averagefuelprice  where  afp_IsFormula = 0   
					and averagefuelprice.afp_tableid = #tmp_maxDate.afp_tableid 
					and averagefuelprice.afp_date <= @MaxSaturday ) 
					
update #tmp_maxDate 
set MaxMondayDOE = (select CASE 	
					WHEN DatePart(Dw, max(afp_date) ) > 2 then dateadd(DD, + 2 , DATEADD(dd, -1 * DatePart(Dw, max(afp_date) ), max(afp_date) ) ) 
					WHEN DatePart(Dw, max(afp_date) ) < 2 then dateadd(DD, + 1  , max(afp_date) )	
					else max(afp_date) 		
					end
					from averagefuelprice  where  afp_IsFormula = 0   
					and averagefuelprice.afp_tableid = #tmp_maxDate.afp_tableid  
					and averagefuelprice.afp_date <= @MaxSaturday ) 
					
update #tmp_maxDate 
	set BeginWeekTHIS	= DateAdd(dd, -1, MaxMondayDOE),
		EndWeekTHIS		= DATEADD(dd, +6, (DateAdd(dd, -1, MaxMondayDOE))),
		BeginWeekLAST	= DATEADD(dd, -7, (DateAdd(dd, -1, MaxMondayDOE))),
		EndWeekLAST		= DATEADD(dd, +6,( DATEADD(dd, -7, (DateAdd(dd, -1, MaxMondayDOE))))),	
		Prev2WksStart   = DATEADD(WW, -2, (DateAdd(dd, -1, MaxMondayDOE))),
		Prev4WksStart   = DATEADD(WW, -4, (DateAdd(dd, -1, MaxMondayDOE))), 	
		PrevMonthFirst = DATEADD(MM, -1, ( dateadd(dd, - (datepart(dd, ActualMaxDOE) - 1 ), ActualMaxDOE ) )) ,
		PrevMonthLast =  DATEADD(dd, -1, ( dateadd(dd, - (datepart(dd, ActualMaxDOE) - 1 ), ActualMaxDOE ) )) 	
-- PTS 75085.end

if (Select Datepart(dw, GETDATE() ) ) > 1 
begin
	Select @BeginWeekTHIS =   DateAdd(DD, -( Datepart(dw, GETDATE() ) - 1 ) , GETDATE() )	-- last Sunday
	Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
	Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
	Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)	
end

if (Select Datepart(dw, GETDATE() ) ) = 1
begin
	Select @BeginWeekTHIS =   DATEADD(dd, -7, GETDATE() )									-- last Sunday
	Select @EndWeekTHIS   =   DateAdd(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
	Select @BeginWeekLAST =   DATEADD(dd, -7, @BeginWeekTHIS)
	Select @EndWeekLAST =	  DATEADD(dd, +6, @BeginWeekLAST)
end 

Select @BeginWeekTHIS		= CONVERT(VARCHAR(10), @BeginWeekTHIS, 101) + ' 00:00:00'
Select @EndWeekTHIS			= CONVERT(VARCHAR(10), @EndWeekTHIS, 101) + ' 23:59:59'
Select @BeginWeekLAST		= CONVERT(VARCHAR(10), @BeginWeekLAST, 101) + ' 00:00:00'
Select @EndWeekLAST			= CONVERT(VARCHAR(10), @EndWeekLAST, 101) + ' 23:59:59'

--  Use only the DOE values ==>  afp_IsFormula = 0
-- Get the maximum Parent date matching the criteria.
if ( @aff_CycleDay is not NULL) and (@aff_CycleDay <> 'UNK')
	begin	
		select  @affCycleDayCode = code from labelfile where labeldefinition = 'affCycleDay' and abbr = ( @aff_CycleDay )		
		
		select	@maxParentDate = MAX(afp_date)
		from	averagefuelprice 	
		where	afp_tableid = @afp_tableid
		and ISNULL(afp_IsFormula, 0) = 0
		--and		Datepart(dw, afp_date) = @affCycleDayCode		
		--and afp_IsFormula = 0  --PTS 61286/5-9-12		
		
		select @maxParentDate_dayofweek  = Datepart(dw, @maxParentDate)
	end
else
begin 
	select	@maxParentDate = MAX(afp_date)
		from averagefuelprice 	
		where	afp_tableid = @afp_tableid	
		and ISNULL(afp_IsFormula, 0) = 0
		--and afp_IsFormula = 0  --PTS 61286/5-9-12		
			
	select @maxParentDate_dayofweek  = Datepart(dw, @maxParentDate)
end

select @maxParent_dow_name	 = abbr from labelfile where labeldefinition = 'affCycleDay' and code = @maxParentDate_dayofweek

select @PREV_WEEK_ParentDate = DateAdd(dd, -7, @maxParentDate)
---------------------------------- 9-30-2011 End-FIX.

-- Check for duplicates: Don't allow
select @formulacount = count(afp_tableid) 
from averagefuelprice  
where afp_tableid = @aff_formula_tableid
and afp_Description = @new_description

if @formulacount > 0 
begin
	--PTS 61286/5-9-12	add Error:  to beginning of messages so PB knows it is an error
	--select @ps_returnmsg = 'Formula ' + @new_description + ' already exists in the Average Fuel Price Table.'
	select @ps_returnmsg = 'Error: Averagefuelprice.afp_tableid =' + cast(@aff_formula_tableid as varchar(5)) + ', Formula "' + @new_description + '" already exists in the Average Fuel Price Table.'
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
	Return
end

-- PTS 63266 New formula
--PTS63266.start
if @aff_Formula = 'PREMN'
begin
	select @todaydaycode	= Datepart(dd, GETDATE() ) 
	select @BeginLastMonth	= DATEADD( dd, -( @todaydaycode -1 ) , getdate())   -- get 1st of this month. -- PTS 63266
	select @EndLastMonth	= DATEADD( dd, -1, @BeginLastMonth)					-- get End of LAST month. -- PTS 63266
	select @BeginLastMonth	= DATEADD( mm, -1 , @BeginLastMonth)				-- get 1st of LAST month. -- PTS 63266
	select @BeginLastMonth	= Cast(CONVERT(VARCHAR(10), @BeginLastMonth, 101) + ' 00:00:00'	as datetime)				  -- PTS 63266
	select @EndLastMonth	= Cast(CONVERT(VARCHAR(10), @EndLastMonth, 101) + ' 23:59:59' as datetime)					  -- PTS 63266
	Select @New_AFP	 = avg(afp_price) 
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						and afp_date >= @BeginLastMonth and afp_date <= @EndLastMonth
						and ISNULL(afp_IsFormula, 0) = 0
			
				IF @New_AFP >0
				begin		
					--PTS63266.start	
						select @NewFormulaEffectiveDate= dateadd(mm, 2,  @BeginLastMonth)	
						select @NewFormulaEffectiveDate	= CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'	-- proc needs to return string
				end 
					--PTS63266.end							
						
	IF @New_AFP is NULL
	begin

	-- PTS 75085.start
		-- if no 'current' then try @maxParentDate		
		select @ccFirstofMonth  = dateadd(dd, - (datepart(dd, @maxParentDate) - 1 ), @maxParentDate )  -- first day of month of MaxParentDate.	
		select @BeginLastMonth = DATEADD(MM, -1, @ccFirstofMonth)
		select @EndLastMonth = DATEADD(DD, -1, @ccFirstofMonth) 		
		select @BeginLastMonth	= Cast(CONVERT(VARCHAR(10), @BeginLastMonth, 101) + ' 00:00:00'	as datetime)
		select @EndLastMonth	= Cast(CONVERT(VARCHAR(10), @EndLastMonth, 101) + ' 23:59:59'	as datetime) 
	
		Select @New_AFP	 = avg(afp_price) 
						from averagefuelprice 
						where afp_tableid = @afp_tableid 
						and afp_date >= @BeginLastMonth and afp_date <= @EndLastMonth
						and ISNULL(afp_IsFormula, 0) = 0
						
				IF @New_AFP >0
				begin		
					--PTS63266.start		
							select @NewFormulaEffectiveDate= dateadd(mm, 2,  @BeginLastMonth)
							select @NewFormulaEffectiveDate	= CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'	-- proc needs to return string		
				end 							
						
		-- if it is STILL Null; get out.
		IF @New_AFP is NULL
		Begin
			select @specificMessage='Error: PREMN: No Parent AverageFuelPrice found for date range: ' + CONVERT(varchar(14),@BeginLastMonth, 101) + ' to ' + CONVERT(varchar(14),@EndLastMonth, 101) 					
		end 
		-- PTS 75085.end
	end 					
end

-- There are 4 'formulas' currenly: AVG2, AVG4 and PreWk are all deal w/ the PREVIOUS week values
------- 9-30-2011 FIX:  changed calulations and error messages.
if @aff_Formula = 'AVG2WK'
begin	
	-- PTS 75085.ReDesign	
	--Select @TestDateBOD = dateadd(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
	--Select @TestDateEOD = dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59') 
	--Select @New_AFP	 = avg(afp_price) 
	--					from averagefuelprice 
	--					where afp_tableid = @afp_tableid 
	--					and afp_date >= @TestDateBOD and afp_date <= @TestDateEOD
	--					and ISNULL(afp_IsFormula, 0) = 0
	--					--and afp_IsFormula = 0  --PTS 61286/5-9-12						
	--					--and afp_date >= dateadd(ww, -3, getdate()) and afp_date <= dateadd(ww, -1, getdate())	
	
	-- PTS 75085.ReDesign	
	Select @New_AFP	 = avg(afp_price) 	
					     from averagefuelprice
					     left join #tmp_maxDate on #tmp_maxDate.afp_tableid  = averagefuelprice.afp_tableid
					     where averagefuelprice.afp_tableid = @afp_tableid
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.Prev2WksStart  
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekLAST  
						
	IF @New_AFP is NULL
	Begin	
		Select @TestDateBOD = Prev2WksStart  from 	#tmp_maxDate
		Select @TestDateEOD = EndWeekLAST    from 	#tmp_maxDate		
		select @specificMessage='Error: AVG2WK: No Parent AverageFuelPrice found for date range: ' + CONVERT(varchar(14),@TestDateBOD, 101) + ' to ' + CONVERT(varchar(14),@TestDateEOD, 101) 					
	end 
end

if @aff_Formula = 'AVG4WK'
begin
	-- PTS 75085.ReDesign
	--Select @TestDateBOD = dateadd(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
	--Select @TestDateEOD = dateadd(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59')
	 
	--Select @New_AFP	 = avg(afp_price) 
	--					from averagefuelprice 
	--					where afp_tableid = @afp_tableid
	--					and afp_date >= @TestDateBOD and afp_date <= @TestDateEOD
	--					and ISNULL(afp_IsFormula, 0) = 0
	--					--and afp_IsFormula = 0  --PTS 61286/5-9-12						
	--					--and afp_date >= dateadd(ww, -5, getdate()) and afp_date <= dateadd(ww, -1, getdate)))
	
	-- PTS 75085.ReDesign	
	Select @New_AFP	 = avg(afp_price) 	
					     from averagefuelprice
					     left join #tmp_maxDate on #tmp_maxDate.afp_tableid  = averagefuelprice.afp_tableid
					     where averagefuelprice.afp_tableid = @afp_tableid
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.Prev4WksStart  
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekLAST 
					
	IF @New_AFP is NULL
	Begin
		Select @TestDateBOD = Prev4WksStart  from 	#tmp_maxDate
		Select @TestDateEOD = EndWeekLAST    from 	#tmp_maxDate	
		select @specificMessage='Error: AVG4WK: No Parent AverageFuelPrice found for date range: ' + CONVERT(varchar(14),@TestDateBOD, 101) + ' to ' + CONVERT(varchar(14),@TestDateEOD, 101) 					
	end 							
end	

-- PTS 75085.start: getting error on "PreviousWeek" calculation
declare @MaxMondayDOE datetime
declare @BeginLAST datetime
declare @EndLAST datetime
declare @tempcount int

if @aff_Formula = 'PREWK'
begin
		-- PTS 75085.ReDesign	
			Select @New_AFP	 = avg(afp_price) 	
					     from averagefuelprice
					     left join #tmp_maxDate on #tmp_maxDate.afp_tableid  = averagefuelprice.afp_tableid
					     where averagefuelprice.afp_tableid = @afp_tableid
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.BeginWeekLAST
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekLAST 

			IF @New_AFP is NULL
				Begin					
					select @specificMessage='Error: PREWK: No Parent AverageFuelPrice found for Previous Week. '	
				end 	
end
-- PTS 75085.end

if @aff_Formula = 'CURWK'
begin	
-- PTS 75085.ReDesign	
			Select @New_AFP	 = avg(afp_price) 	
					     from averagefuelprice
					     left join #tmp_maxDate on #tmp_maxDate.afp_tableid  = averagefuelprice.afp_tableid
					     where averagefuelprice.afp_tableid = @afp_tableid
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.BeginWeekTHIS
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekThis
						
		IF @New_AFP is NULL
				Begin					
					select @specificMessage='Error: PREWK: No Parent AverageFuelPrice found for Current Week. '	
				end 	 
								 
		--				Select @TestDateBOD = CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00'				
		--				Select @New_AFP	 = afp_price
		--						from averagefuelprice 
		--						where afp_tableid = @afp_tableid
		--						and cast(Convert(varchar(10), afp_date, 101) + ' 00:00:00' as DATETime) = cast(@TestDateBOD as DATETime)
		--						and ISNULL(afp_IsFormula, 0) = 0
		--						--and cast(afp_date as DATE) = cast(@TestDateBOD as DATE)
		--						--and afp_IsFormula = 0  --PTS 61286/5-9-12						
								
		--				IF @New_AFP is NULL
		--					Begin
		--						select @specificMessage='Error: PREWK: No Parent AverageFuelPrice found for Previous Week Date = ' + @TestDateBOD + '. '							end 	
end		
	
--if @aff_formula_tableid is null Or @maxdatefortableid is null Or @New_AFP is null 
if @New_AFP is null 
begin	
	if LEN( ISNULL(@specificMessage,'') ) <=0 
		begin
			set @specificMessage = 'Error: could not calculate formula for ' + @new_description + '. '	
			select @ps_returnmsg = 	@specificMessage
		end
	else
		begin
			select @ps_returnmsg = 'Error: Formula ' + @new_description +  ' not created due to: ' + RTrim(LTrim(@specificMessage))
		end
		
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
	Return
end

-- new row timestamp (New Table value Effective Date)
declare @daysaddnbr int
IF @aff_CycleDay is not NULL 
BEGIN
	--select @affCycleDayCode = code from labelfile where labeldefinition = 'affCycleDay' and abbr = ( @aff_CycleDay )
	--select @todaydaycode = Datepart(dw, @BeginWeekTHIS) -- always SUNDAY.
	--select @daysaddnbr = ( @affCycleDayCode - @todaydaycode ) 	
	--Select @NewFormulaEffectiveDate = DATEADD(dd, @daysaddnbr, @BeginWeekTHIS)
	--Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'
	--select ' debug line PREV VALUES ', @NewFormulaEffectiveDate, @BeginWeekTHIS, @aff_CycleDay, @aff_Interval
		
	if @aff_Interval IN ( 'WKLY' , 'BIWKLY'  )
	begin
		select @BeginWeekTHIS = BeginWeekTHIS from #tmp_maxDate
		select @NewFormulaEffectiveDate =  DATEADD(dd, +(@affCycleDayCode - 1), @BeginWeekTHIS ) 	
	end 
END

declare @chosenDate int
--PTS 75085.moved premn code UP
IF @aff_CycleDay IS NULL 
BEGIN
	set @ccFirstofMonth =  dateadd(dd, - (datepart(dd, DATEADD(MM, 1, @maxParentDate) -1 )), DATEADD(MM, 1, @maxParentDate))
	 IF ( @aff_Interval  = 'MNTH' OR @aff_Interval =  'BIMNTH' )  AND @aff_effective_day1 is not NULL  AND @aff_Formula <> 'PREMN'
	 begin 
		select @NewFormulaEffectiveDate = 
			CASE 
				when ( datepart(mm, (dateadd(dd, (@aff_effective_day1 -1), @ccFirstofMonth))) - datepart(mm, @ccFirstofMonth) ) = 0 
					then ( dateadd(dd, (@aff_effective_day1 -1), @ccFirstofMonth) )
				when ( datepart(mm, (dateadd(dd, (@aff_effective_day1 -1), @ccFirstofMonth))) - datepart(mm, @ccFirstofMonth) ) > 0 	
					then ( dateadd(dd, (-1), dateadd(mm, 1, @ccFirstofMonth)) )
				else 	@ccFirstofMonth
			end
		Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'		
	 end 
	 IF @aff_Interval =  'BIMNTH' and @aff_effective_day2 is not NULL
	 begin
		select @NewFormulaEffectiveDate2 = 
		CASE 
				when ( datepart(mm, (dateadd(dd, (@aff_effective_day2 -1), @ccFirstofMonth))) - datepart(mm, @ccFirstofMonth) ) = 0 
					then ( dateadd(dd, (@aff_effective_day2 -1), @ccFirstofMonth) )
				when ( datepart(mm, (dateadd(dd, (@aff_effective_day2 -1), @ccFirstofMonth))) - datepart(mm, @ccFirstofMonth) ) > 0 	
					then ( dateadd(dd, (-1), dateadd(mm, 1, @ccFirstofMonth)) )
				else 	@ccFirstofMonth
			end			
		select @NewFormulaEffectiveDate2 = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate2, 101) + ' 00:00:00'		
	 end 

						--if @aff_Interval =  'MNTH'	and	@aff_Formula <> 'PREMN'
						--begin
						--	if @aff_Interval =  'MNTH'
						--		begin
						--			-- concerned only with aff_effective_day1.
						--			select @todaydaycode = Datepart(dd, GETDATE() ) 
						--			select @NewFormulaEffectiveDate = DATEADD( dd, -( @todaydaycode -1 ) , getdate())  -- get 1st of this month.		
						--			select @NewFormulaEffectiveDate = DATEADD( dd, ( @aff_effective_day1 - 1) , @NewFormulaEffectiveDate) -- the the xx of the month.
						--			Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'			
						--		end
						--	else
						--		--if @aff_Formula =  'BIMNTH'
						--		begin	
						--			-- we have both aff_effective_day1 & aff_effective_day2 / choose which one to use.				
						--			select @chosenDate = @aff_effective_day1
						--			if Datepart(dd, GETDATE() )  >= @aff_effective_day2 
						--				begin				
						--					select @chosenDate = @aff_effective_day2			
						--				end	
									
						--			select @todaydaycode = Datepart(dd, GETDATE() ) 
						--			select @NewFormulaEffectiveDate = DATEADD( dd, -( @todaydaycode -1 ) , getdate())  -- get 1st of this month.
						--			select @NewFormulaEffectiveDate = DATEADD( dd, ( @chosenDate - 1) , @NewFormulaEffectiveDate) -- the the xx of the month.
						--			Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'				
						--		end	
						--	end	
						--if @aff_Interval =  'BIMNTH'
						--	begin			
						--			select @chosenDate = @aff_effective_day1
						--			if Datepart(dd, GETDATE() )  >= @aff_effective_day2 
						--				begin				
						--					select @chosenDate = @aff_effective_day2			
						--				end	
									
						--			select @todaydaycode = Datepart(dd, GETDATE() ) 
						--			select @NewFormulaEffectiveDate = DATEADD( dd, -( @todaydaycode -1 ) , getdate())  -- get 1st of this month.
						--			select @NewFormulaEffectiveDate = DATEADD( dd, ( @chosenDate - 1) , @NewFormulaEffectiveDate) -- the the xx of the month.
						--			Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'		
						--end	
						
						---- PTS 75085.moved up!
						------PTS63266.start
						--if @aff_Interval =  'MNTH'	and	@aff_Formula = 'PREMN'
						--begin
						--	select @todaydaycode = Datepart(dd, GETDATE() ) 
						--	select @NewFormulaEffectiveDate = DATEADD( dd, -( @todaydaycode -1 ) , getdate())  -- get 1st of this month.		
						--	Select @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'	
						--end
						------PTS63266.end			
END

select @formulacount = count(afp_tableid) from averagefuelprice  where afp_tableid = @aff_formula_tableid 										
										and ISNULL(afp_IsFormula, 0) = 0
										and Cast(@NewFormulaEffectiveDate as DATETime) = cast( Convert(varchar(10), afp_date, 101) + ' 00:00:00' as DATETime)
										--and afp_IsFormula = 0  --PTS 61286/5-9-12
										--and Cast(@NewFormulaEffectiveDate as date) = Cast(afp_date as date)
						--and CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) = CONVERT(VARCHAR(10), afp_date, 101) + '00:00:00' 										
if @formulacount > 0 
	begin	
		select @maxdatefortableid = max(afp_date) from averagefuelprice  where afp_tableid = @aff_formula_tableid 											
											and ISNULL(afp_IsFormula, 0) = 0
											and Cast(@NewFormulaEffectiveDate as DATETime) = cast( Convert(varchar(10), afp_date, 101) + ' 00:00:00' as DATETime)
											--and afp_IsFormula = 0  --PTS 61286/5-9-12
											--and Cast(@NewFormulaEffectiveDate as date) = Cast(afp_date as date)
					--and CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) = CONVERT(VARCHAR(10), afp_date, 101) + ' 00:00:00' 	
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

if @maxdatefortableid is null 
begin 
	select	@ps_returnmsg = 'Error: New Date is Null for Formula ' + @new_description + '.'
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
	return 
end
if ( select count(*) from averagefuelprice where afp_tableid = @aff_formula_tableid and afp_date = @maxdatefortableid ) > 0 
begin 
	select	@ps_returnmsg = 'Error: Formula already exists for calculated date: ' + @new_description + '.'
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
	return 
end 

Insert into averagefuelprice(afp_tableid, afp_date, afp_description, afp_price,  afp_IsFormula, rowsec_rsrv_id, afp_revtype1)
values(@aff_formula_tableid, @maxdatefortableid, @new_description, @New_AFP, 1, @rowsec_rsrv_id	, @afp_revtype1)

select	@ps_returnmsg = 'Formula ' + @new_description + ' successfully created in the Average Fuel Price Table.'
SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))



Return
GO
GRANT EXECUTE ON  [dbo].[CreateAvgFuelFormulaGeneric_sp] TO [public]
GO
