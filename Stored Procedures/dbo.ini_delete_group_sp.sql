SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[ini_delete_group_sp]
(
    @group_id int,
    @userid varchar(20)
)

as

/************************************************************************************
 NAME:		ini_delete_group_sp
 DOS NAME:	tmwsp_ini_delete_group_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Delete group information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_delete_group_sp 25, 'LLEHMANN'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Dec-27-2001   LLEHMANN    Initial Creation
Jun-17-2002   TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public

*************************************************************************************/
begin transaction ini_delete_xref_group

declare @cur_dt datetime,
        @counter int,
        @numrows int,
        @error int,
        @group_id_unk int

--Load the variables
select @cur_dt = getdate()

--Update the ini_xref_group_user table for a removed group
select @group_id_unk = group_id 
from ini_group 
where group_name = 'UNK'

update ini_xref_group_user
set group_id = @group_id_unk,
    updated = @cur_dt,
    updated_by = @userid
where group_id = @group_id

select @numrows = @@rowcount, @error = @@error

IF @error != 0
BEGIN
    ROLLBACK TRANSACTION ini_delete_xref_group
    select    @error
    return 1
END

delete ini_xref_group_user
where group_id = @group_id

select @numrows = @@rowcount, @error = @@error

IF @error != 0
BEGIN
    ROLLBACK TRANSACTION ini_delete_xref_group
    select    @error
    return 1
END

commit transaction ini_delete_xref_group

begin transaction ini_delete_xref_group2

delete ini_group
where group_id = @group_id

select @numrows = @@rowcount, @error = @@error

IF @error != 0
BEGIN
    ROLLBACK TRANSACTION ini_delete_xref_group
    select    @error
    return 1
END
commit transaction ini_delete_xref_group2
GO
GRANT EXECUTE ON  [dbo].[ini_delete_group_sp] TO [public]
GO
