SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollCommoditiesView] AS
SELECT
cmd_cmp_id, 
cmd_active, 
cmd_class, 
cmd_name, 
cmd_misc1, 
cmd_makeup_description, 
cmd_cust_num, 
cmd_dot_name, 
cmd_code, 
cmd_hazardous, 
cmd_taxtable1, 
cmd_taxtable2, 
cmd_taxtable3, 
cmd_taxtable4, 
cmd_code_num, 
cmd_specificgravity, 
cmd_updatedby, 
cmd_updateddate, 
cmd_createdate, 
cmd_class2
 
FROM dbo.commodity  (NOLOCK)

GO
GRANT DELETE ON  [dbo].[TMWScrollCommoditiesView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollCommoditiesView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollCommoditiesView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollCommoditiesView] TO [public]
GO
