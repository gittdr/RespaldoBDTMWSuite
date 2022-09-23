SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_folder_errors_only]	
						@FolderSN INT,
						@MaxMessages INT,
						@Earliest DateTime = NULL,
						@Latest DateTime = NULL

AS

/* 10/21/98 TD: Created to allow faster general scroll retrieval. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroup and DTSent to the result set */
/* 09/14/11 DWG: PTS 58991 - Performance revisions.*/
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */

	Declare @GENESIS DateTime = '19500101'
	--No reason to duplicate code for just a join, call Get Folder with Errors Only turned on
	if (ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (ISNULL(@Latest, @GENESIS) = @GENESIS)
		EXEC tm_get_folder @FolderSN, @MaxMessages, 1 --Send in 1 for Errors Only
	Else
		EXEC tm_get_folder @FolderSN, @MaxMessages, 1, @Earliest, @Latest

GO
GRANT EXECUTE ON  [dbo].[tm_get_folder_errors_only] TO [public]
GO
