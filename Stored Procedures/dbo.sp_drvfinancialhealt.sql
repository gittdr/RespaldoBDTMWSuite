SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 7/23/2019 10.30 pm

Stored proc que trae datos crudos para el analisis de situacion financiera por driver

sentencia prueba 

exec sp_drvfinancialhealt 'ALL', 'ALL', 'PROY'

exec sp_drvfinancialhealt 'ALL', 'ALL', 'CONCEP'

exec sp_drvfinancialhealt 'ELIRO', 'ALL', 'DRV'
*/

CREATE proc [dbo].[sp_drvfinancialhealt] (@driver varchar(20) ,@mode varchar(20), @scope varchar(20) = null )


as

declare @standard table (driver varchar(20), clasif varchar(20), sdm_itemcode varchar(10), issuedate datetime, std_description varchar(max), deducsemana float, porpagar float, saldoini float,
pagado float, pctavance float, std_issueddate datetime, sueldoavg float)

if @scope is null
begin
 set @scope  ='DRV'
end



if (@scope ='DRV')
	begin

	insert into @standard

	select 
	asgn_id,
	case when sdm_itemcode in ('IMSS','ISPT') then 'TAX' 
	      when sdm_itemcode in ('OPNVO','SBEMAS','AGNALD','VACAC','PRIMVA','BPOMCE','BONOAS','BRECLU','BONO','AGUINA','AGNALD','VACAS','ISRAGU','COMPTE','COMPAT')
		  or  std_description like ('Sueld%')  then 'PERCEP'
		 when std_startbalance > 0 then 'DEUDA'
		 when std_description not like 'Sueld%' and  sdm_itemcode not in ('ISPT','IMSS')  and std_startbalance  = 0  then 'PREST'
	end  as clasificacion,
	sdm_itemcode,
	std_issuedate,
	std_description,
	case when sdm_itemcode in 
	(select sdm_itemcode from stdmaster where sdm_deductionterm = 'SCH' and sdm_dedschedule = 'Daily') then std_reductionrate * 7
	when sdm_itemcode = 'PA' then std_reductionrate *  
	(select  avg(pyh_totalcomp) from payheader where asgn_id = @driver and datediff(month,pyh_payperiod,getdate()) <= 12 and pyh_paystatus in ('REL','XFR' ))
	else std_reductionrate end as deducsemana,
	std_balance as porpagar,
	std_startbalance as saldoinicial,
	(std_startbalance - std_balance) as pagado,
	case when std_startbalance  = 0 then 0 else 1- ((std_balance) /  std_startbalance) end as pctavance,
	std_issuedate,

----AVG DE PERPCEPCIONES ULTIMOS 4 MESES-------------------------------------------------------------------------------------------
	
(select avg(percepciones) from(
	   select 
	   pyh_payperiod,
	   sum(pyd_amount) as percepciones
	   from paydetail where asgn_id = @driver  and datediff(month,pyh_payperiod,getdate()) <= 4 
	   and pyd_status in ('REL','XFR' )
       and pyt_itemcode  in (select pyt_itemcode from paytype where pyt_description in
	   (
	    --Percepciones
	    '%Porcentaje del Flete', '%Lavadas',  '%Enlonados',  '%Sueldo semanal',   '%Pago por Km',
        '%Stop Pay',   '%Pago Viaje Fijo',  '%Estancias Cte Carga',   '%Estancias Cte Descarga',   '%Estancias en Patio',
        '%Estancias MTTO',    'Vacaciones',   '% bono capacitación',   '%Pago x Kms D.O',    'Patio Bulkmatic',
        '% Bono diesel',    'Prima Vacacional',   'Pago Op Couch-Pro',   'Aguinaldo',   '%Pago a Permisionario', 
        '%Op. disponible sin unidad',   '%% PTU',   'Aguinaldo'
		))

        and year(pyh_payperiod) < '2049'


group by pyh_payperiod,asgn_id
)as q) as sueldoavg

