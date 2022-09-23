SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[sp_tts_systemlink_errorordlog]
as
insert into tts_syslink_errlogords
select substring([message],29,6) ,[message], getdate() from TMWSystemWideLogging where  message  like '%System.Exception: Order(s):%'
and logdate > (select max(insert_date) from tts_syslink_errlogords)


GO
