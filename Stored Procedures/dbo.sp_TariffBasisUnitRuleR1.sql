SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TariffBasisUnitRuleR1]
( @CallerAppABBR        VARCHAR(10)
, @TarNumber            INT
, @TariffInputXml       XML
, @Quantity             DECIMAL(19,6)  OUTPUT
, @Rate                 DECIMAL(19,6)  OUTPUT
, @Description          VARCHAR(100)   OUTPUT
, @ErrorMessage         VARCHAR(1000)  OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_TariffBasisUnitRuleR1
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
 * 003 @TariffInputXml     XML
 * 004 @Quantity           DECIMAL(19,6)
 * 005 @Rate               DECIMAL(19,6)
 * 006 @Description        VARCHAR(100)
 * 007 @ErrorMessage       VARCHAR(1000)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/15/14 - Initial Version Created
 * PTS 83007 DTG 10/01/14 - Updated to take XML tariff input instead of @TariffInputId
 * NSUITE-201762 SPN 08/04/17 - Component Version 1
 *
 **/

SET NOCOUNT ON

BEGIN
    -- Determine current options and change for XQuery to work in any environment
    DECLARE @options INT
    DECLARE @QUOTED_IDENTIFIER          CHAR(1)
    DECLARE @CONCAT_NULL_YIELDS_NULL    CHAR(1)
    DECLARE @ANSI_WARNINGS              CHAR(1)
    DECLARE @ANSI_PADDING               CHAR(1)
    DECLARE @ANSI_NULLS                 CHAR(1)

    SELECT @options = @@OPTIONS

    SELECT @QUOTED_IDENTIFIER = 'N'
    IF ( (256 & @options) = 256 )
          SELECT @QUOTED_IDENTIFIER = 'Y'

    SELECT @CONCAT_NULL_YIELDS_NULL = 'N'
    IF ( (4096 & @options) = 4096 )
          SELECT @CONCAT_NULL_YIELDS_NULL = 'Y'

    SELECT @ANSI_WARNINGS = 'N'
    IF ( (8 & @options) = 8 )
          SELECT @ANSI_WARNINGS = 'Y'

    SELECT @ANSI_PADDING = 'N'
    IF ( (16 & @options) = 16 )
          SELECT @ANSI_PADDING = 'Y'

    SELECT @ANSI_NULLS = 'N'
    IF ( (32 & @options) = 32 )
          SELECT @ANSI_NULLS = 'Y'

    SET QUOTED_IDENTIFIER ON
    SET ANSI_WARNINGS ON
    SET ANSI_PADDING ON
    SET ANSI_NULLS ON
    SET CONCAT_NULL_YIELDS_NULL ON

    DECLARE @TarModule         CHAR(1)

    IF EXISTS (SELECT 1 FROM tariffheader WHERE tar_number = @TarNumber)
        SELECT @TarModule = 'B'
    ELSE
        SELECT @TarModule = 'S'

    IF @TarModule = 'B'
    BEGIN
        EXEC sp_ChargeTypeBasisUnitRuleR1 @TarNumber = @TarNumber
                                         , @CallerAppABBR = @CallerAppABBR
                                         , @TariffInputXml = @TariffInputXml
                                         , @Quantity = @Quantity OUTPUT
                                         , @Rate = @Rate OUTPUT
                                         , @Description = @Description OUTPUT
                                         , @ErrorMessage = @ErrorMessage OUTPUT;
    END

    IF @TarModule = 'S'
    BEGIN
        EXEC sp_PayTypeBasisUnitRuleR1 @TarNumber = @TarNumber
                                      , @CallerAppABBR = @CallerAppABBR
                                      , @TariffInputXml = @TariffInputXml
                                      , @Quantity = @Quantity OUTPUT
                                      , @Rate = @Rate OUTPUT
                                      , @Description = @Description OUTPUT
                                      , @ErrorMessage = @ErrorMessage OUTPUT;
    END

    -- Restore options to avoid disturbing the environment
    IF @QUOTED_IDENTIFIER = 'N'
          SET QUOTED_IDENTIFIER OFF

    IF @ANSI_WARNINGS = 'N'
          SET ANSI_WARNINGS OFF

    IF @ANSI_PADDING = 'N'
          SET ANSI_PADDING OFF

    IF @ANSI_NULLS = 'N'
          SET ANSI_NULLS OFF

    IF @CONCAT_NULL_YIELDS_NULL = 'N'
          SET CONCAT_NULL_YIELDS_NULL OFF

    RETURN
END
GO
GRANT EXECUTE ON  [dbo].[sp_TariffBasisUnitRuleR1] TO [public]
GO
