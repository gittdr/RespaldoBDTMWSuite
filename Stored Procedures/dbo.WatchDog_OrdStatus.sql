SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrdStatus] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogOrdStatus',
	@WatchName varchar(255) = 'OrdStatus',
	@ThresholdFieldName varchar(255) = 'OrdStatus',
	@Billto varchar(10) = '',
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


 Unidad = isnull(( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA')
,Caja = isnull(replace(trl_id,'UNKNOWN','NA'),'NA')
,DestinoFinal = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
,ProximoDestino = 
	cast(stp_mfh_sequence as varchar(2)) + '/'   +    (select cast(count(stp_mfh_sequence)  as varchar(2) ) from  stops sto where  sto.mov_number = stops.mov_number)
       
			  +' ' +

		(select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) where company.cmp_id = stops.cmp_id)


,HoradeLlegada = stp_arrivaldate
,Evento  = case when stp_type  = 'PUP' then 'Carga'  when stp_type  ='DRP' then 'Descarga' else stp_type end


 ,ETA =

		 isnull(cast( stp_rpt_miles  as varchar(10)),'')  + ' Kms        ----------------'  
		 +   (case when  isnull(cast(stp_est_drv_time as varchar(10)),'') < 60 then    isnull(cast(stp_est_drv_time as varchar(10)),'')  + ' Minutos de Manejo'
		 else isnull(cast(stp_est_drv_time/60 as varchar(10)),'') + ' Hora(s) de Manejo'   end) + '---------------' + 'ETA: ' + isnull(cast(stp_eta as varchar(20)),'')  
		
,Ubicacion = isnull((select cast(trc_gps_date as varchar(20)) + ' ' + trc_gps_desc from tractorprofile (nolock) where trc_number = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)),'NA')
	


into #TempResults
from stops 


where stops.lgh_number in (select lgh_number from legheader_active  nolock where lgh_outstatus in ('PLN','DSP','STD') and ord_billto = @Billto)

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
