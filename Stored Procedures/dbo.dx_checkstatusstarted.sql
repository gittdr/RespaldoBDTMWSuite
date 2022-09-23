SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
declare @retcode int
exec @retcode = dx_checkstatusstarted 204910
select @retcode 
*/
CREATE  PROCEDURE [dbo].[dx_checkstatusstarted] (
@mov_number int
)

AS

	DECLARE @ReturnCode int, @StopStarted int
	SET @ReturnCode = 0
	
	select @StopStarted = isNull(max(stp_mfh_sequence),0) from stops 
			where stops.mov_Number = @mov_number and IsNull(stp_status, 'OPN') = 'DNE' 

	if @StopStarted <> 0
		SET @ReturnCode = 1
		
	RETURN @ReturnCode 

GO
GRANT EXECUTE ON  [dbo].[dx_checkstatusstarted] TO [public]
GO
