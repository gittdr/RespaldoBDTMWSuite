SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
declare @retcode int
exec @retcode = dx_checkstatusassignments 204910
select @retcode 
*/
CREATE  PROCEDURE [dbo].[dx_checkstatusassignments] (
@mov_number int
)

AS

	DECLARE @ReturnCode int, @AssignStop int
	SET @ReturnCode = 0
	
	select @AssignStop = isNull(max(stp_mfh_sequence),0) from stops 
						left join legheader on stops.lgh_number = legheader.lgh_number 
						left join carrier on lgh_carrier = car_id
				where stops.mov_Number = @mov_number and IsNull(lgh_carrier, 'UNKNOWN') <> 'UNKNOWN' and car_type1 <> 'RAL'

	if @AssignStop <> 0
		SET @ReturnCode = 1
		
	RETURN @ReturnCode 

GO
GRANT EXECUTE ON  [dbo].[dx_checkstatusassignments] TO [public]
GO
