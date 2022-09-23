SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_MULTI_PH_Branch_LglEntity](@paydate	datetime,	@asgn_type 	varchar(6),	@asgn_id 	varchar(12), @RetrieveBy varchar(30))
AS

Set NoCount On

/* Revision History:
	Date		Name			Label		Description
	-----------	---------------	-------		---------------------------------	
	4/17/2012	JSwindell		PTS60458	Created.
				@RetrieveBy		(fyi:  data can be updated in dwo only when retrieved by NORMAL, else, ReadOnly.
				@RetrieveBy		brn_id or pto_id, or legal_entity or 'normal' [default] {by asgn_type+asgn_id}
				paydate is required ALWAYS.		
				legal_entity 					
*/

If @RetrieveBy is null set @RetrieveBy = 'normal'	
declare @mov_number int 
declare @ord_hdrnumber int
declare @lgh_number int
set @mov_number = 0
set @ord_hdrnumber = 0
set @lgh_number = 0

--If @RetrieveBy = 'normal'	
--	Begin	

select Distinct pyh_pyhnumber, 
						pyh_payto, 
						asgn_type, asgn_id,
						phpcL_childLglEntity, 
						phpcb_childBranch, 
						--payto.brn_id, 
						phpcb_childBranch as 'brn_id', 
						payto.pto_type1,
						isnull(branch.brn_name, 'NameNotFound') as 'brn_name', 
						phpcL_childLglEntity as  'brn_legalentity',
						--isnull(branch.brn_legalentity, 'NotFnd') as 'brn_legalentity',					
						IsNull(legal_entity.le_name,'NameNotFound') as 'le_name',
						@mov_number as 'mov_number',
						@ord_hdrnumber as 'ord_hdrnumber',
						@lgh_number as 'lgh_number',
						@RetrieveBy as 'RetrieveBy'
		from payheader
					 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
					 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
					 left join  payto on payheader.pyh_payto = payto.pto_id
					 left join branch on phpcb_childBranch = branch.brn_id
					 left join legal_entity on phpcL_childLglEntity = legal_entity.le_id
		where					asgn_type = @asgn_type 
					 and		asgn_id = @asgn_id  
					 and		pyh_pyhnumber > 0
					 and		pyh_payperiod = @paydate
					 order by pyh_pyhnumber
		Return



--select Distinct pyh_pyhnumber, 
--						pyh_payto, 
--						asgn_type, asgn_id,
--						phpcL_childLglEntity, 
--						phpcb_childBranch, 
--						--payto.brn_id, 
--						phpcb_childBranch as 'brn_id', 
--						payto.pto_type1,
--						isnull(branch.brn_name, 'NameNotFound') as 'brn_name', 
--						phpcL_childLglEntity as  'brn_legalentity',
--						--isnull(branch.brn_legalentity, 'NotFnd') as 'brn_legalentity',					
--						IsNull(legal_entity.le_name,'NameNotFound') as 'le_name',
--						@mov_number as 'mov_number',
--						@ord_hdrnumber as 'ord_hdrnumber',
--						@lgh_number as 'lgh_number',
--						@RetrieveBy as 'RetrieveBy'
--		from payheader
--					 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
--					 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
--					 left join  payto on payheader.pyh_payto = payto.pto_id
--					 left join branch on phpcb_childBranch = branch.brn_id
--					 left join legal_entity on phpcL_childLglEntity = legal_entity.le_id
--		where					asgn_type = @asgn_type 
--					 and		asgn_id = @asgn_id  
--					 and		pyh_pyhnumber > 0
--					 and		pyh_payperiod = @paydate
--					 order by pyh_pyhnumber
--		Return


		--select Distinct pyh_pyhnumber, pyh_payto, 
		--				asgn_type, asgn_id,
		--				phpcL_childLglEntity, 
		--				phpcb_childBranch, 
		--				payto.brn_id, payto.pto_type1,
		--				branch.brn_name, branch.brn_legalentity, 
		--				legal_entity.le_name,
		--				@mov_number as 'mov_number',
		--				@ord_hdrnumber as 'ord_hdrnumber',
		--				@lgh_number as 'lgh_number',
		--				@RetrieveBy as 'RetrieveBy'
		--from payheader
		--			 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
		--			 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
		--			 left join  payto on payheader.pyh_payto = payto.pto_id
		--			 left join branch on payto.brn_id = branch.brn_id
		--			 left join legal_entity on branch.brn_legalentity = legal_entity.le_id
		--where					asgn_type = @asgn_type 
		--			 and		asgn_id = @asgn_id  
		--			 and		pyh_pyhnumber > 0
		--			 and		pyh_payperiod = @paydate	
		--order by pyh_pyhnumber
		--Return
	--End
	
