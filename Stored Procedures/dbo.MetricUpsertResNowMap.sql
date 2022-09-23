SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpsertResNowMap] (@InsertOrUpdate varchar(1), @zoom varchar(255), @latlong varchar(255), @pgSN int)
AS
	IF @InsertOrUpdate = 'U'
	BEGIN
		UPDATE ResNowMapSetup SET zoom = @zoom, latlong = @latlong WHERE sn = @pgSN
	END
	ELSE IF @InsertOrUpdate = 'I'
	BEGIN
		INSERT INTO ResNowMapSetup (zoom, latlong, sn) VALUES (@zoom, @latlong, @pgSN)
	END
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertResNowMap] TO [public]
GO
