SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAttachmentsbyDataSN]
	@DataSN int

AS

SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED clsAttachments uses recordset AddNew and Update

SELECT SN
FROM dbo.tblAttachments 
WHERE [DataSN] = @DataSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAttachmentsbyDataSN] TO [public]
GO
