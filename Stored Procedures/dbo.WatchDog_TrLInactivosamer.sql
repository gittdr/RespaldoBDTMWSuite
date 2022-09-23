SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_TrLInactivosamer] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogTrlInactAmer',
	@WatchName varchar(255)='TrlAmer',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
    @FiltroNombre varchar(50) = '',
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables





	-- Initialize Temp Table
	

 
            create table #Trlinact (Caja varchar(20), Fechaentrada datetime, fechasalida datetime)
            
            create table #Todisplay (
             Caja varchar(20)
            ,Fechaentrada datetime
            ,FechaLlegadaCliente datetime
            ,ComCargaImpo varchar(200)
            ,FechaUltViaje datetime
            ,FechaLlegadaFrontera  datetime
            ,ComCargaExpo varchar(200)
            ,DiasTranscurridos int
            ,Sello  varchar(100)
            ,Region  varchar(100)
            ,StatusCaja varchar(100) )


if @FiltroNombre = 'nuevas'
begin

Insert into #Trlinact

	
           -- Caja = exp_id
           -- ,Fechaentrada = exp_lastdate
           -- ,Fechasalida  =  exp_expirationdate
   
    select trl_number,trl_startdate,trl_retiredate from trailerprofile where (trl_year) = 2014 and trl_make = 'HYUNDAI' and trl_status = 'USE'

end

if  (@FiltroNombre <> '' and  @FiltroNombre not in ('nuevas','amer'))

begin
			--,Fechaentrada = exp_lastdate jr
            --,Fechasalida  =  exp_expirationdate jr
			Insert into #Trlinact

		    select
            Caja = exp_id
            ,Fechaentrada = exp_expirationdate
            ,Fechasalida  = exp_lastdate 
             
            from expiration where exp_idtype = 'TRL' and exp_code = 'FIAN' and exp_COMPLETED = 'N' --and datediff(dd,exp_lastdate,getdate()) > @Umbralasignacion 
            and exp_id like @FiltroNombre
end

if @FiltroNombre = 'amer' 

begin
			--,Fechaentrada = exp_lastdate
            --,Fechasalida  =  exp_expirationdate
			Insert into #Trlinact
		    select
            Caja = exp_id
            ,Fechaentrada = exp_expirationdate
            ,Fechasalida  = exp_lastdate 
             
            from expiration where exp_idtype = 'TRL' and exp_code = 'FIAN' and exp_COMPLETED = 'N' 
			--and datediff(dd,exp_lastdate,getdate()) > @Umbralasignacion se comentariza atte JR

           
end



if (@FiltroNombre <> ''  and  @FiltroNombre not in ('nuevas','amer') )
 begin


---insertamos solo el valor de la caja y fecha entrada de la tabla #trlinact en la tabla todisplay para despues hacer los respectivos updates----------------------
insert into #Todisplay 

		select  
             Caja
            ,Fechaentrada
            ,FechaLlegadaCliente = null
            ,ComCargaImpo = ''

            ,FechaUltViaje = null
            ,FechaLlegadaFrontera = null
            ,ComCargaExpo =  ''

            ,DiasTranscurridos = 0
            ,Sello = ''
            ,Region =''
            ,StatusCaja = ''
            from #TrlInact
           
