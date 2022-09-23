SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdExternalDataSourceOption_Lookup](@ExternalDataSourceSN int, @OptionName varchar(255), @DefaultValue varchar(255))
AS

	SET NOCOUNT ON

	-- Example.
	-- IF NOT EXISTS(SELECT * FROM dbo.rnExternalDataSourceOptions WHERE OptionName = 'FileForSYSROUTINES'
	IF EXISTS(SELECT sn FROM rnExternalDataSource WHERE sn = @ExternalDataSourceSN)
	BEGIN
		IF NOT EXISTS(SELECT ExternalDataSourceSN FROM dbo.rnExternalDataSourceOptions WHERE OptionName = @OptionName AND ExternalDataSourceSN = @ExternalDataSourceSN)
		BEGIN
			INSERT INTO rnExternalDataSourceOptions (ExternalDataSourceSN, OptionName, OptionValue)
			SELECT @ExternalDataSourceSN, @OptionName, @DefaultValue
		END

		SELECT OptionName, OptionValue FROM rnExternalDataSourceOptions WHERE ExternalDataSourceSN = @ExternalDataSourceSN
	END
GO
GRANT EXECUTE ON  [dbo].[rnwdExternalDataSourceOption_Lookup] TO [public]
GO
