SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[load_heading_sp] @name varchar(20) AS

SELECT min ( labelfile.userlabelname ) , 
min ( labelfile.labeldefinition ) 
FROM labelfile  
WHERE ( labelfile.userlabelname > '' ) AND
( labelfile.labeldefinition  = @name )

GO
GRANT EXECUTE ON  [dbo].[load_heading_sp] TO [public]
GO
