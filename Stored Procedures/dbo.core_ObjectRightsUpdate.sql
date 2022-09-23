SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsUpdate]
			@core_ObjectRights_id as int,
			@core_ObjectRights_objt_objectid as varchar(20),
			@core_ObjectRights_objt_propertyname as varchar(20),
			@core_ObjectRights_grp_groupid as varchar(20)

AS
BEGIN

UPDATE [core_ObjectRights] 
SET
			objt_objectid = @core_ObjectRights_objt_objectid,
			objt_propertyname = @core_ObjectRights_objt_propertyname,
			grp_groupid = @core_ObjectRights_grp_groupid
	WHERE 
			id = @core_ObjectRights_id
END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsUpdate] TO [public]
GO
