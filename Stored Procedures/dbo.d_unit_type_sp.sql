SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_unit_type_sp] (@unit 	varchar(6))
AS

	select labeldefinition
	from labelfile 
	where abbr = @unit
	and labeldefinition like '%Units'

GO
GRANT EXECUTE ON  [dbo].[d_unit_type_sp] TO [public]
GO
