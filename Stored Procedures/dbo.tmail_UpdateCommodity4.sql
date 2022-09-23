SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[tmail_UpdateCommodity4]
    @p_fgt_number     VARCHAR(12),
    @p_cmd_code       VARCHAR(8),
    @p_fgt_weight     VARCHAR(12), --FLOAT,
    @p_fgt_weightunit VARCHAR(6),
    @p_fgt_count      VARCHAR(11), --DECIMAL(10,2),
    @p_fgt_countunit  VARCHAR(6),
    @p_fgt_volume     VARCHAR(12), --FLOAT,
    @p_fgt_volumeunit VARCHAR(6),
    @p_fgt_length     VARCHAR(12), --FLOAT,
    @p_fgt_lengthunit VARCHAR(6),
    @p_fgt_height     VARCHAR(12), --FLOAT,
    @p_fgt_heightunit VARCHAR(6),
    @p_fgt_width      VARCHAR(12), --FLOAT,
    @p_fgt_widthunit  VARCHAR(6),
    @p_fgt_quantity   VARCHAR(12), --FLOAT,
    @p_Flags          VARCHAR(12),
    @p_fgt_tare       VARCHAR(12), --FLOAT,
    @p_fgt_tareunit   VARCHAR(6),
	@p_fgt_volume2	  VARCHAR(12), --FLOAT
	@p_fgt_volume2unit VARCHAR(6),
	@p_fgt_unit varchar(12)

AS


/**
 * 
 * NAME:
 * dbo.tmail_UpdateCommodity4
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * verifies that the Units exist
 * and check values.
 * only output is error rasied when one of the above conditions is not met.
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * 001 - @p_fgt_number     INT, input, null;
 *       the frieght number to update
 * 002 - @p_cmd_code       VARCHAR(8),
 *       the
 * 003 - @p_fgt_weight     VARCHAR(12), --FLOAT,
 *       the
 * 004 - @p_fgt_weightunit VARCHAR(6),
 *       the
 * 005 - @p_fgt_count      VARCHAR(11), --DECIMAL(10,2),
 *       the
 * 006 - @p_fgt_countunit  VARCHAR(6),
 *       the
 * 007 - @p_fgt_volume     VARCHAR(12), --FLOAT,
 *       the
 * 008 - @p_fgt_volumeunit VARCHAR(6),
 *       the
 * 009 - @p_fgt_length     VARCHAR(12), --FLOAT,
 *       the
 * 010 - @p_fgt_lengthunit VARCHAR(6),
 *       the
 * 011 - @p_fgt_height     VARCHAR(12), --FLOAT,
 *       the
 * 012 - @p_fgt_heightunit VARCHAR(6),
 *       the
 * 013 - @p_fgt_width      VARCHAR(12), --FLOAT,
 *       the
 * 014 - @p_fgt_widthunit  VARCHAR(6),
 *       the
 * 015 - @p_fgt_quantity   VARCHAR(12)  --FLOAT,
 *       the
 * 016 - @p_Flags          VARCHAR(12),
 *       flag bit value
 *       1 = Respect zero values
 *       2 = update the parent's commodity
 *       4 = update commodity description
 * 017 - @p_fgt_tare       VARCHAR(12), --FLOAT,
 *       the
 * 018 - @p_fgt_tareunit   VARCHAR(6),
 *       the
 * 019 - @p_fgt_volume2     VARCHAR(12), --FLOAT,
 *       the
 * 020 - @p_fgt_volume2unit VARCHAR(6),
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 11/08/2007.01 - PTS 40256 - Lori Brickley - Added Volume2 and Volume2Unit
 * 09/13/2012.01 - PTS 63197 - Andrew Carper - fixed 'UPDATE freightdetail' stmt, re: [fgt_unit]
 * 04/12/2013    - PTS 41938 - Harry Abramowski - commented on flags and where someone else entered in changes for 41938
 * 05/13/2013    - PTS 51530 - harry abramowski - corrected code to update parent records totals 
 * 09/04/2013    - PTS 51530 - Harry Abramowski - per Andrew Carper I am submitting this for testing without waiting for the index to be made.
 **/
