SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ini_update_xref_group_sp]
(
    @group_id int,
    @userid varchar(20)
)

as

/************************************************************************************
 NAME:        ini_update_xref_group_sp
 DOS NAME:    tmwsp_ini_update_xref_group_sp.sql
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:   Update ini_xref_group_user table
 DEPENDANCIES:
 PROCESS:
 ---------------------------------------------------------------------------
REVISION LOG

DATE           WHO           REASON
----           ---           ------
2001-Dec-27    LLEHMANN    Initial Creation
2002-Jun-18    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
2002-Jun-18    TDRYSDALE   Modified to check if xref exists, if not, create it
2004-Jul-14    EBLACK      Always return one value: -1 if error occurred; else the group_id
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
*************************************************************************************/
begin transaction ini_update_xref_group

declare @cur_dt datetime,
        @counter int,
        @numrows int,
        @error int,
        @xref_count int,
        @group_xref_num int

--Load the variables
select @cur_dt = getdate()


--Update the table for a an existing group xref
IF @group_id <> 0
BEGIN
    /* TJD 18-Jun-2002 */
    /* Check if there is a cross-reference for the user */
    select @xref_count = count(*)
    from ini_xref_group_user
    where usr_userid = @userid

    /* if doesn't exist insert new row, else update existing row */
    if @xref_count = 0
    begin
        EXEC @group_xref_num = getsystemnumber 'INIGU', ''
        IF @group_xref_num is NULL
        BEGIN
            select 0
            return 0
        END
        INSERT INTO ini_xref_group_user
          (group_user_id,
           group_id,
           usr_userid,
           created,
           created_by,
           active)
        select @group_xref_num,
               @group_id,
               @userid,
               @cur_dt,
               user,
               'Y'
    end
  /*update what's already there */
else
    begin
        update ini_xref_group_user
        set group_id = @group_id,
            updated = @cur_dt,
            updated_by = user --TJD 18-Jun-02 Modified from @userid
        where usr_userid = @userid
    end

    select @numrows = @@rowcount, @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_xref_group
        select -1
        return -1
    END
END

--Update the table for a removed group xref
IF @group_id = 0
BEGIN
    select @group_id = group_id from ini_group where group_name = 'UNK'
    update ini_xref_group_user
    set group_id = @group_id,
        updated = @cur_dt,
        updated_by = @userid
    where usr_userid = @userid

    select @numrows = @@rowcount, @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_xref_group
        select -1
        return -1
    END
END

COMMIT TRANSACTION ini_update_xref_group
select @group_id


GO
GRANT EXECUTE ON  [dbo].[ini_update_xref_group_sp] TO [public]
GO
