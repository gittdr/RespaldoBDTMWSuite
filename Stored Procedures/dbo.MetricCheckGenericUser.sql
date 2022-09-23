SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckGenericUser] (@GenericUser varchar(100))
AS
	SET NOCOUNT ON

	SELECT sn, GenericUser, GenericPassword, EncryptStyle = ISNULL(EncryptStyle, '') FROM MetricUser WHERE GenericUser = @GenericUser
GO
GRANT EXECUTE ON  [dbo].[MetricCheckGenericUser] TO [public]
GO
