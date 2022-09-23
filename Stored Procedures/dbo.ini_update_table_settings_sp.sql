SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_update_table_settings_sp]
(
    @value varchar(255),
    @value_id int,
    @table_name varchar(255),
    @userid varchar(20),
    @insert_type varchar(255)
)

as

/************************************************************************************
 NAME:		ini_update_table_settings_sp
 DOS NAME:	tmwsp_ini_update_table_settings_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Update information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_update_table_settings_sp 'test', 1264740, 'ini_section', 'LLEHMANN', ''
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-02-2002    LLEHMANN    Initial Creation
Jun-18-2002    TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/
IF @insert_type = 'UPDATE'
BEGIN
begin transaction ini_update_table_settings

declare @cur_dt datetime,
        @numrows int,
        @error int

--Load the variables
select @cur_dt = getdate()

--check to see which table we are updateing
If UPPER(@table_name) = 'INI_VALUES'
Begin
    update ini_values
    set value_setting = @value,
        updated = @cur_dt,
        updated_by = @userid
    where value_id = @value_id
    select @numrows = @@rowcount, @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_table_settings
        select    'Error Updating ini_values table - ABORTING'
        select    @error
        return 1
    END
END

If UPPER(@table_name) = 'INI_SECTION'
Begin
    update ini_section
    set section_name = @value,
        updated = @cur_dt,
        updated_by = @userid
    where section_id = @value_id
    select @numrows = @@rowcount, @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_table_settings
        select    'Error Updating ini_section table - ABORTING'
        select    @error
        return 1
    END
END

If UPPER(@table_name) = 'INI_ITEM'
Begin
    update ini_item
    set item_name = @value,
        updated = @cur_dt,
        updated_by = @userid
    where item_id = @value_id
    select @numrows = @@rowcount, @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_update_table_settings
        select    'Error Updating ini_item table - ABORTING'
        select    @error
        return 1
    END
END
END
commit transaction ini_update_table_settings
return 0


GO
GRANT EXECUTE ON  [dbo].[ini_update_table_settings_sp] TO [public]
GO
