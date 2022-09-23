SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_recorrepaperwork] 
as

declare @tractor varchar(20)

declare paperwork_cursor CURSOR FOR

select distinct
tractor = (select lgh_tractor from legheader where legheader.lgh_number = paperwork.lgh_number)
from paperwork 
where datediff(dd,pw_dt, getdate()) = 0  
and pw_received = 'Y'
and (select lgh_tractor from legheader where legheader.lgh_number = paperwork.lgh_number) <> 'UNKNOWN'

OPEN paperwork_cursor

FETCH next from paperwork_cursor
into @tractor

WHILE @@FETCH_STATUS = 0  
BEGIN 
  
  exec sp_enviaevliberadas @tractor

  FETCH NEXT FROM paperwork_cursor   
  INTO @tractor

END
CLOSE paperwork_cursor
DEALLOCATE paperwork_cursor;




GO
