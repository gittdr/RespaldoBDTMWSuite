SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_PISAOrdStatus] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogPisaOrdStatus',
	@WatchName varchar(255) = 'KatoenOrdStatus',
	@ThresholdFieldName varchar(255) = 'PisaOrdStatus',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'

)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_NewCarriers
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	    

	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables


select 


 ReferenciaShipment =  isnull((select ord_refnum from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber),'NA')
,Cliente = (select cmp_name from company where stops.cmp_id = company.cmp_id)
,DestinoFinal = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
,Caja = isnull(replace(trl_id,'UNKNOWN','NA'),'NA')
,Unidad = isnull(( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA')
,Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'NA') 
,HoradeLlegada = stp_arrivaldate
,Evento  = case when stp_type  = 'PUP' then 'Carga'  when stp_type  ='DRP' then 'Descarga' else stp_type end
,HoraSalida = stp_departuredate

, EstatusLogistico = 
 case 
 when (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) in ('STD','DSP'))
 then
                       isnull( (select ckc_comment + ' el '+ cast(ckc_date as varchar) from checkcall
                            where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid from ttsusers))
                       and
					   ckc_tractor = (select ord_tractor from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
					   and
					   ckc_number = (select max(ckc_number) from checkcall 
					        where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid from ttsusers))
                       and
					   ckc_tractor = (select ord_tractor from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
					   and
					   ckc_date between (select ord_startdate from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
					    and (select ord_completiondate from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
					  )),'En transito' )
when (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) in ('AVL','PLN')
then
'Viaje planeado para iniciar el: ' + cast( stp_arrivaldate as varchar)
when stp_status ='DNE' then 'Completado'
else '...'
end

 , Ontime =  (case when getdate() >

  (select  stp_schdtearliest from stops r  where stops.stp_number =  r.stp_number
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  t where stops.ord_hdrnumber = t.stp_number and stp_status = 'OPN'))
 then 'Retraso'
 else 'En Tiempo'
 End
 )

,StatusGeneral = case 
   when stp_status ='DNE' then 'Completado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) in ('STD','DSP')) then 'Transito ' +  (select isnull(cast(trc_gps_date as varchar),'') +' | ' + isnull(trc_gps_desc,'')  from tractorprofile where trc_number = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number))
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PLN') then 'Planeado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'AVL') then 'Disponible' 
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PND') then 'Cofirmar orden'
   when  stp_status ='NON' then 'Disponible'  else  stp_status + (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)   end

into #TempResults
from stops 

where stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'PISA' and ord_status  not in ('CAN','MST','PND','PLN','AVL'))
and  datediff(dd,stp_arrivaldate,getdate()) <= 1
and ord_hdrnumber <> '0'
--and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by stp_arrivaldate desc
		  
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1

	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End

	Exec (@SQL)

	Set NoCount Off


GO
