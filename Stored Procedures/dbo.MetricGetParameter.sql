SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetParameter] (@Heading varchar(200), @SubHeading varchar(100), @ParmName varchar(100), @Default varchar(255))
AS
	SET NOCOUNT OFF

	DECLARE @ParmValue varchar(255)

    SELECT @ParmValue = ParmValue FROM metricparameter WHERE Heading = @Heading  AND SubHeading = @SubHeading AND ParmName = @ParmName 

	IF @ParmValue IS NULL
	BEGIN
        IF (@Heading = 'MetricGeneral' And @SubHeading = 'Chart' And @ParmName = 'GRAPH_HEIGHT' )
		BEGIN
			SET @ParmValue = 200 -- pixels
		END
		ELSE 
		BEGIN
			IF (@Heading = 'MetricGeneral' AND @SubHeading = 'Chart' And @ParmName = 'GRAPH_WIDTH')
			BEGIN
				SET @ParmValue = 500 -- pixels 
			END
			ELSE
			BEGIN
				SELECT @ParmValue = @Default
			END
		END
	END

	SELECT @ParmValue
GO
GRANT EXECUTE ON  [dbo].[MetricGetParameter] TO [public]
GO
