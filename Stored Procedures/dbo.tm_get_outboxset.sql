SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_outboxset]	@FolderSN int,
					@MaxMessages int,
					@Earliest DateTime = NULL,
					@Latest DateTime = NULL

AS
/* 10/21/98 TD: Created to allow faster out/sentbox retrieval. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set */
/* 09/14/11 DWG: PTS 58991 - Performance revisions */
/* 01/31/12 VMS: PTS 59317 - Ryder Viewer update  - 2012.01.31 */
/* 03/20/12 DWG: PTS 62144 - Fixed Sent box is not showing all messages that were sent or any messages. Includes fix to UNKNOWN Dispatch Group select, Dispatch name column not showing correct name and To Name column showing “etc */  
/* 11/17/14 rwolfe: PTS 73655 - viewer needs form number on a row by row basis */
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @T1 TABLE (SN INT, 
					DispatchGroupSN INT,
					DispSysID VARCHAR(50)		-- 2012.01.31 - PTS 59317 --2012.03.20 - PTS 62144
				)

	DECLARE @T2 TABLE (SN INT, 
					DTRead DATETIME, 
					DTSent DATETIME, 
					DTReceived DATETIME, 
					Folder INT,
					Status INT,
					Type INT,
					FromName VARCHAR(50),
					Subject VARCHAR(255),
					Priority INT,
					[Size] INT,
					DispatchGroupSN INT,
					DispSysID VARCHAR(50),		-- 2012.01.31 - PTS 59317 --2012.03.20 - PTS 62144
					FromType INT,				-- 2012.01.31 - PTS 59317
					DeliverToType INT,			-- 2012.01.31 - PTS 59317
					Kind INT					--PTS 73655
				)

	DECLARE @EXESQL NVARCHAR(2000) --2012.03.20 - PTS 62144
	DECLARE @AddressBy INT
	DECLARE @UNKNOWN_DispatchGroupSN int
	Declare @GENESIS DateTime = '19500101'

	SELECT @AddressBy = CONVERT(int, Text) 
	FROM tblRs (NOLOCK) 
	WHERE KeyCode = 'ADDRESSBY'	
	
	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup (NOLOCK)
	WHERE Name = CHAR(160) + 'UNKNOWN'  --PTS 62144

	IF ISNULL(@MaxMessages, 0)>0
		SET @EXESQL = 'SELECT TOP (@MaxMessages) '
	ELSE
		SET @EXESQL = 'SELECT '

	----------------------------------------------------------------------------
	-- 2012.01.31 - PTS 59317 - Beg
	SET @EXESQL = @EXESQL + ' ChosenMsg.SN, '

	IF @AddressBy = 0   -- Driver
		SET @EXESQL = @EXESQL + ' ISNULL(tblDrivers.CurrentDispatcher, @UNKNOWN_DispatchGroupSN) DispGrpSN, '
	ELSE
		SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.CurrentDispatcher, @UNKNOWN_DispatchGroupSN), '

	SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.DispSysTruckID, '''') DispSysID '
    
    -- 2012.03.20 - PTS 62144 - Start
	SET @EXESQL = @EXESQL + 
		'FROM tblMessages ChosenMsg (NOLOCK) '

    SET @EXESQL = @EXESQL + '	LEFT JOIN tblMessages HistMsgs (NOLOCK) ON HistMsgs.OrigMsgSN = ChosenMsg.OrigMsgSN  '
    SET @EXESQL = @EXESQL + '	LEFT JOIN tblHistory (NOLOCK) ON tblHistory.MsgSN = HistMsgs.SN '
    SET @EXESQL = @EXESQL + '	LEFT JOIN tblTrucks (NOLOCK) ON tblTrucks.SN = tblHistory.TruckSN '

	IF @AddressBy = 0 -- Driver
		BEGIN
			SET @EXESQL = @EXESQL + 
				'	LEFT JOIN tblDrivers (NOLOCK) ON tblDrivers.SN = tblHistory.DriverSN '
		END

	SET @EXESQL = @EXESQL + ' WHERE ChosenMsg.Folder = @FolderSN  '

	if (NOT ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (NOT ISNULL(@Latest, @GENESIS) = @GENESIS)
		SET @EXESQL = @EXESQL + ' AND ((HistMsgs.DTSent >= @Earliest AND HistMsgs.DTSent <= @Latest) OR (HistMsgs.DTReceived >= @Earliest AND HistMsgs.DTReceived <= @Latest)) '

	SET @EXESQL = @EXESQL + 'ORDER BY ChosenMsg.DTSent DESC, ChosenMsg.SN DESC'
    -- 2012.03.20 - PTS 62144 - End
	-- 2012.01.31 - PTS 59317 - End
	----------------------------------------------------------------------------

	--Fill #T1 with message SN and Dispatch Group
	INSERT INTO @T1 (SN,
		DispatchGroupSN,
		DispSysID)					-- 2012.01.31 - PTS 59317
		EXEC sp_ExecuteSQL @EXESQL, N'@MaxMessages INT, @UNKNOWN_DispatchGroupSN INT, @FolderSN INT, @Earliest DateTime, @Latest DateTime',
			@MaxMessages = @MaxMessages,
			@UNKNOWN_DispatchGroupSN = @UNKNOWN_DispatchGroupSN, 
			@FolderSN = @FolderSN, 
			@Earliest = @Earliest, 
			@Latest = @Latest

	INSERT INTO @T2 
		SELECT	tblMessages.SN,
			DTRead,
			DTSent,
			DTReceived,
			Folder,
			Status,
			Type,
			FromName,
			Subject,
			Priority,
			DATALENGTH(Contents) AS [Size],
			DispatchGroupSN,
			DispSysID,										-- 2012.01.31 - PTS 59317
			ISNULL(FromType,99) AS 'FromType',				-- 2012.01.31 - PTS 59317
			ISNULL(DeliverToType,99) AS 'DeliverToType',		-- 2012.01.31 - PTS 59317
			props.Kind
		FROM dbo.tblMessages (NOLOCK)
			JOIN @T1 T1 ON tblMessages.SN = T1.SN 
			Left JOIN (SELECT  'Kind' = Value, MsgSN FROM tblMsgProperties(NOLOCK) WHERE PropSN = 2)props ON tblMessages.SN = props.MsgSN



	-- Go collect and return the data.
	SELECT MIN(tblMsgPriority.Description) AS Priority

			,MIN(tblMsgType.CodeDisplay) AS Type, 
			(CASE WHEN COUNT(tblAttachments.SN) > 0  THEN 1 ELSE 0 END) AS Attachment, 
            CASE WHEN (SELECT COUNT(*) FROM tblTo (NOLOCK) WHERE Message = T2.SN) > 1 THEN MIN(tblTo.ToName) + '; etc.' Else Min (tblTo.ToName) END as ToFrom,  -- 2012.03.20 - PTS 62144
			MIN(T2.Subject) AS Subject, 
			MIN(T2.DTSent) AS SentReceived, 
			MIN([Size]) AS Size, 
			'' AS [Text], --This field is not kept by Viewer, the preview is always looked up.
			'' AS [Data], --This field is not used by Viewer
			MIN(T2.DTRead) as DTRead, 
			T2.SN, 
			MIN(tblMsgProperties.Value) AS ErrListID, 
			MIN(T2.Status) AS Status ,
			(select name from tbldispatchgroup (nolock) where sn = (select CurrentDispatcher from tbltrucks (nolock) where truckname = (select DispSysTruckID from tbltrucks (nolock) where truckname = CASE WHEN (SELECT COUNT(*) FROM tblTo (NOLOCK) WHERE Message = T2.SN) > 1 THEN MIN(tblTo.ToName) + '; etc.' Else Min (tblTo.ToName) END))) as DispatchGroup, 
            min(Dispatchgroupsn),
		    MAX(tblDispatchGroup.Name) as DispatchGroup,    -- 2012.03.20 - PTS 62144
			MIN(T2.DTSent) as DTSent,
			MIN(T2.DispSysID) as DispSysID,					-- 2012.01.31 - PTS 59317
			MIN(T2.FromType) AS FromType,					-- 2012.01.31 - PTS 59317
			MIN(T2.DeliverToType) AS DeliverToType,			-- 2012.01.31 - PTS 59317
			MIN(ISNULL(T2.Kind, 0)) As Kind

		

	FROM @T2 T2
	    JOIN tblDispatchGroup (NOLOCK) on tblDispatchGroup.SN = T2.DispatchGroupSN
	    LEFT JOIN tblMsgProperties (NOLOCK) ON tblMsgProperties.MsgSN = T2.SN AND tblMsgProperties.PropSN = 6
		JOIN tblMsgType (NOLOCK) ON tblMsgType.SN = T2.Type
		JOIN tblMsgPriority (NOLOCK) ON tblMsgPriority.SN = T2.Priority
    	LEFT JOIN tblTo (NOLOCK) ON T2.SN = tblTo.Message 
		LEFT JOIN tblAttachments (NOLOCK) ON T2.SN = tblAttachments.Message 
	GROUP BY T2.SN
	ORDER BY SentReceived DESC, T2.SN DESC
GO
GRANT EXECUTE ON  [dbo].[tm_get_outboxset] TO [public]
GO
