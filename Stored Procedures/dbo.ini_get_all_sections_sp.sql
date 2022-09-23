SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_all_sections_sp]
as

/************************************************************************************
 NAME:		ini_get_all_sections_sp
 DOS NAME:	tmwsp_ini_get_all_sections_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve section information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_get_all_sections_sp
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-02-2002   LLEHMANN    Initial Creation
Jun-17-2002   TDrysdale   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select distinct s.section_name, 
                s.section_id
from ini_section s


GO
GRANT EXECUTE ON  [dbo].[ini_get_all_sections_sp] TO [public]
GO
