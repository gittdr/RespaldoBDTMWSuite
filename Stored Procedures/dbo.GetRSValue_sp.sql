SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetRSValue_sp] 
	@sKeyCode varchar(10),
	@sResult varchar(255) out

AS
SET NOCOUNT ON

SELECT @sResult = ISNULL(text, '') 
FROM tblRS (NOLOCK)
WHERE keyCode = @sKeyCode
GO
GRANT EXECUTE ON  [dbo].[GetRSValue_sp] TO [public]
GO
