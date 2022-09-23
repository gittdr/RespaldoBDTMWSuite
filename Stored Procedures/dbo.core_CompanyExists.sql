SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[core_CompanyExists] (@id varchar(8)) as
	
select
	count(cmp.cmp_id)
from company cmp
where cmp_id=@id

GO
GRANT EXECUTE ON  [dbo].[core_CompanyExists] TO [public]
GO
