SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAttachmentsbySNData]
	@SN int

AS

SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED clsAttachments uses recordset AddNew and Update

SELECT SN, InLine, DataSN, [Message], InsertionPt 
FROM dbo.tblAttachments 
WHERE [SN] = @SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAttachmentsbySNData] TO [public]
GO
