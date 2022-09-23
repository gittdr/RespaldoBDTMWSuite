SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateItemInternational] 
(
	@MetricCode varchar(200),
	@DefaultCurrency varchar(255)

)
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET RNIDefaultCurrency = @DefaultCurrency
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateItemInternational] TO [public]
GO
