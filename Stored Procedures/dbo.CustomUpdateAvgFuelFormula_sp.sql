SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[CustomUpdateAvgFuelFormula_sp] 
AS
Set Nocount On
 
/**
 *
 * NAME:
 * dbo.CustomUpdateAvgFuelFormula_sp
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Updates custom formulas in averagefuelprice table based on criteria from AvgFuelFormulaCriteria table.  Created for PTS 56708.
 * Should be Run following normal fuel table DOE update.
 * removed input parms --@afp_tableid varchar(8), @FuelDate datetime  and re-wrote whole proc.
* -- PTS 61286  Addtl Tweaks needed:  4/2/2012  { 4 changes }
* -- PTS 68003:
		-- if @gi_string3 = 03 (default) then 	@MondayMonday = monday belonging to week of GETDATE() 
		-- if @gi_string3 = 01 or 02	@MondayMonday = prev dates
		-- if @gi_string3 = 00  then @MondayMonday = @MondayMonday
		-- if @gi_string3 = 04 then @MondayMonday = (use #tmp_maxDoeDates)	
		
		04/14/2014				Consolidated PTS List 65765, 68003, 65092 ) 
		06/11/2014:	PTS 66086:  JSwin	Formula: PREV MONTH / Account Any Day of the Week (raw-data) DOE values
		08/26/2015 PTS 92303 nloke Each DOE record should only be processed once
 **/


