SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Sp_obtiene_completadosEvidencias_Billto] (@billto varchar(100) )
AS
SET NOCOUNT ON

select ord_company,
ord_hdrnumber,
ord_refnum,
'http://10.176.167.171/cgi-bin/img-docfind.pl?reftype=ORD&refnum=' + ord_number as imaging,
ord_status
from orderheader
where ord_hdrnumber in
 (select ord_hdrnumber from paperwork
where ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'cuervo' and ord_completiondate > '2020-01-01')
and cast(paperwork.pw_dt as date) >= cast(getdate()-10 as date)
and abbr in ('CP','RM') and pw_received = 'Y'
and last_updatedby = 'PWReceivedY002_sp') --and ord_hdrnumber = '988619'-- and ord_hdrnumber = '988619' 
and ord_hdrnumber not in (select ord_hdrnumber from [dbo].[convoy360_ViajesClienteAPI] where [evidencias] is not null)



update [dbo].[convoy360_ViajesClienteAPI]
set [evidencias] = getdate()
where ord_hdrnumber in (select 
ord_hdrnumber
from orderheader
where ord_hdrnumber in
 (select ord_hdrnumber from paperwork
where ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'cuervo' and ord_completiondate > '2020-01-01')
and cast(paperwork.pw_dt as date) >= cast(getdate()-10 as date)
and abbr in ('CP','RM') and pw_received = 'Y'
and last_updatedby = 'PWReceivedY002_sp') --and ord_hdrnumber = '988619'-- and ord_hdrnumber = '988619' 
and ord_hdrnumber not in (select ord_hdrnumber from [dbo].[convoy360_ViajesClienteAPI] where [evidencias] is not null))
GO
