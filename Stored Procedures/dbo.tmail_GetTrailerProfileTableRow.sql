SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetTrailerProfileTableRow] 
		@trl_id varchar(30)

AS


BEGIN
	-------------------------------------------------------------------------------
	SELECT trl_id
	  FROM dbo.trailerprofile
	 WHERE trl_id = @trl_id 
	-------------------------------------------------------------------------------
END

GO
GRANT EXECUTE ON  [dbo].[tmail_GetTrailerProfileTableRow] TO [public]
GO
