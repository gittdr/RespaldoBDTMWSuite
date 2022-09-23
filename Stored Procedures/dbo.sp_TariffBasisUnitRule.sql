SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TariffBasisUnitRule]
( @CallerAppABBR        VARCHAR(10)
, @TarNumber            INT
, @TariffInputId        INT
, @Quantity             DECIMAL(19,6)  OUTPUT
, @Rate                 DECIMAL(19,6)  OUTPUT
, @Description          VARCHAR(100)   OUTPUT
, @ErrorMessage         VARCHAR(1000)  OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_TariffBasisUnitRule
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a Shell to execute Custom Tariff Rules
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @CallerAppABBR      VARCHAR(10)
 * 002 @TarNumber          INT
 * 003 @TariffInputId      INT
 * 004 @Quantity           DECIMAL(19,6)
 * 005 @Rate               DECIMAL(19,6)
 * 006 @Description        VARCHAR(100)
 * 007 @ErrorMessage       VARCHAR(1000)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/15/14 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @TarModule         CHAR(1)
   DECLARE @TariffInputTable  VARCHAR(250)

   IF EXISTS (SELECT 1 FROM tariffheader WHERE tar_number = @TarNumber)
      SELECT @TarModule = 'B'
   ELSE
      SELECT @TarModule = 'S'

   IF @CallerAppABBR = 'TS'
      SELECT @TariffInputTable = 'TariffInputTS'
   ELSE
      IF @CallerAppABBR = 'DNR'
         SELECT @TariffInputTable = 'TariffInputDNR'
      ELSE
         RETURN

   IF @TarModule = 'B'
   BEGIN
      EXEC sp_ChargeTypeBasisUnitRule @TarNumber = @TarNumber
                                    , @CallerAppABBR = @CallerAppABBR
                                    , @TariffInputTable = @TariffInputTable
                                    , @TariffInputId = @TariffInputId
                                    , @Quantity = @Quantity OUTPUT
                                    , @Rate = @Rate OUTPUT
                                    , @Description = @Description OUTPUT
                                    , @ErrorMessage = @ErrorMessage OUTPUT;
   END
   IF @TarModule = 'S'
   BEGIN
      EXEC sp_PayTypeBasisUnitRule @TarNumber = @TarNumber
                                 , @CallerAppABBR = @CallerAppABBR
                                 , @TariffInputTable = @TariffInputTable
                                 , @TariffInputId = @TariffInputId
                                 , @Quantity = @Quantity OUTPUT
                                 , @Rate = @Rate OUTPUT
                                 , @Description = @Description OUTPUT
                                 , @ErrorMessage = @ErrorMessage OUTPUT;
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_TariffBasisUnitRule] TO [public]
GO
