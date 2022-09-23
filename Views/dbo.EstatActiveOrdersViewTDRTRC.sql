SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [dbo].[EstatActiveOrdersViewTDRTRC]
as



	select 

	 'TMWWF_ESTAT_ACTIVE' as 'TMWWF_ESTAT_ACTIVE',                                                                                                                             ----0
	
	 isnull(e.ord_hdrnumber, 0)  as ord_hdrnumber,                                                                                                                                               ----1
     isnull(e.ord_number,'0')  as ord_number,
	
	 

/************************************************************************************************************************************************************/
     isnull(e.dispstatus,replace(replace(t.trc_status,'USE','STD'),'VAC','AVL')) as DispStatus  ,                            ----3
/*************************************************************************************************************************************************************/ 
	
	
	
	  (select name from labelfile where labeldefinition = 'fleet' and abbr = t.trc_fleet) as OrderByID ,                                                                                                                                      ----4
	 isnull(e.StartDate,getdate()) 'StartDate',
	 isnull(e.enddate,getdate()) 'EndDate' ,         	 
     (select cmp_name from company where  cmp_id =(select name from labelfile where labeldefinition = 'fleet' and abbr = t.trc_fleet)) 'BillTo', 
	 (select cmp_name from company where  cmp_id =(select name from labelfile where labeldefinition = 'fleet' and abbr = t.trc_fleet)) 'OrderBy',
     
	  e.PickupID 'PickupID',
      e.PickupName 'PickupName',
      e.PickupCity 'PickupCity',
      e.PickupState 'PickupState',

      isnull(e.consigneeid, t.trc_avl_cmp_id) 'ConsigneeID',
      e.ConsigneeName 'ConsigneeName',
      e.ConsigneeCity  'ConsigneeCity',
      e.ConsigneeState 'ConsigneeState', 

	  e.RevType1 'RevType1', 
	  e.revtype2 'RevType2' ,
	  e.RevType3 'RevType3', 
	  e.RevType4 'RevType4',
     isnull(e.billtoid,(select name from labelfile where labeldefinition = 'fleet' and abbr = t.trc_fleet)) 'BillToID',
	 
	 
	 

	
	---------------------------------------------------------------------------------------
     e.Referencia as Referencia,
	 isnull(e.driver1name,(select mpp_lastname + ','+ mpp_firstname from manpowerprofile (nolock) where mpp_id = t.trc_driver)) as Driver1Name,
	 

	
	 case when (estatusicon  = 'Drvng' and Proxevent not in  ('IDMT','EMT')) then 'En transito' 
	 when estatusicon = 'LLD' then 'Cargando' 
	 when estatusicon = 'LUL' then 'Descargando' 
	 when estatusicon = 'IDMT' then 'Final'
	 when trc_status ='PLN'  then 'Disponible'
	  when trc_status = 'VAC' then 'Mantenimiento'
	 when (EstatusIcon = 'Drvng' and Proxevent  ='IDMT') then 'Regreso'
	 when (EstatusIcon = 'Drvng' and Proxevent  ='EMT') then 'Regreso'

	 else  estatusicon end as estatusicon,







	 e.actcomp as Actcomp,
	 e.Actdif as Actdif,

     t.trc_gps_desc 'UbicacionGPS',


	 gpsdated=	 cast(day( t.trc_gps_date) as varchar(20)) +'/'+ cast( month(  t.trc_gps_date) as varchar(20)) + ' ' + cast(datepart(hour,  t.trc_gps_date) as varchar(20)) +':'+
				case when len((cast(datepart(MINUTE,  t.trc_gps_date) as varchar(20)))) = 1 then '0'+ cast(datepart(MINUTE,  t.trc_gps_date) as varchar(20)) else cast(datepart(MINUTE,  t.trc_gps_date) as varchar(20))  end,
	 ProxCita = e.ProxCita,

	  Proxevent,--(select name from eventcodetable where abbr = Proxevent) as  Proxevent,


	 e.Proxcomp as Proxcomp,
	 e.elogist as Elogist,
	 ETAPC = e.ETAPC,
	 ETADif =  e.ETADif,
	 TRCDispo = e.tRCdispo,
	 Tractor =  t.trc_number,
	 t.trc_licnum as PlacasTractor,
	 e.Trailer as Trailer,
	 e.PlacasTrailer  as PlacasTrailer,
	 
	 t.trc_status  'EstadoViaje',
	 OrdenGrid =  case trc_status when 'VAC' then '2049-12-01' else isnull(e.OrdenGrid, '2049-01-01') end
	

	 from tractorprofile t 
	 left  join (select * from [dbo].EstatActiveOrdersViewTDR where dispstatus in ('AVL','PLN','STD') and tractor in  (select trc_number from tractorprofile where trc_status not in ('OUT','VAC') and 
	 trc_Type3 = 'PIL' )) e on e.tractor = t.trc_number
	 

	 where trc_status <> 'OUT'  and trc_type3 = 'PIL'

     
































GO
