SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeMsgs2] ( @SentAge int, @HistAge int, @InboxAge int)

AS


SET NOCOUNT ON

DECLARE @WorkFolder int, @OldDate datetime, @vi_debug int

SET @vi_debug = 0

IF (@vi_debug > 0)
	SELECT 'Input parms' StepDesc, @SentAge SentAge, @HistAge HistAge, @InboxAge InboxAge

-- Purge Sent folders
IF @SentAge <> -1
BEGIN
	IF (@vi_debug > 0)
		SELECT 'In Sent' StepDesc

	SELECT @OldDate = DATEADD(dd, -@SentAge, GetDate() )

	IF (@vi_debug > 0)
		SELECT 'Oldest Date' StepDesc, @OldDate OldDate

	SELECT @WorkFolder = ISNULL(MIN(Sent), 0)
		FROM tblLogin (NOLOCK)

	WHILE @WorkFolder > 0
	BEGIN
		IF (@vi_debug > 0)
			SELECT 'Sent Processing' StepDesc, @WorkFolder WorkFolder
	
		execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
	
		SELECT @WorkFolder = ISNULL(MIN(Sent), 0)
			FROM tblLogin (NOLOCK)
			WHERE Sent > @WorkFolder
	END
END

-- Purge History folder
IF @HistAge <> -1
BEGIN
	IF (@vi_debug > 0)
		SELECT 'In Hist' StepDesc

	SELECT @OldDate = DATEADD(dd, -@HistAge, GetDate() )

	IF (@vi_debug > 0)
		SELECT 'Oldest Date' StepDesc, @OldDate OldDate

	SELECT @WorkFolder = ISNULL(CONVERT(int, Text), 0)
		FROM tblRS (NOLOCK)
		WHERE keyCode = 'HISTORY'

	IF (@vi_debug > 0)
		SELECT 'Hist Processing' StepDesc, @WorkFolder WorkFolder

	execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
END

-- Purge Inbox folders
IF @InboxAge <> -1
BEGIN
	IF (@vi_debug > 0)
		SELECT 'In Inbox' StepDesc

	SELECT @OldDate = DATEADD(dd, -@InboxAge, GetDate() )

	IF (@vi_debug > 0)
		SELECT 'Oldest Date' StepDesc, @OldDate OldDate

	SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
		FROM tblLogin (NOLOCK)

	WHILE @WorkFolder > 0
	BEGIN
		IF (@vi_debug > 0)
			SELECT 'Inbox Processing' StepDesc, @WorkFolder WorkFolder

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
		IF (@vi_debug > 0)
			SELECT 'Inbox Disp Processing' StepDesc, @WorkFolder WorkFolder

		execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
	
		SELECT @WorkFolder = ISNULL(MIN(Inbox), 0)
			FROM tblDispatchGroup (NOLOCK)
			WHERE Inbox > @WorkFolder
	END
END
GO
