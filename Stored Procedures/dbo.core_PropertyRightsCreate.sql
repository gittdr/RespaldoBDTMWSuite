SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_PropertyRightsCreate]
		    @core_PropertyRights_id as varchar(150),
			@core_PropertyRights_objt_objectid as varchar(50),
			@core_PropertyRights_objt_propertyname as varchar(50),
			@core_PropertyRights_grp_groupid as varchar(50),
			@core_PropertyRights_writebln as tinyint ,
			@core_PropertyRights_readbln as tinyint 

AS

SET NOCOUNT ON
INSERT INTO [core_PropertyRights] (
id,
			objt_objectid,
			objt_propertyname,
			grp_groupid,
			writebln,
			readbln
		)
	VALUES (
	@core_PropertyRights_id,
			@core_PropertyRights_objt_objectid,	
			@core_PropertyRights_objt_propertyname,
			@core_PropertyRights_grp_groupid,
			@core_PropertyRights_writebln,
			@core_PropertyRights_readbln
)


SELECT 
	objt_objectid as core_PropertyRights_objt_objecttype,
	objt_propertyname as  core_PropertyRights_objt_objecttype,
	grp_groupid as core_PropertyRights_grp_groupid,
	id as core_PropertyRights_id,
	writebln as core_PropertyRights_writebln,
	readbln as core_PropertyRights_readbln
FROM [core_PropertyRights]
WHERE
		id = @core_PropertyRights_id

GO
GRANT EXECUTE ON  [dbo].[core_PropertyRightsCreate] TO [public]
GO
