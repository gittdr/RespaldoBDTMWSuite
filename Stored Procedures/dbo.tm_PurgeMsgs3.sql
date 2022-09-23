SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeMsgs3] ( @SentAge int, @HistAge int, @InboxAge int, @MaxInboxSize int, @SizePurgeAge int)

AS

SET NOCOUNT ON

DECLARE @WorkFolder int, @OldDate datetime

-- Purge Sent folders
IF @SentAge <> -1
BEGIN
	SELECT @OldDate = DATEADD(dd, -@SentAge, GetDate() )
	SELECT @WorkFolder = ISNULL(MIN(Sent), 0)
	FROM tblLogin (NOLOCK)
	WHILE @WorkFolder > 0
BEGIN
	execute dbo.tm_PurgeFolder @WorkFolder, @OldDate

	SELECT @WorkFolder = ISNULL(MIN(Sent), 0)
	FROM tblLogin (NOLOCK)
	WHERE Sent > @WorkFolder
END
END

-- Purge History folder
IF @HistAge <> -1
BEGIN
	SELECT @OldDate = DATEADD(dd, -@HistAge, GetDate() )
	SELECT @WorkFolder = ISNULL(CONVERT(int, Text), 0)
	FROM tblRS (NOLOCK)
	WHERE keyCode = 'HISTORY'
	execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
END

-- Purge Inbox folders
IF @InboxAge <> -1
BEGIN
	SELECT @OldDate = DATEADD(dd, -@InboxAge, GetDate() )
	SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
	FROM tblLogin (NOLOCK)
	WHILE @WorkFolder > 0
BEGIN
	execute dbo.tm_PurgeFolder @WorkFolder, @OldDate

	SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
	FROM tblLogin (NOLOCK)
	WHERE Inbox > @WorkFolder
END

-- Purge Dispatch Group Inboxes
SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
FROM tblDispatchGroup (NOLOCK)
WHILE @WorkFolder > 0
BEGIN
	execute dbo.tm_PurgeFolder @WorkFolder, @OldDate

	SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
	FROM tblDispatchGroup (NOLOCK)
	WHERE Inbox > @WorkFolder
END
END

-- Purge by inbox size
IF @SizePurgeAge <> -1
BEGIN
	SELECT @OldDate = DATEADD(dd, -@SizePurgeAge, GetDate() )
	SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
	FROM tblLogin (NOLOCK)
	WHILE @WorkFolder > 0
	BEGIN
		execute dbo.tm_PurgeFolderSize @WorkFolder, @MaxInboxSize, @OldDate

		SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
		FROM tblLogin (NOLOCK)
		WHERE Inbox > @WorkFolder
	END
END
GO
