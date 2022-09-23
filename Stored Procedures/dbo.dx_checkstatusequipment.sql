SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
declare @retcode int
exec @retcode = dx_checkstatusequipment 207164
select @retcode 
*/
CREATE  PROCEDURE [dbo].[dx_checkstatusequipment] (
@mov_number int
)

AS

	DECLARE @ReturnCode int, @AssignedLeg int
	SET @ReturnCode = 0
	
	select @AssignedLeg = isNull(max(lgh_number),0) 
						from legheader where legheader.mov_number = @mov_number
						and legheader.lgh_primary_trailer <> 'UNKNOWN'
	if @AssignedLeg <> 0
		SET @ReturnCode = 1
		
	RETURN @ReturnCode 

GO
GRANT EXECUTE ON  [dbo].[dx_checkstatusequipment] TO [public]
GO
