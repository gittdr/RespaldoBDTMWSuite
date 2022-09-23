SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertUser] (@NTUser varchar(100), @SQLUser varchar(100), @GenericUser varchar(100), @Disable int, @GenericPassword varchar(20), @EncryptStyle varchar(10) )
AS
	SET NOCOUNT ON

	DECLARE @sn int
	SET @sn = 0

	IF ISNULL(@NTUser, '') <> '' 
	BEGIN
		IF EXISTS(SELECT sn FROM metricuser WHERE NTUser = @NTUser)
			SELECT @sn = -1
	END
	ELSE IF ISNULL(@SQLUser, '') <> '' 
	BEGIN
		IF EXISTS(SELECT sn FROM metricuser WHERE SQLUser = @SQLUser)
			SELECT @sn = -1
	END
	ELSE IF ISNULL(@GenericUser, '') <> '' 
	BEGIN
		IF EXISTS(SELECT sn FROM metricuser WHERE GenericUser = @GenericUser)
			SELECT @sn = -1
	END
	
	IF (@sn = 0)
	BEGIN
		INSERT INTO metricuser ([NTUser], [SQLUser], [GenericUser], [Disable], [GenericPassword], [EncryptStyle])
			  SELECT @NTUser, @SQLUser, @GenericUser, @Disable, @GenericPassword, @EncryptStyle

		SELECT @sn = @@IDENTITY
	END

	SELECT sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricInsertUser] TO [public]
GO
