SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[load_label_stlmntselect_tpy_sp] @name varchar(20)  as 

select name,abbr,code,label_extrastring1
from labelfile
where labeldefinition = @name
and isnull(retired,'N') = 'N'
and label_extrastring2 = 'TPY'

GO
GRANT EXECUTE ON  [dbo].[load_label_stlmntselect_tpy_sp] TO [public]
GO
