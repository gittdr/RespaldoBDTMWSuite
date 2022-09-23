SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- PTS 68051/23414 - HMA - 3/21/13
-- Created for use by shared file Util.Bas subroutine SetFileVersionsValue
-- however it maybe used by any code that wants to insert into tblFileVersions

create PROCEDURE [dbo].[TM_SetFileVersionsValue](@machine varchar(30),@filecode varchar(30),@textdate varchar(30), @Version varchar(50))
AS

SET NOCOUNT ON 

if ISNULL(@filecode, '') = ''
	BEGIN
	RAISERROR('filecode cannot be set to null or empty string!', 16, 1)
	RETURN
	END

if ISNULL(@machine, '') = ''
	BEGIN
	RAISERROR('machine cannot be set to null or empty string!', 16, 1)
	RETURN
	END
	
if ISNULL(@textdate, '') = ''
	BEGIN
	RAISERROR('textdate cannot be set to null or empty string!', 16, 1)
	RETURN
	END
	
if ISNULL(@Version, '') = ''
	BEGIN
	RAISERROR('Version cannot be set to null or empty string!', 16, 1)
	RETURN
	END			
	
-- INSERT the row if it's not yet here
IF NOT EXISTS (SELECT FileCode 
				FROM tblFileVersions (NOLOCK) 
				WHERE (filecode = @filecode) and (machine = @Machine) ) 
	INSERT INTO tblFileVersions (machine, Filecode, DateText, Version)
	VALUES (@machine ,@filecode ,@textdate, @Version )
ELSE
	UPDATE tblFileVersions
	SET DateText = @textdate, Version = @Version
	WHERE (filecode = @filecode) and (machine = @Machine) 


GO
GRANT EXECUTE ON  [dbo].[TM_SetFileVersionsValue] TO [public]
GO
