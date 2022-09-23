SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetSetting]
( @gi_name  VARCHAR(30)
, @gi_field CHAR(2)
) RETURNS VARCHAR
AS

/**
 *
 * NAME:
 * dbo.fn_GetSetting
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to return GI Settings (@gi_field C1=gi_string1; C2=gi_string2...)
 *
 * RETURNS:
 *
 * VARCHAR
 *
 * PARAMETERS:
 * 001 - @gi_name    VARCHAR(30)
 * 002 - @gi_field   CHAR(2)
 *
 * REVISION HISTORY:
 * PTS 64373 SPN Created 10/26/2012
 *
 **/

BEGIN

   DECLARE @RetVal     VARCHAR(60)
   DECLARE @gi_string1 VARCHAR(60)
   DECLARE @gi_string2 VARCHAR(60)
   DECLARE @gi_string3 VARCHAR(60)
   DECLARE @gi_string4 VARCHAR(60)

   SELECT @gi_string1 = gi_string1
        , @gi_string2 = gi_string2
        , @gi_string3 = gi_string3
        , @gi_string4 = gi_string4
     FROM generalinfo
    WHERE gi_name = @gi_name

   IF @gi_field = 'C1'
      SELECT @RetVal = @gi_string1
   ELSE IF @gi_field = 'C2'
      SELECT @RetVal = @gi_string2
   ELSE IF @gi_field = 'C3'
      SELECT @RetVal = @gi_string3
   ELSE IF @gi_field = 'C4'
      SELECT @RetVal = @gi_string4
   ELSE
      SELECT @RetVal = ''

   RETURN @RetVal
END
GO
GRANT EXECUTE ON  [dbo].[fn_GetSetting] TO [public]
GO
