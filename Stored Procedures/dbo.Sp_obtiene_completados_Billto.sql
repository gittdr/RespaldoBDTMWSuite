SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Sp_obtiene_completados_Billto] (@billto varchar(100) )
AS
SET NOCOUNT ON


select  oh.ord_hdrnumber , lg.lgh_tractor, oh.ord_completiondate
			, (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor and ckc_date <= oh.ord_completiondate)) as locatedAt
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor and ckc_date <= oh.ord_completiondate))/3600.00 as dec(16,4))  as lat
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor and ckc_date <= oh.ord_completiondate))/3600.00)*-1 as dec(16,4)) as long
			--,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) as ord_refnum
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'cuervo'  and
 cast(oh.ord_completiondate as date) >= cast(GETDATE()-10 as date) and oh.ord_status = 'CMP' 
 and (DATEADD(second, DATEDIFF(second, oh.ord_completiondate, GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor and ckc_date <= oh.ord_completiondate)))) is not null
and oh.ord_hdrnumber not in (select ord_hdrnumber from [convoy360_ViajesClienteAPI] where wsRefnum is not null)




insert [dbo].[convoy360_ViajesClienteAPI]([ord_hdrnumber], [ord_status], [fechaCompletado], [completado], [evidencias],[wsRefnum],[ord_refnum])
 select ord_hdrnumber, ord_status, ord_completiondate,'X',null,null,ord_refnum
from orderheader
where cast(ord_completiondate as date) >= cast(GETDATE()-10 as date) and ord_billto = @billto and ord_status = 'CMP'   and ord_hdrnumber not in (select ord_hdrnumber from [convoy360_ViajesClienteAPI] )




GO
