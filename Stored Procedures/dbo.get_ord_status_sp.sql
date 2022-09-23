SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_ord_status_sp]
    @from_idtype VARCHAR(40),
    @from_idvalue VARCHAR(40),
    @retval VARCHAR(15) OUTPUT
AS
/************************************************************************************
 NAME:      dbo.get_ord_status_sp
 TYPE:      stored procedure
 DATABASE:  TMW
 PURPOSE:   A central method for getting the order status given any key field.
            
            @from_idtype - tells the procedure which process to follow in order to 
                           retrieve the ord_status value.

            @from_idvalue - the key id value against which to match the ord_status.
            
        
 RETURNS:   varchar(15) - One of a series of codes indicating the success or error
            status of the procedure.


REVISION LOG

DATE          WHO             REASON
----          ---             ------
03-Oct-2007   Ryan Hing       Created
05-Oct-2007   Ryan Hing       Added retrieval method for ord_hdrnumber
23-Oct-2007   Ryan Hing       Added the REQUIRES and PROVIDES tags
20-Nov-2007   Ryan Hing       PTS38799 - Corrected the logic for the ord_hdrnumber lookup 
*************************************************************************************/
    DECLARE  
        @checkint INT,
        @ord_hdrnumber INT,
        @mov_number INT,
        @thiscount INT

    BEGIN
        -- Validate arguments
        SELECT @thiscount = 0
        
        IF @from_idtype IS NULL OR ASCII(@from_idtype) = 0 OR @from_idtype = ''
        BEGIN
            SELECT @retval = 'NOIDTYPE'
            GOTO THEEND
        END
        
        IF @from_idvalue IS NULL OR ASCII(@from_idvalue) = 0 OR @from_idvalue = ''
        BEGIN
            SELECT @retval = 'NOIDVAL'
            GOTO THEEND
        END
        
        
        -- Begin Main Processing
        -- In order to add different scenarios just add another If statement
        -- Begin lgh_number
        IF @from_idtype = 'lgh_number'
        BEGIN
            SELECT @checkint = CAST(@from_idvalue AS INT)
            
            SELECT @thiscount = count(*)
            FROM legheader
            WHERE lgh_number = @checkint
            
            IF @thiscount > 0 
            BEGIN
                SELECT @mov_number = mov_number
                FROM legheader
                WHERE lgh_number = @checkint
                
                SELECT @thiscount = count(*)
                FROM orderheader
                WHERE mov_number = @mov_number
                
                -- Make sure only one result is found
                IF @thiscount = 1
                BEGIN
                    SELECT @retval = ord_status
                    FROM orderheader
                    WHERE mov_number = @mov_number
                END
                
                -- The id type is not unique, yields ambiguous results
                IF @thiscount > 1
                BEGIN
                    SELECT @retval = 'AMBIGUOUS'
                    GOTO THEEND
                END
                
                -- If no results are found indicate no match
                IF @thiscount < 1
                BEGIN
                    SELECT @retval = 'NOMATCH'
                    GOTO THEEND
                END
            END
            
            -- If no records returned indicate no match
            IF @thiscount = 0
            BEGIN
                SELECT @retval = 'NOMATCH'
                GOTO THEEND
            END
            
            GOTO THEEND
        END
        -- End lgh_number
        
        -- Begin ord_hdrnumber
        IF @from_idtype = 'ord_hdrnumber'
        BEGIN
            SELECT @checkint = CAST(@from_idvalue AS INT)
            
            SELECT @thiscount = count(*)
            FROM orderheader
            WHERE ord_hdrnumber = @checkint

            -- Make sure only one result is found
            IF @thiscount = 1
            BEGIN
                SELECT @retval = ord_status
                FROM orderheader
                WHERE ord_hdrnumber = @checkint
            END
            
            -- The id type is not unique, yields ambiguous results
            IF @thiscount > 1
            BEGIN
                SELECT @retval = 'AMBIGUOUS'
                GOTO THEEND
            END

            -- If no records returned indicate no match
            IF @thiscount = 0
            BEGIN
                SELECT @retval = 'NOMATCH'
                GOTO THEEND
            END
            
            GOTO THEEND
        END
        -- End ord_hdrnumber
        
        
        -- If the procedure has reached this point no valid id type was selected
        SELECT @retval = 'INVIDTYPE'


        -- End Final Processing
        THEEND:
    END



    
 
GO
GRANT EXECUTE ON  [dbo].[get_ord_status_sp] TO [public]
GO
