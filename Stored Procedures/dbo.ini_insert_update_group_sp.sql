SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_insert_update_group_sp]
(
    @group_id int,
    @group_name varchar(255),
    @active varchar(1),
    @userid varchar(20)
)

as

/************************************************************************************
 NAME:		ini_insert_update_group_sp
 DOS NAME:	tmwsp_ini_insert_update_group_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Update ini_group table
 DEPENDANCIES:
 PROCESS:
 exec ini_insert_update_group_sp 7352, '396U', 'Y', 'LLEHMANN'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
2001-Dec-27    LLEHMANN    Initial Creation
2002-Jun-18    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
2004-Jul-14    EBLACK      Always return a single value - -1 if error; else 1
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/
begin transaction ini_update_group

declare @cur_dt datetime,
        @counter int,
        @numrows int,
        @error int

--Load the variables
select @cur_dt = getdate()


--Update the table for a an existing group
update ini_group
set group_name = @group_name,
    active = @active,
    updated = @cur_dt,
    updated_by = @userid
where group_id = @group_id

select @numrows = @@rowcount, @error = @@error

IF @error != 0
BEGIN
    ROLLBACK TRANSACTION ini_update_group
    select -1
    return
END

IF @numrows = 0
BEGIN
    --Update the table for a new group
    Insert into ini_group
    (group_id,
    group_name,
    created,
    created_by,
    updated,
    updated_by,
    active)
    values (@group_id,
    @group_name,
    @cur_dt,
    @userid,
    '',
    '',
    @active)

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_group
        select -1
        return
    END
END
COMMIT TRANSACTION ini_update_group
select 1

GO
GRANT EXECUTE ON  [dbo].[ini_insert_update_group_sp] TO [public]
GO
