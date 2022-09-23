SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
ejemplo consulta:

exec sp_factconceptos 'SAYER','2016-05-01','2016-05-23'
*/

CREATE proc [dbo].[sp_factconceptosbilltos] 
 as


select distinct ivd_billto from invoicedetail (nolock)
order by ivd_Billto desc






GO
