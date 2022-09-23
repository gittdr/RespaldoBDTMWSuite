SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GET_tblViews_DispXfcTagbySN]
( 
	@SN INT
)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_tblViews_DispXfcTagbySN]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *	 * Query tblviews for dispxfctag with SN
 *
 * RETURNS:
 *  VARCHAR(50)
 *
 * PARAMETERS:
 *	@SN INT
 * 
 * REVISION HISTORY:
 * 07/15/2015.01 - PTS91940 - APC - proc created
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

SELECT ISNULL(DispXfcTag, '') FROM tblViews WHERE SN = @sn

GO
GRANT EXECUTE ON  [dbo].[tm_GET_tblViews_DispXfcTagbySN] TO [public]
GO
