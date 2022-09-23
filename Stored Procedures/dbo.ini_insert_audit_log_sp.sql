SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  create proc [dbo].[ini_insert_audit_log_sp] (
    @usr varchar(50),
    @file varchar(255),
    @section  varchar(255),
    @item varchar(255),
    @description varchar(255)
    )

as

/************************************************************************************
 NAME:		      ini_insert_audit_log_sp
 DOS NAME:	tmwsp_ini_insert_audit_log_sp.sql 
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Insert data into ini_insert_audit_log_sp table
 DEPENDANCIES:
 PROCESS:
 ---------------------------------------------------------------------------
REVISION LOG

DATE	  WHO		    REASON
----	  ---		    ------
06/17/02  DCOLLIER      Initial Creation

EXEC ini_insert_audit_log_sp 'dcollier', 'TTS50.INI', 'MILEAGEINTERFACE', 'MILEAGESERVER', 'DEFAULT VALUE bLAH USED'
11/01/2007 MROIK        PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/
declare
@log_id int,
@ld_datetime datetime,
@ll_count int

select @ld_datetime = getdate()
select @description = 'DEFAULT VALUE ' + @description + ' USED'

INSERT ini_audit (
        audit_created,
        audit_createdby,
        audit_user_id,
        audit_file,
        audit_section,
        audit_item,
        audit_oldvalue,
        audit_newvalue,
        audit_description)
VALUES (
        @ld_datetime,
        @usr,
        @usr,
        @file,
        @section,
        @item,
        NULL,
        NULL,
        @description)
GO
GRANT EXECUTE ON  [dbo].[ini_insert_audit_log_sp] TO [public]
GO
