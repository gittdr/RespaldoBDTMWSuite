SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_ChargeTypeBasisUnitRule]
( @TarNumber            INT
, @CallerAppABBR        VARCHAR(10)
, @TariffInputTable     VARCHAR(250)
, @TariffInputId        INT
, @Quantity             DECIMAL(19,6)  OUTPUT
, @Rate                 DECIMAL(19,6)  OUTPUT
, @Description          VARCHAR(100)   OUTPUT
, @ErrorMessage         VARCHAR(1000)  OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_ChargeTypeBasisUnitRule
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
 * 001 @TarNumber          INT
 * 002 @TariffInputId      INT
 * 003 @Quantity           DECIMAL(19,6)
 * 004 @Rate               DECIMAL(19,6)
 * 005 @Description        VARCHAR(100)
 * 006 @ErrorMessage       VARCHAR(1000)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/07/14 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @ChargeTypeBasisUnitRule_Id INT
   DECLARE @RuleType                   VARCHAR(10)
   DECLARE @ProcName                   VARCHAR(200)
   DECLARE @RuleParmsValues            NVARCHAR(MAX)
   DECLARE @SQLString                  NVARCHAR(MAX)
   DECLARE @ParmDefinition             NVARCHAR(MAX)
   DECLARE @count                      INT
   DECLARE @idMax                      INT
   DECLARE @idCur                      INT
   DECLARE @FieldName                  VARCHAR(50)
   DECLARE @InputDataType              VARCHAR(30)
   DECLARE @InputData                  NVARCHAR(MAX)

   DECLARE @RuleMap TABLE
   ( Id INT Identity
   , FieldName       VARCHAR(50)
   , InputDataType   VARCHAR(30)
   )

   DECLARE @Temp TABLE
   ( Quantity             DECIMAL(19,6)
   , Rate                 DECIMAL(19,6)
   , Description          VARCHAR(100)
   , ErrorMessage         VARCHAR(1000)
   )

   --Check Input Table
   IF @TariffInputTable IS NULL
   BEGIN
      SELECT @ErrorMessage = 'Incorrect Input Source'
      RETURN
   END
   IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TariffInputTable)
   BEGIN
      SELECT @ErrorMessage = 'Input Table ' + @TariffInputTable + ' missing in the database'
      RETURN
   END


   --Check Charge Item Rule
   SELECT @ChargeTypeBasisUnitRule_Id = ct.cht_ChargeTypeBasisUnitRule_Id
     FROM tariffheader th
     JOIN ChargeType ct ON th.cht_itemcode = ct.cht_itemcode
    WHERE th.tar_number = @TarNumber
   IF @ChargeTypeBasisUnitRule_Id IS NULL OR @ChargeTypeBasisUnitRule_Id = 0
   BEGIN
      SELECT @ErrorMessage = 'No Rule Defined for the Tariff/Charge'
      RETURN
   END

   --Check Rule
   SELECT @RuleType = RuleType
        , @ProcName = PhysicalName
     FROM ChargeTypeBasisUnitRule
    WHERE id = @ChargeTypeBasisUnitRule_Id
   IF @RuleType IS NULL OR @RuleType <> 'SP'
   BEGIN
      SELECT @ErrorMessage = 'Rule Type is not Stored Procedure'
      RETURN
   END

   IF @ProcName IS NULL OR @ProcName = ''
   BEGIN
      SELECT @ErrorMessage = 'Procedure Name is missing'
      RETURN
   END

   IF LEFT(@ProcName,4) <> 'dbo.'
      SELECT @ProcName = 'dbo.' + @ProcName
   IF NOT EXISTS (SELECT 1
                    FROM sysobjects
                   WHERE id = object_id(@ProcName)
                     AND sysstat & 0xf = 4
          )
   BEGIN
      SELECT @ErrorMessage = 'Stored Procedure ' + @ProcName + ' not found in the database'
      RETURN
   END

   --Check for Input
   SELECT @SQLString = N'SELECT @count = COUNT(1) FROM ' + @TariffInputTable + ' WHERE Id = @TariffInputId'
   SELECT @ParmDefinition = N'@TariffInputId INT, @count INT OUTPUT'
   EXECUTE sp_executesql @SQLString, @ParmDefinition, @TariffInputId = @TariffInputId, @count = @count OUTPUT
   IF @count = 0
   BEGIN
      SELECT @ErrorMessage = 'Input Parameters not found'
      RETURN
   END

   --Rule Mapper
   SELECT @RuleParmsValues = CONVERT(VARCHAR,@TarNumber) + ', ' + CONVERT(VARCHAR,@TariffInputId)
   BEGIN
      INSERT INTO @RuleMap(FieldName, InputDataType)
      SELECT args.MappedVariable, args.InputDataType
        FROM TariffInputSource tis
        JOIN ChargeTypeBasisUnitRuleInputSource ras ON tis.id = ras.TariffInputSource_Id
        JOIN ChargeTypeBasisUnitRuleArgs ra ON ras.id = ra.ChargeTypeBasisUnitRuleInputSource_Id
        JOIN TariffInputSourceArgs args ON ra.TariffInputSourceArgs_Id = args.id
       WHERE tis.ABBR = @CallerAppABBR
         AND ras.ChargeTypeBasisUnitRule_Id = @ChargeTypeBasisUnitRule_Id
         AND args.MappedVariable NOT LIKE '<FUNC>%'
      ORDER BY SeqNo

      SELECT @idMax = MAX(Id) FROM @RuleMap
      SELECT @idCur = 0
      WHILE @idCur < @idMax
      BEGIN
         SELECT @idCur = @idCur + 1
         SELECT @FieldName = FieldName
              , @InputDataType = InputDataType
           FROM @RuleMap
          WHERE id = @idCur

         IF @InputDataType = 'STRING'
         BEGIN
            SELECT @SQLString = N'SELECT @InputData = dbo.fnc_Convert2SqlTextVarchar(' + @FieldName + ') FROM ' + @TariffInputTable + ' WHERE Id = @TariffInputId'
            SELECT @ParmDefinition = N'@TariffInputId INT, @InputData NVARCHAR(MAX) OUTPUT'
            EXECUTE sp_executesql @SQLString, @ParmDefinition, @TariffInputId = @TariffInputId, @InputData = @InputData OUTPUT
         END
         IF @InputDataType = 'NUMBER'
         BEGIN
            SELECT @SQLString = N'SELECT @InputData = dbo.fnc_Convert2SqlTextDecimal(' + @FieldName + ') FROM ' + @TariffInputTable + ' WHERE Id = @TariffInputId'
            SELECT @ParmDefinition = N'@TariffInputId INT, @InputData VARCHAR(MAX) OUTPUT'
            EXECUTE sp_executesql @SQLString, @ParmDefinition, @TariffInputId = @TariffInputId, @InputData = @InputData OUTPUT
         END
         IF @InputDataType = 'DATE'
         BEGIN
            SELECT @SQLString = N'SELECT @InputData = dbo.fnc_Convert2SqlTextDateTime(' + @FieldName + ') FROM ' + @TariffInputTable + ' WHERE Id = @TariffInputId'
            SELECT @ParmDefinition = N'@TariffInputId INT, @InputData VARCHAR(MAX) OUTPUT'
            EXECUTE sp_executesql @SQLString, @ParmDefinition, @TariffInputId = @TariffInputId, @InputData = @InputData OUTPUT
         END
         SELECT @RuleParmsValues = @RuleParmsValues + ', ' + @InputData
      END

   END

   --Begin Dynamic SQL
   BEGIN TRY
      SELECT @SQLString = N'EXEC ' + @ProcName + ' ' + @RuleParmsValues
      INSERT INTO @Temp
      ( Quantity, Rate, Description, ErrorMessage)
      EXECUTE sp_executesql @SQLString
      --End Dynamic SQL

      IF NOT EXISTS (SELECT 1 FROM @Temp)
         SELECT @ErrorMessage = 'Rule Procedure ' + @ProcName + ' returned no record.'
      ELSE
         SELECT TOP 1
                @Quantity     = Quantity
              , @Rate         = Rate
              , @Description  = Description
              , @ErrorMessage = ErrorMessage
           FROM @Temp
   END TRY
   BEGIN CATCH
      SELECT @ErrorMessage = 'Rule Procedure ' + @ProcName + ' has errors.  ' + error_message()
   END CATCH

   --Clear Input
   SELECT @SQLString = N'DELETE FROM ' + @TariffInputTable + ' WHERE Id = @TariffInputId'
   SELECT @ParmDefinition = N'@TariffInputId INT'
   EXECUTE sp_executesql @SQLString, @ParmDefinition, @TariffInputId = @TariffInputId

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_ChargeTypeBasisUnitRule] TO [public]
GO
