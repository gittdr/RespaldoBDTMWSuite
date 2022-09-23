SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_Copy_Freight_Detail] 	@p_sFreightNumber varchar(12), 
												@p_sStopNumber varchar(12), 
												@p_sFlags varchar(12)

AS
/**
 * 
 * NAME:
 * dbo.tmail_Copy_Freight_Detail
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Copies a freight detail to a stop.
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * FreightDetailNumber  - new freight detail number
 *
 * PARAMETERS:
 * 001 - @p_sFreightNumber  VARCHAR(12), input;
 *       Freight Detail Number to copy
 * 002 - @p_sStopNumber    	VARCHAR(12), input;
 *       Stop number to copy the freight detail to
 * 003 - @p_sFlags     		VARCHAR(12), input;
 *       1	Delete Original
 * 	 	 2	Remove first freight detail if no freight details are set
 *	 	 4	Do not copy reference numbers
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 03/24/2006.01 – PTS 31262 - David Gudat – initial version
 *
 **/

SET NOCOUNT ON 

DECLARE @lFlags int,
		@lOrgMove int,
		@lOrgStop int,
		@lNewMove int,
		@lFirst_fgt_number int,
		@stp_number int,
		@fgt_number int,
		@fgt_Sequence int,
		@movenumber varchar(12),
		@stp_status varchar(6),
		@new_fgt_number int,
		@UpdateMovPreProcessor varchar(256),
		@UpdateMovPreProcessorSwitch varchar(1),
		@UpdateMovPostProcessor varchar(256),
		@UpdateMovPostProcessorSwitch varchar(1)

--Convert Flags field to integer
SET @lFlags = CONVERT(int, @p_sFlags)

--check stop number
IF ISNULL(@p_sStopNumber, 0) = 0
	BEGIN
	RAISERROR('Stop number must be passed in.', 16, 1)
	RETURN
	END

--convert stop number to integer
SET @stp_number = CONVERT(int, @p_sStopNumber)

--check freight detail number
IF ISNULL(@p_sFreightNumber, 0 ) = 0
	BEGIN
	RAISERROR('Freight number must be passed in.', 16, 1)
	RETURN
	END

--Convert Freight Detail number to integer
SET @fgt_number = CONVERT(int, @p_sFreightNumber)

--get the departure status and move number on the new stop	
SELECT @stp_status = stp_departure_status, @lNewMove = mov_number  
	FROM stops 
	WHERE stp_number = @stp_number

--make sure the stop departure is not actualized
IF @stp_status = 'DNE' 
	BEGIN
	RAISERROR('Stop number %s for new freight is actualized, can not add freight.', 16, 1, @stp_number)
	RETURN
	END

--get the move number on the original stop	
SELECT @lOrgMove = s.mov_number, @lOrgStop = f.stp_number
	FROM freightdetail f (NOLOCK) 
	INNER JOIN stops s (NOLOCK) ON f.stp_number = s.stp_number
	WHERE fgt_number = @fgt_number

IF (@lFlags & 2) <> 0 --Remove First Freight detail if freight detail is not set
	BEGIN
		--if there is only one freight detail on the stop
		IF (SELECT count(*) FROM freightdetail WHERE stp_number = @stp_number) = 1
		BEGIN
			
			--get the first freight detail number 
			SELECT @lFirst_fgt_number = fgt_number 
			FROM freightdetail (NOLOCK)
			WHERE stp_number =  @stp_number
			
			--check to make sure it has not been set
			IF (SELECT CASE ISNULL(cmd_code, 'UNKNOWN') WHEN 'UNKNOWN' THEN 0 ELSE 1 END +
					   ISNULL(fgt_weight, 0) +
					   ISNULL(fgt_count, 0) +
					   ISNULL(fgt_volume, 0) +
					   ISNULL(fgt_length, 0) +
					   ISNULL(fgt_height, 0) +
					   ISNULL(fgt_width, 0) +
					   ISNULL(fgt_rate, 0) +
					   ISNULL(fgt_charge, 0) +
					   ISNULL(tare_weight, 0) +
					   ISNULL(fgt_pallets_in , 0) +
					   ISNULL(fgt_pallets_out, 0) +
					   ISNULL(fgt_pallets_on_trailer, 0) +
					   CASE ISNULL(fgt_refnum, '') WHEN '' THEN 0 ELSE 1 END +
					   CASE ISNULL(fgt_description, 'UNKNOWN') WHEN 'UNKNOWN' THEN 0 ELSE 1 END 
				FROM freightdetail (NOLOCK)
				WHERE fgt_number = @lFirst_fgt_number) = 0

				--not set, delete the frist freight detail
				DELETE FROM freightdetail WHERE fgt_number = @lFirst_fgt_number
		END
	END