---hacemos los updates correspondientes en cada uno de los campos

       --update #Todisplay  set FechaLlegadaCliente = (select min(lgh_startdate)  from legheader where lgh_primary_trailer = caja) asi estaba JR
	   update #Todisplay  set FechaLlegadaCliente = (select max(stp_arrivaldate) from stops where mov_number = (select max(mov_number)  from legheader where lgh_primary_trailer = caja) 
			 and stp_event in ('DRL', 'LUL','HMT') and stp_status = 'DNE')
			 --and ord_hdrnumber > 0
       update #Todisplay  set ComCargaImpo =  replace((select cmp_name from company where cmp_id = (select ord_consignee from orderheader where ord_trailer = caja 
       and  ord_hdrnumber = (select min(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','')

       update #Todisplay  set FechaUltViaje = (select max(lgh_startdate)  from legheader where lgh_primary_trailer = caja)
       update #Todisplay  set FechaLlegadaFrontera = (select max(lgh_enddate)  from legheader where lgh_primary_trailer = caja)
       update #Todisplay  set ComCargaExpo =  replace((select cmp_name from company where cmp_id = (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = (select max(ord_hdrnumber)  
       from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','')

       update #Todisplay  set DiasTranscurridos = datediff(dd,FechaEntrada,getdate())
       update #Todisplay  set Sello = isnull((select  not_text_large from notes where nre_tablekey = 'orderheader' and not_text_large like '%Sello:%' and nre_tablekey in (select max(ord_hdrnumber) from orderheader where ord_trailer = caja)),'')
       update #Todisplay  set Region = (select case when max(trl_next_region1) = 'UNK' then   max(trl_prior_region1) else max(trl_next_region1) end from trailerprofile where trl_number = substring(caja,5,12)) 
       update #Todisplay  set StatusCaja = (select case when trl_status = 'AVL' and  replace((select cmp_name from company where cmp_id = (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = 
            (select max(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','') = '' then 'VACIA' when trl_status = 'AVL' and replace((select cmp_name from company where cmp_id = 
            (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = (select max(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','') <> '' then 'ENTREGADA' 
             when trl_status ='USE' then 'CARGADA' when trl_status ='PLN' then 'PLANEADA' end as trl_status  from trailerprofile where trl_id = caja)


--mostramos el resultado final de la tabla #todisplay

			select * 
			into 
			#TempResultsa
			from #Todisplay 
            order by  datediff(dd,FechaEntrada,getdate()) DESC

	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResultsa'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsa'
	End

	Exec (@SQL)
	Set NoCount Off


	

 end

else  if  @FiltroNombre = 'amer' 

begin


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---insertamos solo el valor de la caja y fecha entrada de la tabla #trlinact en la tabla todisplay para despues hacer los respectivos updates----------------------
insert into #Todisplay 

		select  
             Caja
            ,Fechaentrada
            ,FechaLlegadaCliente = null
            ,ComCargaImpo = ''

            ,FechaUltViaje = null
            ,FechaLlegadaFrontera = null
            ,ComCargaExpo =  ''

            ,DiasTranscurridos = 0
            ,Sello = ''
            ,Region =''
            ,StatusCaja = ''
            from #TrlInact
           
---hacemos los updates correspondientes en cada uno de los campos

       --update #Todisplay  set FechaLlegadaCliente = (select min(lgh_startdate)  from legheader where lgh_primary_trailer = caja) asi estaba JR
	   update #Todisplay  set FechaLlegadaCliente = (select max(stp_arrivaldate) from stops where mov_number = (select max(mov_number)  from legheader where lgh_primary_trailer = caja) 
			and ord_hdrnumber > 0 and stp_event in ('DRL', 'LUL') and stp_status = 'DNE')
       update #Todisplay  set ComCargaImpo =  replace((select cmp_name from company where cmp_id = (select ord_consignee from orderheader where ord_trailer = caja 
       and  ord_hdrnumber = (select max(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','')

       update #Todisplay  set FechaUltViaje = (select max(lgh_startdate)  from legheader where lgh_primary_trailer = caja)
       update #Todisplay  set FechaLlegadaFrontera = (select max(lgh_enddate)  from legheader where lgh_primary_trailer = caja)
       update #Todisplay  set ComCargaExpo =  replace((select cmp_name from company where cmp_id = (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = (select max(ord_hdrnumber)  
       from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','')

       update #Todisplay  set DiasTranscurridos = datediff(dd,FechaEntrada,getdate())
       update #Todisplay  set Sello = isnull((select  not_text_large from notes where nre_tablekey = 'orderheader' and not_text_large like '%Sello:%' and nre_tablekey in (select max(ord_hdrnumber) from orderheader where ord_trailer = caja)),'')
       update #Todisplay  set Region = (select case when max(trl_next_region1) = 'UNK' then   max(trl_prior_region1) else max(trl_next_region1) end from trailerprofile where trl_number = substring(caja,5,12)) 
       update #Todisplay  set StatusCaja = (select case when trl_status = 'AVL' and  replace((select cmp_name from company where cmp_id = (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = 
            (select max(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','') = '' then 'VACIA' when trl_status = 'AVL' and replace((select cmp_name from company where cmp_id = 
            (select ord_shipper from orderheader where ord_trailer = caja and ord_hdrnumber = (select max(ord_hdrnumber)  from orderheader where ord_trailer = caja ))),'TDR NUEVO LAREDO','') <> '' then 'ENTREGADA' 
             when trl_status ='USE' then 'CARGADA' when trl_status ='PLN' then 'PLANEADA' end as trl_status  from trailerprofile where trl_id = caja)


--mostramos el resultado final de la tabla #todisplay

			select 
			caja,
			FechaLlegadaCliente,
			[Ubicada en] = ComCargaImpo,
			FechaUltViaje,
			DiasTranscurridos,
			Region,
			StatusCaja
			into 
			#TempResultsb
			from #Todisplay 
            order by  datediff(dd,FechaEntrada,getdate()) DESC
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResultsb'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsb'
	End

	Exec (@SQL)
	Set NoCount Off



end


else

 begin

	select  

            Caja
            ,Fechaentrada
            ,Fechasalida
            ,DiasTranscurridos = datediff(dd,FechaEntrada,getdate())
            ,Region = (select case when max(trl_next_region1) = 'UNK' then   max(trl_prior_region1) else max(trl_next_region1) end from trailerprofile where trl_number = substring(caja,5,12)) 
            into   	#TempResults
		    from #TrlInact
            order by  datediff(dd,FechaEntrada,getdate()) DESC




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



 end














GO
