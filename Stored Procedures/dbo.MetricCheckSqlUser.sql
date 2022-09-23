SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckSqlUser] (@SqlUser varchar(100))
AS
	SET NOCOUNT ON

	SELECT sn FROM MetricUser WHERE SqlUser = @SqlUser
GO
GRANT EXECUTE ON  [dbo].[MetricCheckSqlUser] TO [public]
GO
