SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_Convert2SqlTextVarchar]
( @Input  VARCHAR(MAX)
) RETURNS VARCHAR(MAX)

AS
/**
 *
 * NAME:
 * dbo.fnc_Convert2SqlTextVarchar
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns Varchar as Text for using in Dynamic SQL
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @Input   VARCHAR(MAX)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/08/2014 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @RetVal VARCHAR(MAX)

   IF @Input IS NULL
      SELECT @RetVal = 'NULL'
   ELSE
      SELECT @RetVal = '''' + REPLACE(@Input,'''','''''') + ''''

   RETURN @RetVal

END
GO
GRANT EXECUTE ON  [dbo].[fnc_Convert2SqlTextVarchar] TO [public]
GO
