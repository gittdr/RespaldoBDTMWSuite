SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricResNowMenuSection] (@sn int = -1)
AS

	IF @sn = -1
	BEGIN
		SELECT SN, Caption 
		FROM ResNowMenuSection 
		WHERE Active = 1 
		ORDER BY Sort
	END
	ELSE
	BEGIN
		SELECT SN, Caption 
		FROM ResNowMenuSection 
		WHERE sn = @sn
	END
GO
GRANT EXECUTE ON  [dbo].[MetricResNowMenuSection] TO [public]
GO
