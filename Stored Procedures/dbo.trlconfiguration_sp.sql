SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[trlconfiguration_sp]   
AS  
/*   MODIFICATION LOG  
DPETE 22082-23301 created 7/7/4  
  
*/  
Select   
cfg_identity  
--6/24/4 DSK change puts these on the load template table  
--,cfg_trc_type   
--,cfg_trl_type   
--,cfg_pup_type   
,cfg_trlconfiguration   
,cfg_mt_type_loaded   
,cfg_mt_type_empty  
From trlconfiguration  
  
  
  
GO
GRANT EXECUTE ON  [dbo].[trlconfiguration_sp] TO [public]
GO
