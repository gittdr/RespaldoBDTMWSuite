SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_rutaorden]   
(@orden varchar(20))

as

--- si el numero de la orden viene en 0
--- solo se considera el parametro del numero de la unidad.
--- no se dibuja la capa de la ruta que propone global maps.


--Si se incluye el parametro del numero de la orden.

declare @mov as varchar(20)

--para ejemplo le damos un valor a la variable orden


select @mov = (select mov_number from orderheader where ord_hdrnumber = @orden)

select 
secuencia = stp_mfh_sequence 
,comporigen = (cmp_id)
,ciudadorigen = (select alk_city from city where cty_code =stp_city)
,estadoorigen = (select name from labelfile where labeldefinition = 'state' and abbr  = (select cty_state from city where cty_code =stp_city))
,cporigen =  (select cmp_zip from company  where company.cmp_id = stops.cmp_id)
,ciudaddestino = (select alk_city from city where cty_code = (select stp_city from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1)  )
,compdestino =  (select cmp_id from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1) 
,cpdestino =  (select cmp_zip from company  where company.cmp_id = (select cmp_id from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1) )
,estadodestino = (select name from labelfile where labeldefinition = 'state' and abbr  = (select cty_state from city where cty_code =(select stp_city from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1  )))
,stp_status
,detalleparapinorig =  (select cmp_name from company cy where stops.cmp_id = cy.cmp_id) + ' |  Cita entre: ' +  cast(stp_schdtearliest as varchar(25)) + ' y ' + cast(stp_schdtlatest as varchar(25)) + ' | Hora llegada: ' + 
case when stp_Status= 'DNE' then cast(stp_arrivaldate as varchar(25))  else 'No completado' end

,detalleparapidest =    (select cmp_name from company cy where cy.cmp_id = (select cmp_id from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1)  )
+ ' |  Cita entre: ' +    (select isnull(cast(stp_schdtearliest as varchar(25)),'')  from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1) 
 + ' y ' +   (select isnull(cast(stp_schdtlatest as varchar(25)),'')   from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1) 
+ ' | Hora llegada: '

+ case when stp_Status= 'DNE' then  (select isnull(cast(stp_arrivaldate as varchar(25)),'')   from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1)   else 'No completado' end

from stops where stops.mov_number = @mov
and (select alk_city from city where cty_code = (select stp_city from stops st where st.mov_number = @mov and st.stp_mfh_sequence = stops.stp_mfh_sequence + 1)  ) is not null
order by stp_mfh_sequence


GO