IF (@lFlags & 1) <> 0 --Delete Original
	BEGIN

		--get the next freight detail sequence on the new stop
		SELECT @fgt_Sequence = MAX(fgt_sequence)
			FROM freightdetail (NOLOCK)
			WHERE stp_number = @stp_number
	
		SET @fgt_Sequence = ISNULL(@fgt_Sequence, 0) + 1
		
		--change the freight detail stop number to the new stop and also set the new freight sequence number
		UPDATE freightdetail 
			SET stp_number = @stp_number, fgt_sequence = @fgt_Sequence 
			WHERE fgt_number = @fgt_number
				
		--Fix original stop freight detail sequencing
		UPDATE freightdetail 
			SET fgt_sequence = 
				(SELECT count(*) 
					FROM freightdetail s (NOLOCK)
					WHERE s.stp_number = freightdetail.stp_number 
						AND s.fgt_sequence <= freightdetail.fgt_sequence)
			WHERE freightdetail.stp_number = @lOrgStop

	END

ELSE -- Copy the Freight Detail
	BEGIN
	
		--get the next freight detail sequence on the new stop
		SELECT @fgt_Sequence = MAX(fgt_sequence)
			FROM freightdetail (NOLOCK)
			WHERE stp_number = @stp_number
	
		SET @fgt_Sequence = ISNULL(@fgt_Sequence, 0) + 1

		--Get next freight detail number
		EXEC @new_fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL

		--do the insert based on original freigth detail
		INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 					--1	
			                       cmd_code, fgt_description, fgt_reftype, 					--2
			                       fgt_refnum,fgt_pallets_in, 								--3
			                       fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
			                       fgt_carryins2, skip_trigger, fgt_quantity,				--5
			                       fgt_weight, fgt_weightunit, fgt_count,					--6
			                       fgt_countunit, fgt_volume, fgt_volumeunit)				--7
						   SELECT  @stp_number, @fgt_Sequence, @new_fgt_number,				--1
			                       cmd_code, fgt_description, fgt_reftype, 					--2
			                       fgt_refnum,fgt_pallets_in, 								--3
			                       fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
			                       fgt_carryins2, skip_trigger, fgt_quantity,				--5
			                       fgt_weight, fgt_weightunit, fgt_count,					--6
			                       fgt_countunit, fgt_volume, fgt_volumeunit				--7
							FROM freightdetail (NOLOCK)
							WHERE fgt_number = @fgt_number
		
		IF (@lFlags & 4) = 0 --Do not copy reference numbers
			--Copy reference numbers
		    INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, 
										  ref_typedesc, ref_sequence, ord_hdrnumber, 
										  ref_table, ref_sid, ref_pickup, last_updateby)
								SELECT	  @new_fgt_number, ref_type, ref_number, 
										  ref_typedesc, ref_sequence, ord_hdrnumber, 
										  ref_table, ref_sid, ref_pickup, 'TM'
									FROM referencenumber (NOLOCK)
									WHERE ref_tablekey = @fgt_number
										AND ref_table = 'freightdetail'
		
		--Set freight detail number to new freight detail number to return below
		SET @fgt_number = @new_fgt_number

	END


--Run updatemove against original order
SET @movenumber = @lOrgMove

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

--Update the new Move if not the same as the old move
IF @lOrgMove <> @lNewMove
	BEGIN

		--Run updatemove against original order
		SET @movenumber = @lNewMove
		
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
	
	
	END

	--return new or original freight detail number
	SELECT @fgt_number FreightDetailNumber

GO
GRANT EXECUTE ON  [dbo].[tmail_Copy_Freight_Detail] TO [public]
GO
