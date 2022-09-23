SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	 
    create VIEW [dbo].[tblMessagesViewerErrView] 
	WITH SCHEMABINDING
	AS
	SELECT	SN,
			DTRead,
			DTSent,
			DTReceived,
			Folder,
			Status,
			Type,
			FROMName,
			Subject,
			Priority,
			tblMsgProperties.Value,
			convert(varchar(8000),Contents) as Contents
	FROM dbo.tblMessages (NOLOCK)
		join dbo.tblMsgProperties (NOLOCK) on tblMessages.SN = tblMsgProperties.MsgSN 
	WHERE tblMsgProperties.PropSN = 6

GO
