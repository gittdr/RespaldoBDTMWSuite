SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_purge_TMApplicationLog]

AS

	DECLARE @maxSNToDelete int, 
			@BatchSize int
			
	SELECT @maxSNToDelete = MIN(SN) FROM tblTMApplicationLog
	SELECT @BatchSize = TEXT from tblRS where keyCode = 'AppLogPurg'
	
	SET @maxSNToDelete = @maxSNToDelete + @BatchSize
	
	SELECT @maxSNToDelete
	
	DELETE FROM tblTMApplicationLog
	WHERE SN <= @maxSNToDelete
	
GO
GRANT EXECUTE ON  [dbo].[tm_purge_TMApplicationLog] TO [public]
GO
