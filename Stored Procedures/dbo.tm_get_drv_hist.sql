SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_drv_hist]	
					@DriverSN int,
					@MaxMessages int,
					@ErrorsOnly INT = NULL,  --Errors Only will call with this set to 1
					@Earliest DateTime = NULL,
					@Latest DateTime = NULL
AS
/* 10/21/98 TD: Created to allow faster drv hist scroll retrieval. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroup and DTSent to the result set */
/* 09/14/11 DWG: PTS 58974 - UNKNOWN Dispatch Group SN retrieved */
/* 01/31/12 VMS: PTS 59317 - Ryder Viewer update  - 2012.01.31 */
/* 04/18/12 VMS: PTS 62606 - Bug fix - 2012.04.18 */
/* 11/17/14 rwolfe: PTS 73655 - viewer needs form number on a row by row basis */
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */
/* 03/29/16 rwolfe: PTS 98342 - resolve issue, where historical bad data exists, and keeps us from reading current data.   */
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DEClARE @T1 TABLE  (SN INT Primary Key, 
					DispatchGroupSN INT,
					DispSysID VARCHAR(20)		-- 2012.04.18 - PTS 62606
				)

	DECLARE @T2 TABLE (SN INT Primary Key, 
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
					Kind INT --73655
				)

	DECLARE @EXESQL NVARCHAR(2000), @SQLPrams NVARCHAR(2000)				-- 2012.04.18 - PTS 62606
	DECLARE @UNKNOWN_DispatchGroupSN int
    DECLARE @AddressBy INT,	@TmpAddressby VARCHAR(22)
	Declare @GENESIS DateTime = '19500101' 
	Declare @DispPart NVARCHAR(200)

	SELECT @TmpAddressby = [Text]
	FROM tblRs (NOLOCK)
	WHERE KeyCode = 'ADDRESSBY'	
	
  	SET @AddressBy = CONVERT(INT, @TmpAddressby)
	SELECT @UNKNOWN_DispatchGroupSN = SN FROM tblDispatchGroup WHERE Name = ' UNKNOWN'

	IF ISNULL(@MaxMessages, 0)>0
		SET @EXESQL = 'SELECT TOP (@MaxMessages) '
	ELSE
		SET @EXESQL = 'SELECT '

	-------------------------------------------------------------------------------
	-- 2012.01.31 - PTS 59317 - Beg
	SET @EXESQL = @EXESQL + ' MSG.SN, '

	IF @AddressBy = 0   -- Driver
		SET @DispPart = ' MAX(ISNULL(tblDrivers.CurrentDispatcher, @UNKNOWN_DispatchGroupSN)) ' --PTS 98342 Max is needed becuase bad config could make bad data. We need to beable to read the rest of the Query
	ELSE
		SET @DispPart = ' MAX(ISNULL(tblTrucks.CurrentDispatcher, @UNKNOWN_DispatchGroupSN)) '

	SET @EXESQL += @DispPart + ' DispGrpSN, '
	SET @EXESQL = @EXESQL + ' MAX(ISNULL(tblTrucks.DispSysTruckID, '''')) DispSysID '

	SET @EXESQL = @EXESQL + ' FROM tblHistory (NOLOCK) 
			INNER JOIN tblMessages MSG (NOLOCK) ON MSG.SN = tblHistory.MsgSN '

	--Add join for Dispatch Group
	IF @AddressBy = 0 --Driver
		BEGIN
			SET @EXESQL = @EXESQL + 
				' LEFT JOIN tblDrivers (NOLOCK) ON tblDrivers.SN = DriverSN '
		END

	SET @EXESQL = @EXESQL + 
			' LEFT JOIN tblTrucks (NOLOCK) ON tblTrucks.SN = tblHistory.TruckSN '

	-- 2012.01.31 - PTS 59317 - End
	-------------------------------------------------------------------------------

	--If only show messages that have errors
	if ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' JOIN dbo.tblMsgProperties (NOLOCK) on MSG.SN = tblMsgProperties.MsgSN '

	SET @EXESQL = @EXESQL + ' WHERE tblHistory.DriverSN = @DriverSN '

	--If only show messages that have errors
	IF ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' AND tblMsgProperties.PropSN = 6 '

	if (NOT ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (NOT ISNULL(@Latest, @GENESIS) = @GENESIS)
		SET @EXESQL = @EXESQL + ' AND ((MSG.DTSent >= @Earliest AND MSG.DTSent <= @Latest) OR (MSG.DTReceived >= @Earliest AND MSG.DTReceived <= @Latest))'

	set @EXESQL += ' group by MSG.SN, DTSent ' --Assume tblmessages data is clean

	SET @EXESQL = @EXESQL + ' ORDER BY DTSent DESC, MSG.SN DESC '
	SET @SQLPrams = '@DriverSN int, @MaxMessages int, @UNKNOWN_DispatchGroupSN int, @Earliest DateTime, @Latest DateTime'
	--Fill #T1 with message SN and Dispatch Group
	INSERT INTO @T1 (SN,
		DispatchGroupSN,
		DispSysID					-- 2012.01.31 - PTS 59317
		)
	EXEC sp_ExecuteSQL @EXESQL, @SQLPrams, 
		@DriverSN = @DriverSN, 
		@MaxMessages = @MaxMessages, 
		@UNKNOWN_DispatchGroupSN = @UNKNOWN_DispatchGroupSN, 
		@Earliest = @Earliest,
		@Latest = @Latest;

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
			props.Kind						--PTS73655
	FROM dbo.tblMessages (NOLOCK)
		INNER JOIN @T1 T1 ON tblMessages.SN = T1.SN 
		LEFT JOIN (SELECT  'Kind' = Value, MsgSN FROM tblMsgProperties(NOLOCK) WHERE PropSN = 2) props ON tblMessages.SN = props.MsgSN

	-- Go collect and return the data.
	SELECT	tblMsgPriority.Code AS Priority, 
			tblMsgType.Code AS Type, 
			(CASE WHEN tblAttachments.SN > 0  THEN 1 ELSE 0 END) AS Attachment, 
			T2.FromName AS ToFrom, 
			T2.Subject AS Subject, 
			T2.DTReceived AS SentReceived, 
			[Size], 
			'' AS [Text], --This field is not kept by Viewer, the preview is and should always be looked up.
			'' AS [Data], --This field is not used by Viewer
			T2.DTRead AS DTRead, 
			T2.SN, 
			tblMsgProperties.Value AS ErrListID, 
			T2.Status AS Status ,
			tblDispatchGroup.Name as DispatchGroup, 
			T2.DTSent as DTSent,
			T2.DispSysID AS DispSysID,						-- 2012.01.31 - PTS 59317
			T2.FromType AS FromType,						-- 2012.01.31 - PTS 59317
			T2.DeliverToType AS DeliverToType,				-- 2012.01.31 - PTS 59317
			'Kind'=ISNULL(T2.Kind, 0)						--PTS73655
		FROM @T2 T2
			JOIN tblDispatchGroup (NOLOCK) on tblDispatchGroup.SN = T2.DispatchGroupSN
			JOIN tblMsgType (NOLOCK) ON tblMsgType.SN = T2.Type
			JOIN tblMsgPriority (NOLOCK) ON tblMsgPriority.SN = T2.Priority
			LEFT JOIN tblMsgProperties (NOLOCK) ON tblMsgProperties.MsgSN = T2.SN AND tblMsgProperties.PropSN=6
			LEFT JOIN tblAttachments (NOLOCK) ON T2.SN = tblAttachments.Message

GO
GRANT EXECUTE ON  [dbo].[tm_get_drv_hist] TO [public]
GO
