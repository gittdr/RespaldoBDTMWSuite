SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_tts_errorlog_errors]
(
@batch_num int
)

AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This stored proc will provide errorlog error information.
It can be used wherever it is necessary to provide tts_errorlog information for an individual err_batch #. 

*/
    SET NOCOUNT ON
    
    DECLARE @placeholder varchar(50)
    
    SET @placeholder = SPACE(50)
    
    BEGIN
    
        SELECT err_batch,
            err_user_id,
            err_message,
            err_date,
            err_number,
            err_title,
            err_response,
            err_sequence,
            err_icon,
            err_item_number,
            err_type,
            @placeholder AS err_placeholder
        FROM tts_errorlog
        WHERE err_batch = @batch_num
        
    END
GO
GRANT EXECUTE ON  [dbo].[d_get_tts_errorlog_errors] TO [public]
GO
