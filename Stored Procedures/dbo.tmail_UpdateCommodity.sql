SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateCommodity]
    @p_fgt_number     VARCHAR(12),
    @p_cmd_code       VARCHAR(6),
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
    @p_Flags          VARCHAR(12)

AS
/**
 * 
 * NAME:
 * dbo.tmail_UpdateCommodity
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
 * 002 - @p_cmd_code       VARCHAR(6),
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
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 10/07/2005.01 – PTS 30101 - Chris Harshman – initial version
 * 10/17/2005.02 - PTS 30101 - David Gudat - Clean up - Converted to general TotalMail View.
 * 07/11/2006.01 - PTS 31262 - David Gudat - Calls tmail_UpdateCommodity2 - Added Tare Weight.
 *
 **/
 
 SET NOCOUNT ON 
 
DECLARE
  @v_error_msg      VARCHAR(200),
  @v_fgt_number     INT,
  @v_cmd_code       VARCHAR(6),
  @v_fgt_weight     FLOAT,
  @v_fgt_weightunit VARCHAR(6),
  @v_fgt_count      DECIMAL(10,2),
  @v_fgt_countunit  VARCHAR(6),
  @v_fgt_volume     FLOAT,
  @v_fgt_volumeunit VARCHAR(6),
  @v_fgt_length     FLOAT,
  @v_fgt_lengthunit VARCHAR(6),
  @v_fgt_height     FLOAT,
  @v_fgt_heightunit VARCHAR(6),
  @v_fgt_width      FLOAT,
  @v_fgt_widthunit  VARCHAR(6),
  @v_fgt_quantity   FLOAT,
  @v_Flags 			INT

EXEC tmail_UpdateCommodity2 @p_fgt_number, 
							@p_cmd_code, 
							@p_fgt_weight, 
							@p_fgt_weightunit, 
							@p_fgt_count, 
							@p_fgt_countunit, 
							@p_fgt_volume, 
							@p_fgt_volumeunit, 
							@p_fgt_length, 
							@p_fgt_lengthunit, 
							@p_fgt_height, 
							@p_fgt_heightunit, 
							@p_fgt_width, 
							@p_fgt_widthunit, 
							@p_fgt_quantity, 
							@p_Flags,
							NULL, --tare
							NULL --tare unit

GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateCommodity] TO [public]
GO
