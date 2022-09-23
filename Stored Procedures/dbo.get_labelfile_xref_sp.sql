SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[get_labelfile_xref_sp]
    @definition VARCHAR(20),
    @abbr VARCHAR(6),
    @retval VARCHAR(20) OUTPUT
AS
/************************************************************************************
 NAME:      dbo.get_labelfile_xref_sp
 TYPE:      stored procedure
 DATABASE:  TMW
 PURPOSE:   A central method for translating the labelfile abbreviations into their 
            english descriptions.
            
            @definition - tells the procedure which type of labelfile cross reference
                          to process.

            @abbr - The abbreviation in question that we want a translation for.
            
        
 RETURNS:   varchar(20) - The enligh translation of the labelfile abbreviation.


REVISION LOG

DATE          WHO             REASON
----          ---             ------
25-Oct-2007   Ryan Hing       PTS38799 - Created
*************************************************************************************/
    BEGIN
        -- Validate arguments
        IF @definition IS NULL OR ASCII(@definition) = 0 OR @definition = ''
        BEGIN
            SELECT @retval = 'NODEF'
            GOTO THEEND
        END
        
        IF @abbr IS NULL OR ASCII(@abbr) = 0 OR @abbr = ''
        BEGIN
            SELECT @retval = 'NOABBR'
            GOTO THEEND
        END
        
        -- Begin Main Processing
        SELECT @retval = name
        FROM labelfile
        WHERE labeldefinition = @definition
        AND abbr = @abbr
        
        -- End Final Processing
        THEEND:
    END



 
GO
GRANT EXECUTE ON  [dbo].[get_labelfile_xref_sp] TO [public]
GO
