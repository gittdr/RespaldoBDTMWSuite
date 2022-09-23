SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricHandleDetailInfo] (@MetricCode varchar(200), @DateCur varchar(10) )
AS
	-- PART 1: Handle MetricTempIDs
	IF EXISTS(SELECT * FROM MetricTempIDs)
	BEGIN
		DELETE MetricDetailInfo WHERE MetricCode = @MetricCode AND PlainDate = @DateCur

		INSERT INTO MetricDetailInfo (MetricCode, PlainDate, MetricItem)
		SELECT @MetricCode, @DateCur, MetricItem FROM MetricTempIDs 

		DELETE MetricTempIDs
	END

	-- PART 2: Handle MetricTempIDs2
	IF EXISTS(SELECT * FROM MetricTempIDs2)
	BEGIN
		DELETE MetricDetailInfo WHERE MetricCode = @MetricCode AND PlainDate = @DateCur

		INSERT INTO MetricDetailInfo (MetricCode, PlainDate, MetricItem)
		SELECT @MetricCode, @DateCur, MetricItem FROM MetricTempIDs2 WHERE spid = @@spid 

		DELETE MetricTempIDs2 WHERE spid = @@spid
	END
GO
GRANT EXECUTE ON  [dbo].[MetricHandleDetailInfo] TO [public]
GO
