SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[load_display_sp] @name varchar(20) as 

begin
--PTS 70713 MTC removed temp table and put table variables in place to prevent recompiles.

declare @templabel table (labeldefinition varchar(20), [name] varchar(20), abbr varchar(6), code int)


insert @templabel
SELECT labeldefinition ,
name, 
abbr, 
code 
FROM labelfile 
WHERE labeldefinition = @name 

UPDATE @templabel 
SET name = '-' 
WHERE code = 0 

UPDATE @templabel
SET a.name = b.userlabelname
from @templabel a, labelfile b
where 	a.labeldefinition = b.labeldefinition and
  	a.abbr = b.abbr and
	(b.userlabelname is not null and ltrim(rtrim(userlabelname)) <> '')

SELECT name,   
abbr,   
code  
FROM @templabel 
ORDER BY code ASC

end



GO
GRANT EXECUTE ON  [dbo].[load_display_sp] TO [public]
GO
