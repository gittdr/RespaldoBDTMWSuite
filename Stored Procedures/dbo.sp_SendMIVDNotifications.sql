SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SendMIVDNotifications]

AS

/**
 * 
 * NAME:
 * dbo.[sp_SendMIVDNotifications]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * send notifications if compliance report indicates driver has not sent in macro
 *
 * RETURNS:
 *	Nothing
 * 
 * Change Log: 
 * 01/24/2014 - PTS63658 - APC - Create proc
 * 05/07/2014 - PTS75915 - APC - if leg is no longer active, move notifications record to history
 * 06/20/2014 - PTS77783 - APC - add division info to email notification message
 **/
 
DECLARE @gi_BorderCrossingNotificationFlag VARCHAR(60),
		@gi_NotificationLimit INT,
		@gi_NotificationInterval INT,
		@gi_dbmailProfileName VARCHAR(60),
		@gi_emailRecipients VARCHAR(60),
		@NotificationID INT,
		@OrderNumber INT,
		@ComplianceFlag INT,
		@lgh_number INT,
		@driverID VARCHAR(13),
		@last_checkcall_processed INT,
		@last_airmiles_calculated FLOAT,
		@MsgSent_counter INT,
		@NotificationSent_TimeStamp DATETIME,
		@NotificationEmail NVARCHAR(350),
		@NotificationText VARCHAR(255),
		@LastSN INT,
		@MoveToHistory BIT,
		@DriverID_12 VARCHAR(12),
		@FilterData VARCHAR(50),
		@mpp_division VARCHAR(6)
		
-- get GI setting values
SELECT 
	@gi_BorderCrossingNotificationFlag = gi_string1,
	@gi_NotificationLimit = gi_integer1, 
	@gi_NotificationInterval = gi_integer2,
	@gi_emailRecipients = gi_string2,
	@gi_dbmailProfileName = gi_string3
FROM dbo.generalinfo (NOLOCK)
WHERE gi_name = 'Border_Crossing_Notifications'

-- exit proc if gi_setting is not turned on
IF @gi_BorderCrossingNotificationFlag <> 'Y'
RETURN 

-- iterate through tblMIVDNotifications	
SET @NotificationID = 0
SET @MsgSent_counter = 0

