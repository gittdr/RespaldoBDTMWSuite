SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EquipmentReadOnlyView] 
AS

SELECT 
	trl_id AS ID, 
	trl_type1 AS Type1, 
	trl_type2 AS Type2, 
	trl_type3 AS Type3, 
	trl_type4 AS Type4, 
	trl_company AS Company,
	trl_fleet AS Fleet,
	trl_branch AS Branch,
	trl_status AS [Status] ,
	trl_retiredate as RetireDate,
	trl_equipmenttype as EquipmentType
FROM trailerprofile

UNION

SELECT
	trc_number AS ID, 
	trc_type1 AS Type1, 
	trc_type2 AS Type2, 
	trc_type3 AS Type3, 
	trc_type4 AS Type4, 
	trc_company AS Company,
	trc_fleet AS Fleet,
	trc_branch AS Branch,
	trc_status AS [Status] ,
	trc_retiredate as RetireDate,
	CASE trc_require_drvtrl WHEN '4' THEN 'STRAIGHT TRUCK' WHEN '5' THEN 'STRAIGHT TRUCK' ELSE 'TRACTOR' END AS EquipmentType	
FROM tractorprofile
GO
GRANT SELECT ON  [dbo].[EquipmentReadOnlyView] TO [public]
GO
