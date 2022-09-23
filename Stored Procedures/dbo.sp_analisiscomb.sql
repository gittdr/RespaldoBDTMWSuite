SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_analisiscomb] 

as

declare @rendimientos table 
(proyecto varchar (20),
 unidad varchar (20),
  km int, 
  litros int, 
  rendimiento float, 
   fecha datetime,
    mes varchar(2), 
	semana varchar(2),
	 anio varchar(4),
	  monto float,
	  leg varchar(10), 
	  orden varchar(10),
	  movimiento varchar(10),
	   tipo varchar(50),
	   cliente varchar(10),
	   tipocomb varchar(1))


insert into @rendimientos


select 
'',
'',
(select sum(lgh_miles) from legheader (nolock) where legheader.lgh_number = paydetail.lgh_number) as kms,
sum(pyd_quantity) as litros,
(select sum(lgh_miles) from legheader (nolock) where legheader.lgh_number = paydetail.lgh_number) / (sum(pyd_quantity) +.0001)  as rendimiento,
pyh_payperiod as fecha,
'',
'',
'',
sum(pyd_amount) as monto,
lgh_number as leg,
ord_hdrnumber as orden,
mov_number as movimiento,
pyt_itemcode as TipoPayDetail,
'',
case
 when pyt_itemcode  in ('VALECO','COMB','VALEEL','CANVAL','CVELEC') then 'V'
  when pyt_itemcode  in ('CMELEC') then 'C'
  when pyt_itemcode  in ('CREF') then 'T'

 end as TipoPayDetail

from paydetail (nolock) where  year(pyh_payperiod) = 2016 and pyd_quantity <> 0
and pyt_itemcode in ('COMB','VALECO','CANVAL','VALEEL','CVELEC','CMELEC','CREF')
group by 
lgh_number,
ord_hdrnumber,
mov_number,
pyt_itemcode,
pyh_payperiod
order by movimiento

update @rendimientos set unidad = (select lgh_tractor from legheader (nolock) where legheader.lgh_number = leg)
--update @rendimientos set proyecto = (select ord_revtype3 from orderheader (nolock) where orderheader.ord_hdrnumber = orden)

update @rendimientos set proyecto = (select trc_type3 from tractorprofile where tractorprofile.trc_number = unidad) 

update @rendimientos set proyecto = (select trc_type3 from tractorprofile where tractorprofile.trc_number = unidad) where proyecto is null
update @rendimientos set mes = month(fecha)
update @rendimientos set semana = datepart(ww,fecha)
update @rendimientos set anio = year(fecha)
update @rendimientos set cliente = (select ord_billto from orderheader (nolock) where orderheader.ord_hdrnumber = orden)



select * from @rendimientos
GO
