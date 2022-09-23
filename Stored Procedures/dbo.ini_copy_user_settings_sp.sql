SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_copy_user_settings_sp]
(
    @userid varchar(20),
    @userid2 varchar(20),
    @userid_created_by varchar(20)
)

as

/************************************************************************************
 NAME:		ini_copy_user_settings_sp
 DOS NAME:	tmwsp_ini_copy_user_settings_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   copy information from 1 user to selected users for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Feb-19-2002    LLEHMANN    Initial Creation
Jun-17-2002    TDRYSDALE   Grant permissions to tt_db_tmw_update_role instead of Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
public

exec ini_copy_user_settings_sp 'CWOODS', 'LLEHMANN', 'DCOLLIER'
*************************************************************************************/

declare @numrows int,
        @error int,
        @value_id int,
        @created datetime,
        @item_id int,
        @min int,
        @max int,
        @value_setting varchar(255),
        @updated datetime,
        @updated_by varchar(20),
        @file_section_item_id int,
        @active char(1)


select @created = getdate()

--LOAD TEMP TABLE
--select ini_values.value_id, ini_values.value_setting, ini_values.file_section_item_id, ini_values.usr_userid, ini_values.created, ini_values.created_by, ini_values.updated, ini_values.updated_by, ini_values.active
select ini_values.value_id,
       ini_values.value_setting, 
       ini_values.file_section_item_id, 
       ini_values.usr_userid, 
       ini_values.created, 
       ini_values.created_by, 
       ini_values.updated, 
       ini_values.updated_by, 
       ini_values.active
into #hold_settings
from ini_values
where usr_userid = @userid2

--**************************
--***** VALUES  TABLE  *****
--**************************

begin transaction ini_copy_user_table_settings

--Delete any values for this user in the values table
delete ini_values 
where usr_userid = @userid

select @error = @@error
   IF @error < 0
        BEGIN
            ROLLBACK TRANSACTION ini_copy_user_table_settings
            drop table #hold_settings
            select    @error
            return 1
        END
   IF @error > 1
        BEGIN
            ROLLBACK TRANSACTION ini_copy_user_table_settings
            drop table #hold_settings
            select    @error
            return 1
        END

--SET LOOPING VARIABLES
select @min =  min(value_id) 
from #hold_settings

select @max =  max(value_id) 
from #hold_settings

--LOOP THRU TEMP TABLE
WHILE @min <= @max
BEGIN
    EXECUTE @value_id = getsystemnumber 'INIV', ''

    --LOAD THE VARIABLES
    select @value_setting = value_setting,
           @file_section_item_id = file_section_item_id,
           @updated = updated,
           @updated_by = updated_by,
           @active = active
    from #hold_settings
    where value_id = @min

    --INSERT VARIABLES INTO INI_VALUES
    INSERT INTO ini_values
                (value_id, 
                value_setting, 
                file_section_item_id, 
                usr_userid, 
                created, 
                created_by, 
                updated, 
                updated_by, 
                active)
          VALUES(@value_id, 
                @value_setting, 
                @file_section_item_id, 
                @userid, 
                @created, 
                @userid_created_by, 
                @updated, 
                @updated_by, 
                @active)

    select @error = @@error
    IF @error != 0
        BEGIN
            ROLLBACK TRANSACTION ini_copy_user_table_settings
            drop table #hold_settings
            select    @error
            return 1
        END

     --GET NEXT ROW
    select @min =  min(value_id) from #hold_settings
    where value_id > @min
END

COMMIT TRANSACTION ini_copy_user_table_settings

return @error


GO
GRANT EXECUTE ON  [dbo].[ini_copy_user_settings_sp] TO [public]
GO
