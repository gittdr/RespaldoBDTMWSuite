SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_item_comments_sp]
(
    @file_id int,
    @section_id int,
    @item_id int
)

as

/************************************************************************************
 NAME:		ini_get_item_comments_sp
 DOS NAME:	tmwsp_ini_get_item_comments_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Update Item comments for the INI_APPLICATION
 DEPENDANCIES:
 PROCESS:
 exec ini_get_item_comments_sp 4, 88, 623
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
2002-Jan-15    LLEHMANN    Initial Creation
2002-Jun-17    TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/

select a.file_section_item_id,
       a.file_section_id,
       a.item_id,
       a.created, 
       a.created_by,
       a.updated, 
       a.updated_by,
       a.active,
       a.comment
from ini_xref_file_section_item a
     inner join ini_xref_file_section b
        on a.file_section_id = b.file_section_id
where 
b.file_id = @file_id
and b.section_id = @section_id
and a.item_id = @item_id


GO
GRANT EXECUTE ON  [dbo].[ini_get_item_comments_sp] TO [public]
GO
