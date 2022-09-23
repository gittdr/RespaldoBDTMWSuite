SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_checksystemstatus](@LastWarningTime datetime,
											@ReturnString varchar(8000) out,
											@CurrentWarningTime datetime out,
											@QuickCheck int)
AS

/**
 * 
 * NAME:tmail_procname
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	
 * 
 *
 * PARAMETERS:
 * @LastWarningTime datetime,
 * @ReturnString varchar(8000) out,
 * @CurrentWarningTime datetime out,
 * @QuickCheck int
 * 
 * REVISION HISTORY:
 * 04/25/2014.01 - PTS77176 - APC - add tblRS logic for PNet Data Delivery poller check
 * 03/11/2016.01 - PTS98345 - rwolfe - Ajust for Dynamic Message Balencing 
 * 03/17/2016.01 - PTS100423 - JJN - Added error incrmement and warning time so that Transaction Agent will pop up notification in viewer.
 * 03/18/2016.01 - PTS100423 - JJN - Removed Warning time checks to keep agents with shorter cycles from skipping others' messages.
 * 03/18/2016.01 - PTS101212 - rwolfe - if agents are down, it should say that agents are down regardless of which check type
 **/

DECLARE	@DurDelivery int,	-- The number of minutes the delivery agent can be down before we warn
		@DurPoller int,		-- Generic poller...
		@DurQC int,			-- Qualcomm agent...
		@cotTransact int,		-- Expected number of Transaction agents
		@ErrorCount int,		-- How many agent failures
		@Now datetime,
		@tsDelivery datetime,	-- The date time of the last successful Delivery cycle
		@tsPoller datetime,		-- Generic poller cycle
		@tsQC datetime,			-- Qualcomm cycle
		@tsTransact datetime,	-- Transaction agent cycle
		@AdditionalText varchar(50),
		@AgentInfo varchar(8000),
		@AgentName varchar(300),
		@keycode char(10),
		@DurXRSHOS int,
		@tsXRSHOS DATETIME,
		@DurPNetDataDelivery INT,
		@tsPNetDataDelivery DATETIME,
    	@iActuallXacts int

SET @ReturnString = ''
SET @CurrentWarningTime = null
SET @ErrorCount = 0
SET @AgentInfo = ''
SET @AdditionalText = ''

-- Get the number of minutes each agent can be down before we warn
SET @DurDelivery = 0
SET @DurPoller = 0
SET @DurQC = 0
SET @cotTransact = 0

SELECT @DurDelivery = CONVERT(int, ISNULL(text,0))
FROM tblRS (NOLOCK)
WHERE keycode = 'TimeoutDlv'

--SELECT @DurPoller = CONVERT(int, ISNULL(text,0)) FROM tblRS WHERE keycode = 'TimeoutGen'
SELECT @DurPoller = sum(CONVERT(int, ISNULL(text,0)))
FROM tblRS (NOLOCK) 
WHERE keycode like 'TimeoutG%'

SELECT @DurQC = CONVERT(int, ISNULL(text,0))
FROM tblRS (NOLOCK)
WHERE keycode = 'TimeoutQC'

SELECT @cotTransact = CONVERT(int, ISNULL(text,0))
FROM tblRS (NOLOCK)
WHERE keycode = 'TimeoutTMX'

SELECT @DurXRSHOS = CONVERT(int, ISNULL(text,0))
FROM tblRS (NOLOCK)
WHERE keycode = 'TiouXRSHOS'

SELECT @DurPNetDataDelivery = CONVERT(int, ISNULL(text,0))
FROM tblRS (NOLOCK)
WHERE keycode = 'TOutPNetDD'