DECLARE
  @v_error_msg						VARCHAR(200),
  @v_fgt_number						INT,
  @v_cmd_code						VARCHAR(8),
  @v_fgt_weight						FLOAT,
  @v_fgt_weightunit					VARCHAR(6),
  @v_fgt_count						DECIMAL(10,2),
  @v_fgt_countunit					VARCHAR(6),
  @v_fgt_volume						FLOAT,
  @v_fgt_volumeunit					VARCHAR(6),
  @v_fgt_length						FLOAT,
  @v_fgt_lengthunit					VARCHAR(6),
  @v_fgt_height						FLOAT,
  @v_fgt_heightunit					VARCHAR(6),
  @v_fgt_width						FLOAT,
  @v_fgt_widthunit					VARCHAR(6),
  @v_fgt_quantity					FLOAT,
  @v_Flags 							INT,
  @v_fgt_tare						FLOAT,
  @v_fgt_tareunit					VARCHAR(6),
  @i_respect_zero					INT,
  @v_fgt_volume2					FLOAT,
  @v_fgt_volume2unit				VARCHAR(6),
  @i_update_parent_commodity		INT,
  @i_parent_fgt_number				INT,
  @i_update_commodity_description	INT,
  @v_cmd_name						varchar(60),
  @i_mov_number						INT,
  @i_stp_number						INT

  SET @v_error_msg = ''
  SET @v_fgt_number = 0
  SET  @v_cmd_code = ''
  SET  @v_fgt_weight = 0.00
  SET  @v_fgt_weightunit = ''
  SET  @v_fgt_count = 0.00
  SET  @v_fgt_countunit = ''
  SET  @v_fgt_volume = 0.00
  SET  @v_fgt_volumeunit = ''
  SET  @v_fgt_length = 0.00
  SET  @v_fgt_lengthunit = ''
  SET  @v_fgt_height = 0.00
  SET  @v_fgt_heightunit = ''
  SET  @v_fgt_width = 0.00
  SET  @v_fgt_widthunit = ''
  SET  @v_fgt_quantity = 0.00
  SET  @v_Flags = 0
  SET  @v_fgt_tare = 0.00
  SET  @v_fgt_tareunit = ''
  SET  @i_respect_zero = 0
  SET  @v_fgt_volume2 = 0.00
  SET  @v_fgt_volume2unit = ''
  SET  @i_update_parent_commodity = 0
  SET  @i_parent_fgt_number = 0
  SET  @i_update_commodity_description = 0
  SET  @v_cmd_name = ''
  SET  @i_mov_number = 0
  SET  @i_stp_number = 0

BEGIN
  SET NOCOUNT ON

  --Check freight detail number
  IF ISNUMERIC(@p_fgt_number) = 0
    BEGIN
    	SET @v_error_msg = ': ' + 'Could not update freight detail. Invalid freight detail number: ' + ISNULL(@p_fgt_number, '')
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
	END
  
  SET @v_fgt_number = CONVERT(INT, @p_fgt_number)

  IF ISNUMERIC(@p_flags) = 1
    SET @v_Flags = CONVERT(INT, @p_Flags)

  IF (@v_Flags & 1) = 1
	SET @i_respect_zero = 1

  IF (@v_Flags & 2) = 2
	SET @i_update_parent_commodity = 1

