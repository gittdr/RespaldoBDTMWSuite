SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_topup_truck_brn_sp]
(
 @p_brn	varchar(40),
 @p_number int
 )
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns all associate topup branches
TGRIFFIT 42177 06/11/2008 - always show UNKNOWN in the list..

*/

    IF @p_number = 1 
        SET ROWCOUNT 1 
    ELSE IF @p_number <= 8 
        SET ROWCOUNT 8
    ELSE IF @p_number <= 16
        SET ROWCOUNT 16
    ELSE IF @p_number <= 24
        SET ROWCOUNT 24
    ELSE
        SET ROWCOUNT 8
    
    IF EXISTS ( SELECT brn_name FROM associate_branch WHERE brn_name >= @p_brn	) 
        SELECT  brn_name , brn_id, payto_number
            FROM associate_branch 
            WHERE brn_name >= @p_brn	
                 
        UNION
        
        SELECT 'UNKNOWN','UNKNOWN', '0'
        
    ELSE 
        SELECT 'UNKNOWN','UNKNOWN', '0'
    
    SET ROWCOUNT 0 

GO
GRANT EXECUTE ON  [dbo].[d_load_topup_truck_brn_sp] TO [public]
GO
