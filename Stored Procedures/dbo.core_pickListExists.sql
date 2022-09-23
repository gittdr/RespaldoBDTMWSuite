SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_pickListExists]
    @label_labeldefinition varchar(20)
AS
SELECT 
	Count(labeldefinition)
FROM [labelfile]
WHERE
	labeldefinition = @label_labeldefinition
GO
GRANT EXECUTE ON  [dbo].[core_pickListExists] TO [public]
GO
