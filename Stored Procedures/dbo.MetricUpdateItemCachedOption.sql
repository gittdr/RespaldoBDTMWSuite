SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateItemCachedOption] 
(
	@MetricCode varchar(200),
	@CachedDetailYN varchar(1),
	@CacheRefreshAgeMaxMinutes int
)
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET
		CachedDetailYN = @CachedDetailYN,
		CacheRefreshAgeMaxMinutes = @CacheRefreshAgeMaxMinutes
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateItemCachedOption] TO [public]
GO
