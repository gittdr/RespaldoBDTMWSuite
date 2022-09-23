SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[sp_RegistryMonitoringTruncate]
( @TmwXmlImportLog_id   INT
, @result               INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_RegistryMonitoringTruncate
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to ID an XML Import
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @TmwXmlImportLog_id  INT
 * @result              INT OUTPUT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/11/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @msg      NVARCHAR(1000)
   DECLARE @docket   VARCHAR(15)
   DECLARE @id       INT

   SELECT @result = 0

   SELECT @id = 0
   WHILE 1 = 1
   BEGIN
      SELECT @id = MIN(id)
        FROM RMXML_Carrier
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id
         AND id > @id
      IF IsNull(@id,0) = 0
         BREAK

      SELECT @docket = dbo.fn_GetDocketByRootElementID(TmwXmlImportLog_id, RootElementID)
        FROM RMXML_Carrier
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id
         AND id = @id

      BEGIN TRY
         DELETE FROM carrierinsurancelimits
          WHERE cai_id IN (SELECT cai_id
                             FROM carrierinsurance
                            WHERE car_id = dbo.fn_GetCarIdByDocket(@docket)
                          )
         DELETE FROM carrierinsurance
          WHERE car_id = dbo.fn_GetCarIdByDocket(@docket)

         DELETE CarrierCSA
           FROM CarrierCSA cs
           JOIN fn_CarrierCsaDocketLastUpdate(@docket) l ON cs.docket = l.docket
                                                        AND l.providername = 'RegistryMonitoring'
          WHERE cs.docket = @docket

         SELECT @msg = 'All info related to Docket#' + @docket + ' have been truncated.'
         EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
      END TRY
      BEGIN CATCH
         SELECT @result = -1

         --Log Error
         SELECT @msg = 'Error Truncating Docket Info for Docket#' + @docket
         EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
      END CATCH
   END

END
GO
GRANT EXECUTE ON  [dbo].[sp_RegistryMonitoringTruncate] TO [public]
GO
