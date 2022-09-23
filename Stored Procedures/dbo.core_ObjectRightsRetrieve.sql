SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsRetrieve]
			@core_ObjectRights_id as int
AS
BEGIN
SET NOCOUNT ON


SELECT 
id as core_ObjectRights_id, 
objt_objectid as core_ObjectRights_objt_objectid,  
objt_propertyname as core_ObjectRights_objt_propertyname, 
grp_groupid as core_ObjectRights_grp_groupid
FROM [core_ObjectRights] 
WHERE 
	id= @core_ObjectRights_id
END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsRetrieve] TO [public]
GO
