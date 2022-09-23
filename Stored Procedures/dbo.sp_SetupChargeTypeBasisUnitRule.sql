SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_SetupChargeTypeBasisUnitRule]
( @abbr                 VARCHAR(6)
, @BasisUnitRuleName    VARCHAR(30)
, @PhysicalName         VARCHAR(200)
, @InputVariables       VARCHAR(MAX)
) AS
/**
 *
 * NAME:
 * dbo.sp_SetupChargeTypeBasisUnitRule
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

   DECLARE @ChargeTypeBasisUnitRule_Id             INT
   DECLARE @TariffInputSource_Id                   INT
   DECLARE @ChargeTypeBasisUnitRuleInputSource_Id  INT
   DECLARE @TariffInputSourceArgs_Id               INT

   DECLARE @seq INT
   DECLARE @maxseq INT
   DECLARE @TempArgs TABLE
   ( seq	INT IDENTITY
   , id		INT
   )

   --ChargeTypeBasisUnitRule
   IF NOT EXISTS (SELECT 1 FROM ChargeTypeBasisUnitRule WHERE BasisUnitRuleName = @BasisUnitRuleName)
   BEGIN
      INSERT INTO ChargeTypeBasisUnitRule(RuleType,BasisUnitRuleName,PhysicalName)
      VALUES ('SP',@BasisUnitRuleName,@PhysicalName)
   END
   SELECT @ChargeTypeBasisUnitRule_Id = Id FROM ChargeTypeBasisUnitRule WHERE BasisUnitRuleName = @BasisUnitRuleName

   --ChargeTypeBasisUnitRuleInputSource
   SELECT @TariffInputSource_Id = id FROM TariffInputSource WHERE abbr = @abbr
   IF IsNull(@TariffInputSource_Id,0) <> 0
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM ChargeTypeBasisUnitRuleInputSource WHERE ChargeTypeBasisUnitRule_Id = @ChargeTypeBasisUnitRule_Id AND TariffInputSource_Id = @TariffInputSource_Id)
      BEGIN
         INSERT INTO ChargeTypeBasisUnitRuleInputSource(ChargeTypeBasisUnitRule_Id,TariffInputSource_Id)
         VALUES (@ChargeTypeBasisUnitRule_Id,@TariffInputSource_Id)
      END
      SELECT @ChargeTypeBasisUnitRuleInputSource_Id = id FROM ChargeTypeBasisUnitRuleInputSource WHERE ChargeTypeBasisUnitRule_Id = @ChargeTypeBasisUnitRule_Id AND TariffInputSource_Id = @TariffInputSource_Id

      --ChargeTypeBasisUnitRuleArgs
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
	   
		IF NOT EXISTS (SELECT 1 FROM ChargeTypeBasisUnitRuleArgs WHERE ChargeTypeBasisUnitRuleInputSource_Id = @ChargeTypeBasisUnitRuleInputSource_Id AND TariffInputSourceArgs_Id = @TariffInputSourceArgs_Id)
		BEGIN
			INSERT INTO ChargeTypeBasisUnitRuleArgs(ChargeTypeBasisUnitRuleInputSource_Id, TariffInputSourceArgs_Id, SeqNo)
			VALUES (@ChargeTypeBasisUnitRuleInputSource_Id, @TariffInputSourceArgs_Id, @seq)
		END
		ELSE
		BEGIN
		    UPDATE ChargeTypeBasisUnitRuleArgs
		    SET SeqNo = @seq
		    WHERE ChargeTypeBasisUnitRuleInputSource_Id = @ChargeTypeBasisUnitRuleInputSource_Id AND TariffInputSourceArgs_Id = @TariffInputSourceArgs_Id
		END
      END
	END

END
GO
GRANT EXECUTE ON  [dbo].[sp_SetupChargeTypeBasisUnitRule] TO [public]
GO
