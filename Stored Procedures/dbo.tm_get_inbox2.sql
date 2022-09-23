SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec tm_get_inbox2 33,360,300,'01/01/1950','01/01/1950',null
CREATE PROCEDURE [dbo].[tm_get_inbox2]	@LoginSN INT,
					@LoginInboxSN INT,
					@MaxMessages INT,
					@LastTimeStamp DATETIME,
					@NewTimeStamp DATETIME OUT, --Vestigial
					@ErrorsOnly INT = NULL,  --Errors Only will call with this set to 1
					@Earliest DateTime = NULL,
					@Latest DateTime = NULL
AS
/*******************************************************************************************************************  
  Object Description:
    Populates the View Grid for User Inboxes

  Revision History:
  Date         Name              Label/PTS    Description
  -----------  ---------------   ----------  ----------------------------------------
  2011/05/13   Lori Brickley     PTS 55668    Added DispatchGroupSN to the result set 
  2011/09/14   David Gudat       PTS 58991    Performance revisions
  2012/01/31   Virgil Sensabaugh PTS 59317    Ryder Viewer update
  2012/03/08   Virgil Sensabaugh PTS 61968    Increase size @EXESQL
  2012/04/18   Virgil Sensabaugh PTS 62606    Bug fix
  2013/04/18   Rob Scott         PTS 68889    Modify dynamic SQL @EXESQL
  2014/04/14   Harry abramowski  PTS 76613    adding PRIMARY KEY to table Vars @T1 and @T2
  2014/09/19   Harry abramowski  PTS 79308    tblDispatchGroup.SN replacing both tblDrivers.CurrentDispatcher & tblTrucks.CurrentDispatcher
  2014/11/11   Harry abramowski  PTS 83211    bug fix - better SQL for dispatcher when DRIVER based data
  2014/11/17   W. Riley Wolfe    PTS 73655    viewer needs form number on a row by row basis
  2015/02/06   W. Riley Wolfe    PTS 82965    adding search by time range to viewer
  2016/05/25   W. Riley Wolfe    PTS 99720    viewer performance
  2016/09/23   W. Riley Wolfe    PTS 105017   fix Sort order, for first subquery.  Incorrect rows could be selected.
  2016/09/27   W. Riley Wolfe    PTS 105017   DBA Requested changes, Also removed unusual short circuit that will rarely invoke
********************************************************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @T1 TABLE (SN INT PRIMARY KEY,
					DispatchGroupSN INT,
					DispSysID VARCHAR(20),		-- 2012.04.18 - PTS 62606
					DTSent DATETIME)			-- 05/12/2013 - PTS 68889 RRS

	DECLARE @T2 TABLE (SN INT PRIMARY KEY, 
					DTRead DATETIME, 
					DTSent DATETIME, 
					DTReceived DATETIME, 
					Folder INT,
					Status INT,
					Type INT,
					FromName VARCHAR(50),
					Subject VARCHAR(255),
					Priority INT,
					[Size] int,
					DispatchGroupSN int,
					DispSysID VARCHAR(20),		-- 2012.04.18 - PTS 62606
					FromType INT,				-- 2012.01.31 - PTS 59317
					DeliverToType INT,			-- 2012.01.31 - PTS 59317
					Kind INT				--73655
				)


	DECLARE @EXESQL NVARCHAR(MAX)				-- 2012.03.08 - PTS 61968
	DECLARE @Temp DATETIME
	DECLARE @AddressBy INT
	DECLARE @UNKNOWN_DispatchGroupSN int
	Declare @GENESIS DateTime = '19500101'
	DECLARE @SelectVerbage VARCHAR(30)

	SELECT @AddressBy = CONVERT(int, Text)
	FROM tblRs 
	WHERE KeyCode = 'ADDRESSBY'	
	
	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup 
	WHERE Name = ' UNKNOWN'
	
	-- If no login inbox was provided, go find it.
	IF ISNULL(@LoginInboxSN, 0)=0
		SELECT @LoginInboxSN = Inbox 
		FROM tblLogin
		WHERE SN = @LoginSN

--*************************************************************************************************************************************
--START 68889
--*************************************************************************************************************************************

	IF ISNULL(@MaxMessages, 0)>0
		SET @SelectVerbage = 'SELECT TOP (@MaxMessages) '
	ELSE
		SET @SelectVerbage = 'SELECT '

	SET @EXESQL = @SelectVerbage

	-------------------------------------------------------------------------------
	-- 2012.01.31 - PTS 59317 - Beg
	SET @EXESQL = @EXESQL + ' SN, DispGrpSN, DispSysID, DTSent '

	SET @EXESQL = @EXESQL + ' FROM ( ' + @SelectVerbage +' tblMessages.SN, '

	IF @AddressBy = 0   -- Driver
		-- pts 83211
		SET @EXESQL = @EXESQL + ' CASE WHEN ISNULL(tblDrivers.CurrentDispatcher, 0) = 0 THEN ' +
			'CASE WHEN ISNULL(tblTrucks.CurrentDispatcher,0)=0 THEN @UNKNOWN_DispatchGroupSN '  +
			' ELSE tblTrucks.CurrentDispatcher END ELSE tblDrivers.CurrentDispatcher END DispGrpSN,'		
	ELSE
		SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.CurrentDispatcher, @UNKNOWN_DispatchGroupSN) DispGrpSN, '
	
	SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.DispSysTruckID, '''') DispSysID, '
	SET @EXESQL = @EXESQL + ' DTSent '
	SET @EXESQL = @EXESQL + 'FROM dbo.tblMessages '
	SET @EXESQL = @EXESQL + 'INNER JOIN tblDispatchGroup ON tblMessages.Folder = tblDispatchGroup.Inbox '
	SET @EXESQL = @EXESQL + 'INNER JOIN tblDispatchLogins ON tblDispatchGroup.SN = tblDispatchLogins.DispatchGroupSN '
	SET @EXESQL = @EXESQL + 'LEFT JOIN tblHistory HIST ON HIST.MsgSN = tblMessages.SN '
	
	IF @AddressBy = 0 --Driver
		BEGIN
			SET @EXESQL = @EXESQL + 
				' LEFT JOIN tblDrivers ON tblDrivers.SN = 
					CASE WHEN ISNULL(HIST.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
						CASE WHEN ISNULL(ToDrvSN, 0) = 0 THEN FromDrvSN ELSE ToDrvSN END 
					ELSE HIST.DriverSN END '
		END
	
	SET @EXESQL = @EXESQL + 
		' LEFT JOIN tblTrucks ON tblTrucks.SN = 
			CASE WHEN ISNULL(HIST.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
				CASE WHEN ISNULL(ToTrcSN, 0) = 0 THEN FromTrcSN ELSE ToTrcSN END 
			ELSE HIST.TruckSN END '
	-- 2012.01.31 - PTS 59317 - End
	-------------------------------------------------------------------------------
	
	--If only show messages that have errors
	IF ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' JOIN dbo.tblMsgProperties on tblMessages.SN = tblMsgProperties.MsgSN '

	SET @EXESQL = @EXESQL + 'WHERE tblDispatchLogins.LoginSN = @LoginSN '

	--If only show messages that have errors
	IF ISNULL(@ErrorsOnly, 0) > 0 
		SET @EXESQL = @EXESQL + ' AND tblMsgProperties.PropSN = 6 '

	if (NOT ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (NOT ISNULL(@Latest, @GENESIS) = @GENESIS)
    SET @EXESQL = @EXESQL + ' AND ((tblmessages.DTSent >= @Earliest AND tblmessages.DTSent <= @Latest) OR (tblmessages.DTReceived >= @Earliest AND tblmessages.DTReceived <= @Latest))'
  
  SET @EXESQL = @EXESQL + '  ORDER BY DTSent DESC, SN DESC'

  SET @EXESQL = @EXESQL + ' UNION '

  SET @EXESQL = @EXESQL + @SelectVerbage + ' tblMessages.SN, '

	IF @AddressBy = 0   -- Driver
		--SET @EXESQL = @EXESQL + ' ISNULL(tblDrivers.CurrentDispatcher, @UNKNOWN_DispatchGroupSN) DispGrpSN, '
		-- pts 83211
		SET @EXESQL = @EXESQL + ' CASE WHEN ISNULL(tblDrivers.CurrentDispatcher, 0) = 0 THEN ' +
			'CASE WHEN ISNULL(tblTrucks.CurrentDispatcher,0)=0 THEN @UNKNOWN_DispatchGroupSN '  +
			' ELSE tblTrucks.CurrentDispatcher END ELSE tblDrivers.CurrentDispatcher END DispGrpSN,'		
	ELSE
		SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.CurrentDispatcher, @UNKNOWN_DispatchGroupSN) DispGrpSN, '

	SET @EXESQL = @EXESQL + ' ISNULL(tblTrucks.DispSysTruckID, '''') DispSysID, '
	SET @EXESQL = @EXESQL + ' DTSent '
	SET @EXESQL = @EXESQL + 'FROM dbo.tblMessages '
	SET @EXESQL = @EXESQL + 'LEFT JOIN tblHistory HIST ON HIST.MsgSN = tblMessages.SN '
	
	IF @AddressBy = 0 --Driver
	BEGIN
		SET @EXESQL = @EXESQL + 
			' LEFT JOIN tblDrivers ON tblDrivers.SN = 
				CASE WHEN ISNULL(HIST.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
					CASE WHEN ISNULL(ToDrvSN, 0) = 0 THEN FromDrvSN ELSE ToDrvSN END 
				ELSE HIST.DriverSN END '
	END

	SET @EXESQL = @EXESQL + 
		' LEFT JOIN tblTrucks ON tblTrucks.SN = 
			CASE WHEN ISNULL(HIST.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
				CASE WHEN ISNULL(ToTrcSN, 0) = 0 THEN FromTrcSN ELSE ToTrcSN END 
			ELSE HIST.TruckSN END '
	
	SET @EXESQL = @EXESQL + 'WHERE tblMessages.Folder = @LoginInboxSN'
	if (NOT ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (NOT ISNULL(@Latest, @GENESIS) = @GENESIS)
		SET @EXESQL = @EXESQL + ' AND ((tblmessages.DTSent >= @Earliest AND tblmessages.DTSent <= @Latest) OR (tblmessages.DTReceived >= @Earliest AND tblmessages.DTReceived <= @Latest))'

	-- PTS 91960 - 07.01.15 AB: Moved the below statement to this position
	-- to fix an issue with displaying message within a range in the viewer.
	SET @EXESQL = @EXESQL + ' ORDER BY DTSent DESC, SN DESC'
	SET @EXESQL = @EXESQL + ' ) AS A '
	SET @EXESQL = @EXESQL + ' ORDER BY DTSent DESC, SN DESC'

--*************************************************************************************************************************************
--END 68889
--*************************************************************************************************************************************

	--Fill #T1 with message SN and Dispatch Group
	INSERT INTO @T1 (
		SN,
		DispatchGroupSN,
		DispSysID,					-- 2012.01.31 - PTS 59317
		DTSent						-- 05/12/13 - PTS 68889 RRS
		)
		EXEC sp_ExecuteSQL @EXESQL, 
		@params=N'@UNKNOWN_DispatchGroupSN INT, @LoginSN INT, @LoginInboxSN INT, @MaxMessages INT, @Earliest DateTime, @Latest DateTime', 
		@UNKNOWN_DispatchGroupSN=@UNKNOWN_DispatchGroupSN,
		@LoginSN=@LoginSN,
		@LoginInboxSN=@LoginInboxSN,
		@MaxMessages = @MaxMessages,
		@Earliest = @Earliest,
		@Latest = @Latest;

	-- Go collect base message information.
	INSERT INTO @T2 
			SELECT	tblMessages.SN,
			DTRead,
			tblMessages.DTSent,
			DTReceived,
			Folder,
			Status,
			Type,
			FROMName,
			Subject,
			Priority,
			DATALENGTH(Contents) AS [Size],
			DispatchGroupSN,
			DispSysID,										-- 2012.01.31 - PTS 59317
			ISNULL(FromType,99) AS 'FromType',				-- 2012.01.31 - PTS 59317
			ISNULL(DeliverToType,99) AS 'DeliverToType',		-- 2012.01.31 - PTS 59317
			props.Kind						--PTS73655
	FROM dbo.tblMessages
		JOIN @T1 T1 on tblmessages.sn = T1.SN LEFT JOIN (SELECT  'Kind' = Value, MsgSN FROM tblMsgProperties WHERE PropSN = 2) props ON tblMessages.SN = props.MsgSN
	
	-- Go collect and return the data.
	SELECT	tblMsgPriority.Description AS Priority, 
			tblMsgType.CodeDisplay AS Type,  
			CASE WHEN tblAttachments.SN > 0 THEN 1 ELSE 0 END AS Attachment,
			T2.FromName AS ToFrom, 
			T2.Subject AS Subject,
			T2.DTReceived AS SentReceived, 
			[Size],
			'' AS [Text],  --This field is not kept by Viewer, the preview is and should always be looked up.
			'' AS [Data],  --This field is not used by Viewer
			T2.DTRead as DTRead,
			T2.SN, 
			tblMsgProperties.Value as ErrListID, 
			T2.Status AS Status,
			(select name from tbldispatchgroup (nolock) where sn = (select CurrentDispatcher from tbltrucks (nolock) where truckname = (select DispSysTruckID from tbltrucks (nolock) where truckname = T2.FromName ))) as DispatchGroup, 
			--tblDispatchGroup.Name as DispatchGroup, 
			T2.DTSent as DTSent,
			T2.DispSysID AS DispSysID,					-- 2012.01.31 - PTS 59317
			T2.FromType AS FromType,					-- 2012.01.31 - PTS 59317
			T2.DeliverToType AS DeliverToType,			-- 2012.01.31 - PTS 59317
			'Kind'=ISNULL(T2.Kind, 0)
	FROM @T2 T2 
		JOIN tblDispatchGroup on tblDispatchGroup.SN = T2.DispatchGroupSN
		JOIN tblMsgType ON tblMsgType.SN = T2.Type
		JOIN tblMsgPriority ON tblMsgPriority.SN = T2.Priority
		LEFT JOIN tblMsgProperties ON tblMsgProperties.MsgSN = T2.SN AND tblMsgProperties.PropSN = 6
		LEFT JOIN tblAttachments ON T2.SN = tblAttachments.Message  
	WHERE T2.SN IS NOT NULL

GO
GRANT EXECUTE ON  [dbo].[tm_get_inbox2] TO [public]
GO
