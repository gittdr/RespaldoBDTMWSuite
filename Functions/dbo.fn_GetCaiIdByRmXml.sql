SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetCaiIdByRmXml]
( @TmwXmlImportLog_id   INT
, @ParentLevel INT
) RETURNS INT

AS
/**
 *
 * NAME:
 * dbo.fn_GetCaiIdByRmXml
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns CAI_ID from carrierinsurance for given Imported Xml Parent Level info from RMXML_CarrierCoverage
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @TmwXmlImportLog_id    INT
 * 002 @ParentLevel           INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/11/2013 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @CAI_ID   INT

   SELECT @CAI_ID = t.cai_id
     FROM carrierinsurance t
     JOIN RMXML_CarrierCoverage s ON dbo.fn_GetCarIdByDocket(dbo.fn_GetDocketByRootElementID(s.TmwXmlImportLog_id, s.RootElementID)) = t.car_id
                                 AND s.PolicyNumber = t.cai_policynumber
                                 AND dbo.fn_GetLabelAbbrByName('CarInsuranceType',s.coveragedescription) = t.cai_insurance_type
    WHERE s.TmwXmlImportLog_id = @TmwXmlImportLog_id
      AND s.CurrentLevel = @ParentLevel

   RETURN @CAI_ID

END
GO
GRANT EXECUTE ON  [dbo].[fn_GetCaiIdByRmXml] TO [public]
GO
