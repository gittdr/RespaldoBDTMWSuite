SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_drv_hist_Errors_Only] @DriverSN INT,
							@MaxMessages INT,
							@Earliest DateTime = NULL,
							@Latest DateTime = NULL

AS

/* 10/21/98 TD: Created to allow faster drv hist scroll retrieval. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set */
/* 09/14/11 DWG: PTS 58991 - Performance revisions.*/
/* 02/06/15 rwolfe: PTS 82965 - adding search by time range to viewer */

	Declare @GENESIS DateTime = '19500101'
	if (ISNULL(@Earliest, @GENESIS) = @GENESIS) AND (ISNULL(@Latest, @GENESIS) = @GENESIS)
		EXEC tm_get_drv_hist @DriverSN, @MaxMessages, 1  --Send 1 for Errors Only
	Else
		EXEC tm_get_drv_hist @DriverSN, @MaxMessages, 1, @Earliest, @Latest
	
GO
GRANT EXECUTE ON  [dbo].[tm_get_drv_hist_Errors_Only] TO [public]
GO
