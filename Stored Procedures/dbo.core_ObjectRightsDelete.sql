SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsDelete]
		@core_ObjectRights_id as int,
			@core_ObjectRights_objt_objectid as varchar(20),
			@core_ObjectRights_objt_propertyname as varchar(20),
			@core_ObjectRights_grp_groupid as varchar(20)

AS
BEGIN

DELETE FROM [core_ObjectRights] 
		WHERE
			objt_objectid = @core_ObjectRights_objt_objectid AND	
			objt_propertyname = @core_ObjectRights_objt_propertyname AND
			grp_groupid = @core_ObjectRights_grp_groupid		

END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsDelete] TO [public]
GO
