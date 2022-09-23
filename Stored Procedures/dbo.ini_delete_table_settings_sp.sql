SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[ini_delete_table_settings_sp]
(
    @value_id int,
    @xref_file_section_item_id int,
    @xref_file_section_id int,
    @file_id int,
    @section_id int,
    @item_id int,
    @value varchar(255),
    @table_name varchar(255),
    @userid varchar(20),
    @userid_created_by varchar(20),
    @active varchar(1),
    @insert_type varchar(255)
)

as

/************************************************************************************
 NAME:		ini_delete_table_settings_sp
 DOS NAME:	tmwsp_ini_delete_table_settings_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   delete information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
  exec ini_delete_table_settings_sp 33, 655, 3820, 4, 320, 630, 'test', 'ini_section', 'LLEHMANN', 'LLEHMANN', 'Y', 'INSERT'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-02-2002    LLEHMANN    Initial Creation
Jun-17-2002    TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public

*************************************************************************************/

begin transaction ini_delete_table_settings

declare @numrows int,
        @error int


--check to see which table we are updateing
--**************************
--***** SECTION TABLE  *****
--**************************
If UPPER(@table_name) = 'INI_SECTION'
Begin
    delete ini_values
    from ini_values v
        inner join ini_xref_file_section_item xfsi
            on v.file_section_item_id = xfsi.file_section_item_id
        inner join ini_xref_file_section  xfs
            on xfsi.file_section_id = xfs.file_section_id
    where xfs.file_id = @file_id
        and xfs.section_id = @section_id
        and v.usr_userid=@userid

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select    @error
        return 1
    END
END


--**************************
--*****  ITEM TABLE    *****
--**************************
If UPPER(@table_name) = 'INI_ITEM' or upper(@table_name)='INI_VALUES'
Begin
    delete ini_values
    from ini_values v
        inner join ini_xref_file_section_item xfsi
            on v.file_section_item_id = xfsi.file_section_item_id
        inner join ini_xref_file_section  xfs
            on xfsi.file_section_id = xfs.file_section_id
    where xfs.file_id = @file_id
        and xfs.section_id = @section_id
        and xfsi.item_id = @item_id
        and v.usr_userid = @userid

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select    @error
        return 1
    END
END




commit transaction ini_delete_table_settings
SELECT @error
RETURN 0
GO
GRANT EXECUTE ON  [dbo].[ini_delete_table_settings_sp] TO [public]
GO
