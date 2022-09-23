SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_QuarterRound]
( @Source				DECIMAL(19,4)	-- Source Value
, @RoundType			VARCHAR(10)		-- ROUND, FLOOR, CEILING
) RETURNS DECIMAL(19,4)

AS
/**
 *
 * NAME:
 * dbo.fnc_QuarterRound
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns rounded number into nearest quarter
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @Source				DECIMAL(19,4 
 *	002 @RoundType			VARCHAR(10)	
 *
 * REVISION HISTORY:
 * PTS 77529 SPN 05/23/2014 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @RetVal					DECIMAL(19,4)
   DECLARE @SourceAbsWhole			DECIMAL(19,4)
   DECLARE @SourceAbsFraction		DECIMAL(19,4)
   
   SELECT @RetVal = 0
   SELECT @SourceAbsWhole = FLOOR(ABS(@Source))
	SELECT @SourceAbsFraction = ABS(@Source) - @SourceAbsWhole

	SELECT @RoundType = IsNull(@RoundType,'ROUND')

   IF @RoundType = 'FLOOR'
	BEGIN
		IF @Source > 0
			IF @SourceAbsFraction > 0.0000 AND @SourceAbsFraction < 0.2500
				SELECT @RetVal = 0.0000
			ELSE IF @SourceAbsFraction > 0.2500 AND @SourceAbsFraction < 0.5000
				SELECT @RetVal = 0.2500
			ELSE IF @SourceAbsFraction > 0.5000 AND @SourceAbsFraction < 0.7500
				SELECT @RetVal = 0.5000
			ELSE IF @SourceAbsFraction > 0.7500 AND @SourceAbsFraction < 1.0000
				SELECT @RetVal = 0.7500
		ELSE
			IF @SourceAbsFraction > 0.0000 AND @SourceAbsFraction < 0.2500
				SELECT @RetVal = 0.2500
			ELSE IF @SourceAbsFraction > 0.2500 AND @SourceAbsFraction < 0.5000
				SELECT @RetVal = 0.5000
			ELSE IF @SourceAbsFraction > 0.5000 AND @SourceAbsFraction < 0.7500
				SELECT @RetVal = 0.7500
			ELSE IF @SourceAbsFraction > 0.7500 AND @SourceAbsFraction < 1.0000
				SELECT @RetVal = 1
	END

	IF @RoundType = 'CEILING'
	BEGIN
		IF @Source > 0
			IF @SourceAbsFraction > 0.0000 AND @SourceAbsFraction < 0.2500
				SELECT @RetVal = 0.2500
			ELSE IF @SourceAbsFraction > 0.2500 AND @SourceAbsFraction < 0.5000
				SELECT @RetVal = 0.5000
			ELSE IF @SourceAbsFraction > 0.5000 AND @SourceAbsFraction < 0.7500
				SELECT @RetVal = 0.7500
			ELSE IF @SourceAbsFraction > 0.7500 AND @SourceAbsFraction < 1.0000
				SELECT @RetVal = 1
		ELSE
			IF @SourceAbsFraction > 0.0000 AND @SourceAbsFraction < 0.2500
				SELECT @RetVal = 0.0000
			ELSE IF @SourceAbsFraction > 0.2500 AND @SourceAbsFraction < 0.5000
				SELECT @RetVal = 0.2500
			ELSE IF @SourceAbsFraction > 0.5000 AND @SourceAbsFraction < 0.7500
				SELECT @RetVal = 0.5000
			ELSE IF @SourceAbsFraction > 0.7500 AND @SourceAbsFraction < 1.0000
				SELECT @RetVal = 0.7500
	END
		
	IF @RoundType = 'ROUND'
	BEGIN
		IF @SourceAbsFraction > 0.0000 AND @SourceAbsFraction < 0.2500
			IF @SourceAbsFraction >= 0.1250
				SELECT @RetVal = 0.2500
			ELSE
				SELECT @RetVal = 0.0000
		ELSE IF @SourceAbsFraction > 0.2500 AND @SourceAbsFraction < 0.5000
			IF @SourceAbsFraction >= 0.3750
				SELECT @RetVal = 0.5000
			ELSE
				SELECT @RetVal = 0.2500
		ELSE IF @SourceAbsFraction > 0.5000 AND @SourceAbsFraction < 0.7500
			IF @SourceAbsFraction >= 0.6250
				SELECT @RetVal = 0.7500
			ELSE
				SELECT @RetVal = 0.5000
		ELSE IF @SourceAbsFraction > 0.7500 AND @SourceAbsFraction < 1.0000
			IF @SourceAbsFraction >= 0.8750
				SELECT @RetVal = 1
			ELSE
				SELECT @RetVal = 0.7500
	END

	SELECT @RetVal = @SourceAbsWhole + @RetVal
	IF @Source < 0
		SELECT @RetVal = @RetVal * -1
		
   RETURN @RetVal

END
GO
GRANT EXECUTE ON  [dbo].[fnc_QuarterRound] TO [public]
GO
