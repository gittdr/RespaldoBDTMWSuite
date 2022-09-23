SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ArchiveAndPurge_tblMessages] 
	(@SentAge_Archive INT, @HistAge_Archive INT, @InboxAge_Archive INT, @Age_Purge INT, @Rate INT)
	
AS

/*
	Purpose:  Archives AND Purges FROM tblMessages according to the following settings based on parameters
	
	Parameters:
		SentAge_Archive - Messages in a SENT folder and OLDER than x days will be moved to the Archive table
		HistAge_Archive - Messages in a HIST folder and OLDER than x days will be moved to the Archive table
		Inbox_Archive - Messages in a INBOX folder and OLDER than x days will be moved to the Archive table AND OutBox Notes - Always Archived in entirety
		Age_Purge - Messages in the archive tables and OLDER than x days will be DELETED FROM the Archive table
		Rate - The maximum number of records which will be Archived or Purged from any one catagory during a single execution
		
	Change History:
		07/07/11 - PTS 54597 - LAB - Created
		05/13/14 - PTS 75292 - HMA - adding NC indexes to #temp tbls
*/

	CREATE Table #tblMessages_Archive (sn INT)
	CREATE Table #tblMessages_Purge (sn INT)
	
	--PTS 75292
	CREATE NONCLUSTERED INDEX [idx_tmp_Archive]
	ON [#tblMessages_Archive] ([sn])
	CREATE NONCLUSTERED INDEX [idx_tmp_Purge]
	ON [#tblMessages_Purge] ([sn])

	DECLARE @DtSent_Archive DATETIME
	DECLARE @DtHist_Archive DATETIME
	DECLARE @DtInbox_Archive DATETIME
	DECLARE @Dt_Purge DATETIME
	DECLARE @Archive_Count VARCHAR(10)
	DECLARE @Purge_Count VARCHAR(10)

	SET ROWCOUNT @Rate

/*** Archive Staging Start ***/
	--SENT
	IF @SentAge_Archive > 0
	BEGIN
		SET @DtSent_Archive = DATEADD(DAY,-@SentAge_Archive,GETDATE())
		PRINT @DtSent_Archive
		PRINT 'SENT Archive Enabled'
		
		INSERT INTO #tblMessages_Archive (sn)
		SELECT tblMessages.SN 
		FROM tblMessages (NOLOCK)
			JOIN tblFolders (NOLOCK) ON tblMessages.Folder = tblFolders.SN
		WHERE tblfolders.Name = 'SENT'
			AND DtSent < @DTSent_Archive
		
		PRINT 'SENT Archive Staging Complete' 
	END
	ELSE
	BEGIN
		Print 'SENT Archive Disabled'
	END
	
	--HIST
	IF @HistAge_Archive > 0
	BEGIN
		SET @DtHist_Archive = DATEADD(DAY,-@HistAge_Archive,GETDATE())
		
		PRINT 'HIST Archive Enabled'
		
		INSERT INTO #tblMessages_Archive (sn)
		SELECT tblmessages.SN 
		FROM tblMessages (NOLOCK)
			JOIN tblFolders (NOLOCK) ON tblMessages.Folder = tblFolders.SN
		WHERE tblfolders.Name = 'History'
			AND DtSent < @DTHist_Archive 
			
		PRINT 'HIST Archive Staging Complete'
		
	END
	ELSE
	BEGIN
		Print 'HIST Archive Disabled'
	END

	--INBOX/OUTBOX
	IF @InboxAge_Archive > 0
	BEGIN
		SET @DtInbox_Archive = DATEADD(day,-@InboxAge_Archive,GETDATE())
		
		PRINT 'INBOX Archive Enabled'
		
		INSERT INTO #tblMessages_Archive (sn)
		SELECT tblmessages.SN 
		FROM tblMessages (NOLOCK)
			JOIN tblFolders (NOLOCK) on tblMessages.Folder = tblFolders.SN
		WHERE tblfolders.Name = 'INBOX'
			AND DtSent < @DTInbox_Archive 

		INSERT INTO #tblMessages_Archive (sn)
		SELECT tblmessages.SN 
		FROM tblMessages (NOLOCK)
			JOIN tblFolders (NOLOCK) on tblMessages.Folder = tblFolders.SN
		WHERE tblfolders.Name IN (SELECT 'Group: ' + AddressName + '''s Inbox' FROM tblAddresses WHERE AddressType = 3)
			AND DtSent < @DTInbox_Archive 
		
		PRINT 'INBOX Archive Staging Complete'
		
		
		PRINT 'OUTBOX Archive Enabled (INBOX Automatically Enables OUTBOX)'
		
		INSERT INTO #tblMessages_Archive (sn)
		SELECT tblmessages.SN 
		FROM tblMessages (NOLOCK)
			JOIN tblFolders (NOLOCK) on tblMessages.Folder = tblFolders.SN
		WHERE tblfolders.Name = 'OUTBOX'
			AND DtSent < DATEADD(DAY,-1,GETDATE())
		
		PRINT 'OUTBOX Archive Staging Complete'
	END
	ELSE
	BEGIN
		Print 'INBOX Archive Disabled'
	END

	SELECT @Archive_Count = COUNT(DISTINCT SN) FROM #tblMessages_Archive
	
	PRINT 'Archive Count: ' + @Archive_Count 
	
/*** Archive Staging End ***/

/*** Purge Staging Start ***/
	IF @Age_Purge > 0
	BEGIN
		SET @Dt_Purge = DATEADD(day,-@Age_Purge,GETDATE())
		
		PRINT 'PURGE Enabled'
		
		INSERT INTO #tblMessages_Purge(sn)
		SELECT tblmessages_archive.SN 
		FROM tblMessages_archive (NOLOCK)
		WHERE DtSent < @Dt_Purge 
			
		PRINT 'PURGE Staging Complete'
	END
	ELSE
	BEGIN
		Print 'Purge Disabled'
	END
	
	SELECT @Purge_Count = COUNT(DISTINCT SN) FROM #tblMessages_Purge
	
	PRINT 'Purge Count: ' + @Purge_Count 


/*** Purge Staging End ***/	

/*** Archive Processing Start ***/
	SET ROWCOUNT 0
	
	IF EXISTS (SELECT NULL FROM #tblMessages_Archive)
	BEGIN
		INSERT INTO tblMessages_Archive 
				([SN] ,
				[Type] ,
				[Status] ,
				[Priority] ,
				[FROMType] ,
				[DeliverToType] ,
				[DTSent] ,
				[DTReceived] ,
				[DTRead],
				[DTAcknowledged],
				[DTTransferred],
				[Folder],
				[Contents],
				[FROMName],
				[Subject],
				[DeliverTo],
				[HistDrv],
				[HistDrv2],
				[HistTrk],
				--[ts],
				[OrigMsgSN],
				[Receipt],
				[DeliveryKey],
				[Position],
				[PositionZip],
				[NLCPosition],
				[NLCPositionZip],
				[VehicleIgnition],
				[Latitude],
				[Longitude],
				[DTPosition],
				[SpecialMsgSN],
				[ResubmitOf],
				[Odometer],
				[ReplyMsgSN],
				[ReplyMsgPage],
				[ReplyFormID],
				[ReplyPriority],
				[ToDrvSN],
				[ToTrcSN],
				[FROMDrvSN],
				[FROMTrcSN],
				[MaxDelayMins],
				[BaseSN],
				[McuId],
				[Export],
				ArchiveDate)
		SELECT tblmessages.[SN] ,
				[Type] ,
				[Status] ,
				[Priority] ,
				[FROMType] ,
				[DeliverToType] ,
				[DTSent] ,
				[DTReceived] ,
				[DTRead],
				[DTAcknowledged],
				[DTTransferred],
				[Folder],
				[Contents],
				[FROMName],
				[Subject],
				[DeliverTo],
				[HistDrv],
				[HistDrv2],
				[HistTrk],
				--[ts],
				[OrigMsgSN],
				[Receipt],
				[DeliveryKey],
				[Position],
				[PositionZip],
				[NLCPosition],
				[NLCPositionZip],
				[VehicleIgnition],
				[Latitude],
				[Longitude],
				[DTPosition],
				[SpecialMsgSN],
				[ResubmitOf],
				[Odometer],
				[ReplyMsgSN],
				[ReplyMsgPage],
				[ReplyFormID],
				[ReplyPriority],
				[ToDrvSN],
				[ToTrcSN],
				[FROMDrvSN],
				[FROMTrcSN],
				[MaxDelayMins],
				[BaseSN],
				[McuId],
				[Export],
				GETDATE() 
		FROM tblMessages (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblMessages.SN
		WHERE #tblMessages_Archive.SN NOT IN (SELECT SN FROM tblMessages_Archive)
		
		INSERT INTO tblMsgProperties_archive 
			([MsgSN],
			[PropSN],
			[Value])
		SELECT	
			[MsgSN],
			[PropSN],
			[Value]
		FROM tblMsgProperties (NOLOCK)
			JOIN #tblMessages_Archive on #tblMessages_Archive.sn = tblMsgProperties.MsgSN
		WHERE #tblMessages_Archive.sn NOT IN (SELECT MsgSN FROM tblmsgproperties_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)

		INSERT INTO tblAttachments_archive 
			([SN],
			[Message],
			[InsertionPt],
			[DataSN],
			[InLine],
			[Path])
		SELECT  tblattachments.[SN],
			[Message],
			[InsertionPt],
			[DataSN],
			[InLine],
			[Path]
		FROM tblattachments (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblAttachments.Message
		WHERE #tblMessages_Archive.sn NOT IN (SELECT SN FROM tblAttachments_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)
			
		INSERT INTO tblhistory_archive 
			([SN] ,
			[DriverSN],
			[TruckSN],
			[MsgSN],
			[Chached])
		SELECT tblHistory.[SN] ,
			[DriverSN],
			[TruckSN],
			[MsgSN],
			[Chached]
		FROM tblHistory (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblHistory.MsgSN
		WHERE #tblMessages_Archive.sn NOT IN (SELECT MsgSN FROM tblHistory_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)

		INSERT INTO tblAttachmentData_archive 
			([SN],
			[Data],
			[Filename]--,
			--[ts]
			)
		SELECT tblAttachmentData.[sn],
			[Data],
			[Filename]--,
			--[ts]
		FROM tblAttachmentData (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblAttachmentData.SN
		WHERE #tblMessages_Archive.sn NOT IN (SELECT SN FROM tblAttachmentData_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)
		
		INSERT INTO tblErrorData_archive 
			([SN],
			[VBError],
			[Description],
			[Source],
			[Timestamp],
			[ErrListID],
			--[ts],
			[View],
			[Page])
		SELECT tblErrorData.[SN],
			[VBError],
			[Description],
			[Source],
			[Timestamp],
			[ErrListID],
			--[ts],
			[View],
			[Page]
		FROM tblErrorData (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblErrorData.SN
		WHERE #tblMessages_Archive.sn NOT IN (SELECT SN FROM tblErrorData_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)
		
		INSERT INTO tblMsgShareData_archive 
			([OrigMsgSN] ,
			[MsgImage] ,
			[ReadByName] ,
			[ReadByType] ,
			[DispSysKey1] ,
			[DispSysKey2] ,
			[DispSysKeyType] )
		SELECT [OrigMsgSN] ,
			[MsgImage] ,
			[ReadByName] ,
			[ReadByType] ,
			[DispSysKey1] ,
			[DispSysKey2] ,
			[DispSysKeyType] 
		FROM tblMsgShareData (NOLOCK)
		JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblMsgShareData.[OrigMsgSN]
		WHERE #tblMessages_Archive.sn NOT IN (SELECT [OrigMsgSN] FROM tblMsgShareData_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive)
		
		INSERT INTO tblTo_archive
			([SN],
			[Message],
			[ToName],
			[ToType],
			[DTTransferred],
			[IsCC])
		SELECT tblTo.[SN],
			[Message],
			[ToName],
			[ToType],
			[DTTransferred],
			[IsCC]
		FROM tblTo (NOLOCK)
			JOIN #tblMessages_Archive on #tblMessages_Archive.sn = tblTo.Message
		WHERE #tblMessages_Archive.sn NOT in (SELECT SN FROM tblTo_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive) 
		
		INSERT INTO tblexternalids_archive 
			([MCommTypeSN] ,
			[ExternalID] ,
			[TmailObjType] ,
			[TMailObjSN] ,
			[PageNum] ,
			[CabUnitSN] ,
			[MAPIAddressee] ,
			[InstanceID] ,
			[DateAndTime] )
		SELECT [MCommTypeSN] ,
			[ExternalID] ,
			[TmailObjType] ,
			[TMailObjSN] ,
			[PageNum] ,
			[CabUnitSN] ,
			[MAPIAddressee] ,
			[InstanceID] ,
			[DateAndTime]
		FROM tblexternalids (NOLOCK)
			JOIN #tblMessages_Archive ON #tblMessages_Archive.sn = tblexternalids.TMailObjSN
		WHERE tblexternalids.TmailObjType = 'MSG'
			AND #tblMessages_Archive.sn NOT IN (SELECT tmailobjsn FROM tblexternalids_archive)
			AND #tblMessages_Archive.sn IN (SELECT SN FROM tblMessages_archive) 

		DELETE FROM [tblHistory] WHERE tblhistory.MsgSN in (SELECT MsgSN FROM [tblHistory_archive])
		DELETE FROM [tblMsgShareData] WHERE [tblMsgShareData].OrigMsgSN in (SELECT OrigMsgSN FROM [tblMsgShareData_archive])
		DELETE FROM [tblAttachmentData] WHERE sn in (SELECT sn FROM [tblAttachmentData_archive])
		DELETE FROM [tblAttachments] WHERE sn in (SELECT sn FROM [tblAttachments_Archive]) and Message NOT IN (select OrigMsgSN from tblMessages)
		DELETE FROM [tblErrorData] WHERE sn in (SELECT sn FROM [tblErrorData_archive])
		DELETE FROM [tblMsgProperties] WHERE msgsn in (SELECT msgsn FROM [tblMsgProperties_Archive])
		DELETE FROM [tblTo] WHERE sn in (SELECT sn FROM [tblTo_archive])
		DELETE FROM [tblexternalids] WHERE TMailObjSN in (SELECT TMailObjSN FROM [tblexternalids_archive])
		DELETE FROM tblMessages WHERE SN in (SELECT SN FROM tblmessages_archive)

	END
/*** Archive Processing End ***/

/*** Purge Processing Start ***/

	DELETE FROM [tblHistory_archive] WHERE MsgSN in (SELECT SN FROM [#tblMessages_Purge])
	DELETE FROM [tblMsgShareData_archive] WHERE OrigMsgSN in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblAttachmentData_archive] WHERE sn in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblAttachments_archive] WHERE sn in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblErrorData_archive] WHERE sn in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblMsgProperties_archive] WHERE msgsn in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblTo_archive] WHERE sn in (SELECT sn FROM [#tblMessages_Purge])
	DELETE FROM [tblexternalids_archive] WHERE TMailObjSN in (SELECT SN FROM [#tblMessages_Purge])
	DELETE FROM tblMessages_archive WHERE SN in (SELECT SN FROM [#tblMessages_Purge]) 

/*** Purge Processing End ***/
GO
