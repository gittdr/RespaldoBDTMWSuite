SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[CustomUpdateAvgFuelFormulaGeneric_sp] 
AS
Set Nocount On
 
/**
 *
 * NAME:
 * dbo.CustomUpdateAvgFuelFormulaGeneric_sp
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Updates custom formulas in averagefuelprice table based on criteria from AvgFuelFormulaCriteria table.  Created for PTS 56708.
 * Should be Run following normal fuel table DOE update.
 * removed input parms --@afp_tableid varchar(8), @FuelDate datetime  and re-wrote whole proc.
* -- PTS 61286  Addtl Tweaks needed:  4/2/2012  { 4 changes }
* -- PTS 75085  3/19/2014 Proc adjusted to account for 'raw-data' variations (Handle mix & match any-day-of-week DOE values)
 **/


If not exists (select 1 from generalinfo Where gi_name = 'EnableAvgFuelFormulaCalc' and gi_string1 = 'Y' ) Return

-- PTS 65124; handle the datacondition where max/min afp_dates are extraneous
Declare		@MaxSaturday			datetime	
DECLARE		@today_Plus_30			datetime
DECLARE		@today_Minus_30			datetime

SET	@today_Plus_30  = DATEADD(DD, +30, GETDATE() ) 
SET	@today_Minus_30 = DATEADD(DD, -30, GETDATE() ) 
select @MaxSaturday = dateadd(dd, ( 7 - DatePart(Dw, GETDATE() ) ) , GETDATE() ) 

declare @FuelDate				datetime
--select @FuelDate = MAX(afp_date) from AverageFuelPrice where afp_IsFormula = 0
-- PTS 65124; 
select @FuelDate = MAX(afp_date) from AverageFuelPrice 
where ( afp_IsFormula = 0  OR afp_IsFormula is null ) 
and afp_date >=	@today_Minus_30
AND afp_date <=  @today_Plus_30 


-- PTS 75085
if @FuelDate is  NULL  
begin
select @FuelDate = MAX(afp_date) from AverageFuelPrice 
where ( afp_IsFormula = 0  OR afp_IsFormula is null ) 
end 

Set	   @FuelDate = cast(Convert(varchar(10), @FuelDate, 101) + ' 00:00:00' as DATETime)	-- ensure BOD

-- batchLog Constants:
declare @tmwuser varchar (255)
declare @batchUserid varchar(20)
declare @batchNumber int
declare @BatchTitle varchar(60)
declare @BatchType varchar(6)
declare @BatchIcon char(1) 
declare @BatchResponse varchar(10)
-- messageText varchar(255)

exec gettmwuser @tmwuser output
set @batchUserid = LEFT(@tmwuser, 20)
--exec @batchNumber		= getsystemnumber 'BATCHQ', ''
set @batchNumber = 250044
set @BatchTitle = 'AvgFuelFormulaUpdate'
set @BatchType = 'INFO'
set @BatchIcon = 'I'
set @BatchResponse = 'OK'

create table #logMessages(msgsequence int identity, 
		txt1 varchar(60) null, txt2 varchar(60) null, txt3 varchar(60) null , 
		txt4 varchar(60) null, txt5 varchar(60) null)
insert into #logMessages ( txt1 ) values ('Begin CustomUpdateAvgFuelFormula' )

create table #tmp_avgFuelParentDOE(ttID int	identity,
				afp_id int null, 
				Max_afp_date datetime null, 				
				afp_tableid varchar(8) null,
				afp_price money null,
				PrevWk_afp_date datetime null,
				PrevWk_afp_id int null,
				PrevWk_afp_price money null,
				PrevAvg2Wk_price money null,
				PrevAvg4Wk_price money null,
				AvgPreMonth_Price money null)