------------------------------------------------------------------------------------------------------------------


	 from standingdeduction
	 where std_status not in ('CAN','CLD')
	 and asgn_id =  @driver
	 and sdm_itemcode not in ('IMSSRT')
 end



 --Detalle a nivel de Flota ---------------------------------------------------------------------------------------------------------------------------------------
 if (@scope = 'PROY')
  begin

  declare @drivers table (mpp_id varchar(20))
  
  declare @proyhealt   table (driver varchar(20), fleet varchar(20), sueldoavg float, percep float, tax float, prest float, liqcontra float, deuda float, deudatotal float, avancedeuda float, salud float )

  declare @driverhealt table (driver varchar(20), clasif varchar(20), sueldoavg float, deducsemana float, porpagar float, saldoinicial float, pagado float)

  declare @mpp_id varchar(10)
  declare @mpp_name varchar(max)

  if(@driver = 'ALL')
  begin
    insert into @drivers
    select   mpp_id  from manpowerprofile where mpp_status not in  ('OUT','SICT','BAJAA') and mpp_id not in ('UNKNOWN')
   end
  else
  begin
    insert into @drivers
    select   mpp_id  from manpowerprofile where mpp_status not in  ('OUT','SICT','BAJAA') and mpp_id not in ('UNKNOWN')
    and (select name from labelfile where labeldefinition = 'fleet' and abbr =  mpp_fleet) = @driver
  end


 
  declare driverfhealt cursor 
  for 
  --Seleccionamos los valores de la tabla variable
  select * from @drivers

  open driverfhealt
  fetch next from  driverfhealt into @mpp_id

  WHILE @@FETCH_STATUS = 0  
  BEGIN  
   
  insert into @driverhealt

   select
   asgn_id,
   clasificacion,
   avg(sueldoavg),
   sum(deducsemana),
   case when clasificacion = 'DEUDA' then sum(porpagar) else 0 end as PorPagar,
   case when clasificacion = 'DEUDA' then sum(saldoinicial)  else 0 end as SaldoInicial,
   case when clasificacion = 'DEUDA' then sum(pagado)  else 0 end as Pagado
   from
    (
	select 
	asgn_id,
	case when sdm_itemcode in ('IMSS','ISPT') then 'TAX' 
	     when sdm_itemcode in ('OPNVO','SBEMAS','AGNALD','VACAC','PRIMVA','BPOMCE','BONOAS','BRECLU','BONO','AGUINA','AGNALD','VACAS','ISRAGU','COMPTE','COMPE','COMPAT')
		  or  std_description like ('Sueld%')  then 'PERCEP'
		 when std_startbalance > 0 then 'DEUDA'
		 when std_description not like 'Sueld%' and  sdm_itemcode not in ('ISPT','IMSS')  and std_startbalance  = 0  then 'PREST'
	end  as clasificacion,
	sdm_itemcode,
	std_description,

	case when sdm_itemcode in 
	(select sdm_itemcode from stdmaster where sdm_deductionterm = 'SCH' and sdm_dedschedule = 'Daily') then std_reductionrate * 7
	when sdm_itemcode = 'PA' then std_reductionrate *  
	(select  avg(pyh_totalcomp) from payheader where asgn_id = @driver and datediff(month,pyh_payperiod,getdate()) <= 12 and pyh_paystatus in ('REL','XFR' ))
	else std_reductionrate end as deducsemana,

	std_balance as porpagar,
	std_startbalance as saldoinicial,
	(std_startbalance - std_balance) as pagado,
	case when std_startbalance  = 0 then 0 else 1- ((std_balance) /  std_startbalance) end as pctavance,
	std_issuedate,

----AVG DE PERCEPCIONES ULTIMOS 4 MESES-------------------------------------------------------------------------------------------
	
(select avg(percepciones) from(
	   select 
	   pyh_payperiod,
	   sum(pyd_amount) as percepciones
	   from paydetail where asgn_id = @mpp_id  and datediff(month,pyh_payperiod,getdate()) <= 4 
	   and pyd_status in ('REL','XFR' )
       and pyt_itemcode  in (select pyt_itemcode from paytype where pyt_description in
	   (
	    --Percepciones
	    '%Porcentaje del Flete', '%Lavadas',  '%Enlonados',  '%Sueldo semanal',   '%Pago por Km',
        '%Stop Pay',   '%Pago Viaje Fijo',  '%Estancias Cte Carga',   '%Estancias Cte Descarga',   '%Estancias en Patio',
        '%Estancias MTTO',    'Vacaciones',   '% bono capacitación',   '%Pago x Kms D.O',    'Patio Bulkmatic',
        '% Bono diesel',    'Prima Vacacional',   'Pago Op Couch-Pro',   'Aguinaldo',   '%Pago a Permisionario', 
        '%Op. disponible sin unidad',   '%% PTU',   'Aguinaldo'
		))

        and year(pyh_payperiod) < '2049'



group by pyh_payperiod,asgn_id
)as q) as sueldoavg

	 from standingdeduction
	 where std_status not in ('CAN','CLD')
	 and asgn_id =  @mpp_id
	 and sdm_itemcode not in ('IMSSRT')
     ) as fh
	 group by asgn_id, clasificacion


	 insert into @proyhealt  

	 select 
	   @mpp_id,
	   (select name from labelfile where labeldefinition = 'fleet' and abbr =  (select  mpp_fleet from manpowerprofile where mpp_id = @mpp_id)) as fleet,
	   avg(sueldoavg),
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0
	  from @driverhealt

	  update @proyhealt set percep       = isnull((select sum(deducsemana) from @driverhealt where clasif = 'PERCEP' and driver = @mpp_id),0) where driver = @mpp_id
	  update @proyhealt set tax          = isnull((select sum(deducsemana) from @driverhealt where clasif = 'TAX'    and driver = @mpp_id),0) where driver = @mpp_id
	  update @proyhealt set prest        = isnull((select sum(deducsemana) from @driverhealt where clasif = 'PREST'  and driver = @mpp_id),0) where driver = @mpp_id
	   
	  update @proyhealt set deuda        = isnull((select sum(deducsemana) from @driverhealt where clasif = 'DEUDA'  and driver = @mpp_id),0) where driver = @mpp_id
	  update @proyhealt set deudatotal   = isnull((select sum(porpagar   ) from @driverhealt where clasif = 'DEUDA'  and driver = @mpp_id),0) where driver = @mpp_id
	  update @proyhealt set avancedeuda  = isnull((select case when sum(saldoinicial) = 0 then 0 else (sum(pagado) / sum(saldoinicial)) end from @driverhealt where driver = @mpp_id),0)  where driver = @mpp_id
	  
	 
	  delete @driverhealt

	 

	    fetch next from  driverfhealt into @mpp_id
        END  
  
    CLOSE driverfhealt
    DEALLOCATE driverfhealt

	 update @proyhealt set liqcontra    = isnull((select sum(pyd_amount) as liqcontra
	                                     from paydetail where asgn_id =  driver
                                         and pyt_itemcode in ('LIQUI','MN+') 
                                         and pyd_amount > 0 
                                         and  0 =  ( select count(*) from paydetail where pyt_itemcode = 'LIQUI' and asgn_id = driver and pyd_amount = 0 and year(pyh_payperiod) < '2040' and pyd_status = 'REL' and asgn_id = paydetail.asgn_id and year(pyh_payperiod) < '2040')
                                         and pyh_payperiod = (select max(pyh_payperiod) from paydetail  where year(pyh_payperiod) < '2040' and asgn_id = driver and pyd_status = 'REL' and asgn_id = paydetail.asgn_id and year(pyh_payperiod) < '2040')
	 ),0)

