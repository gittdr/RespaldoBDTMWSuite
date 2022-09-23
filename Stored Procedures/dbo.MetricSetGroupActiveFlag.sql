SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSetGroupActiveFlag] (@GroupSN int, @Disabled VARCHAR(1) )
AS
	SET NOCOUNT ON

	UPDATE MetricGroup SET Disable = CASE WHEN ISNULL(@Disabled, '') = '' THEN 0 ELSE 1 END WHERE sn = @GroupSN
GO
GRANT EXECUTE ON  [dbo].[MetricSetGroupActiveFlag] TO [public]
GO
