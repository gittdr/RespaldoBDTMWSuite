SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 create proc [dbo].[ini_report_audit_user_sp]
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
 NAME:		ini_report_audit_user_sp
 DOS NAME:	tmwsp_ini_report_audit_user_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Audit Report information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_report_audit_user_sp 33, 665, 0, 'LLEHMANN', 'Jan 01 2000', 'Feb 16 2002', 'user'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-16-2002    LLEHMANN    Initial Creation
Jun-18-2002    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/

select audit_created,
       audit_createdby,
       audit_user_id,
       audit_file,
       audit_section,
       audit_item,
       audit_oldvalue,
       audit_newvalue,
       audit_description
from ini_audit 
where audit_user_id = @userid
and audit_created between @from_date and @to_date


order by audit_created

GO
GRANT EXECUTE ON  [dbo].[ini_report_audit_user_sp] TO [public]
GO
