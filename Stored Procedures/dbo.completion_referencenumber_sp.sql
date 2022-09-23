SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_referencenumber_sp]

AS

/**
 * 
 * NAME:
 * completion_referencenumber_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 6/28/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 *
 **/

SELECT 	ref_tablekey, 
	ref_type, 
	ref_number, 
	ref_typedesc, 
	ref_sequence, 
	ord_hdrnumber, 
	timestamp, 
	ref_table, 
	ref_sid, 
	ref_pickup, 
	last_updateby, 
	last_updatedate
FROM 	completion_referencenumber

GO
GRANT EXECUTE ON  [dbo].[completion_referencenumber_sp] TO [public]
GO
