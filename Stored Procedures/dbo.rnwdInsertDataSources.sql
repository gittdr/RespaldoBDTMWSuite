SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdInsertDataSources] (
	@AvailableOnlyYN varchar(1) = 'N'
	,@DataSourceType varchar(20)
	,@Caption varchar(20)
	,@CaptionFull varchar(255)
	,@ServerName varchar(100) = NULL	
	,@CatalogName varchar(100) = NULL	
	,@UserId varchar(50) = NULL	
	,@Password varchar(50) = NULL
	,@ConnectionStringOverride varchar(255) = NULL
)
AS
	SET NOCOUNT ON

	INSERT INTO rnExternalDataSource (Available_YN, Caption, CaptionFull, DataSourceType, ServerName, CatalogName, UserId, Password, ConnectionStringOverride)
	SELECT ISNULL(@AvailableOnlyYN , 'N'), @Caption, @CaptionFull, @DataSourceType
		,@ServerName, @CatalogName, @UserId, @Password, @ConnectionStringOverride
		
	SELECT sn = SCOPE_IDENTITY()

GO
GRANT EXECUTE ON  [dbo].[rnwdInsertDataSources] TO [public]
GO