create table #tmp_avgFormula(tfID int	identity,
				afp_id int null, 
				Max_formula_date datetime null, 				
				afp_tableid varchar(8) null,
				Parent_tableid varchar(8) null,
				afp_price money null,				
				aff_Interval varchar(8) null , 
				aff_CycleDay varchar(8) null, 
				aff_Formula varchar(8) null,
				affCycleDayCode Int Null,
				ccFirstofMonth datetime null,
				aff_effective_day1 Int Null,
				aff_effective_day2 Int Null,						
				NextEffectiveDateShouldBe datetime null,
				NextEffectiveDate_2ShouldBe datetime null,
				NewFuelPrice money null,
				MinDoeNeededforEffDay1 datetime null,
				MinDoeNeededforEffDay2 datetime null )

-- 75085 .start
-- Get max averagefuelprice DATE for each 'parent/DOE' table having formula(s).
create table #tmp_maxDate(	tempMaxDtID int	identity, afp_tableid varchar(8) null, 
ActualMaxDOE datetime null,  MaxMondayDOE datetime null,
BeginWeekTHIS datetime null, EndWeekTHIS datetime null, 
BeginWeekLAST datetime null, EndWeekLAST datetime null,
Prev2WksStart datetime null, Prev4WksStart datetime null,
PrevMonthFirst datetime null, PrevMonthLast datetime null)

insert into #tmp_maxDate ( afp_tableid) 
select Distinct(afp_tableid) 
                from AvgFuelFormulaCriteria 
                where aff_formula_tableid in ( select distinct      (afp_tableid)     
                                               from averagefuelprice  
                                               where afp_IsFormula = 1 )    
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
-- 75085 .end

insert into #tmp_avgFuelParentDOE(afp_tableid)
select #tmp_maxDate.afp_tableid from #tmp_maxDate

update #tmp_avgFuelParentDOE
set Max_afp_date = ( select MAX(afp_date)
					 from averagefuelprice 
					 where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
					 group by averagefuelprice.afp_tableid)

