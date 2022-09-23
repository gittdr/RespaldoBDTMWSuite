SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO























CREATE view [dbo].[TMWScrollTractorView_dispo] AS
SELECT 

--inicia seccion datos no se puede modificar
trc_number = trc_number +'            |  TAGIAVE:   ' +isnull(trc_misc1,''), 
trc_type1,
trc_driver =  trc_driver + '     |   ' + (select mpp_firstname+' '+mpp_lastname + '   |    Movil:' + isnull(mpp_currentphone,'')+ ' / Casa: '+ isnull(mpp_homephone,'') from manpowerprofile (nolock) where mpp_id = trc_driver),
trc_status,
trc_company,
trc_terminal,
trc_division,
trc_owner,
trc_fleet = (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet),
ISNULL(trc_licstate, '') as trc_licstate,
ISNULL(trc_licnum, '') as trc_licnum,
ISNULL(trc_serial, '') as trc_serial,
ISNULL(trc_model, '') as trc_model,  
ISNULL(trc_make, '') as trc_make, 
ISNULL(trc_year, 0) as trc_year, 
trc_type2,

   case when trc_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code =  trc_avl_city) = 'GD' then 'BGDA'
        when trc_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code =  trc_avl_city) = 'MX' then 'BMEX'
        when trc_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code =  trc_avl_city) = 'MT' then 'BMTY'
		when trc_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code =  trc_avl_city) = 'NV' then 'BNVL'
		when trc_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code =  trc_avl_city) = 'QR' then 'BQRO'
		else   trc_type3 end as trc_type3,
    


trc_type4,
trc_misc1,
trc_misc2,
trc_misc3,
trc_misc4,
PlannedCity.cty_nmstct, 
AvailableCity.cty_state,
AvailableCity.cty_zip, 
AvailableCity.cty_county, 
trc_avl_cmp_id,
trc_prior_region1,
trc_prior_region2,
trc_prior_region3,
trc_prior_region4,
--acaba secciòn datos que no se pueden modificar

 (case when trc_gps_latitude >1000 then  (trc_gps_latitude/3600.0) else abs(trc_gps_latitude/1.0) end)     'trc_gps_latitude',
 (case when trc_gps_latitude >1000 then  (trc_gps_longitude/3600.0) else abs(trc_gps_longitude/1.0)  end)  'trc_gps_longitude',


 datediff(mi,getdate(), cast (trc_gps_date as varchar) )  'gpslag',


 checkcall = 

 'Operador: '+   isnull((select mpp_firstname +' '+ mpp_lastname from manpowerprofile where mpp_id = trc_driver),'N.D')  +  '<br>'+
 'Tracto: '+  trc_number  +  '<br>'+
 
 'Ubicacion: '+  cast(trc_gps_date as varchar)    
              +'|'+  cast (trc_gps_desc as varchar(100)) +'<br>'+
 'Estatus: '+  (case 
 
 when trc_status = 'AVL'  then 'Disponible'
 when trc_status = 'USE'  then 'En transito'
 when trc_status = 'PLN'  then 'Programado'
 when trc_status = 'VAC' then 'En taller'

else 'En transito'
end) 

--'&Orden=' + cast(( select max(ord_hdrnumber) from orderheader where ord_tractor = trc_number) as varchar(20)) +
+ '</br> <a href="http://10.176.163.68:61/CheckcallsRoute.aspx?Tractor=' + trc_number  + '&Orden=' + 


isnull(
case 
          when trc_status = 'USE' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
		  
		  when trc_status = 'PLN' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
		  
          else ''		  
		  
		  end,'')




 +'" target="_new">Ver recorrido en Google Maps</a>'
+'</br> <font size="1"> Orden: '+ 


isnull(
case 
          when trc_status = 'USE' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
		  
		  when trc_status = 'PLN' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP') )
		  
          else ''		  
		  
		  end,'')


--cast(( select max(ord_hdrnumber) from orderheader where ord_tractor = trc_number) as varchar(20)) 


+ '</font>'

 ,

  icono = 
  
 case 

 when trc_status = 'AVL'  then 'MEDIUM_TRACTOR_GREEN'
  when trc_status = 'LEG'  then 'MEDIUM_TRACTOR_GREEN'
 when trc_status = 'USE'  then 'MEDIUM_TRACTOR_RED'
 when trc_status = 'PLN'  then 'MEDIUM_TRACTOR_YELLOW'
 when trc_status = 'VAC' then 'CIRCLE_RED_CHECK'

