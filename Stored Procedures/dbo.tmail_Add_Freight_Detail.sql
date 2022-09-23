SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_Add_Freight_Detail] 	@p_sStopNumber varchar(12), 	--1
												@p_sFlags varchar(12)			--2

AS

SET NOCOUNT ON

/**
 * 
 * NAME:
 * dbo.tmail_Add_Accessorial
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Adds a freight detail to a stop
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * New freight detail number
 *
 * PARAMETERS:
 * 001 - @p_sStopNumber     VARCHAR(12), input;
 *       Stop number to add freight detail to
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
 * 07/29/2014      PTS 79468 - Harry Abramowski
 **/

DECLARE @stp_number int,
		@fgt_number	int,
		@fgt_Sequence int,
		@stp_status varchar(6),
		@lmove int,
		@movenumber varchar(12),
		@UpdateMovPreProcessor varchar(256),
		@UpdateMovPreProcessorSwitch varchar(1),
		@UpdateMovPostProcessor varchar(256),
		@UpdateMovPostProcessorSwitch varchar(1),
		@iFlags int,--pts 79468
		@i_Allow_update_if_completed int

IF ISNULL(@p_sStopNumber, 0) = 0
	BEGIN
	RAISERROR('Stop number must be passed in.', 16, 1)
	RETURN
	END

SET @stp_number = CONVERT(int, @p_sStopNumber)
SET @iFlags = CONVERT(int, isnull(@p_sFlags,'')) --pts 79468
SET @i_Allow_update_if_completed  = 0 --pts 79468

-- Get the status and move number from the stop
SET @lmove = 0

SELECT @stp_status = stp_status, @movenumber = mov_number  
	FROM stops (NOLOCK)
	WHERE stp_number = @stp_number

--pts 79468
  IF (@iFlags & 1) = 1
	SET @i_Allow_update_if_completed  = 1
	
IF @stp_status = 'DNE' and @i_Allow_update_if_completed <> 1
	BEGIN
	RAISERROR('Stop number %d for freight is actualized, can not add freight.', 16, 1, @stp_number)
	RETURN
	END

SET @movenumber = CONVERT(varchar(12), @lmove)

--get the next freight detail sequence
SELECT @fgt_Sequence = MAX(fgt_sequence)
	FROM freightdetail (NOLOCK)
	WHERE stp_number = @stp_number

SET @fgt_Sequence = @fgt_Sequence + 1

--Get next freight detail number
EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL

--do the insert
INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 					--1	
	                       cmd_code, fgt_description, fgt_reftype, 					--2
	                       fgt_refnum,fgt_pallets_in, 								--3
	                       fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
	                       fgt_carryins2, skip_trigger, fgt_quantity,				--5
	                       fgt_weight, fgt_weightunit, fgt_count,					--6
	                       fgt_countunit, fgt_volume, fgt_volumeunit)				--7
                   VALUES (@stp_number, @fgt_Sequence, @fgt_number, 				--1
	                       'UNKNOWN', 'UNKNOWN', 'REF',								--2
	                       '',0,													--3
	                       0, 0, 0,													--4
	                       0, 1, 0,													--5
	                       0, 'LBS', 0,												--6
	                       'PCS', 0, 'GAL')											--7

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


SELECT @fgt_number FreightDetailNumber

GO
GRANT EXECUTE ON  [dbo].[tmail_Add_Freight_Detail] TO [public]
GO
