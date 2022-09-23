SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_FindFgtDetail2]
    @p_stp_number VARCHAR(200),
    @p_fgt_sequence VARCHAR(6),
    @p_cmd_code VARCHAR(8),
    @p_fgt_reftype VARCHAR(6),
    @p_fgt_refnum VARCHAR(30),
    @p_flags VARCHAR(12),
	@p_SeparateFieldsOn VARCHAR(2000)

AS
/**
 * 
 * NAME:
 * dbo.tmail_FindFgtDetail
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * verifies that the stop number is specified and exists
 * only output is error rasied when one of the above conditions is not met.
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * fgt_number  The first sequenced freight detail number found by specified criteria
 *
 * PARAMETERS:
 * 001 - @p_stp_number VARCHAR(11), input, null;
 *       required for proper functionality,
 *       the stop number to find freight detail for
 * 002 - @p_fgt_sequence VARCHAR(6), input, null;
 *       optional, a specific freight detail on the stop
 * 003 - @p_cmd_code VARCHAR(8), input, null;
 *       optional, a specific commodity code on the stop
 * 004 - @p_fgt_reftype VARCHAR(6),
 *       optional, a reference type code
 * 005 - @p_fgt_refnum VARCHAR(30)
 *       optional, a specific reference number
 * 006 - @p_flags VARCHAR(12)
 *       optional, options
 * 007 - @p_SeparateFieldsOn VARCHAR(2000)
 *       optional, if flag 2 is set then a comma dilimited list of fields to separate on, if not fields are specified then the load assignment default separation fields will be used.
 * 
 * REFERENCES:
 * none
 * 
 * FLAGS:
 * 1 = if multiple rows match, return the one with the lowest sequence number
 * 2 = Find in adjacent stops
 *
 * REVISION HISTORY:
 * 10/06/2005.01 – PTS 30101 - Chris Harshman – initial version
 * 10/17/2005.02 - PTS 30101 - David Gudat - Converted to general TotalMail View.
 * 07/11/07      - PTS 38187 - David Gudat - Added SeparateOnFields parameter
 *
 **/


EXEC tmail_FindFgtDetail4 @p_stp_number,
    @p_fgt_sequence,
    @p_cmd_code,
    @p_fgt_reftype,
    @p_fgt_refnum,
    @p_flags,
	@p_SeparateFieldsOn,
	'',
	'',
	'',
	''

GO
GRANT EXECUTE ON  [dbo].[tmail_FindFgtDetail2] TO [public]
GO
