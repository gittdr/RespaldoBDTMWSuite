SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_group_by_user_sp]
(
    @userid varchar(50)
)
as

/************************************************************************************
 NAME:		ini_get_group_by_user_sp
 DOS NAME:	tmwsp_ini_get_group_by_user_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve group information fror the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_get_group_by_user_sp 'LLEHMANN'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-21-2001   LLEHMANN    Initial Creation
Jun-17-2002   TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select group_name 
from   ini_group a
       inner join ini_xref_group_user b
        on a.group_id = b.group_id
       inner join ttsusers c
        on b.usr_userid = c.usr_userid
where 
c.usr_userid = @userid


GO
GRANT EXECUTE ON  [dbo].[ini_get_group_by_user_sp] TO [public]
GO
