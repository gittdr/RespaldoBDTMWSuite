SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSysParm] (
	@SubHeading varchar(100), 
	@ParmName varchar(200), 
	@ParmValue varchar(255) = NULL, 
	@SetFlag int = NULL,
	@RemoveFlag int = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	-- Purpose: Have a central location for changing and retrieving system parameters.
	-- 			Any time a system parameter is added, the developer must make a change here.
	--			This is so developers are aware of ALL system parameters, and do mistakenly reuse it.
	-- Description: If ParmValue and SetFlag are NULL, then retrieve value.
	
	DECLARE @ParmDescription VARCHAR(255)

	IF @ParmValue IS NULL AND @SetFlag IS NULL  -- RETRIEVE Parameter value
	BEGIN
		SELECT CASE WHEN ISDATE(ParmValue)=1 THEN CONVERT(datetime, ParmValue) ELSE ParmValue END AS ParmValue FROM MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
		RETURN
	END
	
	IF @SetFlag = 1		-- Do Update
	BEGIN
		IF @ParmName = 'RefreshHistoryLastDateTime'  -- SubHeading will be actual MetricCode
		BEGIN
			IF @RemoveFlag = 1 
			BEGIN
				DELETE MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
				RETURN
			END
			SET @ParmDescription = 'Date stored to contain the last date/time that history for a metric was refreshed.  Used in MetricProcessing.'
			IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName)
				UPDATE MetricParameter SET ParmValue = @ParmValue, ParmDescription = @ParmDescription
				WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
			ELSE
				INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmDescription)
				SELECT 'System', @SubHeading, @ParmName, @ParmValue, @ParmDescription
		END

		ELSE IF @SubHeading = 'TimeFrameHeadings' AND 
				(@ParmName = 'BusinessDayThis' OR @ParmName = 'BusinessDayLast' )
		BEGIN
			IF @RemoveFlag = 1 
			BEGIN
				DELETE MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
				RETURN
			END
			SET @ParmDescription = 'Time frame headings for display purposes.'
			IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName)
				UPDATE MetricParameter SET ParmValue = @ParmValue, ParmDescription = @ParmDescription
				WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
			ELSE
				INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmDescription)
				SELECT 'System', @SubHeading, @ParmName, @ParmValue, @ParmDescription
		END

		ELSE IF @SubHeading = 'TimeFrame' AND 
				(@ParmName = 'BusinessDayThis' OR @ParmName = 'BusinessDayLast' )
		BEGIN
			IF @RemoveFlag = 1 
			BEGIN
				DELETE MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
				RETURN
			END
			SET @ParmDescription = 'Time frames to use for display purposes.'
			IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName)
				UPDATE MetricParameter SET ParmValue = @ParmValue, ParmDescription = @ParmDescription
				WHERE Heading = 'System' AND SubHeading = @SubHeading AND ParmName = @ParmName
			ELSE
				INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmDescription)
				SELECT 'System', @SubHeading, @ParmName, @ParmValue, @ParmDescription
		END

	END
GO
GRANT EXECUTE ON  [dbo].[MetricSysParm] TO [public]
GO
