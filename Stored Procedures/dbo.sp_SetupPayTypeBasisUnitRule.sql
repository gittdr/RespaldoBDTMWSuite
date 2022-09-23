SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_SetupPayTypeBasisUnitRule]
( @abbr                 VARCHAR(6)
, @BasisUnitRuleName    VARCHAR(30)
, @PhysicalName         VARCHAR(200)
, @InputVariables       VARCHAR(MAX)
) AS
/**
 *
 * NAME:
 * dbo.sp_SetupPayTypeBasisUnitRule
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a Setup Custom Tariff Rules
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/16/14 - Initial Version Created
 * PTS 83007 DTG 10/01/14 - Updated to take multiple comma separated arguments through @InputVariables
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @PayTypeBasisUnitRule_Id                INT
   DECLARE @TariffInputSource_Id                   INT
   DECLARE @PayTypeBasisUnitRuleInputSource_Id     INT
   DECLARE @TariffInputSourceArgs_Id               INT

   DECLARE @seq INT
   DECLARE @maxseq INT
   DECLARE @TempArgs TABLE
   ( seq	INT IDENTITY
   , id		INT
   )

   --PayTypeBasisUnitRule
   IF NOT EXISTS (SELECT 1 FROM PayTypeBasisUnitRule WHERE BasisUnitRuleName = @BasisUnitRuleName)
   BEGIN
      INSERT INTO PayTypeBasisUnitRule(RuleType,BasisUnitRuleName,PhysicalName)
      VALUES ('SP',@BasisUnitRuleName,@PhysicalName)
   END
   SELECT @PayTypeBasisUnitRule_Id = Id FROM PayTypeBasisUnitRule WHERE BasisUnitRuleName = @BasisUnitRuleName

   --PayTypeBasisUnitRuleInputSource
   SELECT @TariffInputSource_Id = id FROM TariffInputSource WHERE abbr = @abbr
   IF IsNull(@TariffInputSource_Id,0) <> 0
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM PayTypeBasisUnitRuleInputSource WHERE PayTypeBasisUnitRule_Id = @PayTypeBasisUnitRule_Id AND TariffInputSource_Id = @TariffInputSource_Id)
      BEGIN
         INSERT INTO PayTypeBasisUnitRuleInputSource(PayTypeBasisUnitRule_Id,TariffInputSource_Id)
         VALUES (@PayTypeBasisUnitRule_Id,@TariffInputSource_Id)
      END
      SELECT @PayTypeBasisUnitRuleInputSource_Id = id FROM PayTypeBasisUnitRuleInputSource WHERE PayTypeBasisUnitRule_Id = @PayTypeBasisUnitRule_Id AND TariffInputSource_Id = @TariffInputSource_Id

      --PayTypeBasisUnitRuleArgs
	  INSERT INTO @TempArgs(id)
      SELECT args.id
        FROM TariffInputSourceArgs args
            JOIN fn_SplitString(@InputVariables, ',') iv ON args.InputVariable = iv.items
        WHERE args.TariffInputSource_Id = @TariffInputSource_Id
        ORDER BY iv.seqno ASC

      SELECT @seq = 0
      SELECT @maxseq = MAX(seq) FROM @TempArgs
      WHILE @seq < @maxseq
      BEGIN
		SELECT @seq = MIN(seq) FROM @TempArgs WHERE seq > @seq
		SELECT @TariffInputSourceArgs_Id = id FROM @TempArgs WHERE seq = @seq
	   
		IF NOT EXISTS (SELECT 1 FROM PayTypeBasisUnitRuleArgs WHERE PayTypeBasisUnitRuleInputSource_Id = @PayTypeBasisUnitRuleInputSource_Id AND TariffInputSourceArgs_Id = @TariffInputSourceArgs_Id)
		BEGIN
			INSERT INTO PayTypeBasisUnitRuleArgs(PayTypeBasisUnitRuleInputSource_Id, TariffInputSourceArgs_Id, SeqNo)
			VALUES (@PayTypeBasisUnitRuleInputSource_Id, @TariffInputSourceArgs_Id, @seq)
		END
		ELSE
		BEGIN
		    UPDATE PayTypeBasisUnitRuleArgs
		    SET SeqNo = @seq
		    WHERE PayTypeBasisUnitRuleInputSource_Id = @PayTypeBasisUnitRuleInputSource_Id AND TariffInputSourceArgs_Id = @TariffInputSourceArgs_Id
		END
      END
   END

END
GO
GRANT EXECUTE ON  [dbo].[sp_SetupPayTypeBasisUnitRule] TO [public]
GO
