SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_tblAttachmentDatabySN]
	@SN Int
	
AS

SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED clsAttachments uses recordset AddNew and Update

SELECT SN, FileName, Data 
FROM dbo.tblAttachmentData 
WHERE SN = @SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_tblAttachmentDatabySN] TO [public]
GO
