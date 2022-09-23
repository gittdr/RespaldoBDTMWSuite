SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgeFolderSize_Help] ( @Folder int, @MaxSize int, @OldDate datetime )
AS

/* 10-03-01 TD: Created to workaround SQL2K INSERT/Rowcount Issue. */

SET ROWCOUNT @MaxSize

SELECT DTSent 
FROM tblMessages (NOLOCK)
WHERE Folder = @Folder AND DTSent >= @OldDate ORDER BY DTSent Desc

-- Restore rowcount
SET ROWCOUNT 0
GO
