SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_dispatch_lgh]
	@ordernumber varchar(12), 
	@movenumber varchar(12),
	@tractornumber varchar(13)
AS

SET NOCOUNT ON 

DECLARE @sLegNum varchar(12), @lLegNum int,
		@UpdateMovPreProcessor varchar(256),
		@UpdateMovPreProcessorSwitch varchar(1),
		@UpdateMovPostProcessor varchar(256),
		@UpdateMovPostProcessorSwitch varchar(1)

BEGIN
	EXEC dbo.tmail_get_lgh_number_sp @ordernumber, @movenumber, @tractornumber, @sLegNum OUT
	if ISNULL(@sLegNum, '') > ''
		SELECT @lLegNum = CONVERT(int, @sLegNum)
END

-- PTS 27180
-- Get the update move pre-processor
SET @UpdateMovPreProcessor = ''
SET @UpdateMovPreProcessorSwitch = ''
SELECT @UpdateMovPreProcessorSwitch = gi_string1, @UpdateMovPreProcessor = gi_string2
FROM generalinfo (NOLOCK)
WHERE gi_name = 'DispatchPreLghProcessing'

-- Get the update move post-processor
SET @UpdateMovPostProcessor = '' 
SET @UpdateMovPostProcessorSwitch = ''
SELECT @UpdateMovPostProcessorSwitch = gi_string1, @UpdateMovPostProcessor = gi_string2
FROM generalinfo (NOLOCK)
WHERE gi_name = 'DispatchPostLghProcessing'

IF ISNULL(@LLegNum, 0) > 0
	BEGIN
		UPDATE legheader
		SET lgh_outstatus = 'DSP', lgh_dsp_date = GetDate()
		WHERE lgh_number = @lLegNum AND lgh_outstatus = 'PLN'

		-- Set the lgh_updatedby fields
		EXEC dbo.tmail_lghUpdatedBy @lLegNum

		-- PTS 14534
		EXEC dbo.update_assetassignment @movenumber

		-- {27180} run the update move pre-processor
		if @UpdateMovPreProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPreProcessor) > ''
			EXEC (@UpdateMovPreProcessor + ' ' + @movenumber)

		EXEC dbo.update_move_light @movenumber

		-- {27180} run the update move post-processor
		if @UpdateMovPostProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPostProcessor) > ''
			EXEC (@UpdateMovPostProcessor + ' ' + @movenumber)

	END
GO
GRANT EXECUTE ON  [dbo].[tmail_dispatch_lgh] TO [public]
GO
