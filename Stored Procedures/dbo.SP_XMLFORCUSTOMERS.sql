SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[SP_XMLFORCUSTOMERS] (@Customer varchar(20), @token varchar(254), @status varchar(5)) 
as


--SELECCION DEL TIPO DE STATUS DE LA ORDEN A MOSTAR--------------
if @status = 'CMP' 
BEGIN

select top (20)
 case when len(referencia) > 0 then referencia  else 'N/A'  end as 'REFERENCIA',
	 ord_hdrnumber as ORDEN,                                                                                                                                              
     ord_number as NUMEROORDEN,  
	 replace(carrier,'UNKNOWN','TDR') as CARRIER,                                                                                                                               
     DispStatus  as STATUSVIAJE ,                            
	 OrderBy 'IDCLIENTE',                                                                                                                                      
	 StartDate 'FECHAINICIO',
	 Enddate 'FECHAFIN',
	 sh.cmp_name as 'ORIGEN',
	 sh.cty_nmstct as 'CIUDADORIGEN',
     co.cmp_name as 'DESTINO',
	 co.cty_nmstct as 'CIUDADDESTINO',
	 isnull((STUFF((select  '; ' + cast( ivh_hdrnumber as varchar(10))  from invoiceheader   where invoiceheader.ord_hdrnumber = [OperationsInboundView_TDR].ord_hdrnumber FOR XML PATH('')) , 1, 1, '')),'N/A') as 'Facturas'

	



  from [OperationsInboundView_TDR]    
	left join OperationsTrailerView_TDR trl  on trl_number = Trailer
	left join company sh on sh.cmp_id = shipper
	left join company co on co.cmp_id = consignee

	where billto = @Customer
	and DispStatus in ('CMP')
	FOR XML  PATH('ORDEN'), ROOT('ORDENES') 


END



if @status = 'APS' 
 BEGIN
 declare @statustable table (st varchar(5))
   insert into @statustable select 'AVL' union select 'PLN'  union select 'STD'
 END
 ELSE
  BEGIN
   insert into @statustable  select @status
 END

 SELECT
     
	   
	 case when len(referencia) > 0 then referencia  else 'N/A'  end as 'REFERENCIA',
	 ord_hdrnumber as ORDEN,                                                                                                                                              
     ord_number as NUMEROORDEN,  
	 replace(carrier,'UNKNOWN','TDR') as CARRIER,                                                                                                                               
     DispStatus  as STATUSVIAJE ,                            
	 OrderBy 'IDCLIENTE',                                                                                                                                      
	 StartDate 'FECHAINICIO',
	 Enddate 'FECHAFIN',
	 sh.cmp_name as 'ORIGEN',
	 sh.cty_nmstct as 'CIUDADORIGEN',
     co.cmp_name as 'DESTINO',
	 co.cty_nmstct as 'CIUDADDESTINO',



	 case when len(Driver1Name) > 0 then Driver1Name else 'N/A' end as 'OPERADOR',

     case when len(Tractor) > 0 then Tractor else 'N/A' end as 'TRACTOR',
	(select case when len(trc_licnum) > 0 then trc_licnum else 'N/A' end as trc_licnum from tractorprofile (nolock) where trc_number = Tractor) as 'TRCPLACAS',
     case when len(gpsdesc) > 0 then gpsdesc else 'N/A' end as   'TRCGPSUBICACION',
	 gpsdated  as 'TRCGPSFECHA',
	(select  case when len(trc_gps_latitude)  >0 then trc_gps_latitude /3600.00  else 0 end as trc_gps_latitude from tractorprofile (nolock) where trc_number = Tractor) as 'TRCGPSLAT',
	(select case when len(trc_gps_longitude) > 0 then trc_gps_longitude /3600.00  * -1  else 0 end as trc_gps_longitude  from tractorprofile (nolock) where trc_number = Tractor) as 'TRCGPSLONG'
	
	,


	 case when len(Trailer) > 0 then Trailer else 'N/A' end as 'TRAILER',
	 case when len(trl_licnum)>0 then trl_licnum else 'N/A' end as 'TRLPLACAS',
	 case when len(trl_misc4)>0 then trl_misc4 else 'N/A' end as 'TRLGPSUBICACION',
	  trl.FechaGPS   as 'TRLGPSFECHA',
	 case when len(trl_gps_latitude) > 0 then (trl_gps_latitude /3600.00 ) else 0 end as 'TRLGPSALT',
	 case when len(trl_gps_longitude) > 0 then (trl_gps_longitude /3600.00)*-1 else 0 end as 'TRLGPSLONG',
	 case when len([LoadEmpt]) >0 then [LoadEmpt] else 'N/A' end as 'TRLCARGADOVACIO',
	 case when len([Enganche]) >0 then [Enganche] else 'N/A' end as 'TRLENGACNHE',


	 case  when estatusicon = '   PLN' then 'PLN'  when estatusicon  = 'Drvng' then 'Manejando' else (select name from eventcodetable (nolock) where abbr = estatusicon) end as 'ESTATUS',
	 case when len(Actcomp) > 0 then Actcomp else 'N/A' end as 'COMPANIAACTUAL',
	 case when  len(Actdif) > 0 then cast(Actdif  as decimal(8,2) ) else 'N/A' end as HRSENCMPACTUAL,

	 ProxCita as 'PROXCITA',
	 (select case when len(name) >0 then name else 'N/A' end as name from eventcodetable where abbr = Proxevent) as  'PROXEVENTO',
	 case when len(Proxcomp) >0 then Proxcomp else 'N/A' end as  'PROXCOMP',
	 case when len(Elogist) >0 then Elogist else 'N/A' end as 'PORRECORRER',
	 isnull(ETAPC,'1900-01-01')  as 'FECHAETA',
	 case when len(ETADIF) > 0 then cast(ETADif as decimal(8,2) ) else 0 end as 'TARDE-TEMPRANO'
	
	 
	
	
    from [OperationsInboundView_TDR]    
	left join OperationsTrailerView_TDR trl  on trl_number = Trailer
	left join company sh on sh.cmp_id = shipper
	left join company co on co.cmp_id = consignee

	where billto = @Customer and ((select cmp_misc8 from company where cmp_id = @Customer) = @token)
	and DispStatus in (select * from @statustable)
	FOR XML  PATH('ORDEN'), ROOT('ORDENES') 

GO
