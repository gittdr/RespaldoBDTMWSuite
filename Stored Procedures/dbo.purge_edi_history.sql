SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[purge_edi_history]
as
declare @Daysback integer
set @Daysback = 91
Delete from edi_document_tracking where (datediff(day, edt_extract_dttm, getdate()) >= @Daysback)
GO
GRANT EXECUTE ON  [dbo].[purge_edi_history] TO [public]
GO
