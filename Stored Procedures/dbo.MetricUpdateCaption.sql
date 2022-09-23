SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateCaption] (@MetricCode varchar(200), @Caption varchar(80), @CaptionFull varchar(255) )
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET 
		Caption = @Caption,
		CaptionFull = @CaptionFull
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateCaption] TO [public]
GO
