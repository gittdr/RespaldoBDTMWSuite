SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[SSRS_RB_REFNUMVERTICALLIST_01] @p_maxrows INT, @p_TABLE1 VARCHAR(50),@p_key1 INT, @p_type1 VARCHAR(6),
  @p_TABLE2 VARCHAR(50), @p_key2 INT, @p_type2 VARCHAR(6), @p_withtypes CHAR(1)
AS

DECLARE @refs TABLE ( refnum VARCHAR(50))

SET ROWCOUNT  @p_maxrows

INSERT INTO @refs
SELECT (CASE @p_withtypes WHEN 'Y' then ref_type +': ' ELSE'' END ) +ref_number
FROM referencenumber
WHERE ref_TABLE = @p_TABLE1
AND ref_TABLEkey = @p_key1
AND ref_type LIKE @p_type1

INSERT INTO @refs
SELECT (CASE @p_withtypes WHEN 'Y' then ref_type +': ' ELSE'' END ) +ref_number
FROM referencenumber
WHERE ref_TABLE = @p_TABLE2
AND ref_TABLEkey = @p_key2
AND ref_type LIKE @p_type2


SET ROWCOUNT @p_maxrows

SELECT refnum FROM @refs


GO
