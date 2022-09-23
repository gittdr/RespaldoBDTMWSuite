SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_PropertyRightsDelete]
			@core_PropertyRights_id as varchar(150)

AS
BEGIN

DELETE FROM [core_PropertyRights] 
		WHERE
			id = @core_PropertyRights_id 	

END
GO
GRANT EXECUTE ON  [dbo].[core_PropertyRightsDelete] TO [public]
GO
