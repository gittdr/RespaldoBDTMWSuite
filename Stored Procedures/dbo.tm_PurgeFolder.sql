SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tm_PurgeFolder    Script Date: 8/24/99 10:30:13 PM ******/
CREATE PROCEDURE [dbo].[tm_PurgeFolder] ( @Folder int, @OldDate DateTime )

AS

/* 05-25-01 DAG: Converting for international date format */
/* 10-03-01 TD: Converted to new Quick Purge methodology. */

SET NOCOUNT ON

DECLARE @WorkFolder int

execute dbo.tm_PurgeInit @WorkFolder OUT
IF @WorkFolder = 0
	BEGIN
	RAISERROR ('Abort purge.  Initialization Failed', 16, 1)
	RETURN
	END
UPDATE tblMessages SET Folder = @WorkFolder WHERE Folder = @Folder AND DTSent < @OldDate
execute dbo.tm_FastKillFolder @WorkFolder, 1
GO
