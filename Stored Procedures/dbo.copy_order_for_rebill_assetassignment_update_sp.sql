SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[copy_order_for_rebill_assetassignment_update_sp]
        @p_ord_hdrnumber 	int

AS

/**
 * 
 * NAME:
 * copy_order_for_rebill_assetassignment_update_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Sets the assetassignment status of the order passed to this proc to PPD
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:
 * @p_ord_hdrnumber	int
 *
 * REVISION HISTORY:
 * 5/11/2007.01 ? PTS37490 - Dan Hudec ? Created Procedure
 *
 **/

DECLARE	@v_mov_number int

SELECT	@v_mov_number = mov_number
FROM	orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

IF not exists (select * from assetassignment where pyd_status = 'PPD' and mov_number = @v_mov_number)
 BEGIN
	UPDATE	assetassignment  
	SET		pyd_status = 'PPD'  
	FROM	assetassignment a
	WHERE	a.mov_number =  @v_mov_number
 END

GO
GRANT EXECUTE ON  [dbo].[copy_order_for_rebill_assetassignment_update_sp] TO [public]
GO
