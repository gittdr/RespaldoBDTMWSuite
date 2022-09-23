SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[BillDoctypesincnoev]
as
select * from dbo.BillDoctypes
union
select cmp_id,'EV',1,'Y','N','B','NOEVO','N','N',null,1,null,'N','N','N' from company where cmp_billto = 'Y' and cmp_Active = 'Y'
and cmp_id not in (select cmp_id from  dbo.BillDoctypes)
GO
