SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Create view of valid branches and assignments (to be used in dataobjects)
CREATE VIEW [dbo].[V_BRANCH_ASSIGNEDTYPE]
AS
SELECT
		branch_assignedtype.bat_id,   
		branch_assignedtype.brn_id,   
		branch.brn_name,   
		branch_assignedtype.bat_type, 
		CASE branch_assignedtype.bat_type
			WHEN 'CHARGETYPE' THEN
				(SELECT cht_description FROM chargetype WHERE cht_itemcode = branch_assignedtype.bat_value)
			WHEN 'PAYTYPE' THEN
				(SELECT pyt_description FROM paytype WHERE pyt_itemcode = branch_assignedtype.bat_value)
			WHEN 'USERS' THEN
				(SELECT usr_fname + SPACE(1) + usr_lname FROM ttsusers WHERE usr_userid = branch_assignedtype.bat_value)
			ELSE 
				labelfile.name
		END bat_type_name,
		branch_assignedtype.bat_value,
		branch_assignedtype.bat_default,
		branch_assignedtype.bat_active,
		branch_assignedtype.bat_display_order,
		branch_assignedtype.bat_last_updatedby,
		branch_assignedtype.bat_last_updatedon
	FROM branch,
			branch_assignedtype LEFT OUTER JOIN labelfile 
			ON branch_assignedtype.bat_type = labelfile.labeldefinition 
			AND branch_assignedtype.bat_value = labelfile.abbr
			
 WHERE ( branch_assignedtype.brn_id = branch.brn_id ) and  
       ( branch_assignedtype.bat_active is NULL OR branch_assignedtype.bat_active = 'Y' ) and
       ( branch.brn_retired is null or branch.brn_retired = 0 )
GO
GRANT SELECT ON  [dbo].[V_BRANCH_ASSIGNEDTYPE] TO [public]
GO
