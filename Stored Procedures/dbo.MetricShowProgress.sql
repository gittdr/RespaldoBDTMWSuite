SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricShowProgress] 
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	IF (SELECT MAX(upd_daily) FROM metricdetail (NOLOCK) WHERE upd_daily IS NOT NULL) > (SELECT MAX(upd_summary) FROM metricdetail (NOLOCK) WHERE upd_summary IS NOT NULL)
		SELECT 'Running daily numbers for ' + metricCode + ', and then will run the summary.', PlainDate FROM metricdetail 
		WHERE upd_daily = (SELECT MAX(upd_daily) FROM metricdetail (NOLOCK))
	ELSE
		SELECT 'Running summary numbers for ' + MetricCode, PlainDate, upd_summary FROM metricdetail (NOLOCK)
		WHERE upd_daily = (SELECT MAX(upd_daily) FROM metricdetail (NOLOCK))

GO
GRANT EXECUTE ON  [dbo].[MetricShowProgress] TO [public]
GO
