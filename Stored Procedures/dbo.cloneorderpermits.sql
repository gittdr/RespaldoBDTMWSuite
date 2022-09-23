SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cloneorderpermits](@source_mov_number int, @source_lgh_number int,  @new_mov_number int, @new_lgh_number int)
AS

	INSERT INTO Permit_Requirements 
		(PM_ID,
		 mov_number, 
		 lgh_number, 
		asgn_type,
		PR_Default,
		PR_Escort_Required,
		PR_Escort_Type,
		PR_Escort_Qty)
     	SELECT	PR.PM_ID,
		@new_mov_number,  
		@new_lgh_number,
		PR.asgn_type,
		PR.PR_Default,
		PR.PR_Escort_Required,
		PR.PR_Escort_Type,
		PR.PR_Escort_Qty
	FROM	Permit_Requirements PR
/*JLB PTS 31037 do not copy system generated permits they will be recreated in update_mov
	WHERE (PR.lgh_number = @source_lgh_number) OR
		((PR.mov_number = @source_mov_number) AND (@source_lgh_number IS NULL))
*/
	WHERE (isnull(PR.PR_Default, 'N') <> 'Y')
     AND (PR.lgh_number = @source_lgh_number) OR ((PR.mov_number = @source_mov_number) AND (@source_lgh_number IS NULL))
		

GO
GRANT EXECUTE ON  [dbo].[cloneorderpermits] TO [public]
GO
