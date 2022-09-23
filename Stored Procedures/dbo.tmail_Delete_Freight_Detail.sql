SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_Delete_Freight_Detail] 	@p_sFreightNumber varchar(12), 	--1
													@p_sFlags varchar(12)			--2

AS
/**
 * 
 * NAME:
 * dbo.tmail_Add_Accessorial
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Deletes a freight detail
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * 001 - @p_sFreightNumber  VARCHAR(12), input;
 *       Freight detail number to delete
 * 002 - @p_sFlags		  	VARCHAR(12), input;
 * 		 None
 *       
 * REFERENCES:
 * update_assetassignment
 * update_move_light
 * update_ord
 * 
 * REVISION HISTORY:
 * 03/24/2006.01 – PTS 31262 - David Gudat – initial version
 *
 **/
 
 SET NOCOUNT ON 
 
DECLARE @fgt_number int,
		@stp_number int,
		@lmove int,
		@movenumber varchar(12),
		@stp_status varchar(6),
		@UpdateMovPreProcessor varchar(256),
		@UpdateMovPreProcessorSwitch varchar(1),
		@UpdateMovPostProcessor varchar(256),
		@UpdateMovPostProcessorSwitch varchar(1)

IF ISNULL(@p_sFreightNumber, 0 ) = 0
	BEGIN
	RAISERROR('Freight number must be passed in.', 16, 1)
	RETURN
	END

SET @fgt_number = CONVERT(int, @p_sFreightNumber)

IF EXISTS (SELECT fgt_number 
			FROM freightdetail (NOLOCK)
			WHERE fgt_number = @fgt_number)
	BEGIN

	-- Get the move number 
	SET @lmove = 0
	
	--get stop number before deletion
	SELECT @stp_number = f.stp_number, @lmove = mov_number, @stp_status = stp_departure_status
		FROM freightdetail f (NOLOCK)
		INNER JOIN stops s  (NOLOCK) ON f.stp_number = s.stp_number
		WHERE fgt_number = @fgt_number

	IF @stp_status = 'DNE' 
		BEGIN
		RAISERROR('Stop number %s for freight is actualized, can not delete freight.', 16, 1, @stp_number)
		RETURN
		END

	SET @movenumber = CONVERT(varchar(12), @lmove)

	--Delete the freight detail
	DELETE FROM freightdetail WHERE fgt_number = @fgt_number

	--Fix stop freight detail sequencing
	UPDATE freightdetail 
		SET fgt_sequence = 
			(SELECT count(*) 
				FROM freightdetail s (NOLOCK)
				WHERE s.stp_number = freightdetail.stp_number 
					AND s.fgt_sequence <= freightdetail.fgt_sequence)
		WHERE freightdetail.stp_number = @stp_number
	
	-- PTS 27180
	-- Get the update move pre-processor
	SET @UpdateMovPreProcessor = ''
	SET @UpdateMovPreProcessorSwitch = ''
	SELECT @UpdateMovPreProcessorSwitch = gi_string1, @UpdateMovPreProcessor = gi_string2
	FROM generalinfo  (NOLOCK)
	WHERE gi_name = 'DispatchPreLghProcessing'
	
	-- Get the update move post-processor
	SET @UpdateMovPostProcessor = ''
	SET @UpdateMovPostProcessorSwitch = ''
	SELECT @UpdateMovPostProcessorSwitch = gi_string1, @UpdateMovPostProcessor = gi_string2
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'DispatchPostLghProcessing'
	
	-- PTS 14534
	EXEC dbo.update_assetassignment @movenumber
	
	-- run the update move pre-processor
	if @UpdateMovPreProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPreProcessor) > ''
		EXEC (@UpdateMovPreProcessor + ' ' + @movenumber)
	
	EXEC dbo.update_move_light @movenumber
	
	-- run the update move post-processor
	if @UpdateMovPostProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPostProcessor) > ''
		EXEC (@UpdateMovPostProcessor + ' ' + @movenumber)
	
	EXEC dbo.update_ord @movenumber, 'UNK'
	
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_Delete_Freight_Detail] TO [public]
GO
