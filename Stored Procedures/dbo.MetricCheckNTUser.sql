SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckNTUser] (@LogonUser varchar(100))
AS
	SET NOCOUNT ON

	SELECT sn FROM MetricUser WHERE NTUser = @LogonUser
GO
GRANT EXECUTE ON  [dbo].[MetricCheckNTUser] TO [public]
GO
