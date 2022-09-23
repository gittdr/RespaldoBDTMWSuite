SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 create proc [dbo].[ini_search_for_section_sp]
(
@search varchar(50)
)
as

/************************************************************************************
 NAME:		ini_search_for_section_sp
 DOS NAME:	tmwsp_ini_search_for_section_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve matching section information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_search_for_section_sp 'aCC'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Feb-26-2002   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
************************************************************************************/


select a.file_name,
       b.section_name
from ini_file a
     inner join ini_xref_file_section d
        on a.file_id = d.file_id

     inner join ini_section b
        on d.section_id = b.section_id
where 
upper(b.section_name) like '%' + upper(@search) + '%'


GO
GRANT EXECUTE ON  [dbo].[ini_search_for_section_sp] TO [public]
GO
