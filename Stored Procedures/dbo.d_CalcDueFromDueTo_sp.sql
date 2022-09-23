SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Procedure [dbo].[d_CalcDueFromDueTo_sp] (@type CHAR(6), @id CHAR(13), @paydate DATETIME)
AS

Set NoCount On

/* Revision History:
	Date		Name		Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------
	
	4/2012	JSwindell	PTS 60458   Created.	pulled code out of PB (f_Calc_exchangechecks) so can adjust as needed without PB mods.	
			Input asset type, asset id, payperiod
			result set out = data from #tmpDueFromTo to populate dwo.
			--	Client Rules for WHEN Exchange check Deduction/ Reimbursement Adjustments are created.
			--	if sum_pyd_amount for each legal entity is >= 0; do nothing
			--	if sum_pyd_amount for each legal entity is <= 0; do nothing
			--  if sum_pyd_amount for some legal entities is < 0 and some > 0, run the process
			--	until we achieve a zero dollar amount on negative rows, a positive dollar amount on negative rows 
			--	or until we run out of data to draw from.
	5/25/2012	PTS 60458_QA_Fix:  Corrected script for a certain data scenario that did not produce correct results. 
	8/21/2012	Tweaks resulting from Client testing. ( falls under PTS 64302 )	
	1/2/2013	PTS 66293: { condition not accounted for }
	1/21/2013   PTS 66293-2: QA identified proc issue
	1/29/2013	PTS 66293-3: data conditon caused loop issue
	2/1/2013	PTS 66293-4: above cng introduced new bug.
*/


declare @GrandTotal money 
declare @CntNegRows int
declare @CntPosRows int
declare @CntLglEntity int		--64302
declare @idxGreatest int
declare @idxLeast	 int
declare @MaxAmt		money
declare @MinAmt		money
declare @wrkvalue	money
declare @wrkphF		int
declare @wrkpht		int
declare	@wrkLglF	varchar(12)
declare	@wrkLglT	varchar(12)
declare @loopcnt	int
---------------------------------  PTS 60458_QA_Fix.start
declare @SumPOSAmt		money
declare @SumNEGAmt		money
declare @Diff_OF_Sums	money
---------------------------------	PTS 60458_QA_Fix.end
declare	@pydPlaceHolder	int
set @pydPlaceHolder = 0
set @CntLglEntity = 0			--64302

Create Table #tmpPHLglEnt (tmpid_1 int identity(1,1) not null, PH int null,  LglEntity varchar(12) null, Sum_pyd_amount money null, WorkingTotal money null )

Create Table #tmpDueFromTo (tmpid_2 int identity(1,1) not null, 
							PHFrom int null,  
							PHTo int null,  
							LglEntDueFrom varchar(12) null, 
							AmtdueFrom money null, 
							LglEntDueTo varchar(12) null,
							AmtdueTo money null,
							BranchFrom varchar(12) null,
							BranchTo varchar(12) null,
							lgh_From int null,
							lgh_To int null
							)

-- ignore any PH's with zero sums
Insert #tmpPHLglEnt ( PH, Sum_pyd_amount, WorkingTotal )
select pd.pyh_number, SUM(pd.pyd_amount), SUM(pd.pyd_amount)
from paydetail pd 
where pd.asgn_type = @type and pd.asgn_id = @id and pd.pyh_payperiod = @paydate 
group by pd.pyh_number
having SUM(pd.pyd_amount) <> 0
order by SUM(pd.pyd_amount) desc

update #tmpPHLglEnt  set LglEntity = (select min(phpcL_childLglEntity) from ph_parent_child_lglentity where #tmpPHLglEnt.ph = phpcL_childPH )

