SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAddUserIfNotExists] (@LogonUser varchar(100) )
AS
	SET NOCOUNT OFF

	IF EXISTS(SELECT sn FROM MetricUser WHERE NTUser = @LogonUser)
		SELECT sn FROM MetricUser WHERE NTUser = @LogonUser
	ELSE
	BEGIN
		INSERT INTO MetricUser (NTUser) SELECT @LogonUser
		
		SELECT 0
	END
GO
GRANT EXECUTE ON  [dbo].[MetricAddUserIfNotExists] TO [public]
GO
