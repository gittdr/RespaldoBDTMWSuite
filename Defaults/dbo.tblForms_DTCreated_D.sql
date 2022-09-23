SET QUOTED_IDENTIFIER OFF
GO
CREATE DEFAULT [dbo].[tblForms_DTCreated_D] AS convert(datetime,convert(varchar,getdate(),1))
GO
