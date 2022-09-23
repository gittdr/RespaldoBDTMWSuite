SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateOverviewParameterPart] (@sn int, @PiePage int, @Active int, @Side varchar(255), @Sort int, @Mode varchar(255), @CannedMode int
)
AS
	SET NOCOUNT ON

	UPDATE RN_OverviewParameter SET
		Page = @PiePage,
		Active = @Active,
		Side = @Side,
		Sort = @Sort,
		Mode = @Mode,
		CannedMode = @CannedMode
	WHERE sn = @sn

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateOverviewParameterPart] TO [public]
GO
