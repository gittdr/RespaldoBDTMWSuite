SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_get_items_sp]
(
        @userid char(20),
        @file_id    int,
        @section_id int
)
as

/************************************************************************************
 NAME:		ini_get_items_sp
 DOS NAME:	tmwsp_ini_get_items_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve information for the order
 DEPENDANCIES:
 PROCESS:
 exec ini_get_items_sp 'LLEHMANN', 33, 320
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-28-2001   LLEHMANN    Initial Creation
Jun-17-2002   TDrysdale   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select distinct m.item_name, 
                m.item_id, 
                v.value_setting,
                v.value_id 
from ini_section s
     inner join ini_xref_file_section f
        on s.section_id = f.section_id
     inner join ini_xref_file_section_item i
        on f.file_section_id = i.file_section_id
     inner join ini_values v
        on i.file_section_item_id=v.file_section_item_id
     inner join ini_item m
        on i.item_id = m.item_id
where 
v.usr_userid = @userid
and f.file_id = @file_id
and f.section_id = @section_id

GO
GRANT EXECUTE ON  [dbo].[ini_get_items_sp] TO [public]
GO
