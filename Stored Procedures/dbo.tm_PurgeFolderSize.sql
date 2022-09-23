SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeFolderSize] ( @Folder int, @MaxSize int, @OldDate datetime )

AS

/* 05-25-01 DAG: Converting for international date format */
/* 10-03-01 TD: Modified to workaround SQL2K Insert/RowCount issue. */

SET NOCOUNT ON

DECLARE @WorkFolder int

CREATE TABLE #tmp (DTSent datetime)

-- Purges messages older than olddate in the given folder which have more than MaxSize more recent messages.
IF ISNull(@OldDate, '19500101') < '19510101'
	SELECT @OldDate = '19500101'

-- Reset OldDate based on MaxSize
IF ISNULL(@MaxSize, 0)>0
	BEGIN
	INSERT INTO #tmp EXECUTE dbo.tm_PurgeFolderSize_Help @Folder, @MaxSize, @OldDate
	SELECT @OldDate = ISNULL(Min(DTSent), @OldDate) FROM #tmp
	END

execute dbo.tm_PurgeFolderUnread @Folder, @OldDate
GO
