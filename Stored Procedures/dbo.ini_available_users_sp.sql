SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[ini_available_users_sp]

as

/************************************************************************************
 NAME:		ini_available_users_sp
 DOS NAME:	tmwsp_ini_available_users_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve available users for a given group
 DEPENDANCIES:
 PROCESS:
 exec ini_available_users_sp
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
08/03/2001     LLEHMANN    Initial Creation
06/17/2002     TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
11/01/2007     MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/

select usr_fname, 
       usr_lname, 
       usr_userid
from  ttsusers 



GO
GRANT EXECUTE ON  [dbo].[ini_available_users_sp] TO [public]
GO
