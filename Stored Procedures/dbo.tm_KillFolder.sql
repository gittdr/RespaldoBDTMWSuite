SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_KillFolder] ( @Folder int, @LeaveRootFolder int )

AS

SET NOCOUNT ON 

DECLARE @Work int

-- Recurse into subfolders.
SELECT @Work = ISNULL( Min(SN), 0) 
FROM tblFolders (NOLOCK)
WHERE Parent = @Folder
WHILE @Work > 0
BEGIN
	EXECUTE dbo.tm_KillFolder @Work, 0

	SELECT @Work = ISNULL( Min(SN), 0) 
	FROM tblFolders (NOLOCK)
	WHERE Parent = @Folder
END

-- Now kill messages.
SELECT @Work = IsNull(MIN(SN), 0)
	FROM tblMessages (NOLOCK)
	WHERE Folder = @Folder
WHILE @Work > 0
BEGIN
	execute dbo.tm_KillMsg @Work

	SELECT @Work = IsNull(MIN(SN), 0)
		FROM tblMessages (NOLOCK)
		WHERE Folder = @Folder
		AND SN > @Work
END

IF @LeaveRootFolder = 0
	DELETE FROM tblFolders WHERE SN = @Folder


GO
GRANT EXECUTE ON  [dbo].[tm_KillFolder] TO [public]
GO
