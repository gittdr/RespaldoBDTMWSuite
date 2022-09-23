SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [dbo].[vista_abastos_dipersion]
as
--select  trc as unidad,
-- proyecto,
--sum(litros) as Litros,
--(select tca_type from tractoraccesories t where  tca_type='DISPP' and t.tca_tractor = s.trc ) as accesorios,
--(select count(*) from stopsdiesel t where Litros = 0 and s.trc = t.trc and datediff(day,Fin,getdate())= 1 and s.proveedor = t.proveedor ) as StopsSinLitros,
--Proveedor from stopsdiesel s
--where proyecto IN ( /*'CEMEX','AUDI'*/'SAYER')
--and datediff(day,Fin,getdate())= 1 
--and Litros > 0
--group by trc, Proveedor, proyecto




select 
s.trc as unidad,
s.proyecto,
Sum(s.Litros) as litros,
T.tca_type as accesorios,
(select count(*) from stopsdiesel t where Litros = 0 and s.trc = t.trc and datediff(day,Fin,getdate())= 1 and s.proveedor = t.proveedor ) as StopsSinLitros,
Proveedor 
from stopsdiesel s
INNER JOIN tractoraccesories t ON t.tca_tractor = s.trc 
where proyecto IN ( 'AUDI','LIVERPOOL')
AND  datediff(day,Fin,getdate())= 1 
and  T.tca_type='DISPP'
--and s.trc in (
--'1629'
--)
group by trc, Proveedor,tca_type,Proyecto

GO
