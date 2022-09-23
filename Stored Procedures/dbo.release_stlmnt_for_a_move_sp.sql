SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[release_stlmnt_for_a_move_sp]
(
    @mov_number int
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    DECLARE @rtn int
 
    UPDATE paydetail
    SET pyd_status = 'PND'
    WHERE mov_number = @mov_number
    AND pyd_status = 'HLD'
    
       
    IF @@error <> 0 
        SELECT @rtn = -1
    ELSE
        SELECT @rtn = 0
        
    return @rtn

GO
GRANT EXECUTE ON  [dbo].[release_stlmnt_for_a_move_sp] TO [public]
GO
