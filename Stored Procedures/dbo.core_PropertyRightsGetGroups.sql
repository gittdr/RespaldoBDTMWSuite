SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_PropertyRightsGetGroups]
	-- Add the parameters for the stored procedure here
					@core_PropertyRights_object_id as varchar(50),
					@core_PropertyRights_group_id as varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	SELECT 
	 id as core_PropertyRights_id,
  	 objt_objectid as core_PropertyRights_objt_objectid,
	 objt_propertyname as core_PropertyRights_objt_propertyname,
	 grp_groupid as core_PropertyRights_grp_groupid,
	 writebln as core_PropertyRights_writebln,
     readbln as core_PropertyRights_readbln
	FROM [core_PropertyRights]
	WHERE
		objt_objectid  = @core_PropertyRights_object_id AND grp_groupid = @core_PropertyRights_group_id
END
GO
GRANT EXECUTE ON  [dbo].[core_PropertyRightsGetGroups] TO [public]
GO
