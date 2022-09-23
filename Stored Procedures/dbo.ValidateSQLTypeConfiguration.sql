SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ValidateSQLTypeConfiguration]
@CLASSNAME as VARCHAR(100)
AS
	IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = @CLASSNAME +'ValidateType')
		BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE type = 'p' AND name = @CLASSNAME + 'ValidateLogic')
				BEGIN
					DECLARE @SQLSTR AS VARCHAR(500)
					SET @SQLSTR =  'DECLARE @RESULTS AS ' + @CLASSNAME + 'ValidateType SELECT * FROM @RESULTS '
					EXEC (@SQLSTR)
				END
		END
	ELSE
		BEGIN
			SELECT ERROR = @CLASSNAME + ' Type not setup properly in database'
		END

GO
GRANT EXECUTE ON  [dbo].[ValidateSQLTypeConfiguration] TO [public]
GO
