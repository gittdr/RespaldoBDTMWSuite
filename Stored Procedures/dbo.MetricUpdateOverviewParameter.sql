SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateOverviewParameter] (@sn int, @Heading varchar(255), @PrcHeading varchar(255), @NumberOfValues int, 
		@LabelDefinition varchar(255), @Colors varchar(1023), @DaysBack int, @DaysRange int, @Parameters varchar(255), @ProcedureName varchar(255)
)
AS
	SET NOCOUNT ON

	UPDATE RN_OverviewParameter SET
		Heading = @Heading,
		PrcHeading = @PrcHeading,
		NumberOfValues =@NumberOfValues,
		LabelDefinition = @LabelDefinition,
		Colors = @Colors,
		DaysBack = @DaysBack,
		DaysRange = @DaysRange,
		Parameters =@Parameters,
		ProcedureName = @ProcedureName
	WHERE sn = @sn

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateOverviewParameter] TO [public]
GO
