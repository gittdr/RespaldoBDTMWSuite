SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 create proc [dbo].[ini_report_compare_2_users_sp]
(
@user1 varchar(20), @user2 varchar(20)
)
as

/************************************************************************************
 NAME:		ini_report_compare_2_users_sp
 DOS NAME:	tmwsp_ini_report_compare_2_users_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve item information for the ini_user_maintenance app
 DEPENDANCIES:
 PROCESS:
 exec ini_report_compare_2_users_sp 'LLEHMANN', 'KDECELLE'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-14-2002   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
11/01/2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/


select ini_values.value_id,
       ini_values.value_setting,
       ini_values.file_section_item_id,
       ini_values.usr_userid,
       ini_values.created,
       ini_values.created_by,
       ini_values.updated,
       ini_values.updated_by,
       ini_values.active 
into #user_settings 
from ini_values 
where usr_userid = @user1

--extra first
select
    'User 2 has...' as atype,
    @user2,
    'User 1 does not...' as btype,
    @user1,
    a.usr_userid,
    e.file_name,
    f.section_name,
    c.item_name,
    a.value_setting
from
    ini_values a
    inner join ini_xref_file_section_item b
        on a.file_section_item_id = b.file_section_item_id
    inner join ini_item c 
        on c.item_id = b.item_id
    inner join ini_xref_file_section d
        on d.file_section_id = b.file_section_id
    inner join ini_file e
        on e.file_id = d.file_id
    inner join ini_section f 
        on f.section_id = d.section_id
        
where a.usr_userid = @user2
AND not exists 
    (select 'x' 
    from #user_settings us
        inner join  ini_values a 
            on        
              us.file_section_item_id=a.file_section_item_id)

union

select
    'Same setting... different value' as atype,
    @user1,
    'Same setting... different value' as btype,
    @user2,
    a.usr_userid,
    e.file_name,
    f.section_name,
    c.item_name,
    a.value_setting
from
    ini_values a
    inner join ini_xref_file_section_item b 
        on a.file_section_item_id = b.file_section_item_id
    inner join  ini_item c
        on b.item_id = c.item_id
    inner join ini_xref_file_section d 
        on d.file_section_id = b.file_section_id
    inner join ini_file e
        on d.file_id = e.file_id
    inner join ini_section f
        on f.section_id = d.section_id
where a.usr_userid = @user2
AND exists 
    (select 'x' 
     from #user_settings us
        inner join ini_values a 
            on
        us.file_section_item_id=a.file_section_item_id 
     where us.value_setting<>a.value_setting)

union

select
    'User 1 has...' as atype,
    @user1,
    'User 2 does not...' as btype,
    @user2,
    a.usr_userid,
    e.file_name,
    f.section_name,
    c.item_name,
    a.value_setting
from
    #user_settings a
    inner join ini_xref_file_section_item b
        on a.file_section_item_id = b.file_section_item_id
    inner join ini_item c 
        on c.item_id = b.item_id
    inner join ini_xref_file_section d
        on d.file_section_id = b.file_section_id
    inner join ini_file e
        on e.file_id = d.file_id
    inner join ini_section f 
        on f.section_id = d.section_id
where 
not exists 
    (select 'x' 
     from ini_values us
        inner join #user_settings a
            on  us.file_section_item_id=a.file_section_item_id
     where us.usr_userid= @user2
      )

order by atype

drop table #user_settings




GO
GRANT EXECUTE ON  [dbo].[ini_report_compare_2_users_sp] TO [public]
GO
