SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_master_refnumber_sp]
    @process_type varchar(30),
    @branch varchar(10),
    @ord_hdrnumber int,
    @master_refnumber varchar(15),
    @retval varchar(15) OUTPUT
    
AS

/************************************************************************************
 NAME:      process_master_refnumber_sp
 TYPE:      stored procedure
 DATABASE:  TMW
 PURPOSE:   Processes the retrieval and storage of Master Order reference number
            records.
            
            Valid process types are:
            'store' - Actually stores the information by either UPDATING the existing
                      master order or INSERTING a new master order reference number
                      record.
            
            'validate_store' - Only validates that the master order reference number 
                      is valid. Performs NO OPERATIONS.
            
            'retrieve' - Simply gets the Master Order reference number for a given
                      ord_hdrnumber and branch
        
        
 RETURNS:   varchar(15) - One of a series of codes indicating the success or error
            status of the procedure.


REVISION LOG

DATE          WHO             REASON
----          ---             ------
20-Sep-2007   Ryan Hing       PTS# 38781/38782 - Created
15-Nov-2007   Ryan Hing       PTS# 38781/38782 - Moved the order number check after 
                              the validate only return statement so that the pre-save
                              check won't error out for new orders (which won't have 
                              order numbers yet at the time of this execution)
                              Also removed extraneous database object checking and
                              added the REQUIRES/PROVIDES tags.
                             
*************************************************************************************/

   DECLARE  
    @check int, 
    @this_ordhdrnumber int
   
   BEGIN
        --------------- VALIDATE ARGUMENTS ---------------
        IF @process_type is null or @process_type = '' OR ASCII(@process_type) = 0
        BEGIN
            SELECT @retval = 'NOPROC' -- No action specified
            GOTO THEEND
        END
        
        IF @branch IS NULL or @branch = '' OR ASCII(@branch) = 0
        BEGIN
            SELECT @branch = 'UNK' -- Default to 'UNK' branch
        END
        
        --------------- BEGIN MAIN PROCESSING ---------------
        IF @process_type = 'store' OR @process_type = 'validate_store'
        BEGIN
            -- The empty strgin from powerbuilder still translates to a "NUL"
            -- ascii character, which is not '' or null in MS SQL Server.
            -- We must use the ASCII function to determine if it is in fact this
            -- ascii nul value instead of checking for ''.
            IF @master_refnumber IS NULL OR @master_refnumber = '' OR ASCII(@master_refnumber) = 0
            BEGIN
                SELECT @retval = 'NOREF' -- Cannot have blank reference number
                GOTO THEEND
            END
            
            -- Does the the Master Reference Number exists for the branch?
            SELECT @check = count(*)
            FROM masterorders_ref
            WHERE ord_revtype1  = @branch
            AND   master_refnumber = @master_refnumber
            
            -- No...
            IF @check = 0
            BEGIN
                -- Is this for VALIDATION only?
                IF @process_type = 'validate_store'
                BEGIN
                    -- Validate only take no action.
                    SELECT @retval = 'SUCCESS'
                    GOTO THEEND
                END

                --If no order number is provided check to see if
                IF @ord_hdrnumber <= 0 
                BEGIN
                    SELECT @retval = 'INVORDNUM' -- Invalid order number
                    GOTO THEEND
                END
                
                -- Check is the Order exists in orderheader; if this procedure is being
                -- called to STORE data to the masterorders_ref table the order MUST EXIST
                -- in the orderheader table first.
                SELECT @check = count(*)
                FROM orderheader
                WHERE ord_hdrnumber = @ord_hdrnumber
                
                IF @check = 0
                BEGIN
                    SELECT @retval = 'NOORDER' -- The order does not exist in orderheader
                    GOTO THEEND
                END

            -- Does the ord_hdrnumber exist for this branch?
                SELECT @check = count(*)
                FROM masterorders_ref
                WHERE   ord_revtype1 = @branch
                AND     ord_hdrnumber = @ord_hdrnumber

                -- No: INSERT
                IF @check = 0
                BEGIN
                    INSERT INTO masterorders_ref
                    (
                    ord_hdrnumber,
                        master_refnumber,
                        ord_revtype1
                    )
                    VALUES
                    (
                        @ord_hdrnumber,
                        @master_refnumber,
                        @branch
                    )
                    
                    SELECT @retval = 'SUCCESS'
                    GOTO THEEND
                END
                
                -- Yes: UPDATE
                IF @check > 0
                BEGIN
                    UPDATE masterorders_ref
                    SET master_refnumber = @master_refnumber
                    WHERE ord_hdrnumber = @ord_hdrnumber
                    AND   ord_revtype1 = @branch
                    
                    SELECT @retval = 'SUCCESS'
                    GOTO THEEND
                END

                SELECT @retval = 'NOOP'
                GOTO THEEND
            END
            
            -- Yes...
            IF @check > 0
            BEGIN
                SELECT @this_ordhdrnumber = ord_hdrnumber
                FROM masterorders_ref
                WHERE ord_hdrnumber = @ord_hdrnumber
                AND   ord_revtype1 = @branch
                AND   master_refnumber = @master_refnumber
                
                -- It exists but it is exactly the same (ie: No Change)
                IF @this_ordhdrnumber = @ord_hdrnumber
                BEGIN
                    SELECT @retval = 'SUCCESS'
                    GOTO THEEND
                END
                
                SELECT @retval = 'EXISTS'
                GOTO THEEND
            END
        END
        
        IF @process_type = 'retrieve'
        BEGIN
            IF @ord_hdrnumber <= 0 
            BEGIN
                SELECT @retval = 'INVORDNUM' -- Invalid order number
                GOTO THEEND
            END
            
            -- Retrieve the master order
            SELECT @retval = master_refnumber
            FROM masterorders_ref
            WHERE ord_revtype1 = @branch
            AND   ord_hdrnumber = @ord_hdrnumber
            
            IF @retval IS NULL
            BEGIN
                SELECT @retval = 'NOREFNUM'
                GOTO THEEND
            END
            
            GOTO THEEND
        END
        
        IF @process_type = 'ordernum'
        BEGIN
            IF @master_refnumber IS NULL OR @master_refnumber = ''
            BEGIN
                SELECT @retval = 'INVREFNUM' -- Invalid order number
                GOTO THEEND
            END
            
            -- Retrieve the master order
            SELECT @this_ordhdrnumber = 0
            
            SELECT @this_ordhdrnumber = ord_hdrnumber
            FROM masterorders_ref
            WHERE ord_revtype1 = @branch
            AND   master_refnumber = @master_refnumber
            
            IF @this_ordhdrnumber <= 0
            BEGIN
                SELECT @retval = 'NOORDNUM'
                GOTO THEEND
            END
            
            SELECT @retval = CAST(@this_ordhdrnumber AS varchar(15))
            GOTO THEEND
        END
        
        IF @process_type = 'remove' OR @process_type = 'validate_remove'
        BEGIN
            IF @ord_hdrnumber <= 0 
            BEGIN
                SELECT @retval = 'INVORDNUM' -- Invalid order number
                GOTO THEEND
            END
            
            -- Is this for VALIDATION only?
            IF @process_type = 'validate_remove'
            BEGIN
                -- Validate only take no action.
                SELECT @retval = 'SUCCESS'
               GOTO THEEND
            END
            
            -- Delete the Master Order reference record
            DELETE FROM masterorders_ref
            WHERE ord_hdrnumber = @ord_hdrnumber
            AND   ord_revtype1 = @branch
            
            -- Perform a check to see if the Master Order reference still exists
            SELECT @check = count(*)
            FROM masterorders_ref
            WHERE ord_revtype1 = @branch
            AND   ord_hdrnumber = @ord_hdrnumber
            
            IF @check > 0
            BEGIN
                SELECT @retval = 'DELFAIL'
                GOTO THEEND
            END
            
            -- Return successful delete op
            SELECT @retval = 'SUCCESS'
            GOTO THEEND
        END
        
        
        -- If the procedure has reached this point no valid process was selected
        SELECT @retval = 'INVPROC'
        
        
        
        --------------- FINAL PROCESSING ---------------
        THEEND:
        --Nothing to do for final processing
  
    END


 
GO
GRANT EXECUTE ON  [dbo].[process_master_refnumber_sp] TO [public]
GO
