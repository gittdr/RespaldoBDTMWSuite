SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpdateDataSource] (@DataSourceSN varchar(100), @Available_YN varchar(1), @Caption varchar(20), @CaptionFull varchar(255), 
			@DataSourceType varchar(20), @ServerName varchar(100), @CatalogName varchar(100), @UserId varchar(50), @Password varchar(50), @ConnectionStringOverride varchar(255)
)
AS
	SET NOCOUNT ON


	UPDATE rnExternalDataSource SET
 		Available_YN = @Available_YN,
		DataSourceType = @DataSourceType,
		Caption = @Caption,
		CaptionFull = @CaptionFull,
		ServerName = @ServerName,
		CatalogName = @CatalogName,
		UserID = @UserID,
		[Password] = @Password,
		ConnectionStringOverride = @ConnectionStringOverride
	WHERE sn = @DataSourceSN

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateDataSource] TO [public]
GO
