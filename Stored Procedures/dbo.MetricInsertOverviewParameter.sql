SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertOverviewParameter] (@PiePage int, @Active int, @Side varchar(255), @Sort int, @Mode varchar(255), @CannedMode int, @Heading varchar(255), @PrcHeading varchar(255), 
		@NumberOfValues varchar(255), @LabelDefinition varchar(255), @Colors varchar(1023), @DaysBack int, @DaysRange int, @Parameters varchar(255), @ProcedureName varchar(255)
)
AS
	SET NOCOUNT ON

	INSERT INTO RN_OverviewParameter (Page, Active, Side, Sort, Mode, Heading, PrcHeading, NumberOfValues, LabelDefinition, Colors, DaysBack, DaysRange, [Parameters], CannedMode, ProcedureName)
    VALUES (@PiePage, @Active, @Side, @Sort, @Mode, @Heading, @PrcHeading, @NumberOfValues, @LabelDefinition, @Colors, @DaysBack,@DaysRange, @Parameters, @CannedMode, @ProcedureName)
GO
GRANT EXECUTE ON  [dbo].[MetricInsertOverviewParameter] TO [public]
GO
