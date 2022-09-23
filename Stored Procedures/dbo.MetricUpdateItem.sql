SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateItem] 
(
	@MetricCode varchar(200),
	@ProcedureName varchar(255),
	@FormatText varchar(12),
	@NumDigitsAfterDecimal int,
	@Cumulative int,
	@Annualize int,
	@MetricStartDate varchar(100),
	@DetailFilename varchar(255),
	@ShowDetailYN varchar(1),
	@DataSourceSN int
)
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET
		ProcedureName =			@ProcedureName,
		FormatText =			@FormatText,
		NumDigitsAfterDecimal = @NumDigitsAfterDecimal,
		Cumulative =			@Cumulative,
		Annualize =				@Annualize,
		StartDate =				@MetricStartDate,
		DetailFilename =		@DetailFilename,
		ShowDetailByDefaultYN = @ShowDetailYN,
		DataSourceSn =			@DataSourceSN
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateItem] TO [public]
GO
