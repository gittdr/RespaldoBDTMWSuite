SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_reprocess214s]
		(				
		@stp_number INT	
		)
AS


DECLARE 
	@stp_status varchar(6),
	@stp_type varchar(6),
	@stp_departure_status varchar(6)
	

SELECT  @stp_number = stp_number,  @stp_type = stp_type,  @stp_status = stp_status ,  @stp_departure_status = stp_departure_status
FROM	dbo.stops 	(NOLOCK)
WHERE	(stp_number = @stp_number)

IF (@stp_status = 'DNE') AND (@stp_departure_status = 'DNE')
	BEGIN
			UPDATE dbo.stops 
			SET stp_status = 'OPN', stp_departure_status = 'OPN' 
			WHERE stp_number = @stp_number
			
			UPDATE	dbo.stops
			SET  stp_status = 'DNE', stp_departure_status = 'DNE'
			
			WHERE	stp_number = @stp_number 					
	END	

GO
GRANT EXECUTE ON  [dbo].[sp_reprocess214s] TO [public]
GO
