SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdExternalDataSourceOption_Upsert] (@ExternalDataSourceSN int, @OptionName varchar(255), @OptionValue varchar(255))
AS
	SET NOCOUNT ON

	-- Example.
	IF EXISTS(SELECT sn FROM rnExternalDataSource WHERE sn = @ExternalDataSourceSN)
	BEGIN
		IF NOT EXISTS(SELECT ExternalDataSourceSN FROM rnExternalDataSourceOptions WHERE OptionName = @OptionName AND ExternalDataSourceSN = @ExternalDataSourceSN)
		BEGIN
			INSERT INTO rnExternalDataSourceOptions (ExternalDataSourceSN, OptionName, OptionValue)
			SELECT @ExternalDataSourceSN, @OptionName, @OptionValue
		END
		ELSE
		BEGIN
			UPDATE rnExternalDataSourceOptions SET OptionValue = @OptionValue WHERE OptionName = @OptionName AND ExternalDataSourceSN = @ExternalDataSourceSN
		END
	END

-- Page will add, modify, and delete connections.
-- Page will also edit parameters for that connection type.
-- If paramters do not exist for a type, they will be created automatically.

-- rnExternalDataSourceOption_Lookup 1, 'abc', '123'

GO
GRANT EXECUTE ON  [dbo].[rnwdExternalDataSourceOption_Upsert] TO [public]
GO