else 'CIRCLE_RED_CHECK'
end,
  
  
 (case when trc_gps_latitude >1000 then  (trc_gps_latitude/3600.0) else abs(trc_gps_latitude/1.0) end)     'latitud',
 (case when trc_gps_latitude >1000 then  (trc_gps_longitude/3600.0) else abs(trc_gps_longitude/1.0)  end)  'longitud',
 trc_number as tractor,
 
 
 
 Statustrac = 

  case 


 when trc_status = 'AVL'  then '3.D'
  when trc_status = 'LEG'  then '3.D'

 when trc_status = 'VAC' then '4.F'
 when trc_status = 'PLN' and 
                   (select count(ord_hdrnumber)  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) = 0 then '3.D'
 when trc_status = 'PLN' and 
                   (select count(ord_hdrnumber)  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) <> 0 then '2.P'



 when  rtrim(trc_lastpos_nearctynme) = 


 isnull(
		

         (select  +'[' + rtrim(max(cmp_id)) + ']'  from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')),'')
	
		  then '1.S'

		     when trc_status = 'USE' then '1.T'


else trc_Status
end,



fechagpstxt =  case when datediff(dd,trc_gps_date,getdate()) = 0  then  substring(convert(varchar(24),trc_gps_date,114),1,5)
else +'.'+substring(convert(varchar(24),trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc_gps_date,114),1,5)
 end ,
trc_gps_date,
trc_gps_desc,
ISNULL(trc_exp1_date,'12/31/49') as 'trc_exp1_date',
ISNULL(trc_exp2_date,'12/31/49') as 'trc_exp2_date'

 




,
Cliente =

isnull(
case 
          when trc_status = 'USE' 
          then   (select ord_billto  from legheader_active where 
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) ))
		  
		  when trc_status = 'PLN' 
          then   (select ord_billto  from legheader_active where 
		   legheader_active.lgh_number  = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) ))
		  
          else 'Sin Orden'		  
		  
		  end,'Sin Orden.')


,Destino =

isnull(
case 
          when trc_status = 'USE' 
          then   (select ord_Consignee from orderheader where 
		  orderheader.ord_hdrnumber   = ((select max(ord_hdrnumber)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) ))
		  
		  when trc_status = 'PLN' 
           then   (select ord_Consignee from orderheader where 
		     orderheader.ord_hdrnumber  = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) ))
		  
          else ' '		  
		  
		  end,' ')


,CiudadOrigen =

isnull(
case 
          when trc_status = 'USE' 
          then 
		   (select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) 
		   where cmp_id  
		   = (select ord_shipper from orderheader where 
		  orderheader.ord_hdrnumber   = ((select max(ord_hdrnumber)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) )))
		  
		  when trc_status = 'PLN' 
           then   
		    (select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock)
		    where cmp_id = 
		   (select ord_shipper from orderheader
		    where 
		     orderheader.ord_hdrnumber  = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) )))
		  
          else ' '		  
		  
		  end,' ')




,CiudadDestino =

isnull(
case 
          when trc_status = 'USE' 
          then 
		   (select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock)
		    where cmp_id = (select ord_consignee from orderheader where 
		  orderheader.ord_hdrnumber   = ((select max(ord_hdrnumber)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) )))
		  
		  when trc_status = 'PLN' 
           then  
		  (select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock)
		    where cmp_id = (select ord_consignee from orderheader where 
		     orderheader.ord_hdrnumber  = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) )))
		  
          else ' '		  
		  
		  end,' ')


	


,Remolque =

isnull(
case 
          when trc_status = 'USE' 
          then   (select lgh_primary_trailer  from legheader_active (nolock)  where 
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) ))
		  
		  when trc_status = 'PLN' 
          then   (select lgh_primary_trailer from legheader_active (nolock) where 
		   legheader_active.lgh_number  = ((select max(lgh_number)  from legheader_active where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) ))
		  
          else ' '		  
		  
		  end,' ')


,Escuderia = (select name from labelfile nolock where abbr = trc_teamleader and labeldefinition = 'Teamleader')

