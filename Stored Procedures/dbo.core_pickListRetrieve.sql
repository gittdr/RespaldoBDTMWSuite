SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_pickListRetrieve]
    @label_labeldefinition varchar(20)
AS
SELECT 
    labeldefinition AS label_labeldefinition,
    name AS label_name,
    abbr AS label_abbr,
    code AS label_code,
    userlabelname AS label_userlabelname,
    retired AS label_retired
FROM [labelfile]
WHERE
    labeldefinition = @label_labeldefinition 
ORDER BY
	code

GO
GRANT EXECUTE ON  [dbo].[core_pickListRetrieve] TO [public]
GO
