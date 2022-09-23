SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_section_comments_sp]
(
    @file_id int,
    @section_id int
)

as

/************************************************************************************
 NAME:		ini_get_section_comments_sp
 DOS NAME:	tmwsp_ini_get_section_comments_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Get Section comments for the INI_APPLICATION
 DEPENDANCIES:
 PROCESS:
 exec ini_get_section_comments_sp 4, 88
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
2002-Jan-15    LLEHMANN    Initial Creation
2002-Jun-17    TDrysdale   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/


select file_section_id,
       file_id,
       section_id,
       created,
       created_by,
       updated,
       updated_by,
       active,
       comment
from ini_xref_file_section
where file_id = @file_id
and section_id = @section_id


GO
GRANT EXECUTE ON  [dbo].[ini_get_section_comments_sp] TO [public]
GO
