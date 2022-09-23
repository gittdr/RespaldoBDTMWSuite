SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_spid_tracking_delete_sp]                

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_spid_tracking_delete_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Logs the users userid, alias and spid to a table.
EXECUTION and INPUTS:

EXEC  tmw_spid_tracking_delete_sp 


----------------------------------------------------------------------------------*/

delete from spid_tracking where spid = @@spid

return  @@error
GO
GRANT EXECUTE ON  [dbo].[tmw_spid_tracking_delete_sp] TO [public]
GO
