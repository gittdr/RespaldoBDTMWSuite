SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[SP_UpdateMoveProcessingDriverEmergencyAlerts] ( @MovNumber INT )
AS /*
 * NAME:
 * dbo.SP_UpdateMoveProcessingDriverEmergencyAlerts
 *
 * TYPE:
 * storedprocedure
 *
 * DESCRIPTION:
 * This is a Hook to UpdateMovePostProcessing Stored Proc for DriverEmergencyAlert system

 * RETURNS:
 *
 * RESULT SETS: 
 * 
 
 * REFERENCES:
 * 
 * REVISION HISTORY:
 
 **/ 

    DECLARE @NextStopCity AS INT ,
        @Asgn_id AS VARCHAR(8) ,
        @NextStop_Number AS INT ,
        @nextLghNumber AS INTEGER ,
        @now AS DATETIME,
        @latseconds AS INT,
        @longseconds AS INT,
        @cmp_id as VARCHAR(8)
    SET @now = GETDATE()
    SET @latseconds = 0
    SET @longseconds = 0


	DECLARE @stp_mfh_sequence INT
	SET @stp_mfh_sequence = -1
	
	SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence) from stops (NOLOCK) WHERE mov_number = @MovNumber
	
	WHILE EXISTS (SELECT 1 FROM Stops (NOLOCK) WHERE mov_number = @MovNumber and stp_mfh_sequence >=@stp_mfh_sequence) 
	BEGIN
	select @stp_mfh_sequence
		SELECT TOP 1
				@NextStopCity = stops.stp_city ,
				@NextStop_Number = Stops.stp_number ,
				@nextLghNumber = stops.lgh_number ,
				@Asgn_id = legheader.lgh_driver1 ,
				@now = stops.stp_arrivaldate ,
				@latseconds = company.cmp_latseconds,
				@longseconds = company.cmp_longseconds,
				@cmp_id = company.cmp_id
		FROM    StopS
				INNER JOIN [Event] ON Stops.stp_number = [Event].stp_number
				--INNER JOIN assetassignment ON assetassignment.next_opn_evt_number = [Event].evt_number
				INNER JOIN legheader ON legheader.lgh_number = stops.lgh_number
										--AND assetassignment.next_opn_evt_number <> 0
										--AND assetassignment.asgn_type = 'DRV'
										AND legheader.mov_number = @MovNumber
										AND (legheader.lgh_outstatus = 'STD'
											OR
											legheader.lgh_tm_status IN ('SENT','ACCEPT','ERROR'))
										AND legheader.lgh_outstatus <> 'CMP'
				INNER JOIN company ON stops.cmp_id = company.cmp_id
				
		WHERE stp_mfh_sequence = @stp_mfh_sequence								
		ORDER BY stp_mfh_sequence
			
				
					
		IF ( @NextStopCity > 0
			 AND @Asgn_id <> ''
			 AND @nextLghNumber > 0
			 AND @NextStop_Number > 0
		   ) 
			EXEC sp_checkcall_DriverEmergencyAlerts @Asgn_id, @nextLghNumber, 0.0, 0.0, @latseconds, @longseconds, @NextStop_Number, @NextStopCity, @now, @cmp_id

		
		SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence) from stops (NOLOCK) where mov_number = @MovNumber and stp_mfh_sequence > @stp_mfh_sequence
		
		
		END



GO
GRANT EXECUTE ON  [dbo].[SP_UpdateMoveProcessingDriverEmergencyAlerts] TO [public]
GO
