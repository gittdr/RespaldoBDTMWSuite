SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetUserInfoBySN] (@UserSN int)
AS
	SET NOCOUNT ON

	SELECT sn, ISNULL(NTUser, '') AS NTUser, ISNULL(SQLUser, '') AS SQLUser, ISNULL(GenericUser, '') AS GenericUser, ISNULL(Disable, 0) AS Disable
			, ISNULL(GenericPassword, '') AS GenericPassword, EncryptStyle = ISNULL(EncryptStyle, '') 
	FROM MetricUser 
	WHERE sn = @UserSN

GO
GRANT EXECUTE ON  [dbo].[MetricGetUserInfoBySN] TO [public]
GO
