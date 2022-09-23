SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[core_pickListDelete]
    @label_labeldefinition varchar(20)
AS
DELETE FROM [labelfile] 
WHERE
    labeldefinition = @label_labeldefinition


GO
GRANT EXECUTE ON  [dbo].[core_pickListDelete] TO [public]
GO
