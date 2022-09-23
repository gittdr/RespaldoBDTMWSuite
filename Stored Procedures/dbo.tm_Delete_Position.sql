SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Delete_Position]	
						@sPositionSN varchar(12),
						@sFlags varchar(12)
AS

SET NOCOUNT ON

	DECLARE @iPositionSN int, 
			@iFlags int

	if ISNULL(@sPositionSN, '') = ''
		BEGIN
		RAISERROR ('tm_Delete_Position:Position SN must be passed in.', 16, 1)
		RETURN
		END
	
	SET @iPositionSN = CONVERT(int, @sPositionSN)
	SET @iFlags = CONVERT(int, @sFlags)

	DELETE 
		FROM tblLatLongs 
		WHERE SN = @sPositionSN
	
GO
GRANT EXECUTE ON  [dbo].[tm_Delete_Position] TO [public]
GO
