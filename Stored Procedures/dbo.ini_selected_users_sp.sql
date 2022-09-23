SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_selected_users_sp]
(
@group_name varchar(255)
)

as

/************************************************************************************
 NAME:		ini_selected_users_sp
 DOS NAME:	tmwsp_ini_selected_users_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve available users for a given group
 DEPENDANCIES:
 PROCESS:
 exec ini_selected_users_sp '006U'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
08/03/2001     LLEHMANN    Initial Creation
06/17/2002     TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
11/01/2007     MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select usr_fname, 
       usr_lname,
       x.usr_userid,
       i.group_id, 
       i.group_name,
       x.group_id
from ini_group i
     inner join ini_xref_group_user x
        on x.group_id = i.group_id
        
     inner join ttsusers t
        on t.usr_userid = x.usr_userid
where 
i.group_name = @group_name


GO
GRANT EXECUTE ON  [dbo].[ini_selected_users_sp] TO [public]
GO
