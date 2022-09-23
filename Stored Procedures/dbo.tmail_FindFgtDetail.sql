SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_FindFgtDetail]
    @p_stp_number VARCHAR(12),
    @p_fgt_sequence VARCHAR(6),
    @p_cmd_code VARCHAR(8),
    @p_fgt_reftype VARCHAR(6),
    @p_fgt_refnum VARCHAR(30),
    @p_flags VARCHAR(12)

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
 * 
 * REFERENCES:
 * none
 * 
 * FLAGS:
 * 1 = if multiple rows match, return the one with the lowest sequence number
 *
 * REVISION HISTORY:
 * 10/06/2005.01 – PTS 30101 - Chris Harshman – initial version
 * 10/17/2005.02 - PTS 30101 - David Gudat - Converted to general TotalMail View.
 * 07/11/07      - PTS 38187 - David Gudat - Added SeparateOnFields paramter, created tmail_FindFgtDetail2
 *
 **/


EXEC tmail_FindFgtDetail2
    @p_stp_number ,
    @p_fgt_sequence,
    @p_cmd_code ,
    @p_fgt_reftype ,
    @p_fgt_refnum,
    @p_flags,
	''

GO
GRANT EXECUTE ON  [dbo].[tmail_FindFgtDetail] TO [public]
GO
