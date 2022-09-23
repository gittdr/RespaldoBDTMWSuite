SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricInsertDataSource] (@Available_YN varchar(1), @Caption varchar(20), @CaptionFull varchar(255), 
			@DataSourceType varchar(20), @ServerName varchar(100), @CatalogName varchar(100), @UserId varchar(50), @Password varchar(50), @ConnectionStringOverride varchar(255),
			@FileContainingSYSROUTINES varchar(100)
)
AS
	SET NOCOUNT ON
	DECLARE @DataSourceSN int

	INSERT INTO rnExternalDataSource (Available_YN, Caption, CaptionFull, DataSourceType, ServerName, CatalogName, UserId, Password, ConnectionStringOverride)
	SELECT @Available_YN, @Caption, @CaptionFull, @DataSourceType, @ServerName, @CatalogName, @UserId, @Password, @ConnectionStringOverride

	SELECT @DataSourceSN = sn FROM rnExternalDataSource WHERE Caption = @Caption

	SELECT DataSourceSN = @DataSourceSN
GO
GRANT EXECUTE ON  [dbo].[MetricInsertDataSource] TO [public]
GO
