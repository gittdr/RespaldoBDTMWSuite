SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_delete_all_settings_sp]
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
 NAME:		ini_delete_all_settings_sp
 DOS NAME:	tmwsp_ini_delete_all_settings_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   insert information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_delete_all_settings_sp 33, 655, 3820, 4, 320, 630, 'test', 'ini_section', 'LLEHMANN', 'LLEHMANN', 'Y', 'INSERT'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-02-2002    LLEHMANN    Initial Creation
Jun-17-2002    TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

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
    --DELETE INI_VALUES
    delete ini_values
    from ini_values 
         inner join ini_xref_file_section_item i 
                on ini_values.file_section_item_id = i.file_section_item_id
         inner join ini_xref_file_section f
                on f.file_section_id=i.file_section_id
        where 
            f.file_id = @file_id and
            f.section_id = @section_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select @error
        return 1
    END

    --DELETE ROWS FROM INI_XREF_FILE_SECTION_ITEM
    delete ini_xref_file_section_item
    from ini_xref_file_section_item 
       inner join  ini_xref_file_section fs
          on ini_xref_file_section_item.file_section_id = fs.file_section_id
    where 
        fs.file_id = @file_id and
        fs.section_id = @section_id    

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select    @error
        return 1
    END

    --DELETE ROWS FROM INI_XREF_FILE_SECTION
    delete ini_xref_file_section
    where section_id = @section_id
    and file_id = @file_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select    @error
        return 1
    END

    --CHECK AND SEE IF ANY ROWS EXIST FOR THIS SECTION
    select @numrows = count(*)
    from ini_xref_file_section 
    where section_id = @section_id
    and file_id = @file_id

    IF @numrows = 0
    BEGIN 
        --DELETE ROWS FROM INI_SECTION
        delete ini_section where section_id = @section_id

        select @error = @@error

        IF @error != 0
        BEGIN
            ROLLBACK TRANSACTION ini_delete_table_settings
            select    @error
            return 1
        END
    END
END


--**************************
--*****  ITEM TABLE    *****
--**************************
If UPPER(@table_name) = 'INI_ITEM'
Begin
    delete ini_values
          from ini_values 
            inner join ini_xref_file_section_item i on
                ini_values.file_section_item_id=i.file_section_item_id
            inner join ini_xref_file_section fs 
                on fs.file_section_id=i.file_section_id
          where 
          fs.file_id = @file_id
          and i.item_id = @item_id
          and fs.section_id = @section_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select  @error
        return 1
    END

    --DELETE ROWS FROM INI_XREF_FILE_SECTION_ITEM
      delete ini_xref_file_section_item 
      from ini_xref_file_section_item i
            inner join ini_xref_file_section fs 
                on fs.file_section_id=i.file_section_id
          where 
          fs.file_id = @file_id
          and i.item_id = @item_id
          and fs.section_id = @section_id

    select @error = @@error

    IF @error != 0
    BEGIN
        ROLLBACK TRANSACTION ini_delete_table_settings
        select    @error
        return 1
    END

    --CHECK AND SEE IF ANY ROWS EXIST FOR THIS ITEM
    select @numrows = count(*)
    from ini_xref_file_section_item 
    where item_id = @item_id
  

    IF @numrows = 0
    BEGIN 
        --DELETE ROWS FROM INI_ITEM
        delete ini_item where item_id = @item_id

        select @error = @@error

        IF @error != 0
        BEGIN
            ROLLBACK TRANSACTION ini_delete_table_settings
            select    @error
            return 1
        END
    END
END


--**************************
--***** VALUES  TABLE  *****
--**************************
If UPPER(@table_name) = 'INI_VALUES'
Begin

--Delete any values for this user in the values table
delete ini_values
       from ini_values v
            inner join ini_xref_file_section_item i
                on v.file_section_item_id = i.file_section_item_id
            inner join ini_xref_file_section f 
                on f.file_section_id=i.file_section_id
            
       where 
       i.item_id = @item_id
       and f.file_id = @file_id
       and f.section_id = @section_id

       select @error = @@error
       IF @error <>0
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
GRANT EXECUTE ON  [dbo].[ini_delete_all_settings_sp] TO [public]
GO