-- Delivery check
IF (@DurDelivery > 0) -- User has configured to monitor Delivery agent
  BEGIN
	-- Get the timestamp of the last successful Delivery agent cycle
	SET @tsDelivery = '19500101'
	SELECT @tsDelivery = CONVERT(datetime, ISNULL(text, '19500101'))
	FROM tblRS (NOLOCK)
	WHERE keycode = 'TStmpDlv'

	IF (@tsDelivery > '19500101') 
	  BEGIN
		SET @Now = GETUTCDATE()

		-- Check if Delivery agent has cycled within the set amount of minutes and that we haven't just shown
		--  the warning message
		IF (DATEDIFF(mi, @tsDelivery, @Now) > @DurDelivery)
		  BEGIN
				SET @ErrorCount = @ErrorCount + 1
				SET @CurrentWarningTime = @Now
		  END
			
		-- Get the agent info
		SET @AgentInfo = 'Delivery last processed ' + CONVERT(varchar(10),DATEDIFF(mi, @tsDelivery, @Now)) + ' minutes ago' + CHAR(10) + CHAR(13)
	  END
  END

-- Generic poller check VV 22288
IF (@DurPoller > 0) -- User has configured to monitor the generic poller
   BEGIN
      -- Get the timestamp of the last successful generic poller cycle
      SET @tsPoller = '19500101'
      SET @Now = GETUTCDATE()

      DECLARE pollers_cursor CURSOR FOR
      SELECT keycode, ISNULL(text, '19500101'), description FROM tblRS (NOLOCK) WHERE keycode like 'TStmpGen%'
      OPEN pollers_cursor
      FETCH NEXT FROM pollers_cursor INTO @keycode, @tsPoller, @AgentName
      WHILE @@FETCH_STATUS=0
      BEGIN
      --Lovely bit below is on account of TStmpGen switching to hex vals. Must convert agent code from string to hex to dec to string then padleft. Naturally, TSQL handles all these quite neatly.
      DECLARE @keycodeDec int = 0
	  DECLARE @keycodeXfc varchar(3)
      SET @keycodeDec = CONVERT(INT, CONVERT(VARBINARY, N'0x' + RIGHT(@keycode,2), 1))
	  SET @keycodeXfc = CAST(@keycodeDec as varchar)
      IF( @keycodeDec < 10 ) SET @keycodeXfc = '0' + @keycodeXfc	--This stupidity because of preexisting, nonchanging legacy code stupidity
	 SELECT @DurPoller = (select CONVERT(int, ISNULL(text,0)) from tblRS (NOLOCK) where keycode = 'TimeoutG' + CAST(@keycodeXfc as varchar))
         IF (@tsPoller > '19500101' AND @DurPoller>0) 
         BEGIN
             -- Check if the generic poller has cycled within the set amount of minutes and that we haven't just shown the warning message
             IF (DATEDIFF(mi, @tsPoller, @Now) > @DurPoller)
             BEGIN
                SET @ErrorCount = @ErrorCount + 1
                SET @CurrentWarningTime = @Now
             END
             SET @AgentInfo = @AgentInfo + @AgentName + ' last processed ' + CONVERT(varchar(10),DATEDIFF(mi, @tsPoller, @Now)) + ' minutes ago' + CHAR(10) + CHAR(13)
         END
         FETCH NEXT FROM pollers_cursor INTO @keycode, @tsPoller, @AgentName
      END
      CLOSE pollers_cursor
      DEALLOCATE pollers_cursor
   END

-- QualComm check
IF (@DurQC > 0) -- User has configured to monitor the QualComm agent
  BEGIN
	-- Get the timestamp of the last successful Qualcomm agent cycle
	SET @tsQC = '19500101'
	SELECT @tsQC = ISNULL(text, '19500101')
	FROM tblRS (NOLOCK)
	WHERE keycode = 'TStmpQCom'

	IF (@tsQC > '19500101') 
	  BEGIN
		SET @Now = GETUTCDATE()

		-- Check if the Qualcomm agent has cycled within the set amount of minutes and that we haven't just shown
		--  the warning message
		IF (DATEDIFF(mi, @tsQC, @Now) > @DurQC)
		  BEGIN
				SET @ErrorCount = @ErrorCount + 1
				SET @CurrentWarningTime = @Now
		  END

		-- Get the agent info
		SET @AgentInfo = @AgentInfo + 'Omnitracs last processed ' + CONVERT(varchar(10),DATEDIFF(mi, @tsQC, @Now)) + ' minutes ago' + CHAR(10) + CHAR(13)
	  END
  END
  
  -- XRSHOS check
