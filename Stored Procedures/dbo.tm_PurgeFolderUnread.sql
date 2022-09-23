SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeFolderUnread] ( @Folder int, @OldDate DateTime )
AS
SET NOCOUNT ON

DECLARE @WorkMsg int
DECLARE @WorkFolder int


/* 05-25-01 DAG: Converting for international date format */
/* 10-03-01 TD: Converted to new Quick Purge methodology. */

execute dbo.tm_PurgeInit @WorkFolder OUT
IF @WorkFolder = 0
	BEGIN
	RAISERROR ('Abort purge.  Initialization Failed', 16, 1)
	RETURN
	END

IF ISNull(@OldDate, '19500101') < '19510101'
	SELECT @OldDate = '19500101'

UPDATE tblMessages 
	SET Folder = @WorkFolder 
	WHERE Folder = @Folder 
	AND DTSent < @OldDate
	AND ISNULL(DTRead, '21551231') < GetDate()

EXEC dbo.tm_FastKillFolder @WorkFolder, 1
GO
