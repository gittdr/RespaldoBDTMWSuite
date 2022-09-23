SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Purge_tblLatLongs_Help]	@Unit int, @RowCount int

AS


SET ROWCOUNT @RowCount

SELECT DateAndTime
	FROM tblLatlongs (NOLOCK)
	WHERE Unit = @Unit
	ORDER BY DateAndTime DESC

SET ROWCOUNT 0
GO
