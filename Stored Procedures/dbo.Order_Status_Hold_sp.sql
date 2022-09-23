SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Order_Status_Hold_sp]
		(@p_mov_number	int) 
AS

/**
 * 
 * NAME:
 * Order_Status_Hold_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *
 * RETURNS: 
 *
 * RESULT SETS: 
 *
 * PARAMETERS:
 * @p_mov_number	int		Mov number
 *
 *
 * REVISION HISTORY:
 * PTS 46118 JJF 20090717
 *
 **/

	DECLARE @err int
	
	BEGIN TRAN   
	
	UPDATE orderheader
	SET ord_status = 'HLD'
	WHERE mov_number = @p_mov_number

	SELECT @err = @@Error
	
	IF @err = 0 BEGIN
		EXEC update_move @p_mov_number
		SELECT @err = @@Error
	END
	
	IF @err = 0 BEGIN
		COMMIT TRAN
		RETURN 0
	END
	ELSE BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
GO
GRANT EXECUTE ON  [dbo].[Order_Status_Hold_sp] TO [public]
GO
