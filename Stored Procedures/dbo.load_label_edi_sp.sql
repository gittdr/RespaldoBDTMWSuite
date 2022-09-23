SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[load_label_edi_sp] @name varchar(20)  as 

SELECT name, 
abbr, 
code,
edicode
FROM labelfile 
WHERE 	labeldefinition = @name and
	IsNull(retired,'N') <> 'Y' 	

GO
GRANT EXECUTE ON  [dbo].[load_label_edi_sp] TO [public]
GO
