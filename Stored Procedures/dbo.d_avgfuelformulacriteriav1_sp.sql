SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[d_avgfuelformulacriteriav1_sp] 
AS

Set NoCount On

/* Revision History:
	Date		Name		Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------
	
	07/10/2014	JSwindell	PTS 66086   Proc Created for new dwo of same name;  
				AvgFuelFormulaCriteria has 2 new columns: aff_BackFillCreated, afp_CalcPriceUsingDOW 
	
*/
			
declare @columnProtect int	
set @columnProtect = 1	
			   
Declare @tmp_avgfuelFormula TABLE (	TmpIdent				INT         IDENTITY
									,aff_id					int				NULL
								   ,afp_tableid				varchar(8)		NULL
								   ,afp_Description			varchar(30)		NULL
								   ,aff_formula_tableid		varchar(8)		NULL
								   ,aff_Interval			varchar(8)		NULL
								   ,aff_CycleDay			varchar(8)		NULL
								   ,aff_Formula				varchar(8)		NULL
								   ,aff_formula_Acronym		varchar(12)		NULL
								   ,aff_formula_Name		varchar(50)		NULL
								   ,aff_effective_day1		int				NULL
								   ,aff_effective_day2		int				NULL
								   ,last_updateby			varchar(255)	NULL
								   ,last_updatedate			datetime		NULL
								   ,aff_effective_dt		datetime		NULL
								   ,ViewBillingTariff		Int				NULL
								   ,ViewSettlementTariff	Int				NULL
								   ,CountBillingTariff		Int				NULL
								   ,CountSettlementTariff	Int				NULL
								   ,Formula_Count			int				NULL
								   ,StringBillTar			varchar(10)		NULL
								   ,StringStlTar			varchar(10)		NULL
								   ,DOEBillingTariff		Int				NULL
								   ,DOESettlementTariff		Int				NULL
								   ,DOECntBillingTariff		Int				NULL
								   ,DOECntSettlementTariff	Int				NULL
								   ,DOEStringBillTar		varchar(10)		NULL
								   ,DOEStringStlTar			varchar(10)		NULL
								    ,Hx_Count				int				NULL
								    ,UI_Visible				int				NULL
								    ,aff_BackFillCreated	int				NULL
								    ,afp_CalcPriceUsingDOW	int				NULL
								   )

INSERT @tmp_avgfuelFormula( aff_id
							,afp_tableid						
							,afp_Description					
							,aff_formula_tableid				
							,aff_Interval					
							,aff_CycleDay					
							,aff_Formula						
							,aff_formula_Acronym				
							,aff_formula_Name				
							,aff_effective_day1						
							,aff_effective_day2						
							,last_updateby				
							,last_updatedate					
							,aff_effective_dt
							,ViewBillingTariff
							,ViewSettlementTariff
							,CountBillingTariff
							,CountSettlementTariff
							,Formula_Count
							,DOEBillingTariff		
							,DOESettlementTariff		
							,DOECntBillingTariff		
							,DOECntSettlementTariff	
							,Hx_Count
							,UI_Visible	
							,aff_BackFillCreated																--PTS66086	
							,afp_CalcPriceUsingDOW																--PTS66086
							)	
SELECT 						aff_id,
							afp_tableid,   
							afp_Description,   
							aff_formula_tableid,   
							aff_Interval,   
							aff_CycleDay,   
							aff_Formula,   
							aff_formula_Acronym,   
							aff_formula_Name,   
							aff_effective_day1,   
							aff_effective_day2,   	
							last_updateby,   
							last_updatedate,
							aff_effective_dt,
							(select top 1 tariffkey.tar_number from tariffkey 
								where AvgFuelFormulaCriteria.aff_formula_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheader)),		--ViewBillingTariff								
							(select top 1 tariffkey.tar_number from tariffkey 
								where AvgFuelFormulaCriteria.aff_formula_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheaderstl)),   --ViewSettlementTariff							
							(select count(tariffkey.tar_number) from tariffkey 							
								where AvgFuelFormulaCriteria.aff_formula_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheader)),		--CountBillingTariff							
							(select count(tariffkey.tar_number) from tariffkey 
								where AvgFuelFormulaCriteria.aff_formula_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheaderstl)),	--CountSettlementTariff							
							
							(select count(averagefuelprice.afp_tableid)				
								from averagefuelprice 
								where AvgFuelFormulaCriteria.aff_formula_tableid = averagefuelprice.afp_tableid 
								and   averagefuelprice.afp_Description = 
								(AvgFuelFormulaCriteria.afp_Description + ': ' 
									+ AvgFuelFormulaCriteria.aff_formula_Acronym ) ),							--Formula_Count
							
							(select top 1 tariffkey.tar_number from tariffkey 
								where AvgFuelFormulaCriteria.afp_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheader)),		--DOEBillingTariff (View)	
							(select top 1 tariffkey.tar_number from tariffkey 
								where AvgFuelFormulaCriteria.afp_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheaderstl)),   --DOESettlementTariff (View)	
							(select count(distinct(tariffkey.tar_number)) from tariffkey 							
								where AvgFuelFormulaCriteria.afp_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheader)),		--DOECntBillingTariff							
							(select count(distinct(tariffkey.tar_number)) from tariffkey 
								where AvgFuelFormulaCriteria.afp_tableid = tariffkey.trk_fueltableid and
								tariffkey.tar_number in (select distinct(tar_number) from tariffheaderstl)),	--DOECntSettlementTariff
									
							(select count(averagefuelprice.afp_tableid)				
								from averagefuelprice 
								where AvgFuelFormulaCriteria.aff_formula_tableid = averagefuelprice.afp_tableid 
								and   averagefuelprice.afp_Description = 
								( AvgFuelFormulaCriteria.afp_Description + ': ' + AvgFuelFormulaCriteria.aff_formula_Acronym )
								and averagefuelprice.afp_date >= cast(convert(varchar(12), AvgFuelFormulaCriteria.aff_effective_dt,  101) as datetime )
								and afp_date < cast(convert(varchar(12), last_updatedate,  101) as datetime )		)
																												--Hx_Count PTS68003	
																																	 
							,0																					--UI_Visible
							,IsNull(aff_BackFillCreated,0)'aff_BackFillCreated'									--PTS66086;  0 = not, 1 = done	
							,IsNull(afp_CalcPriceUsingDOW,9) 'afp_CalcPriceUsingDOW'							--PTS66086;  9 = 'UNK'
									
				FROM 	AvgFuelFormulaCriteria 
				order by afp_Description, aff_Interval, aff_CycleDay, aff_Formula	
				
	--where afp_tableid = @ls_tableid			
	
