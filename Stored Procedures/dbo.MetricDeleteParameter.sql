SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteParameter] (@Heading varchar(200), @SubHeading varchar(100), @ParmName varchar(100))
AS
	SET NOCOUNT ON

	DELETE MetricParameter WHERE Heading = @Heading AND SubHeading = @SubHeading AND ParmName = @ParmName
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteParameter] TO [public]
GO
