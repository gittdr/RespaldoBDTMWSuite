SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[mbi_parse_str] @cInputStr char(255) output,
                               @cDelimiter char(1),
                               @cOutputStr char(255) output
AS
BEGIN

/************************************************************************************
	NAME:		cry_drttadh_driver_training
				- driver training by training item
	SOURCE:
	CALLED BY:	Crystal report drtradh.rpt
	TYPE:		stored procedure
	DATABASE:	REVENUE
	PURPOSE:	Return driver training records
	DEPENDANCIES:	None
	PROCESS:	Select data by joining tables

	REVISION LOG

    DATE        WHO         REASON
    ----        ---         ------

    ????        ????        Creation
    Jul-17-1998 djohnson    Sybase 11.5 does not handle the RIGHT function in the same way as 11.02
                            Needed to replace it with a second SUBSTRING function.
    Jul-27-1998 djohnson    Increased input and output arguments to max. 255 chars.
    May-26-1999 kbaldwin    This stored procedure is used in a number of different databases.
                            Because of the 11.5 upgrade and the changes to the way Sybase
                            deals with string functions changes needed to be made to the
                            procedure to accomodate those changes. The pathes diverged and
                            the version kept in FSS and Revenue became different. This version
                            is the version from the revenue database complete with changes
                            that will accomodate the 11.5 upgrade and string function changes.
----------
Execute:
----------

DECLARE @cInputStr char(128),
	@cOutputStr char(128)
SELECT @cInputStr = "7C,45,WHAT"
EXEC mbi_parse_str @cInputStr output,',',@cOutputStr output
SELECT @cInputStr
SELECT @cOutputStr

EXEC mbi_parse_str @cInputStr output,',',@cOutputStr output
SELECT @cInputStr
SELECT @cOutputStr

EXEC mbi_parse_str @cInputStr output,',',@cOutputStr output
SELECT @cInputStr
SELECT @cOutputStr

*************************************************************************************/

DECLARE @nIndex	int

SELECT @nIndex = CHARINDEX( @cDelimiter, @cInputStr )

IF @nIndex = 0
  SELECT @cOutputStr = @cInputStr
ELSE
BEGIN
  SELECT @cOutputStr = SUBSTRING( @cInputStr, 1, CHARINDEX( @cDelimiter, @cInputStr) - 1 )
  SELECT @cInputStr = SUBSTRING( @cInputStr, @nIndex+1, len( RTRIM(@cInputStr ) ) )
END

RETURN
END
GO
GRANT EXECUTE ON  [dbo].[mbi_parse_str] TO [public]
GO
