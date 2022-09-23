SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateInProcess] 
(
	@batch int OUTPUT, 
	@note varchar(25), 
	@MetricCode varchar(200)
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	-- CREATE A BATCH....
	IF (@batch IS NULL)
	BEGIN
		SELECT @batch = ISNULL(MAX(batch), 0) + 1 FROM MetricInProcess

		-- Keep the last 3 batches.
		DELETE MetricInProcess 
		FROM MetricInProcess tOut 
		WHERE NOT EXISTS(SELECT batch 
						FROM MetricInProcess 
						WHERE tOut.batch IN (SELECT DISTINCT TOP 2 batch FROM MetricInProcess ORDER BY batch DESC))
	END
	
	--IF (ISNULL(@note, '') <> '' OR ISNULL(@MetricCode, '') <> '') 
	INSERT INTO MetricInProcess (batch, note, MetricCode) SELECT @batch, @note , @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateInProcess] TO [public]
GO
