SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_CarrierCSAInfoProviderList]
AS

/**
 *
 * NAME:
 * dbo.sp_CarrierCSAInfoProviderList
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to List CSA Info Provider List
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 *
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/13/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @temp TABLE
   ( ProviderName VARCHAR(30)
   )

   INSERT INTO @temp (ProviderName)
   SELECT gi_name FROM generalinfo WHERE gi_name = 'Carrier411' AND gi_string1 = 'Y'
   UNION ALL
   SELECT gi_name FROM generalinfo WHERE gi_name = 'RegistryMonitoring' AND gi_string1 = 'Y'
   UNION ALL
   SELECT gi_name FROM generalinfo WHERE gi_name = 'TransCoreCarrierWatch' AND gi_string1 = 'Y'

   SELECT *
     FROM @temp

END
GO
GRANT EXECUTE ON  [dbo].[sp_CarrierCSAInfoProviderList] TO [public]
GO
