SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_inbox_Only_Errors] 
						@LoginSN INT,
						@LoginInboxSN INT,
						@MaxMessages INT,
						@LastTimeStamp DATETIME,
						@NewTimeStamp DATETIME OUT,
						@Earliest DateTime = NULL,
						@Latest DateTime = NULL
AS

/* 05/13/11 LB: PTS 55668 - Added DispatchGroup and DTSent to the result set */
/* 09/14/11 DWG: PTS 58991 - Performance revisions */
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */
	Declare @GENESIS DateTime = '19500101'
	if (ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (ISNULL(@Latest, @GENESIS) = @GENESIS)
		EXEC tm_get_inbox2 @LoginSN, @LoginInboxSN, @MaxMessages, @LastTimeStamp, @NewTimeStamp OUT, 1
	Else
		EXEC tm_get_inbox2 @LoginSN, @LoginInboxSN, @MaxMessages, @LastTimeStamp, @NewTimeStamp OUT, 1, @Earliest, @Latest
SET NOCOUNT ON

GO
GRANT EXECUTE ON  [dbo].[tm_get_inbox_Only_Errors] TO [public]
GO
