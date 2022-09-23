SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_TMWModulesandUsers]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_TMWusersandModules]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * List of TMW Suite Modules and  Users
 *
**************************************************************************

Sample call

select * from vSSRSRB_TMWModulesandUsers
ORDER BY [TMW Module],[TMW User ID]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 4/29/2014 JR Created view
 ************************************************************************/

select 
ISNULL(mod.modulename,'') as [TMW Module],
usr.usr_userid as [TMW User ID],
ISNULL(usr.usr_windows_userid,'') as [Windows ID],
RTRIM(ISNULL(usr.usr_lname,'')) as [Last Name],
RTRIM(ISNULL(usr.usr_mname,'')) as [Middle Name],
RTRIM(ISNULL(usr.usr_fname,'')) as [First Name],
ISNULL(usr.usr_mail_address,'') as [Email Address],
ISNULL(usr.usr_contact_number,'') as [Contact Number],
ISNULL(usr.usr_contact_fax,'') as [Fax],
case usr.usr_sysadmin
when 'Y' then 'Yes'
else 'No'
END
 as [System Admin],
case usr.usr_supervisor
when 'Y' then 'Yes'
else 'No'
END
 as [Supervisor],
usr.usr_type1 [Type 1],
usr.usr_type2 [Type 2],
usr.usr_thirdparty [Third Party],
usr.usr_lgh_type1 as [Leg Type1],
case usr.usr_candeletepay
when 'Y' then 'Yes'
else 'No'
END
as [Can Delete Pay],
usr.usr_booking_terminal as [Booking Terminal],
case usr.usr_printinvoices 
when 'Y' then 'Yes'
else 'No'
END
as [Print Invoices]


from 
ttsmodules mod
left outer join ttsmappings map on map.moduleid = mod.moduleid
left outer join ttsusers usr on map.userid = usr.usr_userid

GO
GRANT SELECT ON  [dbo].[vSSRSRB_TMWModulesandUsers] TO [public]
GO
