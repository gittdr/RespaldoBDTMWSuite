SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsGetAllGroups]
	-- Add the parameters for the stored procedure here
					@object_id as varchar(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	SELECT 
		objt_objectid as core_ObjectRights_objt_objectid, 
		objt_propertyname as core_ObjectRights_objt_propertyname,
		 grp_groupid as core_ObjectRights_grp_groupid,
		  id as core_ObjectRights_id
	FROM [core_ObjectRights]
	
END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsGetAllGroups] TO [public]
GO
