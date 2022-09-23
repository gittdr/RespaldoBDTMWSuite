SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carriercsa_status]
( @CarrierCSA_category     VARCHAR(30)
, @docket                  VARCHAR(15)
, @li_CarrierCsaStatus     INT OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_carriercsa_status
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for determining different carrier csa status
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @CarrierCSA_category     VARCHAR(30)
 * 002 @docket                  VARCHAR(15)
 * 003 @li_CarrierCsaStatus     INT OUTPUT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/19/2013 - Initial Version Created
 * PTS 72555 SPN 10/10/2013 - Removing hard dependency on fn_GetCarrierCSAStatus
 * PTS 97309, 97308, 973010
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @SQLString                  NVARCHAR(MAX)
   DECLARE @ParmDefinition             NVARCHAR(500)

   SELECT @li_CarrierCsaStatus = 0
   Declare @dotnum VARCHAR(15)

   /*Carrier CSA Status*/
   IF EXISTS (SELECT SPECIFIC_NAME
                FROM INFORMATION_SCHEMA.ROUTINES
               WHERE SPECIFIC_SCHEMA = 'dbo'
                 AND SPECIFIC_NAME = 'fn_GetCarrierCSAStatus'
             )
   BEGIN
		SELECT @dotnum = cas_dot_number from carriercsa where docket =@docket
      SELECT @li_CarrierCsaStatus = dbo.fn_GetCarrierCSAStatus(@CarrierCSA_category,@dotnum, @docket)
      /*Begin Dynamic SQL*/
      SELECT @SQLString = N'SELECT @li_CarrierCsaStatus = dbo.fn_GetCarrierCSAStatus(@CarrierCSA_category, @dotnum,@docket)'
      SELECT @ParmDefinition = N'@CarrierCSA_category VARCHAR(30),@dotnum VARCHAR(15), @docket VARCHAR(15), @li_CarrierCsaStatus INT OUTPUT'
      EXECUTE sp_executesql @SQLString, @ParmDefinition, @CarrierCSA_category = @CarrierCSA_category,@dotnum = @dotnum, @docket = @docket, @li_CarrierCsaStatus = @li_CarrierCsaStatus OUTPUT
      /*End Dynamic SQL*/
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carriercsa_status] TO [public]
GO
