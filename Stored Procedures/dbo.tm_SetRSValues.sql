SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 23414
--HMA 2/20/13
-- Created for use by shared file Util.Bas subroutine SetRSValue
-- however it maybe used by any code that wants to insert into tblRS
-- NOTE!!! even though the table allows it - this routine will NOT ALLOW @Keycode to be null


CREATE PROCEDURE [dbo].[tm_SetRSValues](@KEYCode varchar(10),@text varchar(50), @FileDescription varchar(100)=null, @static bit=null) 
AS

SET NOCOUNT ON 

if ISNULL(@KEYCode, '') = ''
	BEGIN
	RAISERROR('KEYCode cannot be set to null or empty string!', 16, 1)
	RETURN
	END
	
-- INSERT the row if it's not yet here
IF NOT EXISTS (SELECT keycode 
				FROM tblRS (NOLOCK) 
				WHERE keycode = @KEYCode) 
	INSERT INTO tblRS (keyCode, text, description, static)
	VALUES (@KEYCode,@text,@FileDescription,isnull(@static,1) )
ELSE
	UPDATE tblRS
	SET text = @text, description = isnull(@FileDescription,description), static = isnull(@static,static) 
	WHERE keycode = @KEYCode

GO
GRANT EXECUTE ON  [dbo].[tm_SetRSValues] TO [public]
GO
