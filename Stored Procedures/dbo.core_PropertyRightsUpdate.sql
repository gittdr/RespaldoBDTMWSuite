SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_PropertyRightsUpdate]
			    @core_PropertyRights_id as varchar(150),
				@core_PropertyRights_objt_objecttype as varchar(50),
				@core_PropertyRights_objt_propertyname as varchar(50),
				@core_PropertyRights_grp_groupid as varchar(50),
				@core_PropertyRights_writebln as tinyint ,
				@core_PropertyRights_readbln as tinyint 

AS
BEGIN

UPDATE [core_PropertyRights] 
SET

			objt_objectid = @core_PropertyRights_objt_objecttype,
			objt_propertyname = @core_PropertyRights_objt_propertyname,
			grp_groupid = @core_PropertyRights_grp_groupid,
			writebln = @core_PropertyRights_writebln,
			readbln = @core_PropertyRights_readbln
	WHERE 
			id = @core_PropertyRights_id
END
GO
GRANT EXECUTE ON  [dbo].[core_PropertyRightsUpdate] TO [public]
GO
