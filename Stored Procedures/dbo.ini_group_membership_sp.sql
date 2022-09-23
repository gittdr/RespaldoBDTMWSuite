SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 create proc [dbo].[ini_group_membership_sp]


as

/************************************************************************************
 NAME:		ini_group_membership_sp
 DOS NAME:	tmwsp_ini_group_membership_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Retrieve Group membership reprot
 DEPENDANCIES:
 PROCESS:
 exec ini_group_membership_sp 
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
2002-Jan-15    LLEHMANN    Initial Creation
2002-Jun-18    TDRYSDALE   Modified permissions to grant access to tt_db_tmw_update_role
                           instead of public
Nov-01-2007    MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server

*************************************************************************************/

select c.group_name ,
       a.usr_userid,
       b.usr_fname,
       b.usr_lname
from ini_xref_group_user a
     inner join ttsusers b
        on a.usr_userid = b.usr_userid
     inner join ini_group c 
        on c.group_id = a.group_id


GO
GRANT EXECUTE ON  [dbo].[ini_group_membership_sp] TO [public]
GO
