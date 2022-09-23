SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdSetDataSources] (@DataSourceSN int
	,@AvailableOnlyYN varchar(1) = 'N'
	,@DataSourceType varchar(20)
	,@Caption varchar(20)
	,@CaptionFull varchar(255)
	,@ServerName varchar(100) = NULL	
	,@CatalogName varchar(100) = NULL	
	,@UserId varchar(50) = NULL	
	,@ChangingPasswordsYN varchar(1) = NULL
	,@Password varchar(50) = NULL
	,@ChangingConnectionStringOverrideYN varchar(1) = NULL
	,@ConnectionStringOverride varchar(255) = NULL
)
AS
	SET NOCOUNT ON

--	Also add EncryptStyle for password for database.
--  Then allow ConnectionString to be used.

	UPDATE rnExternalDataSource SET 
	 		Available_YN = @AvailableOnlyYN
			,DataSourceType = @DataSourceType 
			,Caption = @Caption 
			,CaptionFull = @CaptionFull 
			,ServerName = @ServerName 
			,CatalogName = @CatalogName
			,UserID	= @UserID
			,[Password] = CASE WHEN ISNULL(@ChangingPasswordsYN, 'N') = 'Y' THEN @Password ELSE [Password] END
			,ConnectionStringOverride = CASE WHEN ISNULL(@ChangingConnectionStringOverrideYN, 'N') = 'Y' THEN @ConnectionStringOverride ELSE ConnectionStringOverride END
	WHERE sn = @DataSourceSN
GO
GRANT EXECUTE ON  [dbo].[rnwdSetDataSources] TO [public]
GO
