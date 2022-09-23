SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_file_sp]

as

/************************************************************************************
 NAME:		ini_file_sp
 DOS NAME:	tmwsp_ini_file_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve file information fror the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_file_sp
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-21-2001   LLEHMANN    Initial Creation
Jun-17-2002   TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select file_id,
       file_name
from ini_file


GO
GRANT EXECUTE ON  [dbo].[ini_file_sp] TO [public]
GO
