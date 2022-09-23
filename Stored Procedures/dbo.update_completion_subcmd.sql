SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_completion_subcmd]	
@p_pickup_fgt_number	int,
@p_drop_fgt_number 	int,
@p_action		char(1)

AS

/**
 * 
 * NAME:
 * update_completion_subcmd
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
 * PARAMETERS: 	@p_pickup_fgt_number	int	Pickup Freight Number
 * 		@p_drop_fgt_number 	int	Drop Freight Number
 *		@p_action		char(1)	Insert (I) or Delete (D)
 * REVISION HISTORY:
 * 7/27/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 *
 **/

If @p_action = 'I'
 BEGIN
	INSERT INTO completion_subfgt (subfgt_pickup_number, subfgt_drop_number)
	VALUES (@p_pickup_fgt_number, @p_drop_fgt_number)
 END

If @p_action = 'D'
 BEGIN
	DELETE FROM completion_subfgt
	 WHERE subfgt_pickup_number = @p_pickup_fgt_number and
	       subfgt_drop_number = @p_drop_fgt_number
 END

GO
GRANT EXECUTE ON  [dbo].[update_completion_subcmd] TO [public]
GO
