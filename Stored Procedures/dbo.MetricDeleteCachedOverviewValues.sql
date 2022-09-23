SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteCachedOverviewValues] (@ItemCategory varchar(255) )
AS
	SET NOCOUNT ON

	DELETE RNTrial_Cache_TopValues WHERE ItemCategory = @ItemCategory
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteCachedOverviewValues] TO [public]
GO
