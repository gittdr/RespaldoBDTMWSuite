SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- PTS 69754 - DJM - Added the Terminal value from the Hold Definition
-- PTS 75732 - DZW - This view is used to match updates of OrderHoldDefinitions that come in through EDI. It uses the hld_startdate
--                   and the orderholdparms present to find the original OrderHoldDefinition to update or terminate.

create view [dbo].[OrderHoldDefinitionView] AS  
select ohd.hld_id,   
hld_startdate,  
hld_enddate,  
hld_authorization,  
hld_cbcode,  
hld_type,  
hld_terminal,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'VIN' order by ohp.hld_id) as VIN,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'O' order by ohp.hld_id) as Origin,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'D' order by ohp.hld_id) as Destination,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'MAKE' order by ohp.hld_id) as Make,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'MODEL' order by ohp.hld_id) as Model,
(select top 1 hparm_value from orderholdparms ohp (nolock) where ohp.hld_id = ohd.hld_id and hparm_type = 'YEAR' order by ohp.hld_id) as [Year],
hld_effective_comment,
hld_terminate_comment  
from orderholddefinition ohd (nolock) 
  
GO
GRANT DELETE ON  [dbo].[OrderHoldDefinitionView] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderHoldDefinitionView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderHoldDefinitionView] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderHoldDefinitionView] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderHoldDefinitionView] TO [public]
GO
