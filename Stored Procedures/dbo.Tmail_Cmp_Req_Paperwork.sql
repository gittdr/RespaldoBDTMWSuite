SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Proc [dbo].[Tmail_Cmp_Req_Paperwork]
			@cmp_id varchar(36)

as

IF ISNULL(@cmp_id, '') = ''
	BEGIN
	RAISERROR('Tmail_Cmp_Req_Paperwork: Company ID not specified.', 16, 1)
	RETURN
	END

Create table #TmpBilldoc
		(	doctype varchar(10),
			docname varchar(30),
			cmp_id varchar(8))
	
Insert into #TmpBilldoc
SELECT  bdt_doctype,
		'',
		cmp_id
		 

FROM billdoctypes 
			WHERE	cmp_id = @cmp_id 
			and bdt_inv_required = 'Y'

Update #TmpBilldoc
Set docname = name 
from labelfile, #TmpBilldoc
 where abbr = #TmpBilldoc.doctype  and labeldefinition = 'Paperwork'

Select docname


From #TmpBilldoc

drop table #TmpBilldoc





GO
GRANT EXECUTE ON  [dbo].[Tmail_Cmp_Req_Paperwork] TO [public]
GO
