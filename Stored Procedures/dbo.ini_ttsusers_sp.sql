SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_ttsusers_sp]

as

/************************************************************************************
 NAME:		ini_ttsusers_sp
 DOS NAME:	tmwsp_ini_ttsusers_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve user information fror the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_ttsusers_sp
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-20-2001   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select  usr_userid, 
        usr_fname,
        usr_lname
from ttsusers


GO
GRANT EXECUTE ON  [dbo].[ini_ttsusers_sp] TO [public]
GO
