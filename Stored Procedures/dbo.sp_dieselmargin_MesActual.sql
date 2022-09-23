SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_dieselmargin_MesActual]

as


delete from [dbo].[DieselMargin_7Dias]

insert into [dbo].[DieselMargin_7Dias]
select 
[fechaUpdate] = getdate(),
gerente = case

	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Cemex'        then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'GNV'          then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Audi'  then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Maulec'       then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Pilgrims'     then 'Esther Mora'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'BMW'          then 'Esther Mora'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Sayer'        then 'Esther Mora'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Peñafiel'     then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Liverpool'    then 'Isac Martinez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Walmart'        then 'J.M. Solis'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO1'      then 'Ricardo Rivas'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO2'      then 'Ricardo Rivas'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO3'      then 'Ricardo Rivas'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Eucomex'      then 'Isac Martinez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Fullsureste' then 'Isac Martinez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Tolvas'       then 'Isac Martinez'
	 else ' '

	 end ,


	 lpc = case
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Cemex'        then 'Jaen Ortega'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'GNV'          then 'Yahir Martinez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Audi'         then 'Jaen Ortega'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Maulec'       then 'Angie Curro'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Pilgrims'     then 'Karen Martinez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'BMW'          then 'Christian Uribe'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Sayer'        then 'Ramon Escobedo'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Peñafiel'     then 'Jorge Gonzalez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Liverpool'    then 'Carlos Duarte'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Wm Vh'        then 'Lorenzo Hernandez'
	  when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO1'      then 'Veronica Trejo'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO2'      then 'Carlos Zamudio'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'ABIERTO3'      then 'Claudia Ramirez'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Eucomex'      then 'Israel Orihuela'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Full sureste' then 'Carlos Duarte'
	 when (select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) = 'Tolvas'       then 'Antonio Chavez'
	 else ' '
	  end
,trc_number,
(select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) as flota,
costodiesel,litros,
ingreso,
case when ingreso = 0 and costodiesel  > 0  then 100  when ingreso = 0 and costodiesel = 0 then 0 else  100*(costodiesel/ingreso) end as margen,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as iniciadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('PLN') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as planeadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('CMP') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as completadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('CMP','STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as ordenes,
isnull((select sum(lgh_miles) from legheader where lgh_tractor = trc_number and  lgh_outstatus in  ('CMP','STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ),0) as kmsordenes,
round(isnull((select sum(cast(distancia_recorrida as float)) from fuel.[dbo].[intralix_getperformance1day] where datediff(dd,fecha_final,getdate()) <= 7 and economico = trc_number),0),0) as kmsodo,

(round(case when isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0)  = 0 then 0 else
(isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0) 
-
round(isnull((select sum(cast(distancia_recorrida as float)) from fuel.[dbo].[intralix_getperformance1day] where datediff(dd,fecha_final,getdate()) <= 7 and economico = trc_number),0),0)   
)
/
isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0)end,2) * -1)*100 as pctfueraruta,

(select max(exp_description) from expiration where exp_id = trc_number and datediff(dd,exp_compldate,getdate()) = 12) as expi,

--casetas add by erik
(select sum(tpi.[Importe Facturado]) from   [IAVE].[dbo].[telepeaje_cruces_Jr]  tpi WITH (NOLOCK) where tpi.[No. economico] = trc_number and  datediff(dd,convert(date,Replace([Fecha de Cruce],'/','-'),103),getdate()) <= 7) + 
(select sum(tpi.[Importe Facturado]) from   [IAVE].[dbo].[telepaje_interoperabilidad_Jr] tpi WITH (NOLOCK) where tpi.[No Económico] = trc_number and  datediff(dd,convert(date,Replace([Fecha Cruce],'/','-'),103),getdate()) <= 7)
 as casetas


from
(
select 
trc_number,
sum(fp_amount) as costodiesel,
sum(fp_quantity) as litros,
isnull((select sum(ord_totalcharge) from orderheader where ord_tractor = trc_number and ord_status = 'CMP'
 and datediff(dd,ord_dest_latestdate,getdate()) <= 7  ),0) as ingreso
 from fuelpurchased WITH (NOLOCK)
 where datediff(dd,fp_Date,getdate()) <= 7
 group by trc_number
 ) as dieselmargin
order by margen desc
GO
