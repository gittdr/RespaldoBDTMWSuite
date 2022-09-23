SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[settlement_CompareRateByUnitBasis_shell_sp]
(
  @ps_asgn_type   VARCHAR(6)
, @ps_asgn_id     VARCHAR(13)
, @pl_lgh_number  INT
, @ps_RetVal      VARCHAR(1) OUT
) AS

/**
 * 
 * NAME:
 * settlement_CompareRateByUnitBasis_shell_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns Y/N to the Settlement Rating Process
 *
 * RETURNS: Y/N
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:
 * @ps_asgn_type    VARCHAR(6)  Asset Type
 * @ps_asgn_id      VARCHAR(13) Asset ID
 * @pl_lgh_number   INT         Trip Segment / Leg Header Number
 * @ps_RetVal       VARCHAR(1)  OUT
 *
 * REVISION HISTORY:
 * 11/18/2010 PTS48904 - Suprakash Nandan Created Procedure
 *
 **/

DECLARE @proc_name varchar(60)

SET @ps_RetVal = 'N'

SELECT @proc_name = (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'CompareRateByUnitBasis')
If @proc_name IS NOT NULL AND @proc_name <> ''
   EXEC @proc_name @ps_asgn_type, @ps_asgn_id, @pl_lgh_number, @ps_return = @ps_RetVal OUTPUT

GO
GRANT EXECUTE ON  [dbo].[settlement_CompareRateByUnitBasis_shell_sp] TO [public]
GO
