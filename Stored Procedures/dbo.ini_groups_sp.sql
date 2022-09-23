SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_groups_sp]

as

/************************************************************************************
 NAME:		ini_groups_sp
 DOS NAME:	tmwsp_ini_groups_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve group information fror the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_groups_sp
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-21-2001   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select group_id,
       group_name,
       created,
       created_by,
       updated,
       updated_by,
       active
from ini_group


GO
GRANT EXECUTE ON  [dbo].[ini_groups_sp] TO [public]
GO
