SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_login_alias_logging_sp]
                 @usr_userid varchar(100),
                 @usr_alias varchar(100)

AS

/*---------------------------------------------------------------------------------
    NAME:       tmw_login_alias_logging_sp.sql
    DOS NAME:
    TYPE:       stored procedure
    SYSTEM:     TMW
    PURPOSE:    Records an audit of an login alias event
    
EXECUTION and INPUTS:


EXEC  tmw_login_alias_logging_sp 'KDECELLE','MYALIAS'
select * from alias_logging
----------------------------------------------------------------------------------*/

--PTS38839
insert into alias_logging 
(
    al_usr_userid,
    al_usr_userid_alias,
    al_logdatetime,
    al_spid,
    al_rdbms_login_user,
    al_rdbms_db_user
)
values 
(
    @usr_userid,
    @usr_alias,
    getdate(),
    @@spid,
    system_user,
    suser_sname()
)
--END PTS38839
return  @@error
GO
GRANT EXECUTE ON  [dbo].[tmw_login_alias_logging_sp] TO [public]
GO
