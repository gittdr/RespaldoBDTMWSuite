SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE      Procedure [dbo].[sp_TTSTMWGetPermissionsForMRSysObjects] (@tmwobject as varchar(8000))

--sp_helprotect 'vTTSTMW_CarrierProfile'
--exec sp_TTSTMWGetRolesAndLoginsForObject 'vTTSTMW_CarrierProfile'

As

Create Table #TMWObjectPermissions
	(
	Owner varchar(255),
	Object varchar(255),
	Grantee varchar(255),
	Grantor varchar(255),
	ProtectType varchar(255),
	ActionType varchar(255),
	Cols varchar(255)
	)

Insert into #TMWObjectPermissions
Exec sp_helprotect @tmwobject


select ProtectType,ActionType,Grantee as LoginOrRole
from   #TMWObjectPermissions
order by grantee,protecttype


 






GO
