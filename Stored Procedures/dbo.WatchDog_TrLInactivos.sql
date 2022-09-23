SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_TrLInactivos] 
(

    @Umbralasignacion float = 1,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='PayDetails',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @SoloFlotaLista varchar(255)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


Set @SoloFlotaLista = ',' + ISNULL(@SoloFlotaLista,'') + ','


	-- Initialize Temp Table
	


            --creamos la tabla temporal que contendra la suma de los remolques uno y dos.
            create table #Trlact (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20),ord_hdrnumber varchar(10), lgh_startdate datetime, lgh_enddate datetime, tipore varchar (20) )
			
             --hacemos el insert de los remolques 1 a la tabla.
             Insert into #Trlact (lgh_Trailer,lgh_startdate,lgh_enddate, ord_hdrnumber, tipore)

		    select distinct substring(RNT.lgh_Trailer1,1,10), (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber), 'Remolque 1'
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_TrailerCache_Final TDF (NOLOCK) on RNT.lgh_Trailer1 = TDF.Trailer_id
			where 
            day(getdate()) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            and month(getdate()) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            and year(getdate()) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)
			AND RNT.lgh_Trailer1 <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TDF.Trailer_DateStart AND RNT.lgh_startdate < TDF.Trailer_DateEnd
            and  (select max(trl_owner) from trailerprofile where trl_number = lgh_trailer1)=  'TDR'

	
             --hacemos el insert de los remolque 2 a la tabla.

			 Insert into #Trlact(lgh_Trailer,lgh_startdate,lgh_enddate, ord_hdrnumber, tipore)
			
            select distinct substring(RNT.lgh_Trailer2,1,10), (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber),'Remolque 2'
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_TrailerCache_Final TDF (NOLOCK) on RNT.lgh_Trailer2 = TDF.Trailer_id
			where 
            day(getdate()) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            and month(getdate()) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            and year(getdate()) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)
			AND RNT.lgh_Trailer2 <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TDF.Trailer_DateStart AND RNT.lgh_startdate < TDF.Trailer_DateEnd
            and  (select max(trl_owner) from trailerprofile where trl_number = lgh_trailer2)=  'TDR'


--/* 

--*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      create table #deno (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), fechaini datetime, stat varchar(50), horas int)


        Insert into #Deno(lgh_Trailer, fleet, div, fechaini)
		    

	            Select 
                distinct substring(replace(replace(trailer_id,',',''),'.',''),1,10)
                ,fleet = (select max(name) from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = trailer_fleet)
			    ,div =   trailer_type4
               ,fechaini = (select max(trl_avail_date) from trailerprofile  where trl_number = trailer_id)

               /*
                case 
                when (select max(lgh_Startdate) from ResNow_Triplets RNT where RNT.lgh_trailer1 = trailer_id) 
               < 
                isnull((select max(lgh_Startdate) from ResNow_Triplets RNTE where RNTE.lgh_trailer2 = trailer_id),dateadd(yy,-100,getdate()))
                then (select max(lgh_Startdate) from ResNow_Triplets RNTA where RNTA.lgh_trailer2 = Trailer_id)
                else (select max(lgh_Startdate) from ResNow_Triplets RNTB where RNTB.lgh_trailer1 = Trailer_id) end
                */

                FROM ResNow_TrailerCache_Final RNTCF (NOLOCK) 

			    Where (trailer_retiredate > getdate() AND trailer_startdate <= getdate())
				AND trailer_id <> 'UNKNOWN'
                and Trailer_fleet <> '17'
                     -- Expiration OUT
                and trailer_id not in ( select exp_id from expiration where exp_code = 'OUT' and exp_idtype='TRL')
				and trailer_id not in ( Select  substring(exp_id ,1,10) FROM expiration WITH (NOLOCK)   WHERE exp_idtype='TRL'  and exp_code not in ('OUT','ICFM','INS')  and exp_completed <> 'Y' and exp_id  in ( select trl_number from trailerprofile where trl_owner = 'TDR')     )
                and trailer_owner = 'TDR'

               update #Deno set stat = case when datediff(hh,fechaini,getdate()) >= 0 then 'Horas Inactivo: ' else  'Por iniciar leg en:' end 
               update #Deno set horas =  case when datediff(hh,fechaini,getdate()) < 1  then  datediff(hh,fechaini,getdate()) * -1 else datediff(hh,fechaini,getdate()) end 

               delete from #deno where lgh_trailer in ( ( select trl_number from trailerprofile where trl_owner <> 'TDR')) 
               delete from #deno where   datediff(hh,fechaini,getdate()) <=  0 



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




		select  

            Remolque = lgh_trailer
           -- ,ini = fechaini
            ,Status = stat
            ,Horas  = horas
            ,Flota = fleet
            ,Division = div
            ,Cmpactual =  ( select max(trl_prior_region1) from  trailerprofile where trl_number = lgh_trailer)
            ,RegionActual = (select max(rgh_name) from regionheader (NOLOCK) where rgh_id =( select max(trl_prior_region1) from  trailerprofile where trl_number = lgh_trailer))
            into   	#TempResults
            From #Deno t  where t.lgh_trailer not in (Select lgh_trailer  From #Trlact)  
            and ( @SoloFlotaLista  =',,' or CHARINDEX(',' + (fleet) + ',', @SoloFlotaLista ) > 0)
            Order by horas desc  
 

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
