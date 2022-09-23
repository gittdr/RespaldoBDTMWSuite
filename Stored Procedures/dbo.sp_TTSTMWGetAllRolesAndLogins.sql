SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE             Procedure [dbo].[sp_TTSTMWGetAllRolesAndLogins]

--sp_helprotect 'vTTSTMW_CarrierProfile'
--exec sp_TTSTMWGetRolesAndLoginsForObject 'vTTSTMW_InvoiceInformation'

As


select name as RoleOrLogin,Case When status = 0 Then 'Group/Role' Else 'User/Login' End as Type
from   sysusers 
where  name Not Like 'db_%'
order by name












GO
