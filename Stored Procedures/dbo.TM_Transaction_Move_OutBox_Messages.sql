SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_Transaction_Move_OutBox_Messages]  
   
AS   
  
/**  
 *   
 * NAME:  
 * dbo.TM_Transaction_Move_OutBox_Messages  
 *  
 * TYPE:  
 * Stored Procedure  
 *  
 * DESCRIPTION:  
 * Used for Message Balancing. Move all the Tn transaction Server outbox messages   
 *   to the T outbox for Delivery to process them  
 *  
 * RETURNS:  
 * NONE  
 *   
 * PARAMETERS:  
 * NONE  
 *   
 * Change Log:   
 * DWG 05/01/2013 PTS 61250 - Created  
 *  
 **/  
  
/*  
 Flags:  
 See TM_Transaction_Distribute_Messages  
*/  
BEGIN

    DECLARE @iTran0OutboxSN int 
    SELECT @iTran0OutboxSN = outbox from tblServer where servercode = 'T'

    UPDATE tblMessages
    SET Folder = @iTran0OutboxSN
    FROM tblserver s inner join tblMessages m on s.outbox = m.folder   
    where LEFT(s.ServerCode, 1) = 'T' and s.ServerCode <> 'T' and s.SN <> 0 
     
END  
GO
GRANT EXECUTE ON  [dbo].[TM_Transaction_Move_OutBox_Messages] TO [public]
GO