,ord_hdrnumber = 
isnull(
case 
          when trc_status = 'USE' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
		  
		  when trc_status = 'PLN' 
          then (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
		  
          else ''		  
		  
		  end,'')



,lgh_number = 
isnull(
case 
          when trc_status = 'USE' 
          then (select cast(max(lgh_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
		  
		  when trc_status = 'PLN' 
          then (select cast(max(lgh_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
		  
          else ''		  
		  
		  end,'')


,InicioOrdenDt = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		  select ord_startdate from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')))
		  
		  when trc_status = 'PLN' 


          then 
		   (
		  select ord_startdate from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')))
		  
          else ''		  
		  
		  end,'')


,InicioOrden = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		  select 
		   substring(convert(varchar(24),max(ord_startdate ),1),0,6)  +' '  +  substring(convert(varchar(24),max(ord_startdate) ,114),1,5)  
		  from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')))
		  
		  when trc_status = 'PLN' 


          then 
		   (
		   select
		 substring(convert(varchar(24),max(ord_startdate ),1),0,6)  +' '  +  substring(convert(varchar(24),max(ord_startdate) ,114),1,5)
		  from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')))
		  
          else ''		  
		  
		  end,'')


,FinOrdendt = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		  select ord_completiondate from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')))
		  
		  when trc_status = 'PLN' 


          then 
		   (
		  select ord_completiondate from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ( 'PLN','DSP')))
		  
          else ''		  
		  
		  end,'')

,FinOrden = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		  select 
		  substring(convert(varchar(24),max(ord_completiondate ),1),0,6)  +' '  +  substring(convert(varchar(24),max(ord_completiondate) ,114),1,5)
		  ord_completiondate 
		  from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')))
		  
		  when trc_status = 'PLN' 


          then 
		   (
		  select 
		  substring(convert(varchar(24),max(ord_completiondate ),1),0,6)  +' '  +  substring(convert(varchar(24),max(ord_completiondate) ,114),1,5)  
		  from orderheader where ord_hdrnumber =
		  (select cast(max(ord_hdrnumber) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ( 'PLN','DSP')))
		  
          else ''		  
		  
		  end,'')



,ProxEvento =  
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		( select name from eventcodetable  (nolock) where abbr = (select max(stp_event)  from  stops (nolock) where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')))
		  )
		 
		  when trc_status = 'PLN'  

	

          then 
		   (
	

		  ( select name from eventcodetable  (nolock) where abbr = (select max(stp_event)  from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN')))
		  )
          else ''		  
		

		  end,'')
		


,ProxCita = 
--considerar si sera arrivaldate o schdt latest

isnull(
case 
          when trc_status = 'USE' 
          then (
		

		 (select 
		 substring(convert(varchar(24),max(stp_arrivaldate),1),0,6)  +' '  +  substring(convert(varchar(24),max(stp_arrivaldate),114),1,5)
		 
		  from  stops (nolock) where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_Number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN'))
		  )
		 
		  when trc_status = 'PLN' 
		

          then 
		   (
	

		(Select  
		 substring(convert(varchar(24),max(stp_arrivaldate),1),0,6)  +' '  +  substring(convert(varchar(24),max(stp_arrivaldate),114),1,5)
		 from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN'))
		  )
          else ''
		
		  		  
		   end,'')



,ProxCitadt = 
--considerar si sera arrivaldate o schdt latest


isnull(
case 
          when trc_status = 'USE' 
          then (
		

		 (select 
		 stp_arrivaldate
		 
		  from  stops (nolock) where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_Number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN'))
		  )
		 
		  when trc_status = 'PLN' 
		

          then 
		   (
	

		(Select  
	      stp_arrivaldate
		 from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN'))
		  )
          else ''
		
		  		  
		   end,'')







,ProxDestino = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		
		(select cast(max(stp_mfh_sequence)  as varchar(2) )+'/'   from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN'))

		  		

			  +

			  		
		(select cast(count(stp_mfh_sequence)  as varchar(2) ) from  stops (nolock) 
		where stops.mov_number
		 = (select max(mov_number)  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number  and legheader_active.lgh_outstatus in ('STD','DSP'))
       )

	
	
			  +' ' +

		(select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) where cmp_id = (select max(cmp_id)  from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')))
		  )
		 
		  when trc_status = 'PLN'  


          then 
		   (
	
	           
		  (select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) where cmp_id = (select max(cmp_id) from  stops (nolock) 
		  where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN')))
		  )
          else ''	
			    
		  end,'')


		  ,ProxCiudadDestino = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		(select cty_nmstct from company (nolock) where cmp_id = (select max(cmp_id)  from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')))
		  )
		 
		  when trc_status = 'PLN'  


          then 
		   (
	

		  (select cty_nmstct from company (nolock) where cmp_id = (select max(cmp_id) from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN')))
		  )
          else ''	
			    
		  end,'')



		  ,Calceta = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		 (select
		 
		 isnull(cast( stp_rpt_miles  as varchar(10)),'')  + ' Kms        ----------------'  
		 +   (case when  isnull(cast(stp_est_drv_time as varchar(10)),'') < 60 then    isnull(cast(stp_est_drv_time as varchar(10)),'')  + ' Minutos de Manejo'
		 else isnull(cast(stp_est_drv_time/60 as varchar(10)),'') + ' Hora(s) de Manejo'   end) + '---------------' + 'ETA: ' + isnull(cast(stp_eta as varchar(20)),'')  
		
		 
		from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')))
		  
		 
		  when trc_status = 'PLN'  


          then 
		   (
	

		  ( (select
		 
		 isnull(cast( stp_rpt_miles  as varchar(20)),'ND.............')  + ' Kms        ----------------'  
		 +   (case when  isnull(cast(stp_est_drv_time as varchar(10)),'') < 60 then    isnull(cast(stp_est_drv_time as varchar(10)),'')  + ' Minutos de Manejo'
		 else isnull(cast(stp_est_drv_time/60 as varchar(10)),'') + ' Hora(s) de Manejo'   end) + '---------------' + 'ETA: ' + isnull(cast(stp_eta as varchar(20)),'')  
		  
		  
		  
		  
		   from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN')))
		  )
          else ''	
			    
		  end,'')



		  ,etatime = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		 (select
		stp_eta
		
		 
		from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) 
		 where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) and stp_status = 'OPN')))
		  
		 
		  when trc_status = 'PLN'  


          then 
		   (
	

		  ( (select
		 
	       stp_eta 
		  
		 
		   from  stops (nolock) where stops.mov_number 
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) and stp_status = 'OPN')))
		  )
          else ''	
			    
		  end,'')








		  
		  ,Comentario = 
isnull(
case 
          when trc_status = 'USE' 
          then (
		

		(select max(stp_comment)  from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP'))
         and stp_mfh_sequence = (select max(stp_mfh_sequence) from  stops  (nolock) 
		 where  (stp_comment is not null or  stp_comment = '')  and stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('STD','DSP')) ))
		  )
		 
		  when trc_status = 'PLN'  


          then 
		   (
	

		(select max(stp_comment)  from  stops (nolock) 
		where stops.mov_number
		 = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP'))
         and stp_mfh_sequence = (select max(stp_mfh_sequence) from  stops  (nolock) 
		 where  (stp_comment is not null or  stp_comment = '')  and stops.mov_number
		  = (select cast(max(mov_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.lgh_tractor = dbo.tractorprofile.trc_number and legheader_active.lgh_outstatus in ('PLN','DSP')) ))
		  )
          else ''	
			    
		  end,''),


		 SitioActual =  trc_lastpos_nearctynme,
		 estatusgps = case 
		 when trc_lastpos_nearctynme like '%ZBC/%' 
		  then'BAJCOVER'
		 when trc_lastpos_nearctynme <> '' 
		 and  (datediff(mi,cast (trc_gps_date as varchar),getdate() ) > 15)
		  then 'SEG'
		  when trc_lastpos_nearctynme = '' 
		  and   (datediff(mi,cast (trc_gps_date as varchar),getdate() ) > 15)
		  then 'NOSEG'
	
		 else
		    'OK'
		 end


,kmsultsiete = case when trc_driver = 'UNKNOWN' then '0' else 
(select mpp_mile_day7 from manpowerprofile where mpp_id = trc_driver) end

,drvavailabledate = (select   substring(convert(varchar(24),max(mpp_avl_date),1),0,6)  +' '  +  substring(convert(varchar(24),max(mpp_avl_date) ,114),1,5) from manpowerprofile where mpp_id = trc_driver)





		

FROM dbo.tractorprofile (NOLOCK) LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
					    LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 

						where trc_Status not in ('OUT')
						

















GO
GRANT SELECT ON  [dbo].[TMWScrollTractorView_dispo] TO [public]
GO
