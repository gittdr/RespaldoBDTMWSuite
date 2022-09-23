SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetLabelAbbrByName]
( @labeldefinition   VARCHAR(20)
, @name              VARCHAR(20)
) RETURNS VARCHAR(6)

AS
/**
 *
 * NAME:
 * dbo.fn_GetLabelAbbrByName
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns ABBR from labelfile for given labeldefinition and name
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @labeldefinition VARCHAR(20)
 * 002 @name            VARCHAR(20)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/07/2013 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @ABBR   VARCHAR(6)

   SELECT @ABBR = abbr
     FROM labelfile
    WHERE labeldefinition = @labeldefinition
      AND name = @name

   IF @ABBR IS NULL
      SELECT @ABBR = 'UNK'

   RETURN @ABBR

END
GO
GRANT EXECUTE ON  [dbo].[fn_GetLabelAbbrByName] TO [public]
GO
