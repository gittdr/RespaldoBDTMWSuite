SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSaveUser] (@UserSN int, @NTUser varchar(100), @SQLUser varchar(100), @GenericUser varchar(100), @Disable int, @GenericPassword varchar(20), @EncryptStyle varchar(10)='' )
AS
	SET NOCOUNT ON

	UPDATE metricuser SET 
		NTUser = @NTUser, 
		SQLUser = @SQLUser, 
		GenericUser = @GenericUser, 
		Disable = @Disable, 
		GenericPassword = @GenericPassword,
		EncryptStyle = @EncryptStyle
	WHERE sn = @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricSaveUser] TO [public]
GO
