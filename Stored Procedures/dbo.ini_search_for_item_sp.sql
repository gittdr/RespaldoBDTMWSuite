SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_search_for_item_sp]
(
@search varchar(50)
)
as

/************************************************************************************
 NAME:		ini_search_for_item_sp
 DOS NAME:	tmwsp_ini_search_for_item_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:       Retrieve matching item information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_search_for_item_sp 'acC'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Feb-26-2002   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select f.file_name, 
       s.section_name,
       c. item_name
from 
     ini_item c    
     inner join ini_xref_file_section_item e 
        on e.item_id = c.item_id
     inner join ini_xref_file_section d
        on d.file_section_id = e.file_section_id
     inner join ini_section  s
        on s.section_id = d.section_id
     inner join ini_file f 
        on f.file_id = d.file_id
        
where 
upper(c.item_name) like '%' + upper(@search) + '%'




GO
GRANT EXECUTE ON  [dbo].[ini_search_for_item_sp] TO [public]
GO
