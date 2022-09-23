SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_ChargeTypeBasisUnitRuleBillToMileMT]
( @TarNumber      INT
, @TariffInputId  INT
, @OrdHdrNumber   INT
) AS
/**
 *
 * NAME:
 * dbo.sp_ChargeTypeBasisUnitRuleBillToMileMT
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a Test for Custom Tariff Rules
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/16/14 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @SQLString         NVARCHAR(MAX)
   DECLARE @ParmDefinition    NVARCHAR(MAX)
   DECLARE @Qty               DECIMAL(19,6)

   SELECT @SQLString = N'SELECT @Qty = SUM(sbtm.billto_miles) FROM stops_billtomiles sbtm JOIN stops s ON sbtm.stp_number = s.stp_number WHERE sbtm.billto_miles_ord_hdrnumber = @OrdHdrNumber AND s.stp_loadstatus <> ''LD'''
   SELECT @ParmDefinition = N'@OrdHdrNumber INT, @Qty INT OUTPUT'
   EXECUTE sp_executesql @SQLString, @ParmDefinition, @OrdHdrNumber = @OrdHdrNumber, @Qty = @Qty OUTPUT

   SELECT @Qty AS Quantity, 0 AS Rate, '' AS Description, '' AS ErrorMessage

END
GO
GRANT EXECUTE ON  [dbo].[sp_ChargeTypeBasisUnitRuleBillToMileMT] TO [public]
GO
