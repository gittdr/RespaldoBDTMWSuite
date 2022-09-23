SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
declare @retcode int
exec @retcode = dx_checkcustomsactivity 204910, 'CBR' 
select @retcode 
*/
CREATE  PROCEDURE [dbo].[dx_checkcustomsactivity] (
@mov_number int,
@status varchar(3),
@bondlocation varchar(50)
)

AS

	DECLARE @ReturnCode int, @maxBondSeq int, @maxDoneSeq int
	SET @ReturnCode = 0
	
	if @status = 'CBR'
		begin
		declare @cmp_id varchar(8)
		exec dx_findbondstop @mov_number, @bondlocation, @cmp_id output
		select @maxBondSeq = isNull(max(stp_mfh_sequence),0) from stops 
						where stops.mov_Number = @mov_number and cmp_id = @cmp_id 
		end
	else
		set @maxBondSeq = 0

	select @maxDoneSeq = isNull(max(stp_mfh_sequence),0) from stops 
						where stops.mov_Number = @mov_number and stp_status = 'DNE'

	if @maxDoneSeq > @maxBondSeq 
		SET @ReturnCode = 1
		
	RETURN @ReturnCode 

GO
GRANT EXECUTE ON  [dbo].[dx_checkcustomsactivity] TO [public]
GO
