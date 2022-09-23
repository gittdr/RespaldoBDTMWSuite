SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_checkcall_DriverEmergencyAlerts]
    (
      @Driver_asgn_id VARCHAR(13) ,
      @ckc_lghnumber INTEGER ,
      @checkcall_latitude DECIMAL(12, 4) ,
      @checkcall_Longitude DECIMAL(12, 4) ,
      @ckc_latseconds INT ,
      @ckc_longseconds INT ,
      @NextStop_Number INT ,
      @NextStop_City INT ,
      @NextStop_ArrivalDate DATETIME,
      @cmp_id VARCHAR(8)


    )
AS /*
 * NAME:
 * dbo.sp_checkcall_DriverEmergencyAlerts
 *
 * TYPE:
 * storedprocedure
 *
 * DESCRIPTION:
 * sp Processes Alert Messages for Driver. 

 * RETURNS:
 *
 * RESULT SETS: 
 * 
 
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 10/12/2012	 - PTS64370 - APC - Process Driver Emergency Alerts based on checkcall lat/long within Alert Radius
 **/ 

	DECLARE 
		@COUNTER INT,
		--@minimum_Hours_Since_Last_Duplicate_Msg INT,
		@msgid INT,
		@stopCity VARCHAR(50)


    DECLARE @AlertMessagesforDriver TABLE
        (
		  ID smallint Primary KEY IDENTITY(0,1),        
          AlertID INT NOT NULL ,
          AlertMessages VARCHAR(500)
        )

	-- GREATER THAN (12) HOURS SINCE LAST DUPLICATE MSG WAS SENT
	--SET @minimum_Hours_Since_Last_Duplicate_Msg = 12 

    INSERT  INTO @AlertMessagesforDriver
		EXEC sp_DriverEmergencyAlerts @Driver_asgn_id, @cmp_id, 
			@NextStop_Number, @NextStop_City, @NextStop_ArrivalDate, 
			@checkcall_latitude, @checkcall_Longitude, @ckc_latseconds, 
			@ckc_longseconds

	 
	
			 

/* loop through each record of AlertMessagesForDriver (multiple records will occur if multiple alerts in proximity of checkcall)*/                                						
	--SET @COUNTER = 1;
	SELECT @COUNTER = MIN(ALERTID) from @AlertMessagesforDriver 
	WHILE EXISTS(SELECT ALERTID FROM @AlertMessagesforDriver WHERE ALERTID >= @Counter)
		BEGIN
		
		
		IF ( NOT EXISTS ( SELECT    1
						  FROM      TotalMailDriverEmergencyAlerts t
						  WHERE     --t.Stp_Number = @NextStop_Number
									 t.lgh_number = @ckc_lghnumber
									AND t.asgn_id = @Driver_asgn_id 
									AND t.drv_emergency_alert_id = @COUNTER
									--AND DATEDIFF(HH, TotalMailSentDate, GETDATE()) > @minimum_Hours_Since_Last_Duplicate_Msg
						 )
		   ) 
			BEGIN
				-- Put a Record in total Mail Message Queue				
				INSERT  INTO TMSQLMessage
						( msg_Date ,
						  msg_FormID ,
						  msg_To ,
						  msg_ToType ,
						  msg_FilterData ,
						  msg_FilterDataDupWaitSeconds ,
						  msg_From ,
						  msg_FromType ,
						  msg_Subject
						)
						SELECT  GETDATE() ,
								10 ,
								@Driver_asgn_id ,
								5 ,
								@Driver_asgn_id + convert(varchar(5),@COUNTER) ,
								5 ,
								'Admin' ,
								1 ,
								'EMERGENCY ALERT'
						FROM    @AlertMessagesforDriver
						WHERE	ALERTID = @COUNTER;
				SELECT  @msgid = SCOPE_IDENTITY();


				SELECT  @stopCity = city.cty_nmstct
				FROM    city
				WHERE   city.cty_code = @NextStop_City
				INSERT  INTO TMSQLMessageData
						( msg_ID ,
						  msd_Seq ,
						  msd_FieldName ,
						  msd_FieldValue
						)
				SELECT @msgid,
						1,
						'Field01',
						AlertMessages
						
				FROM    @AlertMessagesforDriver
				WHERE	ALERTID = @COUNTER ;
						 
				/*

				SELECT  @stopCity = city.cty_nmstct
				FROM    city
				WHERE   city.cty_code = @NextStop_City
				INSERT  INTO TMSQLMessageData
						( msg_ID ,
						  msd_Seq ,
						  msd_FieldName ,
						  msd_FieldValue
						)
				VALUES  ( @msgid ,
						  1 ,
						  'Field02' ,
						  'StopCity:' + @stopCity 
						)

*/
					
				INSERT  INTO TotalMailDriverEmergencyAlerts
						( asgn_id ,
						  lgh_number ,
						  Stp_Number ,
						  FriendlyMessage ,
						  TotalMailSentDate ,
						  drv_emergency_alert_id
						)
						SELECT  @Driver_asgn_id ,
								@ckc_lghnumber ,
								@NextStop_Number ,
								AlertMessages ,
								GETDATE(),
								AlertID
						FROM    @AlertMessagesforDriver
						WHERE	ALERTID = @COUNTER ;

			END	
			
			-- INCREMENT COUNTER
			SELECT @COUNTER = MIN(ALERTID) from @AlertMessagesforDriver WHERE ALERTID > 	@COUNTER	
		END




GO
GRANT EXECUTE ON  [dbo].[sp_checkcall_DriverEmergencyAlerts] TO [public]
GO
