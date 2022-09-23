SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	
    CREATE VIEW [dbo].[tblMessagesViewerView] 
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
			convert(varchar(8000),Contents) as Contents
	FROM dbo.tblMessages (NOLOCK)


GO