--pts 41938
  IF (@v_Flags & 4) = 4
	SET @i_update_commodity_description = 1

  --Check for valid Commodity code 
  SET @v_cmd_code = ISNULL(@p_cmd_code, '')
  IF (@v_cmd_code <> '')
	  IF NOT EXISTS (SELECT COUNT(*) 
			FROM Commodity (NOLOCK)
	        WHERE cmd_code = @v_cmd_code) 
	    BEGIN
	    	SET @v_error_msg = 'Unknown commodity code: ' + @v_cmd_code
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
	  ELSE
		BEGIN
			--Set the Description on valid commodity
			SELECT @v_cmd_name = cmd_name FROM Commodity WHERE cmd_code = @v_cmd_code
		END

  
  --Check for valid Units
  SET @v_fgt_weightunit = ISNULL(@p_fgt_weightunit, '')
  IF (@v_fgt_weightunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'WeightUnits'
					AND abbr = @v_fgt_weightunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown weight unit: ' + @v_fgt_weightunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
  
  SET @v_fgt_countunit = ISNULL(@p_fgt_countunit, '')
  IF (@v_fgt_countunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'Countunits'
					AND abbr = @v_fgt_countunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown count unit: ' + @v_fgt_countunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
  
  SET @v_fgt_volumeunit = ISNULL(@p_fgt_volumeunit, '')
  IF (@v_fgt_volumeunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'VolumeUnits'
					AND abbr = @v_fgt_volumeunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown volume unit: ' + @v_fgt_volumeunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
  
  SET @v_fgt_volume2unit = ISNULL(@p_fgt_volume2unit, '')
  IF (@v_fgt_volume2unit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) FROM labelfile (NOLOCK)
	         WHERE labeldefinition = 'VolumeUnits'
	           AND abbr = @v_fgt_volume2unit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown volume unit: ' + @v_fgt_volume2unit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END

  SET @v_fgt_lengthunit = ISNULL(@p_fgt_lengthunit, '')
  IF (@v_fgt_lengthunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) FROM labelfile (NOLOCK)
	         WHERE labeldefinition = 'DistanceUnits'
	           AND abbr = @v_fgt_lengthunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown length distance unit: ' + @v_fgt_lengthunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
  
  SET @v_fgt_heightunit = ISNULL(@p_fgt_heightunit, '')
  IF (@v_fgt_heightunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) FROM labelfile (NOLOCK)
	         WHERE labeldefinition = 'DistanceUnits'
	           AND abbr = @v_fgt_heightunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown height distance unit: ' + @v_fgt_heightunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END
  
  SET @v_fgt_widthunit = ISNULL(@p_fgt_widthunit, '')
  IF (@v_fgt_widthunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) FROM labelfile (NOLOCK)
	         WHERE labeldefinition = 'DistanceUnits'
	           AND abbr =  @v_fgt_widthunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown width distance unit: ' +  @p_fgt_widthunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END

  SET @v_fgt_tareunit = ISNULL(@p_fgt_tareunit, '')
  IF (@v_fgt_tareunit <> '')
	  IF NOT EXISTS (SELECT COUNT(*) FROM labelfile (NOLOCK)
	         WHERE labeldefinition = 'WeightUnit'
	           AND abbr =  @v_fgt_tareunit)
	    BEGIN
	    	SET @v_error_msg = 'Unknown tare weight unit: ' +  @p_fgt_tareunit
	    	RAISERROR (@v_error_msg, 16, 1)
	    	RETURN 1
	    END

  --Check values -- (Zero value will not update)
  IF ISNUMERIC(@p_fgt_weight) = 1 OR ISNULL(@p_fgt_weight, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
		  IF ISNULL(@p_fgt_weight, '') <> ''
			  SET @v_fgt_weight = CONVERT(float, @p_fgt_weight)
	  END
  ELSE 
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Weight value: ' + @p_fgt_weight
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_count = 0
  IF ISNUMERIC(@p_fgt_count) = 1 OR ISNULL(@p_fgt_count, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
	     IF ISNULL(@p_fgt_count, '') <> ''
		    SET @v_fgt_count = CONVERT(DECIMAL(10,2), @p_fgt_count)
	  END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Count value: ' + @p_fgt_count
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_volume = 0
  IF ISNUMERIC(@p_fgt_volume) = 1 OR ISNULL(@p_fgt_volume, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
	  	IF ISNULL(@p_fgt_volume, '') <> ''
		  SET @v_fgt_volume = CONVERT(float, @p_fgt_volume)
      END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Volume value: ' + @p_fgt_volume
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

SET @v_fgt_volume2 = 0
  IF ISNUMERIC(@p_fgt_volume2) = 1 OR ISNULL(@p_fgt_volume2, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
	  	IF ISNULL(@p_fgt_volume2, '') <> ''
		  SET @v_fgt_volume2 = CONVERT(float, @p_fgt_volume2)
      END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Volume2 value: ' + @p_fgt_volume2
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_length = 0
  IF ISNUMERIC(@p_fgt_length) = 1 OR ISNULL(@p_fgt_length, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
	  	IF ISNULL(@p_fgt_length, '') <> ''
		  SET @v_fgt_length = CONVERT(float, @p_fgt_length)
      END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Length value: ' + @p_fgt_length
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_height = 0
  IF ISNUMERIC(@p_fgt_height) = 1 OR ISNULL(@p_fgt_height, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
	  	IF ISNULL(@p_fgt_height, '') <> ''
		  SET @v_fgt_height = CONVERT(float, @p_fgt_height)
      END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Height value: ' + @p_fgt_height
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_width = 0
  IF ISNUMERIC(@p_fgt_width) = 1 OR ISNULL(@p_fgt_width, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
		  IF ISNULL(@p_fgt_width, '') <> ''
			  SET @v_fgt_width = CONVERT(float, @p_fgt_width)
	  END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Width value: ' + @p_fgt_width
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  SET @v_fgt_quantity = 0
  IF ISNUMERIC(@p_fgt_quantity) = 1 OR ISNULL(@p_fgt_quantity, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
		  IF ISNULL(@p_fgt_quantity, '') <> ''
			  SET @v_fgt_quantity = CONVERT(float, @p_fgt_quantity)
	  END
  ELSE
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Quantity value: ' + @p_fgt_quantity
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END

  --Check values -- (Zero value will not update)
  SET @v_fgt_tare = 0
  IF ISNUMERIC(@p_fgt_tare) = 1 OR ISNULL(@p_fgt_tare, '') = '' --Let Numeric, NULL, or blank through
	  BEGIN
		  IF ISNULL(@p_fgt_tare, '') <> ''
			  SET @v_fgt_tare = CONVERT(float, @p_fgt_tare)
	  END
  ELSE 
    BEGIN
    	SET @v_error_msg = ': ' + 'Invalid Tare Weight value: ' + @p_fgt_tare
    	RAISERROR (@v_error_msg, 16, 1)
    	RETURN 1
    END
    
--05/13/2013    - PTS 51530
/*
SELECT @i_mov_number = ISNULL(mov_number,-1) 
FROM stops (NOLOCK)
WHERE stp_number = @i_stp_number

IF EXISTS (	SELECT fgt_parentcmd_fgt_number 
			FROM freightdetail (NOLOCK) 
			WHERE fgt_parentcmd_fgt_number = @i_parent_fgt_number
				AND stp_number IN (SELECT stp_number from stops (NOLOCK) where mov_number = @i_mov_number)
			GROUP BY fgt_parentcmd_fgt_number having count(*) >1
			)
	SET @i_parent_fgt_number = -1
*/

  UPDATE freightdetail SET
      cmd_code 			= CASE @v_cmd_code WHEN '' THEN cmd_code ELSE @v_cmd_code END,
      --pts 41938
	  fgt_description   = CASE WHEN @v_cmd_name <> '' AND @i_update_commodity_description = 1 THEN @v_cmd_name ELSE fgt_description END,
      fgt_weight 		= CASE WHEN @v_fgt_weight = 0 AND @i_respect_zero = 0 THEN fgt_weight ELSE @v_fgt_weight END,
      fgt_weightunit 	= CASE @v_fgt_weightunit WHEN '' THEN fgt_weightunit ELSE @v_fgt_weightunit END,
      fgt_count		    = CASE WHEN @v_fgt_count = 0 AND @i_respect_zero = 0 THEN fgt_count ELSE @v_fgt_count END,
      fgt_countunit  	= CASE @v_fgt_countunit WHEN '' THEN fgt_countunit ELSE @v_fgt_countunit END,
      fgt_volume	    = CASE WHEN @v_fgt_volume = 0 AND @i_respect_zero = 0 THEN fgt_volume ELSE @v_fgt_volume END,
      fgt_volumeunit    = CASE @v_fgt_volumeunit WHEN '' THEN fgt_volumeunit ELSE @v_fgt_volumeunit END,
      fgt_length	    = CASE WHEN @v_fgt_length = 0 AND @i_respect_zero = 0 THEN fgt_length ELSE @v_fgt_length END,
      fgt_lengthunit 	= CASE @v_fgt_lengthunit WHEN '' THEN fgt_lengthunit ELSE @v_fgt_lengthunit END,
      fgt_height	    = CASE WHEN @v_fgt_height = 0 AND @i_respect_zero = 0 THEN fgt_height ELSE @v_fgt_height END,
      fgt_heightunit 	= CASE @v_fgt_heightunit WHEN '' THEN fgt_heightunit ELSE @v_fgt_heightunit END, 
      fgt_width		    = CASE WHEN @v_fgt_width = 0 AND @i_respect_zero = 0 THEN fgt_width ELSE @v_fgt_width END,
      fgt_widthunit 	= CASE @v_fgt_widthunit WHEN '' THEN fgt_widthunit ELSE @v_fgt_widthunit END,
      fgt_quantity	    = CASE WHEN @v_fgt_quantity = 0 AND @i_respect_zero = 0 THEN fgt_quantity ELSE @v_fgt_quantity END,
      tare_weight	    = CASE WHEN @v_fgt_tare = 0 AND @i_respect_zero = 0 THEN tare_weight ELSE @v_fgt_tare END,
      tare_weightunit	= CASE @v_fgt_tareunit WHEN '' THEN tare_weightunit ELSE @v_fgt_tareunit END,
      fgt_volume2	    = CASE WHEN @v_fgt_volume2 = 0 AND @i_respect_zero = 0 THEN fgt_volume2 ELSE @v_fgt_volume2 END,
      fgt_volume2unit   = CASE @v_fgt_volume2unit WHEN '' THEN fgt_volume2unit ELSE @v_fgt_volume2unit END,
      fgt_unit			= CASE @p_fgt_unit WHEN '' THEN fgt_unit ELSE @p_fgt_unit END	  
    WHERE fgt_number = @v_fgt_number
	--	05/13/2013    - PTS 51530  OR (@i_update_parent_commodity = 1 AND fgt_number = @i_parent_fgt_number)


SET @i_parent_fgt_number = -1 
SELECT @i_parent_fgt_number = ISNULL(fgt_parentcmd_fgt_number,-1) 
-- pts 51530   , @i_stp_number = ISNULL(stp_number,-1) 
FROM freightdetail (NOLOCK)
WHERE fgt_number = @v_fgt_number

--05/13/2013    - PTS 51530
declare @volume float,@quantity float,@volume2 float

if @i_parent_fgt_number is not null and @i_parent_fgt_number <>0
	begin
		--set @volume=(select sum(fgt_volume) from freightdetail where fgt_parentcmd_fgt_number=@i_parent_fgt_number)
		--update freightdetail set fgt_volume=@volume where fgt_number=@i_parent_fgt_number
		--set @quantity=(select sum(fgt_quantity) from freightdetail where fgt_parentcmd_fgt_number=@i_parent_fgt_number)
		--update freightdetail set fgt_quantity=@quantity where fgt_number=@i_parent_fgt_number
		--set @volume2=(select sum(fgt_volume2) from freightdetail where fgt_parentcmd_fgt_number=@i_parent_fgt_number)
		--update freightdetail set fgt_volume2=@volume2 where fgt_number=@i_parent_fgt_number
		-- thanks to Chris Morton for the following replacement script
		SELECT @volume = sum(fgt_volume),@quantity = sum(fgt_quantity), @volume2 = SUM(fgt_volume2) 
		  from freightdetail where fgt_parentcmd_fgt_number=@i_parent_fgt_number
		
		UPDATE freightdetail 
		SET fgt_volume=@volume, fgt_quantity=@quantity, fgt_volume2=@volume2
		where fgt_number=@i_parent_fgt_number

	end
 -- 5/14/13 end of pts 51530
END


GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateCommodity4] TO [public]
GO
