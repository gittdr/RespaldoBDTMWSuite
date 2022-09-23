SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Order_Status_Dispatch_sp]
		(@p_mov_number	int) 
AS

/**
 * 
 * NAME:
 * Order_Status_Dispatch_sp
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
 * 10/12/2005.01 ? PTS30121 - Jon Fallon ? Created Procedure
 *
 **/

	DECLARE @err int
	
	BEGIN TRAN   
	
	SELECT @err = 0
	
	WHILE ((	SELECT COUNT(*)   
			FROM	STOPS  
            WHERE	mov_number = @p_mov_number AND  
					stp_lgh_status <> 'DSP') > 0) and (@err = 0) BEGIN  
	
		UPDATE stops  
        SET skip_trigger = 1,   
			stp_lgh_status = 'DSP'   
		WHERE mov_number = @p_mov_number AND  
				stp_number = (SELECT MIN(stp_number)   
								FROM   stops  
								WHERE  mov_number = @p_mov_number AND  
										stp_lgh_status <> 'DSP')  
		SELECT @err = @@Error
	END  
	
	UPDATE orderheader
	SET ord_status = 'DSP'
	WHERE mov_number = @p_mov_number
	SELECT @err = @@Error

	IF @err = 0 BEGIN
		UPDATE legheader SET lgh_outstatus = 'DSP' WHERE mov_number = @p_mov_number
		SELECT @err = @@Error
	END
	
	IF @err = 0 BEGIN
		exec update_assetassignment @p_mov_number
		SELECT @err = @@Error
	END
	--IF @err = 0 BEGIN
	--	exec update_move_light @p_mov_number
	--	SELECT @err = @@Error
	--END
	
	IF @err = 0 BEGIN
		COMMIT TRAN
		RETURN 0
	END
	ELSE BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
GO
GRANT EXECUTE ON  [dbo].[Order_Status_Dispatch_sp] TO [public]
GO
