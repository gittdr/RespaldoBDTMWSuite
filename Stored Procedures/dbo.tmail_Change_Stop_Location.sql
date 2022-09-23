SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_Change_Stop_Location] @p_sCompanyID varchar(25),  	--PTS 61189 change cmp_id fields to 25 length
												@p_sStopNumber varchar(12), 
												@p_sFlags varchar(12)

AS



--------------IMPORTANT------------
--NOTE
--NOTE: Please also change the ResetStopCompany sub in PSUpdate.clsUpdateMoveLib (UpdatMove) if you change this stored procedure
--NOTE
-----------------------------------

/**
 * 
 * NAME:
 * dbo.tmail_Change_Stop_Location
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Changes the company id on a stop. Updates stop company info.
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * 001 - @p_sCompanyID		VARCHAR(8), input;
 *       New company ID for stop
 * 002 - @p_sStopNumber		VARCHAR(12), input;
 *       Stop number to change company ID on
 * 003 - @p_sFlags		  	VARCHAR(12), input;
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

	DECLARE @stp_number int, 
			@movenumber int, 
			@stp_Status varchar(6),
			@UpdateMovPreProcessor varchar(256),
			@UpdateMovPreProcessorSwitch varchar(1),
			@UpdateMovPostProcessor varchar(256),
			@UpdateMovPostProcessorSwitch varchar(1)

	--check stop number
	IF ISNULL(@p_sStopNumber, 0) = 0
		BEGIN
		RAISERROR('Stop number must be passed in.', 16, 1)
		RETURN
		END
	
	SET @stp_number = CONVERT(int, @p_sStopNumber)

	--get status and move number from stop
	SELECT @stp_status = stp_status, @movenumber = mov_number  
		FROM stops (NOLOCK) 
		WHERE stp_number = @stp_number

	--make sure the stop is not actualized
	IF @stp_status = 'DNE' 
		BEGIN
		RAISERROR('Stop number %d is actualized, can not change location.', 16, 1, @stp_number)
		RETURN
		END

	UPDATE Stops
		SET cmp_id = @p_sCompanyID,
			cmp_name = ISNULL(c.cmp_name, ''),
			stp_address = ISNULL(c.cmp_address1, ''),
			stp_address2 = ISNULL(c.cmp_address2, ''),
			stp_zipcode = ISNULL(c.cmp_zip, ''),
			stp_phonenumber = ISNULL(c.cmp_primaryphone,''), 
			stp_phonenumber2 = ISNULL(c.cmp_secondaryphone,''), 
			stp_contact = ISNULL(c.cmp_contact,''),
			stp_city = ISNULL(c.cmp_city, 0)
		FROM Stops, Company c
    	WHERE c.cmp_id = @p_sCompanyID AND stp_number = @stp_number


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
	

GO
GRANT EXECUTE ON  [dbo].[tmail_Change_Stop_Location] TO [public]
GO
