SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricLogProcessEvent] (@Event varchar(255), @MetricCode varchar(200))
AS
	SET NOCOUNT ON

	INSERT INTO ResNowLog (MetricCode, source, longdesc) 
	SELECT @MetricCode, 'Metrics', @Event
GO
GRANT EXECUTE ON  [dbo].[MetricLogProcessEvent] TO [public]
GO
