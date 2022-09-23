SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.view_batch    Script Date: 6/1/99 11:54:42 AM ******/
create procedure [dbo].[view_batch]

as

Select err_batch,
	max(err_date),
	max(err_user_id)
from tts_errorlog
group by err_batch
order by err_batch desc

return



GO
GRANT EXECUTE ON  [dbo].[view_batch] TO [public]
GO
