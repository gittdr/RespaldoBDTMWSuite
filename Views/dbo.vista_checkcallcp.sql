SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_checkcallcp]

--select * from [dbo].[vista_checkcallcp]
as

select
ckc_tractor,
ckc_date,
fechatxt =  case when datediff(dd,ckc_date,getdate()) = 0  then  substring(convert(varchar(24),ckc_date,114),1,5)
else +'.'+substring(convert(varchar(24),ckc_date,1),0,6)  +' '  +  substring(convert(varchar(24),ckc_date,114),1,5)
 end ,
ckc_comment = case when ckc_event = 'TRP' then ckc_comment
                   when ckc_Event = 'SIT' then ckc_comment + ' | ' +ckc_commentlarge end,

inout=  case when ckc_comment like 'Entrando a:%' then 'In'
             when  ckc_comment like 'Saliendo de:%' then 'Out'
			 else ''
			 end,

mapa = 'http://maps.google.com.mx/maps?F=Q&source=s_q&hl=es&geocode=&q=' + CAST((ckc_latseconds) / 3600.00 AS varchar) 
                   + ',-' + CAST((ckc_longseconds)/ 3600.00 AS varchar) + ' & z=13',

/*
inout = case when ckc_comment like 'Entrando a:%'  then 'In'
        when ckc_comment like 'Saliendo de:%' then 'Out'
		else ''
		end,

		*/
tipo = case 

             when ckc_comment  like '%OP/%' and ckc_event = 'SIT' and ckc_comment like 'Entrando a:%' then 'Entrando a Casa Operador'
             when ckc_comment  like '%OP/%' and ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%' then 'Saliendo de Casa Operador'
			 when ckc_comment  like '%OP/%' and ckc_event = 'SIT'  then 'En Casa Operador'

             when ckc_comment like '%ZBC/%' and ckc_event = 'SIT'  and ckc_comment like 'Entrando a:%'  then 'Entrando a Zona Baja Cobertura'
			 when ckc_comment like '%ZBC/%' and ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%'  then 'Saliendo de Zona Baja Cobertura'
			 when ckc_comment like '%ZBC/%' and ckc_event = 'SIT'  then 'En Zona Baja Cobertura'

			 when ckc_comment like '%CAS/%' and ckc_event = 'SIT'  and ckc_comment like 'Entrando a:%'  then 'Entrando a Caseta'
			 when ckc_comment like '%CAS/%' and ckc_event = 'SIT'  and  ckc_comment like 'Saliendo de:%' then 'Saliendo de Caseta'
			 when ckc_comment like '%CAS/%' and ckc_event = 'SIT'  then 'En Caseta'

			 when ckc_comment like '%PP/%' and ckc_event = 'SIT'  and ckc_comment like 'Entrando a:%'  then 'Entrando a Paradero-Pensione'
			 when ckc_comment like '%PP/%' and ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%'  then 'Saliendo de Paradero-Pension'
			 when ckc_comment like '%PP/%' and ckc_event = 'SIT'   then 'En Paradero-Pension'

			 when ckc_comment like '%TDR%' and ckc_event = 'SIT' and ckc_comment like 'Entrando a:%'   then 'Entrando a Patio TDR'
			 when ckc_comment like '%TDR%' and ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%'  then 'Saliendo de Patio TDR'
			  when ckc_comment like '%TDR%' and ckc_event = 'SIT'   then 'En Patio TDR'

			 when ckc_comment like '%GAS/%' and ckc_event = 'SIT' and ckc_comment like 'Entrando a:%'   then 'Entrndo a Gasolinera'
			 when ckc_comment like '%GAS/%' and ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%'  then 'Saliendo de Gasolinera'
			 when ckc_comment like '%GAS/%' and ckc_event = 'SIT'  then 'En Gasolinera'

			 when ckc_event = 'SIT' and ckc_comment like 'Entrando a:%'  then 'Entrando a Cliente:'
			 when ckc_event = 'SIT' and  ckc_comment like 'Saliendo de:%'  then 'Saliendo de Cliente'
			 when ckc_event = 'SIT'   then 'En Cliente'


			 when ckc_event = 'TRP' then 'Transito Calle'
		end,
		ckc_event
from checkcall
where datediff(dd,getdate(),ckc_date) <= 30







GO
GRANT SELECT ON  [dbo].[vista_checkcallcp] TO [public]
GO
