SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Procedimiento para obtener las posicionescada 5 minutos antes de la fecha y hora del día de hoy.
--DROP PROCEDURE Sp_obtiene_posiciones cada 7 minutos
--GO

-- exec Sp_obtiene_posiciones_JR  'CONDUCMT'

--select * from orderheader where ord_billto like 'CON%'


CREATE PROCEDURE [dbo].[Sp_obtiene_posiciones_JR] @as_billto varchar(10) = null
AS
SET NOCOUNT ON

Declare @ldt_fechatiempoActual datetime,
		@ldt_fechatiempo7menos datetime

DECLARE @TTPosiciones TABLE(
		 TT_Evento varchar(4),
		 TT_ckc_date datetime, 
		 TT_ckc_latseconds decimal(16,4), 
		 TT_ckc_longseconds decimal(16,4), 
		 TT_ckc_speed varchar(100),
		 TT_ckc_placa varchar(100),
		 TT_referencia varchar(800))

-- Obtiene la fecha y tiempo de este instante	

select @ldt_fechatiempo7menos  = DATEADD(minute,-5,getdate())

Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'REF' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'PALACIO'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null


Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'REF' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'LIVERPOL'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null


Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'REF' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'CHEDRA'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null



Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'PROTEAK'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null





Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)

from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'QUAKER'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null

-- DHLMETRO JR
Insert Into @TTPosiciones
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'REF' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'DHLMETRO'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null

-- JR DHLMETRO



Insert Into @TTPosiciones --viakable tractor
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)

from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
where oh.ord_billto = 'CONDUCMT'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null


Insert Into @TTPosiciones  --viakable caja 1.
select '1' 
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tl.trl_licnum
			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)

from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join trailerprofile tl on tl.trl_number = lg.lgh_primary_trailer
where oh.ord_billto = 'CONDUCMT'  and oh.ord_status in ('STD','PLN') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tl.trl_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null






Insert Into @TTPosiciones
--select '1'
--			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
--			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
--			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
--			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
--			,tp.trc_licnum
--			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
--from legheader lg
--inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
--inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
--where oh.ord_billto = 'HOMEDEP'  and  lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
select '1'
			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
			,(select ckc_speed from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))
			,tp.trc_licnum
			,rf.ref_number
			--,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
inner join referencenumber rf on oh.ord_hdrnumber = rf.ord_hdrnumber 
where oh.ord_billto = 'HOMEDEP'  and  lgh_outstatus <> ('CMP')  
AND lgh_carrier = 'UNKNOWN' 
and tp.trc_licnum is not null 
and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
and rf.REF_TYPE = 'BL#'

select  * from @TTPosiciones



-- test el codigo


--Declare @ldt_fechatiempoActual datetime,
--		@ldt_fechatiempo7menos datetime
--		select @ldt_fechatiempo7menos  = DATEADD(minute,-5,getdate())

--		select '1',  DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), ckc_date), CAST(ckc_latseconds/3600.00 as dec(16,4)) , cast((ckc_longseconds/3600.00)*-1 as dec(16,4)),
--placa = trc_licnum
--, ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in 
--		(select ord_hdrnumber from orderheader where ord_billto = 'HOMEDEP'  and ord_status in ('STD') and  ckc_asgnid = ord_tractor))
--	   ,(select top 1 ord_hdrnumber from orderheader where ord_billto = 'HOMEDEP'  and ord_status in ('STD') and  ckc_asgnid = ord_tractor))
-- from checkcall, tractorprofile  
--WHERE ckc_asgntype = 'DRV' and ckc_asgnid in (
--select lg.lgh_tractor from legheader lg
--inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
--where oh.ord_billto = 'HOMEDEP'  and oh.ord_status in ('STD') and lgh_outstatus <> ('CMP') AND trc_number = ckc_asgnid AND lgh_carrier = 'UNKNOWN'
--) and
--ckc_updatedon >= @ldt_fechatiempo7menos and  ckc_updatedon  = (select max(ckc.ckc_updatedon) from checkcall ckc where ckc.ckc_asgnid = checkcall.ckc_asgnid )
--order by ckc_updatedon desc




--select * from orderheader where ord_billto = 'homedep'  AND ORD_HDRNUMBER = '663487' order by ord_hdrnumber desc
--select * from referencenumber where  REF_NUMBER = '8061186182'ord_hdrnumber = '661818'


--select '1' 
--			,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))
--			,CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) 
--			,cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4))
--			,tp.trc_licnum, tp.trc_number
--			,ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
--			,lg.ord_hdrnumber
--from legheader lg
--inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
--inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
--where oh.ord_billto = 'HOMEDEP'  and oh.ord_status in ('STD') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN'







GO
