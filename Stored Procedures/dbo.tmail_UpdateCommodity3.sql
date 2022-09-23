SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateCommodity3]
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
	@p_fgt_volume2unit VARCHAR(6)

AS
/**
 * 
 * NAME:
 * dbo.tmail_UpdateCommodity3
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
 *
 **/
	
	EXEC tmail_UpdateCommodity4  @p_fgt_number,
    @p_cmd_code,
    @p_fgt_weight, --FLOAT,
    @p_fgt_weightunit,
    @p_fgt_count, --DECIMAL(10,2),
    @p_fgt_countunit,
    @p_fgt_volume, --FLOAT,
    @p_fgt_volumeunit,
    @p_fgt_length, --FLOAT,
    @p_fgt_lengthunit,
    @p_fgt_height, --FLOAT,
    @p_fgt_heightunit,
    @p_fgt_width, --FLOAT,
    @p_fgt_widthunit,
    @p_fgt_quantity, --FLOAT,
    @p_Flags,
    @p_fgt_tare, --FLOAT,
    @p_fgt_tareunit,
	@p_fgt_volume2, --FLOAT
	@p_fgt_volume2unit,
	''
 
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateCommodity3] TO [public]
GO