select @CntLglEntity = count(*) from #tmpPHLglEnt		--64302
select @GrandTotal = SUM(Sum_pyd_amount) from #tmpPHLglEnt
set @CntNegRows = (select count(Sum_pyd_amount) from #tmpPHLglEnt where Sum_pyd_amount < 0 )
set @CntPosRows = (select count(Sum_pyd_amount) from #tmpPHLglEnt where Sum_pyd_amount > 0 )

-- PTS 66293-2: QA identified proc issue
IF (  select count(*) from #tmpPHLglEnt )  = 1
BEGIN
	if ( select count(*) from #tmpDueFromTo )  <= 0 
	begin
		Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo, BranchFrom, BranchTo, lgh_From, lgh_To)
		select 0, 'N/A' ,0, 0, 'N/A' ,0, 'N/A', 'N/A', 0, 0
	end			
		select PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo, 
		BranchFrom, BranchTo, lgh_From, lgh_To, 
		@pydPlaceHolder 'pydFrom', @pydPlaceHolder 'pydTo' 
		FROM #tmpDueFromTo
	RETURN
END

set @loopcnt = 1
while @CntNegRows > 0
begin

IF @loopcnt > 	( ( select count(*) from #tmpPHLglEnt ) * 2 )  BREAK

	set @CntNegRows		= (select count(Sum_pyd_amount) from #tmpPHLglEnt where WorkingTotal < 0 )	
	set @idxGreatest	= (select Min(tmpid_1) from #tmpPHLglEnt where WorkingTotal = (select MAX(WorkingTotal) from #tmpPHLglEnt where WorkingTotal > 0 ) )
	set @idxLeast		= (select Min(tmpid_1) from #tmpPHLglEnt where WorkingTotal = (select MIN(WorkingTotal) from #tmpPHLglEnt where WorkingTotal < 0 ) )
		 	
	If ( @CntNegRows <= 0 or @idxGreatest <= 0 or @idxLeast <= 0  ) 
		begin
			set @CntNegRows = 0
			break
		end 
		
		select @MaxAmt =  WorkingTotal from #tmpPHLglEnt where tmpid_1 = @idxGreatest		-- these are for debug for a minute.
		select @MinAmt =  WorkingTotal from #tmpPHLglEnt where tmpid_1 = @idxLeast			-- these are for debug for a minute.
		set @wrkvalue = (select WorkingTotal from #tmpPHLglEnt where tmpid_1 = @idxGreatest) + (select WorkingTotal from #tmpPHLglEnt where tmpid_1 = @idxLeast)
		
		--set @SumPOSAmt = ( select SUM(t1.Sum_pyd_amount) from #tmpPHLglEnt as t1 where t1.Sum_pyd_amount > 0 ) --PTS 60458_QA_Fix
		--set @SumNEGAmt = ( select SUM(t2.Sum_pyd_amount) from #tmpPHLglEnt as t2 where t2.Sum_pyd_amount < 0 ) --PTS 60458_QA_Fix
		
		set @SumPOSAmt = ( select SUM(t1.Sum_pyd_amount) from #tmpPHLglEnt as t1 where t1.Sum_pyd_amount > 0  and WorkingTotal <> 0 ) --PTS 66293-4
		set @SumNEGAmt = ( select SUM(t2.Sum_pyd_amount) from #tmpPHLglEnt as t2 where t2.Sum_pyd_amount < 0  and WorkingTotal <> 0 ) --PTS 66293-4
		
		set @Diff_OF_Sums = @SumPOSAmt + @SumNEGAmt															   --PTS 60458_QA_Fix
		
		--PTS 60458_QA_Fix  change if condition.
		--if ( @wrkvalue < 0 ) 		
		if ( @wrkvalue < 0 And @Diff_OF_Sums <= 0 ) 
		begin		
		
			-- PTS66293-2.start
			
			if @CntPosRows = 1 and @CntNegRows = 1 
			begin 				
				IF ABS(@MinAmt)  >=  ABS(@MaxAmt) 
				begin
					set @wrkvalue = ( @MaxAmt * -1 ) 
					select @wrkphF	=	PH from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkLglF =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkphT	=	PH from #tmpPHLglEnt where tmpid_1 = @idxLeast
					select @wrkLglT =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxLeast
					Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo)			
					select @wrkphF, @wrkLglF, ( @MaxAmt * -1  ) , @wrkphT, @wrkLglT, ( @MaxAmt   )  
					set @CntNegRows = 0
					break									
				end			
			end 			
			-- PTS66293-2.end
		
			-- PTS66293
			IF @CntNegRows = 1 AND ( @wrkvalue  = @Diff_OF_Sums ) 
				Begin				
					select @wrkphF	=	PH from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkLglF =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkphT	=	PH from #tmpPHLglEnt where tmpid_1 = @idxLeast
					select @wrkLglT =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxLeast				
					Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo)			
					select @wrkphF, @wrkLglF, ( @Diff_OF_Sums * -1  ) , @wrkphT, @wrkLglT, ( @Diff_OF_Sums  )  
					set @CntNegRows = 0	-- PTS66293-2
					break				-- PTS66293-2				
				END
		
			-- original script got out here
			--set @CntNegRows = 0		-- PTS66293-2
			--break						-- PTS66293-2
			
			-- PTS66293-2.start
			IF @CntNegRows >= 1 AND ( @wrkvalue  <> @Diff_OF_Sums ) 
			 begin				
					select @wrkphF	=	PH from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkLglF =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxGreatest
					select @wrkphT	=	PH from #tmpPHLglEnt where tmpid_1 = @idxLeast
					select @wrkLglT =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxLeast	
			
					Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo)					
					select @wrkphF, @wrkLglF, ( @MaxAmt * -1  ) , @wrkphT, @wrkLglT, ( @MaxAmt  )  
				
					update #tmpPHLglEnt set WorkingTotal =  @wrkvalue  where tmpid_1 = @idxLeast
					update #tmpPHLglEnt set WorkingTotal = ( WorkingTotal + ( @MaxAmt * -1 ) )  where tmpid_1 = @idxGreatest
			 end 
			-- PTS66293-2.end
			
		end 
		
		-- original calc (#1)		
		if @wrkvalue >= 0 
		begin
			select @wrkphF	=	PH from #tmpPHLglEnt where tmpid_1 = @idxGreatest
			select @wrkLglF =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxGreatest
			select @wrkphT	=	PH from #tmpPHLglEnt where tmpid_1 = @idxLeast
			select @wrkLglT =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxLeast
			
			Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo)
			select @wrkphF, @wrkLglF, ( @MinAmt  ) , @wrkphT, @wrkLglT, ( @MinAmt * -1 ) 
			
			--PTS 60458_QA_Fix  change update
			update #tmpPHLglEnt set WorkingTotal =  @wrkvalue  where tmpid_1 = @idxGreatest
			update #tmpPHLglEnt set WorkingTotal = ( WorkingTotal + ( @MinAmt * -1 ) )  where tmpid_1 = @idxLeast
			
			--update #tmpPHLglEnt set WorkingTotal = ( WorkingTotal + ( @wrkvalue * -1 ) )  where tmpid_1 = @idxGreatest
			--update #tmpPHLglEnt set WorkingTotal = ( WorkingTotal + ( @MinAmt * -1 ) )  where tmpid_1 = @idxLeast
		end
		
		-- new calc (#2)
		--PTS 60458_QA_Fix  add additional begin/end condition
		if @wrkvalue < 0 And @Diff_OF_Sums > 0
		begin		
		
			select @wrkphF	=	PH from #tmpPHLglEnt where tmpid_1 = @idxGreatest
			select @wrkLglF =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxGreatest
			select @wrkphT	=	PH from #tmpPHLglEnt where tmpid_1 = @idxLeast
			select @wrkLglT =	LglEntity from #tmpPHLglEnt where tmpid_1 = @idxLeast	
		
			Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo)
			--select @wrkphF, @wrkLglF, ( @MaxAmt  ) , @wrkphT, @wrkLglT, ( @MaxAmt * -1 )
			select @wrkphF, @wrkLglF, ( @MaxAmt * -1  ) , @wrkphT, @wrkLglT, ( @MaxAmt  )  
			
			update #tmpPHLglEnt set WorkingTotal =  @wrkvalue  where tmpid_1 = @idxLeast
			update #tmpPHLglEnt set WorkingTotal = ( WorkingTotal + ( @MaxAmt * -1 ) )  where tmpid_1 = @idxGreatest
		
		end 
	
set @loopcnt = @loopcnt + 1				
end 

If ( select count(*) from #tmpDueFromTo )  > 0
	Begin
		update #tmpDueFromTo  
		set BranchFrom = (select min(phpcb_childBranch) 
						  from ph_parent_child_branch
						  where #tmpDueFromTo.PHFrom = phpcb_childPH )
		update #tmpDueFromTo  
		set BranchTo = (select min(phpcb_childBranch) 
						  from ph_parent_child_branch
						  where #tmpDueFromTo.PHTo = phpcb_childPH )
						  
		update #tmpDueFromTo				  
		set lgh_From = ( select min(lgh_number)
							from paydetail 
							where paydetail.lgh_number > 0 
							and #tmpDueFromTo.PHFrom = paydetail.pyh_number
							group by pyh_number )
		update #tmpDueFromTo				  
		set lgh_To = ( select min(lgh_number)
							from paydetail 
							where paydetail.lgh_number > 0 
							and #tmpDueFromTo.PHTo = paydetail.pyh_number
							group by pyh_number )	
						  	
	End 	  

if ( select count(*) from #tmpDueFromTo )  <= 0 
begin
	Insert Into #tmpDueFromTo(PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo, BranchFrom, BranchTo, lgh_From, lgh_To)
	select 0, 'N/A' ,0, 0, 'N/A' ,0, 'N/A', 'N/A', 0, 0
end

select PHFrom, LglEntDueFrom, AmtdueFrom, PHTo, LglEntDueTo, AmtdueTo, 
BranchFrom, BranchTo, lgh_From, lgh_To, 
@pydPlaceHolder 'pydFrom', @pydPlaceHolder 'pydTo' 
FROM #tmpDueFromTo

IF OBJECT_ID(N'tempdb..#tmpPHLglEnt', N'U') IS NOT NULL 
DROP TABLE #tmpPHLglEnt
IF OBJECT_ID(N'tempdb..#tmpDueFromTo', N'U') IS NOT NULL 
DROP TABLE #tmpDueFromTo



GO
GRANT EXECUTE ON  [dbo].[d_CalcDueFromDueTo_sp] TO [public]
GO
