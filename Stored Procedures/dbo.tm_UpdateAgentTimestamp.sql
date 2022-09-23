SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_UpdateAgentTimestamp](@AgentCode varchar(20), @AgentName varchar(100) = NULL )

AS

SET NOCOUNT ON

DECLARE @rowCt AS Integer,
@description AS varchar(100)

SET @description = isnull(@AgentName, 
	'Timestamp of last ' +
	CASE
		WHEN @AgentCode LIKE 'tstmpdlv%' THEN 'Delivery '
		WHEN @AgentCode LIKE 'tstmpxact%' THEN 'Transaction '
		WHEN @AgentCode LIKE 'tstmpgen%' THEN 'Generic Poller '
		ELSE 'UNKNOWN '
	END +
	'agent cycle')
SET @rowCt = (SELECT Count(keyCode) FROM tblRS (NOLOCK) 
				WHERE keyCode = @AgentCode OR 
					( keycode LIKE @AgentCode + '%' AND [description] = @description )
				)
-- INSERT the row if it's gone for some reason
IF @rowCt = 0
	INSERT INTO tblRS (keycode, text, description, static)
	VALUES (@AgentCode,GETUTCDATE(),@description,0)
ELSE
BEGIN
	IF NOT EXISTS (SELECT keycode 
						FROM tblRS (NOLOCK) 
						WHERE keycode LIKE @AgentCode + '%' AND [description] = @description
					)
		INSERT INTO tblRS (keycode, text, description, static)
		VALUES (@AgentCode + CAST(@rowCt + 1 AS varchar(2)),GETUTCDATE(),@description,0)
	ELSE
		UPDATE tblRS
		SET [text] = GETUTCDATE()
		WHERE keycode LIKE @AgentCode + '%' AND [description] = @description
END
GRANT EXECUTE ON dbo.tm_UpdateAgentTimestamp TO public
GO
GRANT EXECUTE ON  [dbo].[tm_UpdateAgentTimestamp] TO [public]
GO
