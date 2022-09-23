SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[setting_getPrecedence] (
	@scopeType as int,
	@scopeLocked as bit,
    @machineName as varchar(100)
	)
RETURNS int
	BEGIN
		DECLARE @precedence int;
		SET @machineName = ISNULL(@machineName, '');
		SET @precedence = 
			2 * (CASE @scopeLocked WHEN 1 THEN 1000 + @scopeType ELSE 1000 - @scopeType END) +
			(CASE @machineName WHEN '' THEN 0 ELSE 1 END);
		RETURN @precedence
	END
GO
GRANT EXECUTE ON  [dbo].[setting_getPrecedence] TO [public]
GO
