SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tm_PurgeInit    Script Date: 10/3/01 ******/
CREATE PROCEDURE [dbo].[tm_PurgeInit] ( @Folder int OUT )
AS

/* 10-3-01 TD: Creates the purge directory for the new purge routines. */
SET NOCOUNT ON

DECLARE @WorkDir int

SELECT @WorkDir = ISNULL(MIN(working), 0) 
FROM tblServer (NOLOCK)
WHERE ServerCode = 'P'

IF NOT EXISTS (SELECT * 
				FROM tblFolders (NOLOCK)
				WHERE SN = @WorkDir)
	SELECT @WorkDir = 0

IF @WorkDir = 0
	BEGIN
	INSERT INTO tblFolders (Parent, Name, Owner, IsPublic) VALUES (NULL, 'Purge Work', 0, 0)
	SELECT @WorkDir = @@IDENTITY
	IF EXISTS (SELECT * 
				FROM tblServer (NOLOCK)
				WHERE ServerCode = 'P')
		UPDATE tblServer SET Working = @WorkDir WHERE ServerCode = 'P'
	ELSE
		INSERT INTO tblServer (ServerCode, Working) VALUES ('P', @WorkDir)
	END

SELECT @Folder = @WorkDir
GO