declare @semanio varchar(20) = (select max(semanio) from [172.24.16.113].TMW_DWLIVE.dbo.fleetperformance)

  insert into  [172.24.16.113].TMW_DWLIVE.dbo.tts_DrvFinHealth
   
   select
   @semanio,
    driver, fleet, sueldoavg, percep, tax, prest, liqcontra, deuda,deudatotal, avancedeuda,salud,0
    from @proyhealt
	where sueldoavg is not null

	update   [172.24.16.113].TMW_DWLIVE.dbo.tts_DrvFinHealth set salud =  round( 1- (prest+liqcontra+deuda) / (sueldoavg- tax ),2)



	exec [172.24.16.113].TMW_DWLIVE.dbo.sp_fleetperfdriverpay   @semanio,'all','upall'


  end


---------------
If @scope = 'CONCEP'
begin

insert into  [172.24.16.113].TMW_DWLive.dbo.tts_DrvDeudaConcepts

 select 
    (select max(semanio) from [172.24.16.113].TMW_DWLIVE.dbo.fleetperformance),
   sdm_itemcode as item,
   isnull((select sdm_description from stdmaster  where stdmaster.sdm_itemcode =standingdeduction.sdm_itemcode), sdm_itemcode) as Concepto,
   sum(std_balance) as monto,
   sum(std_balance) as porpagar,
   sum(std_startbalance) as saldoinicial,
   sum(std_startbalance - std_balance) as pagado,
   0 as avance,
	(select (select name from labelfile where mpp_fleet =abbr and labeldefinition = 'fleet') from manpowerprofile where mpp_id = asgn_id) as fleet
 from standingdeduction
	 where std_status not in ('CAN','CLD')
	 and sdm_itemcode not in ('IMSSRT')
	 and sdm_itemcode not in ('OPNVO','SBEMAS','AGNALD','VACAC','PRIMVA','BPOMCE','BONOAS','BRECLU','BONO','AGUINA','AGNALD','VACAS','ISRAGU','COMPTE','COMPE')
	 and sdm_itemcode not in ('IMSS','ISPT')
	 and std_description not like 'Sueld%'
	 and std_startbalance > 0
	 and asgn_id not in (select mpp_id from manpowerprofile where mpp_status not in  ('OUT','SICT','BAJAA'))
	 group by asgn_id, standingdeduction.sdm_itemcode 
end
  

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


 if @mode = 'PERCEP' and @scope = 'DRV'
 begin
	   if ( select count(*) from @standard  where clasif = 'PERCEP' ) = 0
	   begin

	   select top 1 driver,'','', '', 0,0,0,0,0,0,sueldoavg from @standard
	   
	 end
	 else
	 begin
	   select  * from @standard
	   where clasif = 'PERCEP'
 
	 end
 end

  if @mode = 'PREST' and @scope = 'DRV'
 begin
   select * from @standard 
   where  clasif = 'PREST'
 end

   if @mode = 'TAX' and @scope = 'DRV'
 begin
   select * from @standard
   where clasif = 'TAX'
 end

   if @mode = 'DEUDA' and @scope = 'DRV'
 begin
   select * from @standard
    where clasif = 'DEUDA'
 end

    if @mode = 'ALL' and @scope = 'DRV'
 begin
	
	select *  from @standard
 end



GO
