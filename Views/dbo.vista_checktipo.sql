SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_checktipo]

--select * from vista_checktipo  where ckc_tractor = '1204' order by ckc_date desc
as

select
ckc_tractor,
ckc_date,
ckc_comment,
mapa = 'http://maps.google.com.mx/maps?F=Q&source=s_q&hl=es&geocode=&q=' + CAST((ckc_latseconds) / 3600.00 AS varchar) 
                   + ',-' + CAST((ckc_longseconds)/ 3600.00 AS varchar) + ' & z=13',
inout = case when ckc_comment like 'Entrando a:%'  then 'In'
        when ckc_comment like 'Saliendo de:%' then 'Out'
		else ''
		end,
tipo = case when ckc_comment  like '%OP/%' and ckc_event = 'SIT'  then 'Casas Operadores'
             when ckc_comment like '%ZBC/%' and ckc_event = 'SIT'  then 'Zona Baja Cobertura'
			 when ckc_comment like '%CAS/%' and ckc_event = 'SIT'  then 'Casetas'
			 when ckc_comment like '%PP/%' and ckc_event = 'SIT'  then 'Paraderos-Pensiones'
			 when ckc_comment like '%TDR%' and ckc_event = 'SIT'  then 'Patios TDR'
			 when ckc_event = 'SIT' then 'Clientes'
			 when ckc_event = 'TRP' then 'Transito Calle'
		end,
		ckc_event
from checkcall
where datediff(dd,getdate(),ckc_date) <= 6







GO
GRANT ALTER ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT CONTROL ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT DELETE ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT INSERT ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT SELECT ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT UPDATE ON  [dbo].[vista_checktipo] TO [public]
GO
GRANT VIEW DEFINITION ON  [dbo].[vista_checktipo] TO [public]
GO
