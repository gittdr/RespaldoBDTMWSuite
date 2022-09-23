SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_Zip3] (@CmpZip VARCHAR(10), @CmpState VARCHAR(2), @CmpCity Int, @StateOnly VARCHAR(1))

RETURNS VARCHAR(3)
AS
	BEGIN
	Declare @Zip3 VARCHAR(3)
	Set @Zip3 =
	(CASE WHEN IsNumeric(LEFT(IsNull(@CmpZip, 'UNK'), 3)) = 1 AND @StateOnly <> 'Y' THEN 
					(SELECT TOP 1 IsNull(PID,'UNK') FROM ResNowZip3Translation (NOLOCK) 
					WHERE LEFT(@CmpZip, 3) BETWEEN LowZip AND HighZip) 
				ELSE 
					(CASE WHEN IsNull(@CmpState,'UN') <> 'UN' THEN 
						LEFT(@CmpState + SPACE(3), 3) 
					ELSE LEFT(IsNull((SELECT cty_state FROM city (NOLOCK) WHERE cty_code = @CmpCity),'UN') + SPACE(3), 3)  END) END)
	if (@Zip3 is NULL) or (@Zip3 = 'UN') SET @Zip3 = 'UNK'
	
	return @Zip3 
	
END
GO
GRANT EXECUTE ON  [dbo].[fnc_Zip3] TO [public]
GO
