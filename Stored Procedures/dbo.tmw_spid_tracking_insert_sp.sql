SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_spid_tracking_insert_sp]
                 @usr_userid varchar(100),
                 @usr_alias varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_spid_tracking_insert_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Logs the users userid, alias and spid to a table.
EXECUTION and INPUTS:

--No alias
EXEC  tmw_spid_tracking_insert_sp 'KDECELLE',null

--Alias

EXEC  tmw_spid_tracking_insert_sp 'KDECELLE','BMURPHY'
select * from spid_tracking
----------------------------------------------------------------------------------*/

declare @windowlogin varchar(100)

--remove any previous spids
exec tmw_spid_tracking_delete_sp 


select @windowlogin = usr_windows_userid from ttsusers where
usr_userid = @usr_userid

insert into spid_tracking 
(spid,
rdbms_login,
rdbms_user,
usr_userid,
usr_windows_userid,
usr_alias,
created)
values
(
  @@spid,
  suser_sname(),
  user_name(),
  @usr_userid,
  @windowlogin,
  @usr_alias,
  getdate()
)
  
return  @@error
GO
GRANT EXECUTE ON  [dbo].[tmw_spid_tracking_insert_sp] TO [public]
GO
