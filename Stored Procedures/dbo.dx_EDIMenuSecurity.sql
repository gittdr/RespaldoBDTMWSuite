SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIMenuSecurity](@frm_name varchar(60))
as

/*******************************************************************************************************************  
  Object Description:
  dx_EDIMenuSecurity

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

declare @access table (dx_command varchar(255), dx_accesslevel int)
insert @access (dx_command, dx_accesslevel)
select mnu_itemid, 0 from ttsmenulist
 where mnu_moduleid = '204' and mnu_name = @frm_name

declare @tmwuser varchar(20), @sysadmin char(1)
--exec gettmwuser @tmwuser OUTPUT	AR 07.01.09
exec dx_gettmwuser @tmwuser OUTPUT

select @sysadmin = usr_sysadmin from ttsusers where usr_userid = @tmwuser
if isnull(@sysadmin,'N') <> 'Y'
begin
	update @access
	   set dx_accesslevel = (select min(mnu_accesslevel)
				  from ttsmenusecurity
				 where dx_command = mnu_itemid
				   and mnu_name = @frm_name
				   and mnu_useridtype = 'B'
				   and mnu_userid in (select grp_id from ttsgroupasgn where usr_userid = @tmwuser))
	  from ttsmenusecurity
	 where dx_command = mnu_itemid
	   and mnu_name = @frm_name
	   and mnu_useridtype = 'B'
	   and mnu_userid in (select grp_id from ttsgroupasgn where usr_userid = @tmwuser)

	update @access
	   set dx_accesslevel = (select min(mnu_accesslevel)
				  from ttsmenusecurity
				 where dx_command = mnu_itemid
				   and mnu_name = @frm_name
				   and mnu_useridtype = 'A'
				   and mnu_userid = @tmwuser)
	  from ttsmenusecurity
	 where dx_command = mnu_itemid
	   and mnu_name = @frm_name
	   and mnu_useridtype = 'A'
	   and mnu_userid = @tmwuser
end

select * from @access

select isnull(gi_string1,'') as 'PwdMatch', isnull(gi_string2,'') as 'PwdAdd'
  from generalinfo
 where gi_name = rtrim(left(@frm_name,21)) + 'Passwords'

GO
GRANT EXECUTE ON  [dbo].[dx_EDIMenuSecurity] TO [public]
GO
