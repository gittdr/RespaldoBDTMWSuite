SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_TMWMenusecurity]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_TMWMenusecurity]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * List of TMW Suite menus and  Users
 *
**************************************************************************

Sample call
select * 
from vSSRSRB_TMWMenusecurity
ORDER BY [Module Name],[Menu Name],[Menu Text],[Access ID]

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
 * 5/5/2014 JR Created view
 ************************************************************************/
select   
  ml.mnu_moduleid as [Module ID],
  m.modulename as [Module Name],
  ml.mnu_name as [Menu Name],
  ml.mnu_itemid as [Item ID],
  replace(ml.mnu_itemtext, '&', '') as [Menu Text],
  ISNULL(tts.mnu_userid,'') as [Access ID],
  case when isnull(tts.mnu_accesslevel,0) = 10 then 1 else 0 end as [Menu Access Level]
from ttsmenulist ml
   join ttsmodules m on ml.mnu_moduleid = m.moduleid
   left join ttsmenusecurity tts on tts.mnu_name = ml.mnu_name and tts.mnu_itemid = ml.mnu_itemid 




GO
GRANT SELECT ON  [dbo].[vSSRSRB_TMWMenusecurity] TO [public]
GO
