SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_statemiles_sp]	@p_ord_number char(12)

AS

/**
 * 
 * NAME:
 * completion_statemiles_sp
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
 * PARAMETERS: @p_ord_number	order number used to retrieve statemiles
 *
 * REVISION HISTORY:
 * 6/29/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 *
 **/

SELECT	ord_number,
	state_code,
	state_start_odometer,
	state_end_odometer
FROM 	completion_statemiles
WHERE	ord_number = @p_ord_number

GO
GRANT EXECUTE ON  [dbo].[completion_statemiles_sp] TO [public]
GO
