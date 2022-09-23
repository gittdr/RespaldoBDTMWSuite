SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetLabelFromType] (@type char(8), @abbr varchar(6))  
-- if no abbr is supplied, return all names and abbrs for the given type
-- if abbr is supplied then return the specific name for that abbr and type
AS
SET NOCOUNT ON

if @abbr = '' or @abbr = NULL
	select name, abbr from labelfile where labeldefinition = @type 	order by name
else
	select name from labelfile where labeldefinition = @type and abbr = @abbr
GO
GRANT EXECUTE ON  [dbo].[estatGetLabelFromType] TO [public]
GO