WHILE (1 = 1)
BEGIN
	SELECT TOP 1 
		@NotificationID = n.NotificationID, 
		@OrderNumber = o.ord_number,
		@lgh_number = n.lgh_number,
		@driverid = n.driverid,
		@last_checkcall_processed = n.last_checkcall_processed,
		@last_airmiles_calculated = n.last_airmiles_calculated,
		@MsgSent_counter = n.MsgSent_counter,
		@NotificationSent_TimeStamp = ISNULL(n.NotificationSent_TimeStamp,'1950-01-01'),
		@mpp_division = l.mpp_division
	FROM dbo.tblMIVDNotifications n (NOLOCK)
	INNER JOIN dbo.legheader l (NOLOCK)
	ON n.lgh_number = l.lgh_number
	INNER JOIN dbo.orderheader o (NOLOCK)
	ON l.ord_hdrnumber = o.ord_hdrnumber
	WHERE NotificationID > @NotificationID
	ORDER BY NotificationID

	IF @@ROWCOUNT = 0 BEGIN
		BREAK;
	END
	
	SET @MoveToHistory = 0;
	
	-- if leg is no longer active, move record to history table
	IF NOT EXISTS (SELECT TOP 1 lgh_number FROM dbo.legheader_active WHERE lgh_number = @lgh_number) BEGIN
		SET @MoveToHistory = 1;
	END
	
	IF @MoveToHistory = 0 BEGIN 
		-- Set Compliance Report Flag
		IF NOT EXISTS(select ordernumber from transx_compliancestatus2 (NOLOCK) where ordernumber = @OrderNumber) BEGIN
			SET @ComplianceFlag=0;	
		END
		ELSE BEGIN	
			-- set compliance report flag (if northboundmeat or southboundmeat flag is set on the order)
			SELECT @ComplianceFlag = CASE 
				WHEN (ISNULL(cs.northboundmeat, 0) > 0 
					OR ISNULL(cs.southboundmeat,0) > 0) 
				THEN 1 ELSE 0 END
			FROM TransX_ComplianceStatus2 cs (NOLOCK)
			WHERE cs.OrderNumber = @OrderNumber
		END
		
		-- if macro has NOT been received from driver, 
		IF @ComplianceFlag = 0 BEGIN
			-- if message has NOT been sent out max times
			IF @gi_NotificationLimit > @MsgSent_counter BEGIN
				-- making sure msg isnt sent before x minutes is up (interval)
				-- if diff between [time of last sent msg] and [current time] >= interval
				IF DATEDIFF(mi, @NotificationSent_TimeStamp, CURRENT_TIMESTAMP) >= @gi_NotificationInterval BEGIN
					-- send notifications			
					-- hardcoded notification EMAIL per SR
					SET @NotificationEmail = 
						'Order Number: [' + CONVERT(NVARCHAR(12), @OrderNumber) + ']' + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
						+ 'Driver: [' + CONVERT(NVARCHAR(13), @DriverID) + ']' + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
						+ 'Division: [' + @mpp_division + ']' + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
						+ 'This driver is moving away from meat inspection and we have not received ' 
						+ 'the meat inspection macro required for this load. Driver needs to be '  
						+ 'contacted ASAP to confirm inspection has been completed and to ensure ' 
						+ 'that the required macro is sent.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
					
					-- queue email
					EXEC MSDB.dbo.sp_send_dbmail 
						@profile_name = @gi_dbmailProfileName,
						@recipients = @gi_emailRecipients,
						@subject = N'MIVD Notification', 
						@body = @NotificationEmail	
					
					-- hardcoded notification totalmail text msg
					SET @NotificationText = 
						'You are currently moving away from meat inspection and have not '
						+ 'completed your meat inspection macro. Please stop at the next '
						+ 'safe point and send in your macro ASAP.'
						/*
						+ '   Until the macro has been received, this msg will be resent ' + 
						+ CONVERT(VARCHAR(8), @MsgSent_counter) + ' more times.'
						*/
					-- queue text message
					SELECT @DriverID_12 = LEFT(@driverID, 12);
					SET @FilterData = 
						(SELECT @DriverID_12 + '_' 
						+ CONVERT(VARCHAR(8),DATEPART(mi,CURRENT_TIMESTAMP)))
						
					EXEC asyncmessage_sp NULL, NULL, NULL, 
						@DriverID_12, 10, 0, @FilterData, 
						'MIVD Border Notification', 'TEXT01', 
						@NotificationText, 1, @LastSN OUT
					
					-- update tblMIVDNotifications flag/timestamp
					UPDATE dbo.tblMIVDNotifications 
					SET 
						MsgSent_counter = n.MsgSent_counter + 1,
						NotificationSent_TimeStamp = CURRENT_TIMESTAMP
					FROM dbo.tblMIVDNotifications n
					WHERE NotificationID = @NotificationID
				END
			END
			ELSE BEGIN
			-- message HAS been sent out max times, 
			-- set flag to move this record from notifications to history
				SET @MoveToHistory = 1;
			END	
		END
		ELSE BEGIN	
			-- macro HAS been received from driver
			SET @MoveToHistory = 1;
		END
	END
	
	IF @MoveToHistory = 1 BEGIN
	-- move to history table and remove from notifications table
		INSERT INTO dbo.tblMIVDNotifications_History
		        ( NotificationID ,
		          lgh_number ,
		          DriverID ,
		          last_checkcall_processed ,
		          last_airmiles_calculated ,
		          MsgSent_counter ,
		          NotificationSent_TimeStamp ,
		          Resolution_TimeStamp
		        )
		VALUES  ( @NotificationID,
		          @lgh_number,
		          @driverid,
		          @last_checkcall_processed,
		          @last_airmiles_calculated,
		          @MsgSent_counter,
		          @NotificationSent_TimeStamp,
		          CURRENT_TIMESTAMP		          
		        )
		DELETE FROM dbo.tblMIVDNotifications
		WHERE NotificationID = @NotificationID;
		
	END
		
END

GO
GRANT EXECUTE ON  [dbo].[sp_SendMIVDNotifications] TO [public]
GO
