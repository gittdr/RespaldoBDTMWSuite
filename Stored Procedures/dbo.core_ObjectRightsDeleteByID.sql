SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsDeleteByID]
		@core_ObjectRights_id as int
			

AS
BEGIN

DELETE FROM [core_ObjectRights] 
		WHERE
			id = @core_ObjectRights_id 
END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsDeleteByID] TO [public]
GO
