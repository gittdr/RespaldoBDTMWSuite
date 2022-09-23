SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO






Create Procedure [dbo].[DriverAwareSuite_GetExpirationPriorityStatuses]

as

Select  IsNull(Abbr,'') as Abbr, 
	IsNull(name,'') as Name 
from    labelfile (NOLOCK) 
where   labeldefinition='ExpPriority' 
        --and 
        --retired<>'Y' 
order by Abbr






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetExpirationPriorityStatuses] TO [public]
GO
