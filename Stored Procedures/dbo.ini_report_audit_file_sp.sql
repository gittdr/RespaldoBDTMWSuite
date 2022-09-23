SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_report_audit_file_sp]
(
    @file_id int,
    @section_id int,
    @item_id int,
    @userid varchar(20),
    @from_date varchar(18),
    @to_date varchar(18),
    @search_by varchar(20)
)

as

/************************************************************************************
 NAME:		ini_report_audit_file_sp
 DOS NAME:	tmwsp_ini_report_audit_file_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Audit Report information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_report_audit_file_sp 33, 665, 0, 'LLEHMANN', 'Jan 12 2000', 'Jan 16 2002', 'user'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-16-2002    LLEHMANN    Initial Creation
Jun-18-2002    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select  a.audit_created,
        a.audit_createdby,
        a.audit_user_id,
        a.audit_file,
        a.audit_section,
        a.audit_item,
        a.audit_oldvalue,
        a.audit_newvalue,
        a.audit_description  
from ini_audit a
     inner join ini_file b
        on a.audit_file = b.file_name
where 
b.file_id = @file_id
and a.audit_created between convert(datetime,@from_date) and convert(datetime,@to_date)

order by audit_created


GO
GRANT EXECUTE ON  [dbo].[ini_report_audit_file_sp] TO [public]
GO
