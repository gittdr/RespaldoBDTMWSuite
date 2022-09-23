SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_StripCommentsFromSQLString]
	(@text Varchar(8000))

RETURNS Varchar(8000)
AS
BEGIN
Declare @work Varchar(8000)
Declare @i int
Set @work=''
Set @i=1
While @I<Len(@Text)
BEGIN
	If (Substring(@Text,@i,2)='/*')
		BEGIN
			WHILE Substring(@Text,@i,2)<>'*/'
			BEGIN
				Set @i=@i +1
				IF @i>Len(@Text) BREAK
			END
			Set @i=@i +1

			GOTO BOTTOM_LOOP
		END
	If (Substring(@Text,@i,2)='--')
		BEGIN
			WHILE ASCII(Substring(@Text,@i+1,1))>=32
			BEGIN
				Set @i=@i +1
				IF @i>Len(@Text) BREAK
			END
			GOTO BOTTOM_LOOP
		END

	Set @Work= @Work	+ substring(@Text,@i,1)

BOTTOM_LOOP:
	Set @i=@i +1
END

Return @work

END
GO
GRANT EXECUTE ON  [dbo].[fnc_StripCommentsFromSQLString] TO [public]
GO