Update @tmp_avgfuelFormula set	StringBillTar = Case 
			when   CountBillingTariff > 1 then 'Multi(' + LTrim(RTrim(CAST(CountBillingTariff as varchar(4) ))) + ')' 
			else Cast(ViewBillingTariff as Varchar(10) ) end
			
Update @tmp_avgfuelFormula set	StringStlTar  = Case 
when   CountSettlementTariff > 1 then 'Multi(' + LTrim(RTrim(CAST(CountSettlementTariff as varchar(4) ))) + ')' 
else Cast(ViewSettlementTariff as Varchar(10) ) end

Update @tmp_avgfuelFormula set	DOEStringBillTar = Case 
when   DOECntBillingTariff > 1 then 'Multi(' + LTrim(RTrim(CAST(DOECntBillingTariff as varchar(4) ))) + ')'  
else Cast(DOEBillingTariff as Varchar(10) ) end

Update @tmp_avgfuelFormula set	DOEStringStlTar  = Case 
when   DOECntSettlementTariff > 1 then 'Multi(' + LTrim(RTrim(CAST(DOECntSettlementTariff as varchar(4) ))) + ')'  
else Cast(DOESettlementTariff as Varchar(10) ) end

select afp_Description , Min(TmpIdent) 'TmpIdent'
into #ttemp
from @tmp_avgfuelFormula 
group by afp_Description 

Update @tmp_avgfuelFormula set UI_Visible = TmpIdent where TmpIdent in (select #ttemp.TmpIdent from  #ttemp ) 


-- 68003 05/24/2013; include ccbackfill ~ bool 0 = no, not ok.
--					 and	 ccbackfillckbox ckbox avail to user only if = 1. 
	

select		 aff_id					
			,afp_tableid
			,afp_Description
			,aff_formula_tableid
			,aff_Interval
			,aff_CycleDay
			,aff_Formula
			,aff_formula_Acronym
			,aff_formula_Name
			,aff_effective_day1
			,aff_effective_day2
			,last_updateby
			,last_updatedate
			,aff_effective_dt
			,StringBillTar as 'ViewBillingTariff'
			,StringStlTar  as 'ViewSettlementTariff'		
			,Formula_Count
			,DOEStringBillTar	as 'DOEBillingTariff'
			,DOEStringStlTar	as 'DOEStlmntTariff'
			,Hx_Count																				--Hx_Count PTS68003
				,Case When ( Formula_Count <= 0  OR IsNull(aff_BackFillCreated,0) = 1  ) then 0		-- 0 means NOT OK to backfill; 1 means OK to backfill.	
				else 1														
				End 'BackfillOK'				 													--ccbackfillOK PTS68003
			,cast( 0 as int) 'Backfillckbox'														--ccbackfillckbox PTS68003
			,CountBillingTariff
			,CountSettlementTariff			
			,UI_Visible	
			,@columnProtect as 'BillTarProtect'						-- init all these to 1 ==> protected
			,@columnProtect as 'StlTarProtect'	
			,@columnProtect as 'BillParentTarProtect'	
			,@columnProtect as 'StlParentTarProtect'
			,aff_BackFillCreated									--PTS66086	
			,afp_CalcPriceUsingDOW									--PTS66086			
from @tmp_avgfuelFormula


GO
GRANT EXECUTE ON  [dbo].[d_avgfuelformulacriteriav1_sp] TO [public]
GO
