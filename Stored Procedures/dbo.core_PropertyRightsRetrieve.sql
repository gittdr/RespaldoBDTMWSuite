SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
CREATE PROCEDURE [dbo].[core_PropertyRightsRetrieve]
			@core_PropertyRights_id as varchar(150)
AS
BEGIN
SET NOCOUNT ON

SELECT 
	 id as  core_PropertyRights_id,
  	 objt_objectid as  core_PropertyRights_objt_objectid,
	 objt_propertyname as  core_PropertyRights_objt_propertyname,
	 grp_groupid as  core_PropertyRights_grp_groupid,
	 writebln as  core_PropertyRights_writebln,
     readbln as  core_PropertyRights_readbln
FROM [core_PropertyRights] 
WHERE 
	id= @core_PropertyRights_id
END
GO
GRANT EXECUTE ON  [dbo].[core_PropertyRightsRetrieve] TO [public]
GO
