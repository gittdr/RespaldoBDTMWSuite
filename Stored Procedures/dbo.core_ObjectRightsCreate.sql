SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsCreate]
		    @core_ObjectRights_id as int,
			@core_ObjectRights_objt_objectid as varchar(20),
			@core_ObjectRights_objt_propertyname as varchar(20),
			@core_ObjectRights_grp_groupid as varchar(20)

AS

SET NOCOUNT ON
INSERT INTO [core_ObjectRights] (
			objt_objectid,
			objt_propertyname,
			grp_groupid
		)
	VALUES (
			@core_ObjectRights_objt_objectid,	
			@core_ObjectRights_objt_propertyname,
			@core_ObjectRights_grp_groupid		
)


SELECT 
	objt_objectid as core_ObjectRights_objt_objectid,
	objt_propertyname as  core_ObjectRights_objt_propertyname,
	grp_groupid as core_ObjectRights_grp_groupid,
	id as core_ObjectRights_id
FROM [core_ObjectRights]
WHERE
		id = SCOPE_IDENTITY()

GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsCreate] TO [public]
GO
