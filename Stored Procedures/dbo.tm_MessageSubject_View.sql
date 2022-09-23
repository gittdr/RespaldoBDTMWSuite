SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MessageSubject_View] @sSN varchar(15),
											@NewText varchar(255),
											@sFlags varchar(20)
AS

/***************************************************************
* Flags:
*	no flag or zero	- replace subject with New Text
*	+1	Append the New Text to the existing subject
*	+2	Prepend the New Text to the existing subject
***************************************************************/

SET NOCOUNT ON

DECLARE @SN int,
		@iFlags int

IF ISNUMERIC(@sSN) > 0 
	SELECT @SN = CONVERT(int, @sSN)
ELSE
  BEGIN
	RAISERROR ('Invalid Message SN: (%s).', 16, 1, @sSN)
	RETURN
  END

SET @iFlags = 0
IF ISNUMERIC(@sFlags) > 0 
	SELECT @iFlags = CONVERT(int, @sFlags)
ELSE
	SET @iFlags = 0

IF (@iFlags = 0)
	-- Default is to replace the existing subject with the New Text
	UPDATE tblMessages
	SET Subject = @NewText
	WHERE SN = @SN
ELSE IF (@iFlags & 1) <> 0
	-- Append the New Text to the existing subject
	UPDATE tblMessages
	SET Subject = LEFT(Subject + ' ' + @NewText, 254)
	WHERE SN = @SN
ELSE IF (@iFlags & 2) <> 0
	-- Prepend the New Text to the existing subject
	-- Append the New Text to the existing subject
	UPDATE tblMessages
	SET Subject = LEFT(@NewText + ' ' + Subject, 254)
	WHERE SN = @SN
GO
GRANT EXECUTE ON  [dbo].[tm_MessageSubject_View] TO [public]
GO
