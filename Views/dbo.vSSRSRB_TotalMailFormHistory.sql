SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_TotalMailFormHistory]
AS

/**
 *
 * NAME:
 * dbo.[vSSRSRB_TotalMailFormHistory]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View to display forms usage. NOTE - must be applied to the TOTALMAIL database if seperate
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_TotalMailFormHistory]

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
 * 4/22/2014 JR created view
 ***********************************************************/
 
SELECT 
(select top 1 tbltrucks.DispSysTruckID from tblTrucks where SN=m.HistTrk) as [Tractor],
(select top 1 rtrim(tbldrivers.name) + ' (' + RTRIM(tbldrivers.DispSysDriverID) + ')' from tblDrivers where sn=m.histdrv) as [Driver],
f.name [Form Name],
f.formid as  [TotalMail Form ID],
c.id as [Mobile Comm Form ID],
1 as [Messagecount],
case(select count(e.sn)
from tblErrorData e 
join tblMsgProperties p1 on e.ErrListID = p1.value and p1.propsn=6 
where p1.MsgSN = m.SN
) 
when 0 then 0
else 1
end
as [Errored],
m.subject as [Subject],
m.dtsent as [DateSent],
(Cast(Floor(Cast(m.dtsent as float))as smalldatetime)) AS [DateSentOnly],
m.[FromName] as [From Name],
(select top 1 [Description] from tblAddressTypes a 
where a.SN=m.FromType) as [From Type],
m.DeliverTo as [DeliverTo],
(select top 1 [Description] from tblAddressTypes a 
where a.SN=m.DeliverTotype) as [Deliver To Type],
s.description as [Status]

FROM tblMessages m (nolock)
join tblMsgProperties  p (nolock) on  m.SN =  p.MsgSN
join tblPropertyTypes t (nolock) on p.PropSN =  t.SN	
join  tblForms f (nolock) on p.Value = f.SN
join tblselectedmobilecomm c (nolock) on  c.formsn=f.sn
join tblmsgstatus s on m.Status=s.SN
WHERE  t.propertyname = 'Form'	
AND m.Folder = (select top 1  CONVERT(int,text) from tblrs where keyCode = 'HISTORY')


GO
GRANT SELECT ON  [dbo].[vSSRSRB_TotalMailFormHistory] TO [public]
GO
