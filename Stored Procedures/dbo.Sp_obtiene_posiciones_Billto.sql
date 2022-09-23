SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Sp_obtiene_posiciones_Billto] (@billto varchar(100) , @reftype varchar(100) )
AS
SET NOCOUNT ON

select  oh.ord_hdrnumber , lg.lgh_tractor, oh.ord_completiondate
			, (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) as locatedAt
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,5))  as lat
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,5)) as long
			--,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = @reftype AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) as ord_refnum
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = @billto  and  lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null

GO
