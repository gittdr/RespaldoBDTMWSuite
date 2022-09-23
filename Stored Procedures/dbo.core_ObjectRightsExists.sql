SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_ObjectRightsExists]
			@core_ObjectRights_id as int
AS
BEGIN
SELECT
		Count(*)
FROM [core_ObjectRights]
WHERE
	id = @core_ObjectRights_id		
END
GO
GRANT EXECUTE ON  [dbo].[core_ObjectRightsExists] TO [public]
GO
