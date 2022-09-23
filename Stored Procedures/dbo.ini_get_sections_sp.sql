SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_sections_sp]
(
@userid char(20),
@file_id int
)
as

/************************************************************************************
 NAME:		ini_get_sections_sp
 DOS NAME:	tmwsp_ini_get_sections_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve section information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_get_sections_sp 'LLEHMANN', 33
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-28-2001   LLEHMANN    Initial Creation
Jun-17-2002   TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select distinct s.section_name,
                s.section_id
from ini_section s
     inner join ini_xref_file_section f
        on f.section_id = s.section_id
     inner join ini_xref_file_section_item i
        on i.file_section_id = f.file_section_id
     inner join ini_values v
        on v.file_section_item_id = i.file_section_item_id
     inner join ini_file x
        on f.file_id = x.file_id
where 
x.file_id = @file_id
and v.usr_userid = @userid


GO
GRANT EXECUTE ON  [dbo].[ini_get_sections_sp] TO [public]
GO
