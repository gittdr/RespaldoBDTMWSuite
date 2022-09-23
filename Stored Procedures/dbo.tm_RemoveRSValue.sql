SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_RemoveRSValue](@KeyCode varchar(32), @OpEnum tinyint = 0) 
/*
NAME:
dbo.tm_RemoveRSValue

TYPE:
Stored Procedure

DESCRIPTION:
remove value from tblRS

Prams:
@KeyCode: pattern to match against same column on table random shit
@OpEnum: enum to indicate comparison operator

Change Log: 
2016/03/17 dlehr: PTS100158	init 
*/
AS

SET NOCOUNT ON 

IF ISNULL(@KeyCode, '') = ''
	BEGIN
	RAISERROR('KeyCode must contain value.', 16, 1)
	RETURN
	END
	
	DECLARE @Cmd nvarchar(512), @ParmDef nvarchar(32)
  
	SET @Cmd = 	N'DELETE FROM [dbo].[tblRS] WHERE [keyCode] '
				+ CASE 
					WHEN @OpEnum = 128 THEN N'LIKE ' 
					ELSE N'= '
				  END
				+ N'@KeyCode'

	SET @ParmDef = '@KeyCode varchar(32)'

	EXEC sp_executesql @Cmd, @ParmDef, @KeyCode = @KeyCode
GO
GRANT EXECUTE ON  [dbo].[tm_RemoveRSValue] TO [public]
GO