update #tmp_avgFuelParentDOE
set afp_id = ( select afp_id 
				from averagefuelprice 
				where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
				AND  #tmp_avgFuelParentDOE.Max_afp_date = averagefuelprice.afp_date )
				
update #tmp_avgFuelParentDOE
set afp_price = ( select afp_price
				from averagefuelprice 
				where #tmp_avgFuelParentDOE.afp_id = averagefuelprice.afp_id )
				
update #tmp_avgFuelParentDOE
Set PrevWk_afp_date	= ( select MAX(afp_date)
						from averagefuelprice 
						where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
						AND  averagefuelprice.afp_date < #tmp_avgFuelParentDOE.Max_afp_date
						group by afp_tableid )			

update #tmp_avgFuelParentDOE
set PrevWk_afp_id = ( select afp_id 
					  from averagefuelprice 
					  where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
					  AND  #tmp_avgFuelParentDOE.PrevWk_afp_date = averagefuelprice.afp_date )
					  
update #tmp_avgFuelParentDOE
set PrevWk_afp_price = ( select afp_price
				from averagefuelprice 
				where #tmp_avgFuelParentDOE.PrevWk_afp_id = averagefuelprice.afp_id )	
				
----=====================================================================================	
update #tmp_avgFuelParentDOE
set PrevAvg2Wk_price = ( select avg(afp_price)
						 from averagefuelprice 
						 where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.Prev2WksStart 
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekLAST   )						 
from #tmp_avgFuelParentDOE
left join #tmp_maxDate on (#tmp_maxDate.afp_tableid  = #tmp_avgFuelParentDOE.afp_tableid )

update #tmp_avgFuelParentDOE
set PrevAvg4Wk_price = ( select avg(afp_price)
						 from averagefuelprice 
						 where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.Prev4WksStart 
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.EndWeekLAST   )						 
from #tmp_avgFuelParentDOE
left join #tmp_maxDate on (#tmp_maxDate.afp_tableid  = #tmp_avgFuelParentDOE.afp_tableid )
									
update #tmp_avgFuelParentDOE
set AvgPreMonth_Price = ( select avg(afp_price)
						 from averagefuelprice 
						 where #tmp_avgFuelParentDOE.afp_tableid = averagefuelprice.afp_tableid 
						 AND   averagefuelprice.afp_date >= #tmp_maxDate.PrevMonthFirst 
						 AND   averagefuelprice.afp_date <= #tmp_maxDate.PrevMonthLast   )						 
from #tmp_avgFuelParentDOE
left join #tmp_maxDate on (#tmp_maxDate.afp_tableid  = #tmp_avgFuelParentDOE.afp_tableid )		
									
-----------=================================================================================
insert into #tmp_avgFormula(afp_tableid, Parent_tableid, aff_Interval, aff_CycleDay, 
			aff_Formula, aff_effective_day1, aff_effective_day2 )
select Distinct aff_formula_tableid, afp_tableid, aff_Interval, aff_CycleDay, 
			aff_Formula, aff_effective_day1, aff_effective_day2			
                from AvgFuelFormulaCriteria 
                where aff_formula_tableid in ( select distinct      (afp_tableid)     
                                               from averagefuelprice  
                                               where afp_IsFormula = 1 )  
                                               
update #tmp_avgFormula
Set Max_formula_date = ( select MAX(afp_date)
						from averagefuelprice 
						where #tmp_avgFormula.afp_tableid = averagefuelprice.afp_tableid 						
						group by afp_tableid )
						
update #tmp_avgFormula
set afp_id = ( select afp_id 
					  from averagefuelprice 
					  where #tmp_avgFormula.afp_tableid = averagefuelprice.afp_tableid 
					  AND  #tmp_avgFormula.Max_formula_date = averagefuelprice.afp_date )	
					  
update #tmp_avgFormula
set afp_price = ( select afp_price
				from averagefuelprice 
				where #tmp_avgFormula.afp_id = averagefuelprice.afp_id )	
				
update #tmp_avgFormula
set affCycleDayCode = (	select code from labelfile 
						where labeldefinition = 'affCycleDay' 
						and abbr = #tmp_avgFormula.aff_CycleDay
						and #tmp_avgFormula.aff_CycleDay is not null
						and #tmp_avgFormula.aff_CycleDay <> 'UNK')
where #tmp_avgFormula.aff_CycleDay is not null
and #tmp_avgFormula.aff_CycleDay <> 'UNK'				
				
update #tmp_avgFormula
		set NextEffectiveDateShouldBe =  DATEADD(dd, +(affCycleDayCode - 1), #tmp_maxDate.BeginWeekTHIS ) 	
from #tmp_avgFormula		
left join #tmp_maxDate
on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
where aff_Interval ='WKLY' 	
and aff_CycleDay is not null
and aff_CycleDay <> 'UNK'	
			
update #tmp_avgFormula
	set NextEffectiveDateShouldBe = DATEADD(dd, +(affCycleDayCode - 1), #tmp_maxDate.BeginWeekTHIS ) 
from #tmp_avgFormula		
left join #tmp_maxDate
on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
where	aff_Interval in ('BIWKLY')	
and		aff_CycleDay is not null
and		aff_CycleDay <> 'UNK'	
and		DATEADD(dd, +(affCycleDayCode - 1), #tmp_maxDate.BeginWeekTHIS ) >= DATEADD(WW, +2, Max_formula_date)	

update #tmp_avgFormula 
set ccFirstofMonth = dateadd(dd, - (datepart(dd, DATEADD(MM, 1, Max_formula_date) -1 )), DATEADD(MM, 1, Max_formula_date))
where ( aff_Interval in ('MNTH', 'BIMNTH') and aff_effective_day1 is not NULL ) 
Or ( aff_Interval = 'MNTH' And aff_Formula = 'PREMN' )

update #tmp_avgFormula	
set NextEffectiveDateShouldBe = 
	CASE 
		when ( datepart(mm, (dateadd(dd, (aff_effective_day1 -1), ccFirstofMonth))) - datepart(mm, ccFirstofMonth) ) = 0 
			then ( dateadd(dd, (aff_effective_day1 -1), ccFirstofMonth) )
		when ( datepart(mm, (dateadd(dd, (aff_effective_day1 -1), ccFirstofMonth))) - datepart(mm, ccFirstofMonth) ) > 0 	
				then ( dateadd(dd, (-1), dateadd(mm, 1, ccFirstofMonth)) )
	else 	ccFirstofMonth
	end
where  aff_Interval in ('MNTH', 'BIMNTH') and aff_effective_day1 is not NULL

update #tmp_avgFormula 
set NextEffectiveDate_2ShouldBe = 
	CASE 
		when ( datepart(mm, (dateadd(dd, (aff_effective_day2 -1), ccFirstofMonth))) - datepart(mm, ccFirstofMonth) ) = 0 
			then ( dateadd(dd, (aff_effective_day2 -1), ccFirstofMonth) )
		when ( datepart(mm, (dateadd(dd, (aff_effective_day2 -1), ccFirstofMonth))) - datepart(mm, ccFirstofMonth) ) > 0 	
				then ( dateadd(dd, (-1), dateadd(mm, 1, ccFirstofMonth)) )
	else 	ccFirstofMonth
	end
where aff_Interval =  'BIMNTH' and aff_effective_day2 is not NULL	

update #tmp_avgFormula	
set NextEffectiveDateShouldBe = DateAdd(mm, +2, PrevMonthFirst)
from #tmp_avgFormula		
left join #tmp_maxDate
on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid		
where aff_Interval = 'MNTH' And aff_Formula = 'PREMN'
		
update #tmp_avgFormula	
set MinDoeNeededforEffDay1 = 
		(case 
			when datepart(dw, NextEffectiveDateShouldBe) = 1 then 
				case aff_formula
					when 'CURWK' then dateadd(ww, -1, NextEffectiveDateShouldBe)   else dateadd(ww, -2, NextEffectiveDateShouldBe)  end 
			when datepart(dw, NextEffectiveDateShouldBe) > 1 then 
				CASE aff_formula
					when 'CURWK' then dateadd(ww, -1, (dateadd(DD, + 1 , DATEADD(dd, -1 * DatePart(Dw, NextEffectiveDateShouldBe ),NextEffectiveDateShouldBe )))) 
					else dateadd(ww, -2, (dateadd(DD, + 1 , DATEADD(dd, -1 * DatePart(Dw, NextEffectiveDateShouldBe ),NextEffectiveDateShouldBe ))))
			 end 
		end 			
		) 
where NextEffectiveDateShouldBe is not null 
	
update #tmp_avgFormula	
set MinDoeNeededforEffDay2 = 
		(case 
			when datepart(dw, NextEffectiveDate_2ShouldBe) = 1 then 
				case aff_formula
					when 'CURWK' then dateadd(ww, -1, NextEffectiveDate_2ShouldBe)   else dateadd(ww, -2, NextEffectiveDate_2ShouldBe)  end 
			when datepart(dw, NextEffectiveDate_2ShouldBe) > 1 then 
				CASE aff_formula
					when 'CURWK' then dateadd(ww, -1, (dateadd(DD, + 1 , DATEADD(dd, -1 * DatePart(Dw, NextEffectiveDate_2ShouldBe ),NextEffectiveDate_2ShouldBe )))) 
					else dateadd(ww, -2, (dateadd(DD, + 1 , DATEADD(dd, -1 * DatePart(Dw, NextEffectiveDate_2ShouldBe ),NextEffectiveDate_2ShouldBe ))))
			 end 
		end 			
		) 
where NextEffectiveDate_2ShouldBe is not null 
					
------  debug lines.start		
----select * from  #logMessages
--select * from  #tmp_avgFormula
--select * from  #tmp_avgFuelParentDOE
--select * from  #tmp_maxDate	
--return 
------  debug lines.end	
			
IF ( select count(*) from #tmp_avgFormula
		left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
		where ( #tmp_avgFormula.MinDoeNeededforEffDay1 > #tmp_maxDate.ActualMaxDOE )	) > 0   
	begin			
		insert into #logMessages ( txt1, txt2, txt3 , txt4, txt5) 			
		select  'The Minimum Raw/D.O.E. DATE needed for this calculation: (', 
		(select max(AvgFuelFormulaCriteria.aff_formula_name) from AvgFuelFormulaCriteria where aff_formula_tableid = #tmp_avgFormula.afp_tableid),
		(select max(averagefuelprice.afp_description) from averagefuelprice where afp_tableid = #tmp_avgFormula.Parent_tableid),
		' / Effective Date: ' + CONVERT(VARCHAR(10), NextEffectiveDateShouldBe, 101) + ') ' 
				+ ' Needs to be ' + CONVERT(VARCHAR(10), MinDoeNeededforEffDay1, 101) + '. ',
		' Max Available is : ' +  CONVERT(VARCHAR(10),  #tmp_maxDate.ActualMaxDOE , 101)  
		from #tmp_avgFormula
		left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
		where ( #tmp_avgFormula.MinDoeNeededforEffDay1 > #tmp_maxDate.ActualMaxDOE )		
	end 		
		
IF ( select count(*) from #tmp_avgFormula
		left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
		where ( #tmp_avgFormula.MinDoeNeededforEffDay2 > #tmp_maxDate.ActualMaxDOE )	) > 0   
	begin			
		insert into #logMessages ( txt1, txt2, txt3 , txt4, txt5) 			
		select  'The Minimum Raw/D.O.E. DATE needed for this calculation: (', 
		(select max(AvgFuelFormulaCriteria.aff_formula_name) from AvgFuelFormulaCriteria where aff_formula_tableid = #tmp_avgFormula.afp_tableid),
		(select max(averagefuelprice.afp_description) from averagefuelprice where afp_tableid = #tmp_avgFormula.Parent_tableid),
		' / Effective Date: ' + CONVERT(VARCHAR(10), NextEffectiveDate_2ShouldBe, 101) + ') ' 
				+ ' Needs to be ' + CONVERT(VARCHAR(10), MinDoeNeededforEffDay2, 101) + '. ',
		' Max Available is : ' +  CONVERT(VARCHAR(10),  #tmp_maxDate.ActualMaxDOE , 101)  
		from #tmp_avgFormula
		left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
		where ( #tmp_avgFormula.MinDoeNeededforEffDay2 > #tmp_maxDate.ActualMaxDOE )		
	end 

delete from #tmp_avgFormula where tfID in ( select #tmp_avgFormula.tfid from #tmp_avgFormula 
											left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
											where ( #tmp_avgFormula.MinDoeNeededforEffDay1 > #tmp_maxDate.ActualMaxDOE )	
											OR    ( #tmp_avgFormula.MinDoeNeededforEffDay2 > #tmp_maxDate.ActualMaxDOE )	)		


-- IF the 'new' formula's already exist in avgfuel - remove from temp table	
delete from #tmp_avgFormula where tfID in ( select  #tmp_avgFormula.tfid 
											from #tmp_avgFormula 
											left join averagefuelprice on averagefuelprice.afp_tableid = #tmp_avgFormula.afp_tableid
											left join #tmp_maxDate	on		#tmp_avgFormula.Parent_tableid = #tmp_maxDate.afp_tableid	
											where averagefuelprice.afp_tableid = #tmp_avgFormula.afp_tableid  AND 
											averagefuelprice.afp_date = #tmp_avgFormula.NextEffectiveDateShouldBe AND
											averagefuelprice.afp_price = #tmp_avgFormula.afp_price	)
	
IF ( select count(*) from #tmp_avgFormula
	where ( NextEffectiveDateShouldBe is null   OR Max_formula_date >= NextEffectiveDateShouldBe )
		AND ( aff_Interval in (	'WKLY', 'BIWKLY' )	
		and aff_CycleDay is not null
		and aff_CycleDay <> 'UNK'	) ) > 0 
	begin 
			--  if the data already exists, drop it.				
			delete from #tmp_avgFormula 	
			where ( NextEffectiveDateShouldBe is null   OR Max_formula_date >= NextEffectiveDateShouldBe )
			AND ( aff_Interval in (	'WKLY', 'BIWKLY' )	
			and aff_CycleDay is not null
			and aff_CycleDay <> 'UNK'		)
	end 	

declare @tcount int
select @tcount = count(*) from #tmp_avgFormula
insert into #logMessages ( txt1, txt2 ) select 'End Of CustomUpdateAvgFuelFormula' , ':   ' + CAST(@tcount as varchar(6) ) + ' formulas created.'

IF  ( select count(*) from #logMessages ) > 0   
	begin	
		insert into tts_errorlog(err_title, err_batch, err_user_id, err_date, err_type,  err_icon, err_response, err_message, err_sequence)
		select @BatchTitle, @batchNumber, @batchUserid, getdate(), @BatchType, @BatchIcon, @BatchResponse, 
		SUBSTRING(( LTRIM(RTRIM(IsNull(txt1,''))) + LTRIM(RTRIM( IsNull(txt2,'')))+ ':' + LTRIM(RTRIM( IsNull(txt3,''))) 
					+ LTRIM(RTRIM(IsNull(txt4,''))) + ' ' + LTRIM(RTRIM( IsNull(txt5,''))) ) , 1, 253 ),
		msgsequence from #logMessages
	end  

if (select COUNT(*) from #tmp_avgFormula)  <= 0 return

-- PTS 61286  replace select w/ select distinct  4/2/2012
Insert into averagefuelprice(	afp_tableid, 
								afp_date, 
								afp_description, 
								afp_price,  
								afp_IsFormula
								)
select distinct					
								afp_tableid, 
								NextEffectiveDateShouldBe, 
								(select max(averagefuelprice.afp_description) from averagefuelprice where afp_tableid = #tmp_avgFormula.afp_tableid),
								afp_price,
								1
from #tmp_avgFormula
where NextEffectiveDateShouldBe is not null

-- PTS 61286  replace select w/ select distinct  4/2/2012
Insert into averagefuelprice(	afp_tableid, 
								afp_date, 
								afp_description, 
								afp_price,  
								afp_IsFormula
								)
select distinct					
								afp_tableid,  
								NextEffectiveDate_2ShouldBe, 
								(select max(averagefuelprice.afp_description) from averagefuelprice where afp_tableid = #tmp_avgFormula.afp_tableid),
								afp_price,
								1
from #tmp_avgFormula
where aff_interval = 'BIMNTH'
and NextEffectiveDate_2ShouldBe is not null			
				
	
IF OBJECT_ID(N'tempdb.. #logMessages ', N'U') IS NOT NULL 
Drop Table #logMessages

IF OBJECT_ID(N'tempdb.. #tmp_avgFormula ', N'U') IS NOT NULL 
Drop Table #tmp_avgFormula

IF OBJECT_ID(N'tempdb.. #tmp_avgFuelParentDOE', N'U') IS NOT NULL 
Drop Table #tmp_avgFuelParentDOE

IF OBJECT_ID(N'tempdb.. #tmp_maxDate ', N'U') IS NOT NULL 
Drop Table #tmp_maxDate
	
RETURN 	

GO
GRANT EXECUTE ON  [dbo].[CustomUpdateAvgFuelFormulaGeneric_sp] TO [public]
GO
