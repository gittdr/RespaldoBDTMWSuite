SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_folder] 
					@FolderSN INT,
					@MaxMessages INT,
					@ErrorsOnly INT = NULL,  --Errors Only will call with this set to 1
					@Earliest DateTime = NULL,
					@Latest DateTime = NULL
AS

/* 10/21/98 TD: Created to allow faster general scroll retrieval. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set */
/* 09/14/11 DWG: PTS 58991 - Performance revisions */
/* 01/31/12 VMS: PTS 59317 - Ryder Viewer update  - 2012.01.31 */
/* 04/18/12 VMS: PTS 62606 - Bug fix - 2012.04.18 */
/* 11/11/14 HMA: PTS 83211 - bug fix - better SQL for dispatcher when DRIVER based data */
/* 11/17/14 rwolfe: PTS 73655 - viewer needs form number on a row by row basis */
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */
/* 05/25/16 rwolfe: PTS 99720 - viewer performance*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @T1 TABLE (
		SN INT, 
		DispatchGroupSN INT,
		DispSysID VARCHAR(20)		-- 2012.04.18 - PTS 62606
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
					DispSysID VARCHAR(20),		-- 2012.04.18 - PTS 62606
					FromType INT,				-- 2012.01.31 - PTS 59317
					DeliverToType INT,			-- 2012.01.31 - PTS 59317
					Kind INT					--PTS 73655
				)

	DECLARE @EXESQL NVARCHAR(2000)				-- 2012.04.18 - PTS 62606
	DECLARE @AddressBy INT
	DECLARE @UNKNOWN_DispatchGroupSN int
	Declare @GENESIS DateTime = '19500101'

	SELECT @AddressBy = CONVERT(int, Text) 
	FROM tblRs (NOLOCK) 
	WHERE KeyCode = 'ADDRESSBY'	
	
	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup  (NOLOCK)
	WHERE Name = ' UNKNOWN'
	
	IF ISNULL(@MaxMessages, 0)>0
		SET @EXESQL = 'SELECT TOP  (@MaxMessages) '
	ELSE
		SET @EXESQL = 'SELECT'
	----------------------------------------------------------------------------
	-- 2012.01.31 - PTS 59317 - Beg
	SET @EXESQL = @EXESQL + ' tblMessages.SN, ' 

	IF @AddressBy = 0   -- Driver
		-- pts 83211
		SET @EXESQL = @EXESQL + ' CASE WHEN ISNULL(tblDrivers.CurrentDispatcher, 0) = 0 THEN ' +
			' CASE WHEN ISNULL(tblTrucks.CurrentDispatcher,0)=0 THEN @UNKNOWN_DispatchGroupSN '  +
			' ELSE tblTrucks.CurrentDispatcher END ELSE tblDrivers.CurrentDispatcher END DispGrpSN, '		
	ELSE
		SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.CurrentDispatcher, @UNKNOWN_DispatchGroupSN) DispGrpSN, '

	SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.DispSysTruckID, '''') DispSysID '

	SET @EXESQL = @EXESQL + 'FROM dbo.tblMessages (NOLOCK)  
   			LEFT JOIN tblHistory HIST (NOLOCK) ON HIST.MsgSN = tblMessages.SN'  

	--If only show messages that have errors
	if ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' JOIN dbo.tblMsgProperties (NOLOCK) on tblMessages.SN = tblMsgProperties.MsgSN '

	IF @AddressBy = 0 --Driver
		BEGIN
			SET @EXESQL = @EXESQL + 
				' LEFT JOIN tblDrivers (NOLOCK) ON tblDrivers.SN = 
					CASE WHEN ISNULL(HIST.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
						CASE WHEN ISNULL(ToDrvSN, 0) = 0 THEN FromDrvSN ELSE ToDrvSN END 
					ELSE HIST.DriverSN END '
		END

	SET @EXESQL = @EXESQL + 
		' LEFT JOIN tblTrucks (NOLOCK) ON tblTrucks.SN = 
			CASE WHEN ISNULL(HIST.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
				CASE WHEN ISNULL(ToTrcSN, 0) = 0 THEN FromTrcSN ELSE ToTrcSN END 
			ELSE HIST.TruckSN END '
	-- 2012.01.31 - PTS 59317 - End
	-------------------------------------------------------------------------------	

	SET @EXESQL = @EXESQL + 'WHERE Folder = @FolderSN ' 

	--If only show messages that have errors
	IF ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' AND tblMsgProperties.PropSN = 6 '

	if (NOT ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (NOT ISNULL(@Latest, @GENESIS) = @GENESIS)
		SET @EXESQL = @EXESQL + ' AND ((tblMessages.DTSent >= @Earliest AND tblMessages.DTSent <= @Latest) OR (tblMessages.DTReceived >= @Earliest AND tblMessages.DTReceived <= @Latest)) '

	SET @EXESQL = @EXESQL + ' ORDER BY DTSent DESC, tblMessages.SN DESC'

	--Fill #T1 with message SN and Dispatch Group
	INSERT INTO @T1 (
		SN,
		DispatchGroupSN,
		DispSysID					-- 2012.01.31 - PTS 59317
		)
		EXEC sp_ExecuteSQL @EXESQL, N'@FolderSN INT, @MaxMessages INT, @UNKNOWN_DispatchGroupSN int, @Earliest DateTime, @Latest DateTime', 
		@FolderSN = @FolderSN, 
		@MaxMessages = @MaxMessages, 
		@UNKNOWN_DispatchGroupSN = @UNKNOWN_DispatchGroupSN,
		@Earliest = @Earliest,
		@Latest = @Latest

	-- Go collect the base message information
	INSERT INTO @T2 
			SELECT	tblMessages.SN,
			DTRead,
			tblMessages.DTSent,
			DTReceived,
			Folder,
			Status,
			Type,
			FromName,
			Subject,
			Priority,
			DATALENGTH(Contents) AS [Size],
			DispatchGroupSN,
			DispSysID ,										-- 2012.01.31 - PTS 59317
			ISNULL(FromType,99) AS 'FromType',				-- 2012.01.31 - PTS 59317
			ISNULL(DeliverToType,99) AS 'DeliverToType'		-- 2012.01.31 - PTS 59317
			,props.Kind
		FROM dbo.tblMessages (NOLOCK)
			JOIN @T1 T1 on tblmessages.sn = T1.SN Left JOIN (SELECT  'Kind' = Value, MsgSN FROM tblMsgProperties(NOLOCK) WHERE PropSN = 2)props ON tblMessages.SN = props.MsgSN

	-- Go collect and return the data.
	SELECT	tblMsgPriority.Description AS Priority, 
			tblMsgType.CodeDisplay AS Type, 
			CASE WHEN tblAttachments.SN > 0 THEN 1 ELSE 0 END AS Attachment, 
			T2.FromName AS ToFrom, 
			T2.Subject AS Subject, 
			T2.DTReceived AS SentReceived, 
			[Size], 
			'' AS [Text], --This field is not kept by Viewer, the preview is always looked up.
			'' AS [Data], --This field is not used by Viewer
			T2.DTRead as DTRead, 
			T2.SN, 
			tblMsgProperties.Value as ErrListID, 
			T2.Status AS Status, 
			(select name from tbldispatchgroup (nolock) where sn = (select CurrentDispatcher from tbltrucks (nolock) where truckname = (select DispSysTruckID from tbltrucks (nolock) where truckname = T2.FromName ))) as DispatchGroup, 
			--tblDispatchGroup.Name as DispatchGroup, 
			T2.DTSent as DTSent,
			T2.DispSysID AS DispSysID,				-- 2012.01.31 - PTS 59317
			T2.FromType AS FromType,				-- 2012.01.31 - PTS 59317
			T2.DeliverToType AS DeliverToType,		-- 2012.01.31 - PTS 59317
			'Kind'=ISNULL(T2.Kind, 0)
		FROM @T2 T2
			JOIN tblDispatchGroup (NOLOCK) ON tblDispatchGroup.SN = T2.DispatchGroupSN
			JOIN tblMsgType (NOLOCK) ON tblMsgType.SN = T2.Type
			JOIN tblMsgPriority (NOLOCK)ON tblMsgPriority.SN = T2.Priority
			LEFT JOIN tblAttachments (NOLOCK) ON T2.SN = tblAttachments.Message 
			LEFT JOIN tblMsgProperties (NOLOCK) ON tblMsgProperties.MsgSN = T2.SN AND tblMsgProperties.PropSN = 6

GO
GRANT EXECUTE ON  [dbo].[tm_get_folder] TO [public]
GO