-- If @RetrieveBy = 'legal_entity'	
--	Begin	
--		select Distinct pyh_pyhnumber, pyh_payto,
--						asgn_type, asgn_id, 
--						phpcL_childLglEntity, 
--						phpcb_childBranch, 
--						payto.brn_id, payto.pto_type1,
--						branch.brn_name, branch.brn_legalentity, 
--						legal_entity.le_name,
--						@mov_number as 'mov_number',
--						@ord_hdrnumber as 'ord_hdrnumber',
--						@lgh_number as 'lgh_number',
--						@RetrieveBy as 'RetrieveBy'
--		from payheader
--					 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
--					 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
--					 left join  payto on payheader.pyh_payto = payto.pto_id
--					 left join branch on payto.brn_id = branch.brn_id
--					 left join legal_entity on branch.brn_legalentity = legal_entity.le_id
--		where					branch.brn_legalentity = @asgn_type 					
--					 and		phpcL_childLglEntity	 = @asgn_type 
--					 and		pyh_pyhnumber > 0
--					 and		pyh_payperiod = @paydate	
--		order by pyh_pyhnumber
--		Return
--	End
	
--If @RetrieveBy = 'brn_id'
--	Begin	
--		select Distinct pyh_pyhnumber, pyh_payto, 
--						asgn_type, asgn_id,
--						phpcL_childLglEntity, 
--						phpcb_childBranch, 
--						payto.brn_id, payto.pto_type1,
--						branch.brn_name, branch.brn_legalentity, 
--						legal_entity.le_name,
--						@mov_number as 'mov_number',
--						@ord_hdrnumber as 'ord_hdrnumber',
--						@lgh_number as 'lgh_number',
--						@RetrieveBy as 'RetrieveBy'
--		from payheader
--					 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
--					 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
--					 left join  payto on payheader.pyh_payto = payto.pto_id
--					 left join branch on payto.brn_id = branch.brn_id
--					 left join legal_entity on branch.brn_legalentity = legal_entity.le_id
--		where					branch.brn_legalentity = @asgn_type 					
--					 and		branch.brn_id = @asgn_id
--					 and		pyh_pyhnumber > 0
--					 and		pyh_payperiod = @paydate	
--		order by pyh_pyhnumber
--		Return
--	End
	
--If @RetrieveBy = 'pto_id'
--	Begin	
--		select Distinct pyh_pyhnumber, pyh_payto, 
--						asgn_type, asgn_id,
--						phpcL_childLglEntity, 
--						phpcb_childBranch, 
--						payto.brn_id, payto.pto_type1,
--						branch.brn_name, branch.brn_legalentity, 
--						legal_entity.le_name,
--						@mov_number as 'mov_number',
--						@ord_hdrnumber as 'ord_hdrnumber',
--						@lgh_number as 'lgh_number',
--						@RetrieveBy as 'RetrieveBy'
--		from payheader
--					 left join  ph_parent_child_lglentity on pyh_pyhnumber = phpcL_childPH
--					 left join  ph_parent_child_branch on pyh_pyhnumber = phpcb_childPH
--					 left join  payto on payheader.pyh_payto = payto.pto_id
--					 left join branch on payto.brn_id = branch.brn_id
--					 left join legal_entity on branch.brn_legalentity = legal_entity.le_id
--		where					branch.brn_legalentity = @asgn_type 					
--					 And		payto.pto_id = @asgn_id
--					 and		pyh_pyhnumber > 0
--					 and		pyh_payperiod = @paydate	
--		order by pyh_pyhnumber
--		Return
--	End

GO
GRANT EXECUTE ON  [dbo].[d_MULTI_PH_Branch_LglEntity] TO [public]
GO
