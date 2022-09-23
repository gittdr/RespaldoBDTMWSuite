SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Flder_Cnt]
	@iFolder_SN INT

AS

	SELECT COUNT(*) 
	FROM tblMessages (nolock)
        	WHERE tblMessages.Folder = @iFolder_SN
		AND tblMessages.DTRead IS NULL

GO
GRANT EXECUTE ON  [dbo].[tm_Get_Flder_Cnt] TO [public]
GO