If not exists (select 1 from generalinfo Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' ) Return
If not exists (select 1 from generalinfo Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' ) Return
--PTS 68003_1.start		
If not exists (select 1 from generalinfo Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' ) Return
Declare @gi_integer1				int				-- 75085 et al;
declare	@MondayMonday				datetime
declare @maxParentDate				datetime
declare	@maxParentDate_dayofweek	int

Declare	@gi_string3 				varchar(2)

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

-- everything begins with MONDAY of THIS week
select @MondayMonday	= (select DateAdd(DD, (-( Datepart(dw, GETDATE() ) - 1 )) + 1 , GETDATE() ) )
if @gi_string3 = '01'   select @MondayMonday	= DateAdd(DD, -7, @MondayMonday )		-- fuel & effective dates from monday - 7
if @gi_string3 = '02'   select @MondayMonday	= DateAdd(DD, -14, @MondayMonday )		-- fuel & effective dates from monday - 14
Set @MondayMonday = CONVERT(VARCHAR(10), @MondayMonday, 101) + ' 00:00:00'

create table #tmp_maxDoeDates(ttID int	identity,
				afp_date datetime null, 				
				afp_tableid varchar(8) null,
				ttid_mondaymonday datetime null,
				maxParentDate	datetime null,
				maxparentdow	int	null,
				BeginWeekTHIS	datetime null,
				EndWeekTHIS		datetime null,
				BeginWeekLAST	datetime null,
				EndWeekLAST		datetime null,
				CurrWkPrice		money null,
				Avgprice1		money null, 
				Avgprice2		money null, 
				Avgprice3		money null, 
				Avgprice4		money null,
				AfpId	int )  		
						
Insert Into #tmp_maxDoeDates
select max(afp_date), afp_tableid, @MondayMonday, null, null, null, null, null, null, 0,0,0,0,0, afp_id
from	averagefuelprice 
where averagefuelprice.afp_date  <= GETDATE()
and averagefuelprice.afp_tableid in (select distinct(AvgFuelFormulaCriteria.afp_tableid) 
								from	AvgFuelFormulaCriteria 
								join	AverageFuelPrice 
								on		AverageFuelPrice.afp_tableid = AvgFuelFormulaCriteria.aff_formula_tableid 
								and		AverageFuelPrice.afp_description =  (AvgFuelFormulaCriteria.afp_description + ': ' + AvgFuelFormulaCriteria.aff_formula_Acronym) ) 
and averagefuelprice.afp_IsProcessed is null
group by 	averagefuelprice.afp_tableid, afp_id 
-- 92303 nloke added afp_id to the select and afp_IsProcessed					

--==================
if @gi_string3 = '01' or @gi_string3 = '02'
begin 
	update #tmp_maxDoeDates
	set #tmp_maxDoeDates.afp_date = @MondayMonday 
	where #tmp_maxDoeDates.afp_date >= @MondayMonday 
end
if @gi_string3 = '00' or @gi_string3 = '01' or @gi_string3 = '02' 
delete from #tmp_maxDoeDates where #tmp_maxDoeDates.afp_date <> @MondayMonday
--==================

if @gi_string3 = '00' or @gi_string3 = '01' or @gi_string3 = '02' 
begin
	update #tmp_maxDoeDates
	set maxParentDate = #tmp_maxDoeDates.afp_date
	where #tmp_maxDoeDates.afp_date = @MondayMonday
end

if @gi_string3 = '03' 
begin
	update #tmp_maxDoeDates
	set maxParentDate = #tmp_maxDoeDates.afp_date	
	where #tmp_maxDoeDates.afp_date  <= @MondayMonday
end

if @gi_string3 = '04' 
begin
	update #tmp_maxDoeDates
	set maxParentDate = #tmp_maxDoeDates.afp_date	
	where #tmp_maxDoeDates.afp_date <= GETDATE()
end
-- 92303 nloke - doe dates should only be processed once.
delete from #tmp_maxDoeDates where #tmp_maxDoeDates.afp_tableid in (select distinct averagefuelprice.afp_tableid
																			from averagefuelprice
																			join #tmp_maxDoeDates on averagefuelprice.afp_tableid = #tmp_maxDoeDates.afp_tableid
																			where #tmp_maxDoeDates.maxParentDate = averagefuelprice.afp_IsProcessed
																			and averagefuelprice.afp_IsFormula = 0)
-- end 92303
--==================
update #tmp_maxDoeDates
	set BeginWeekTHIS	= DateAdd(dd, -1, maxParentDate),
		EndWeekTHIS		= DATEADD(dd, +6, (DateAdd(dd, -1, maxParentDate))),
		BeginWeekLAST	= DATEADD(dd, -7, (DateAdd(dd, -1, maxParentDate))),
		EndWeekLAST		= DATEADD(dd, +6,( DATEADD(dd, -7, (DateAdd(dd, -1, maxParentDate)))))	
		
update #tmp_maxDoeDates
set #tmp_maxDoeDates.maxparentdow = Datepart(dw, maxParentDate)
where maxParentDate is not null 		

-- get most current week's price...
update #tmp_maxDoeDates
set #tmp_maxDoeDates.CurrWkPrice = IsNull(averagefuelprice.afp_price, 0 )
from averagefuelprice
left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = averagefuelprice.afp_tableid	)
where averagefuelprice.afp_IsFormula = 0 	
and averagefuelprice.afp_date = ( select min(a1.afp_date) from averagefuelprice a1 where #tmp_maxDoeDates.afp_tableid = a1.afp_tableid
									and a1.afp_IsFormula = 0 
									and a1.afp_date between #tmp_maxDoeDates.BeginWeekTHIS AND #tmp_maxDoeDates.EndWeekTHIS  ) 

----Avgprice1  =  prev week									
update #tmp_maxDoeDates
set #tmp_maxDoeDates.Avgprice1 = IsNull(averagefuelprice.afp_price, 0 )
from averagefuelprice
left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = averagefuelprice.afp_tableid	)
where averagefuelprice.afp_IsFormula = 0 	
and averagefuelprice.afp_date = ( select min(a1.afp_date) from averagefuelprice a1 where #tmp_maxDoeDates.afp_tableid = a1.afp_tableid
									and a1.afp_IsFormula = 0 
									and a1.afp_date between #tmp_maxDoeDates.BeginWeekLAST AND #tmp_maxDoeDates.EndWeekLAST  ) 

--Avgprice2  =  2 weeks ago
update #tmp_maxDoeDates
set #tmp_maxDoeDates.Avgprice2 = IsNull(averagefuelprice.afp_price, 0 )
from averagefuelprice
left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = averagefuelprice.afp_tableid	)
where averagefuelprice.afp_IsFormula = 0 	
and averagefuelprice.afp_date  =  ( select min(a1.afp_date) from averagefuelprice a1
										left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = a1.afp_tableid	)	
										where #tmp_maxDoeDates.afp_tableid = a1.afp_tableid 
										and  a1.afp_IsFormula = 0
										and a1.afp_date >= DateAdd(ww, -1, #tmp_maxDoeDates.BeginWeekLAST)
										and a1.afp_date <= DateAdd(ww, -1,#tmp_maxDoeDates.EndWeekLAST) )
--Avgprice3  =  3 weeks ago
update #tmp_maxDoeDates
set #tmp_maxDoeDates.Avgprice3 = IsNull(averagefuelprice.afp_price, 0 )
from averagefuelprice
left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = averagefuelprice.afp_tableid	)
where averagefuelprice.afp_IsFormula = 0 	
and averagefuelprice.afp_date  =  ( select min(a1.afp_date) from averagefuelprice a1
										left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = a1.afp_tableid	)	
										where #tmp_maxDoeDates.afp_tableid = a1.afp_tableid 
										and  a1.afp_IsFormula = 0
										and a1.afp_date >= DateAdd(ww, -2, #tmp_maxDoeDates.BeginWeekLAST)
										and a1.afp_date <= DateAdd(ww, -2,#tmp_maxDoeDates.EndWeekLAST) )
--Avgprice4  =  4 weeks ago
update #tmp_maxDoeDates
set #tmp_maxDoeDates.Avgprice4 = IsNull(averagefuelprice.afp_price, 0 )
from averagefuelprice
left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = averagefuelprice.afp_tableid	)
where averagefuelprice.afp_IsFormula = 0 	
and averagefuelprice.afp_date  =  ( select min(a1.afp_date) from averagefuelprice a1
										left join #tmp_maxDoeDates on (#tmp_maxDoeDates.afp_tableid = a1.afp_tableid	)	
										where #tmp_maxDoeDates.afp_tableid = a1.afp_tableid 
										and  a1.afp_IsFormula = 0
										and a1.afp_date >= DateAdd(ww, -3, #tmp_maxDoeDates.BeginWeekLAST)
										and a1.afp_date <= DateAdd(ww, -3,#tmp_maxDoeDates.EndWeekLAST) )
--PTS 68003_1.end

create table #tmp_AFP_update 
(	
		tempID int	identity,
		afp_id int null, 
		afp_price money null, 
		afp_date datetime null, 				
		aff_id int null, 
		afp_tableid varchar(8) null,
		aff_Interval varchar(8) null , 
		aff_CycleDay varchar(8) null, 
		aff_Formula varchar(8) null,
		aff_effective_day1 int null , 
		aff_effective_day2 int null,
		afp_IsFormula int null,
		aff_formula_tableid varchar(8) null,
		NewFuelPrice money null, 
		IsUpdated char(1),		
		NextEffectiveDateShouldBe datetime null,
		NextEffectiveDate_2ShouldBe datetime null,
		affCycleDayCode Int Null,
		afp_description varchar(30) null,
		maxparentdate	datetime null,			-- PTS 68003	
		afp_CalcPriceUsingDOW int null			-- PTS 66086
)
							  
Insert into #tmp_AFP_update (
		afp_id, 
		afp_price, 
		afp_date, 	
		aff_id, 
		afp_tableid,
		aff_Interval, 
		aff_CycleDay, 
		aff_Formula,
		aff_effective_day1, 
		aff_effective_day2,
		afp_IsFormula,
		aff_formula_tableid, 
		NewFuelPrice, 
		IsUpdated,
		NextEffectiveDateShouldBe, 
		NextEffectiveDate_2ShouldBe,
		affCycleDayCode,
		afp_description,
		maxparentdate,						-- PTS 68003
		afp_CalcPriceUsingDOW				-- PTS 66086
		)	
select						
		AverageFuelPrice.afp_id, 
		AverageFuelPrice.afp_price,
		AverageFuelPrice.afp_date, 		
		AvgFuelFormulaCriteria.aff_id,	
		AvgFuelFormulaCriteria.afp_tableid,
		AvgFuelFormulaCriteria.aff_Interval, 
		AvgFuelFormulaCriteria.aff_CycleDay, 
		AvgFuelFormulaCriteria.aff_Formula,   
		AvgFuelFormulaCriteria.aff_effective_day1, 
		AvgFuelFormulaCriteria.aff_effective_day2,	
		AverageFuelPrice.afp_IsFormula,	 
		AvgFuelFormulaCriteria.aff_formula_tableid,
		(select null)  as 'NewFuelPrice',
		'N' as IsUpdated,		
		(select null) as 'NextEffectiveDateShouldBe',
		(select null) as 'NextEffectiveDate_2ShouldBe',
		(select null) as 'affCycleDayCode',
		AverageFuelPrice.afp_description,
		#tmp_maxDoeDates.maxparentdate,						-- PTS 68003; add column and new from/join/where
		IsNull(AvgFuelFormulaCriteria.afp_CalcPriceUsingDOW,0)				-- PTS 66086		
from	AvgFuelFormulaCriteria 
left join	AverageFuelPrice on		AverageFuelPrice.afp_tableid = AvgFuelFormulaCriteria.aff_formula_tableid
left join	#tmp_maxDoeDates on		AvgFuelFormulaCriteria.afp_tableid = #tmp_maxDoeDates.afp_tableid
where aff_formula_tableid in ( select distinct      (afp_tableid)     
                                               from averagefuelprice  
                                               where afp_IsFormula = 1 ) 
and    #tmp_maxDoeDates.maxParentDate is not NULL 

update #tmp_AFP_update
set affCycleDayCode = (	select code from labelfile 
						where labeldefinition = 'affCycleDay' 
						and abbr = #tmp_AFP_update.aff_CycleDay
						and #tmp_AFP_update.aff_CycleDay is not null
						and #tmp_AFP_update.aff_CycleDay <> 'UNK')
where #tmp_AFP_update.aff_CycleDay is not null
and #tmp_AFP_update.aff_CycleDay <> 'UNK'

--------- 8/28/2013 bug Fix.start
update #tmp_AFP_update
set affCycleDayCode = 	( affCycleDayCode - 1 )	
where #tmp_AFP_update.aff_CycleDay is not null
and #tmp_AFP_update.aff_CycleDay <> 'UNK'
--------- 8/28/2013 bug Fix.end			
				
update #tmp_AFP_update	
set NextEffectiveDateShouldBe = CASE #tmp_AFP_update.aff_Interval 
			when 'WKLY' then DateAdd(dd, +7, #tmp_AFP_update.afp_date )
			--Case aff_formula
			--					When 'CURWK' then DateAdd(dd, +7, #tmp_AFP_update.afp_date )
			--					When 'PREWK' then DateAdd(dd, +7, #tmp_AFP_update.afp_date )
			--					Else  DateAdd(dd, +(affCycleDayCode), #tmp_maxDoeDates.BeginWeekTHIS ) 
			--					End
			when 'BIWKLY' then Case aff_formula
								When 'CURWK' then DateAdd(dd, (7+(affCycleDayCode)), #tmp_maxDoeDates.BeginWeekTHIS )
								When 'PREWK' then DATEADD(DD, (7+(affCycleDayCode)), #tmp_maxDoeDates.BeginWeekLAST )
								else DateAdd(dd, (7+(affCycleDayCode)), #tmp_maxDoeDates.BeginWeekTHIS )
								End
			end
from #tmp_AFP_update		
left join #tmp_maxDoeDates	
on		#tmp_AFP_update.afp_tableid = #tmp_maxDoeDates.afp_tableid	
where aff_Interval in (	'WKLY', 'BIWKLY' )	
and aff_CycleDay is not null
and aff_CycleDay <> 'UNK'	

update #tmp_AFP_update	
set NextEffectiveDateShouldBe = DateAdd( dd, +(aff_effective_day1 - 1 ), 
				(DATEADD (DD, -(Datepart(dd, #tmp_AFP_update.maxparentdate ) - 1), #tmp_AFP_update.maxparentdate )))
from #tmp_AFP_update		
left join #tmp_maxDoeDates	
on		#tmp_AFP_update.afp_tableid = #tmp_maxDoeDates.afp_tableid	
where	aff_Interval in ('MNTH', 'BIMNTH') and aff_effective_day1 is not NULL
		
update #tmp_AFP_update	
set NextEffectiveDate_2ShouldBe = DateAdd( dd, +(aff_effective_day2 - 1 ), 
				(DATEADD (DD, -(Datepart(dd, #tmp_AFP_update.maxparentdate ) - 1), #tmp_AFP_update.maxparentdate )))
from #tmp_AFP_update		
left join #tmp_maxDoeDates	
on		#tmp_AFP_update.afp_tableid = #tmp_maxDoeDates.afp_tableid	
where	aff_Interval = 'BIMNTH' and aff_effective_day2 is not NULL

-- choose the best date		
update #tmp_AFP_update	
set NextEffectiveDateShouldBe = NextEffectiveDate_2ShouldBe
where	 Datepart(dd, maxparentdate)  >= DATEPART( dd, NextEffectiveDate_2ShouldBe) 
AND ( aff_Interval in ('MNTH', 'BIMNTH') and aff_effective_day2 is not NULL  ) 
-- PTS 68003_3.end	 'MNTH', 'BIMNTH'	

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
   #tmp_AFP_update.NewFuelPrice  = ( select min(#tmp_maxDoeDates.CurrWkPrice)
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid )
where #tmp_AFP_update.aff_Formula = 'CURWK' 

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select min(#tmp_maxDoeDates.avgprice1)
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid )
where #tmp_AFP_update.aff_Formula = 'PREWK' 

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select (#tmp_maxDoeDates.Avgprice1 + #tmp_maxDoeDates.Avgprice2 ) / 2
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid
									and #tmp_AFP_update.maxparentdate = #tmp_maxDoeDates.maxParentDate )
where #tmp_AFP_update.aff_Formula = 'AVG2WK'	
 

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select (#tmp_maxDoeDates.Avgprice1 + #tmp_maxDoeDates.Avgprice2 +  #tmp_maxDoeDates.Avgprice3 + #tmp_maxDoeDates.Avgprice4 ) / 4
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid
									and #tmp_AFP_update.maxparentdate = #tmp_maxDoeDates.maxParentDate )
where #tmp_AFP_update.aff_Formula = 'AVG4WK'

--PTS 66086.start
update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select (#tmp_maxDoeDates.Avgprice1 + #tmp_maxDoeDates.Avgprice2 +  #tmp_maxDoeDates.Avgprice3 + #tmp_maxDoeDates.Avgprice4 ) / 4
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid
									and #tmp_AFP_update.maxparentdate = #tmp_maxDoeDates.maxParentDate )
where #tmp_AFP_update.aff_Formula = 'PREMN'

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select (#tmp_maxDoeDates.Avgprice1 + #tmp_maxDoeDates.Avgprice2 +  #tmp_maxDoeDates.Avgprice3 + #tmp_maxDoeDates.Avgprice4 ) / 4
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid
									and #tmp_AFP_update.maxparentdate = #tmp_maxDoeDates.maxParentDate )
where #tmp_AFP_update.aff_Formula = 'PMMON'

update #tmp_AFP_update
set #tmp_AFP_update.IsUpdated = 'Y'	,
 #tmp_AFP_update.NewFuelPrice  = ( select (#tmp_maxDoeDates.Avgprice1 + #tmp_maxDoeDates.Avgprice2 +  #tmp_maxDoeDates.Avgprice3 + #tmp_maxDoeDates.Avgprice4 ) / 4
									from #tmp_maxDoeDates
									where #tmp_maxDoeDates.afp_tableid = #tmp_AFP_update.afp_tableid
									and #tmp_AFP_update.maxparentdate = #tmp_maxDoeDates.maxParentDate )
where #tmp_AFP_update.aff_Formula = 'PMDOW'
--PTS 66086.end

--=========================================================================================
--delete from #tmp_AFP_update where IsUpdated <> 'Y'	-- PTS 61286  modify delete statement 4/2/2012
delete from #tmp_AFP_update where ( IsUpdated <> 'Y'  OR NewFuelPrice is null ) 
if (select COUNT(*) from #tmp_AFP_update)  <= 0 return

-- PTS 68003_5.start
--select distinct afp_tableid, afp_date, afp_description, afp_price				-- PTS 68003_5
select distinct  afp_tableid , afp_date, afp_description, afp_price, afp_id
into #tempRemoveDuplicates
from averagefuelprice 
where afp_isformula = 1
order by afp_tableid, afp_date desc, afp_description, afp_price 

--delete from #tmp_AFP_update where afp_date = NextEffectiveDateShouldBe AND afp_price = NewFuelPrice
--if (select COUNT(*) from #tmp_AFP_update)  <= 0 return

delete	from #tmp_AFP_update 
		where tempID in (	select #tmp_AFP_update.tempid
							from #tmp_AFP_update
							left join #tempRemoveDuplicates ON ( #tempRemoveDuplicates.afp_tableid = #tmp_AFP_update.aff_formula_tableid )
							where #tempRemoveDuplicates.afp_date = #tmp_AFP_update.NextEffectiveDateShouldBe ) 
							--and #tempRemoveDuplicates.afp_price  = #tmp_AFP_update.NewFuelPrice
							--and #tempRemoveDuplicates.afp_description = #tmp_AFP_update.afp_description  )

if (select COUNT(*) from #tmp_AFP_update)  <= 0 
begin	
	return	
end

-- PTS 61286  replace select w/ select distinct  4/2/2012
Insert into averagefuelprice(	afp_tableid, 
								afp_date, 
								afp_description, 
								afp_price,  
								afp_IsFormula
								)
select distinct					
								aff_formula_tableid, 
								NextEffectiveDateShouldBe, 
								afp_description, 
								NewFuelPrice,
								1
from #tmp_AFP_update
where NextEffectiveDateShouldBe is not NULL

-- 92303 nloke
update averagefuelprice
set afp_IsProcessed = (select max(#tmp_maxDoeDates.maxParentDate) from #tmp_maxDoeDates)
where averagefuelprice.afp_id in (select #tmp_maxDoeDates.AfpId from #tmp_maxDoeDates
										join averagefuelprice on averagefuelprice.afp_id = #tmp_maxDoeDates.AfpId)
--end 92303

-- PTS 68003_6.start
---- PTS 61286  replace select w/ select distinct  4/2/2012
--Insert into averagefuelprice(	afp_tableid, 
--								afp_date, 
--								afp_description, 
--								afp_price,  
--								afp_IsFormula
--								)
--select distinct					
--								aff_formula_tableid, 
--								NextEffectiveDate_2ShouldBe, 
--								afp_description, 
--								NewFuelPrice,
--								1
--from #tmp_AFP_update
--where aff_interval = 'BIMNTH'
--and NextEffectiveDate_2ShouldBe is not null
-- PTS 68003_6.end

drop table #tmp_AFP_update
drop table #tempRemoveDuplicates
drop table #tmp_maxDoeDates
Return


GO
GRANT EXECUTE ON  [dbo].[CustomUpdateAvgFuelFormula_sp] TO [public]
GO
