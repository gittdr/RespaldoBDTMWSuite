SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetDocketByRootElementID]
( @TmwXmlImportLog_id   INT
, @RootElementID INT
) RETURNS VARCHAR(15)

AS
/**
 *
 * NAME:
 * dbo.fn_GetDocketByRootElementID
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns DOCKET# from RMXMLCarrier for given RootElementID
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @TmwXmlImportLog_id    INT
 * 002 @RootElementID         INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/13/2013 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @MCNumber   VARCHAR(15)

   SELECT @MCNumber = MAX(MCNumber)
     FROM dbo.RMXML_Carrier
    WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id
      AND RootElementID = @RootElementID

   RETURN @MCNumber

END
GO
GRANT EXECUTE ON  [dbo].[fn_GetDocketByRootElementID] TO [public]
GO
