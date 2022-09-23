SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_security_proc_sp]
                 @rolename varchar(100),
                 @pword varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_security_proc_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Stub procedure for future security integration
    
EXECUTION and INPUTS:


EXEC  tmw_security_proc_sp 'ROLE','PASSWORD'

----------------------------------------------------------------------------------*/


--IMPORTANT - DO NOT RETURN A RESULT SET.  POWERBUILDER IS NOT
--EXPECTING A RESULT SET AND DOES NOT HAVE A 'CLOSE' STATEMENT.  
--RETURN A RESULT SET WILL CAUSE ERRORS IN THE APPLICATION.
return 1
GO
GRANT EXECUTE ON  [dbo].[tmw_security_proc_sp] TO [public]
GO