IF (@DurXRSHOS > 0) -- User has configured to monitor the QualComm agent
  BEGIN
	-- Get the timestamp of the last successful XRSHOS agent cycle
	SET @tsXRSHOS = '19500101'
	SELECT @tsXRSHOS = ISNULL(text, '19500101')
	FROM tblRS (NOLOCK)
	WHERE keycode = 'tsXRSHOS'

	IF (@tsXRSHOS > '19500101') 
	  BEGIN
		SET @Now = GETUTCDATE()

		-- Check if the XRSHOS agent has cycled within the set amount of minutes and that we haven't just shown
		--  the warning message
		IF (DATEDIFF(mi, @tsXRSHOS, @Now) > @DurXRSHOS)
		  BEGIN
				SET @ErrorCount = @ErrorCount + 1
				SET @CurrentWarningTime = @Now
		  END

		-- Get the agent info
		SET @AgentInfo = @AgentInfo + 'XRSHOS last processed ' + CONVERT(varchar(10),DATEDIFF(mi, @tsXRSHOS, @Now)) + ' minutes ago' + CHAR(10) + CHAR(13)
	  END
  END
  
  -- PNet Data Delivery check
IF (@DurPNetDataDelivery > 0) -- User has configured to monitor the PNetDD agent
  BEGIN
	-- Get the timestamp of the last successful PNetDD agent cycle
	--SET @tsPNetDataDelivery = '19500101'
	SELECT @tsPNetDataDelivery = ISNULL(text, '19500101')
	FROM tblRS (NOLOCK)
	WHERE keycode = 'tsPNetDD'

	IF (@tsPNetDataDelivery > '19500101') 
	  BEGIN
		SET @Now = GETUTCDATE()

		-- Check if the PNetDD agent has cycled within the set amount of minutes and that we haven't just shown the warning message
		IF (DATEDIFF(mi, @tsPNetDataDelivery, @Now) > @DurPNetDataDelivery)
		  BEGIN
				SET @ErrorCount = @ErrorCount + 1
				SET @CurrentWarningTime = @Now
		  END

		-- Get the agent info
		SET @AgentInfo = @AgentInfo + 'PNetDD last processed ' + CONVERT(varchar(10),DATEDIFF(mi, @tsPNetDataDelivery, @Now)) + ' minutes ago' + CHAR(10) + CHAR(13)
	  END
  END  

-- Transaction check
IF (@cotTransact > 0) -- User has configured to monitor the Transaction agent
   BEGIN
      Select @iActuallXacts = count(*) from tblServer(nolock) where ServerCode = 'TMUL'
       
      if @cotTransact > @iActuallXacts
		BEGIN
			SET @ErrorCount = @ErrorCount + 1
			SET @CurrentWarningTime = @Now
		END

		--PTS 100423 Per Riley's request report the removed 'Only' wording and always report how many are running.
		SET @AgentInfo = @AgentInfo  +  CONVERT(varchar(22), @iActuallXacts) + ' of the expected ' + CONVERT(varchar(22), @cotTransact) + ' Transaction Agents are Running. ' + CHAR(10) + CHAR(13)
   END

-- If we encountered an error, remove the last comma, otherwise, set @ReturnString to ''
IF (@ErrorCount > 0)
BEGIN
	IF (@ErrorCount = 1)
		SET @ReturnString = 'AGENT APPEARS TO BE DOWN:'
	ELSE
		SET @ReturnString = 'AGENTS APPEAR TO BE DOWN:'

	-- Get any additional text
	SELECT @AdditionalText = ISNULL(TEXT, '')
	FROM tblRS
	WHERE keycode = 'VWarnText'

	IF (Len(@AdditionalText) > 0)
		SET @ReturnString = @ReturnString + CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13) + @AdditionalText
	SET @ReturnString = @ReturnString + CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13) + @AgentInfo
END
ELSE
BEGIN
	IF (@QuickCheck <> 0)
	BEGIN
		SET @ReturnString = @AgentInfo
	END
END
	
GO
GRANT EXECUTE ON  [dbo].[tm_checksystemstatus] TO [public]
GO
