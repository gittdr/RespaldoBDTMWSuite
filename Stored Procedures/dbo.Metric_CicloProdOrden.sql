SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_CicloProdOrden] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	--@numerador Varchar(255) = 'IN',  --     IN,OUT
    @Modo varchar(20) = 'Ordenes',
    @Proceso varchar(20)  = '***Todos***' ,   --MEX,QRO
    @Cliente varchar(20) = '***Todos***'
 
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Detalle,2:Cliente


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
     -- Set  @Clientes  = ',' + ISNULL(@Clientes,'') + ','

    declare @diashla int
    declare @diashld int
    declare @diasprn int


	-- Creación de la tabla temporal

	CREATE TABLE #Resumencvo( Estatus varchar(40), Orders int ,Revenue float,lag  float) 
   
	-- Carga de la tabla temporal 
--OPCION PARA TRAER DATOS DE UN SOLO CLIENTE.
if @cliente <> '***TODOS***'

 BEGIN



	execute tmwsuite.dbo.d_orders_sinpaper_sp  
	 @ps_date = 'start', @ps_status = 'AVL', @ps_dispstatus = '', 
	@ps_billto =  @cliente , @ps_shipper = '%', @ps_consignee = '%', @ps_orderedby = '%', 
	@pdtm_shipdate1 = {ts '1950-01-01 00:00:00.000'}, @pdtm_shipdate2 = {ts '2049-12-31 23:59:00.000'}, 
	@pdtm_deldate1 = {ts '1950-01-01 00:00:00.000'}, @pdtm_deldate2 = {ts '2049-12-31 23:59:00.000'}, @ps_rev1 = '%',
	 @ps_rev2 = '%', @ps_rev3 = '%', @ps_rev4 = '%', @ps_bookedrev1 = '%', @pdtm_schearliest_date1 = {ts '1950-01-01 00:00:00.000'}, 
	@pdtm_schearliest_date2 = {ts '2049-12-31 23:59:00.000'}, @ps_ord_status = 'UNK', @ps_PwrkMarkedYesIni = 'ALL', @ps_paperworkfilter = 'N/A', 
	@ps_bookedby='%', @ps_ordersource='%',@ps_reftable='none',@ps_reftype='UNK',@ps_refnumber='',@ps_othertype1='%', @ps_othertype2='%',@ps_othertype3='%',
	@ps_othertype4='%', @ps_cmpinvtypes='%', @ord_invoice_effectivedate1={ts '1950-01-01 00:00:00.000'}, @ord_invoice_effectivedate2={ts '2049-12-31 23:59:00.000'}

insert into #Resumencvo

	select '01.AVL' ,count(*) ,sum(ord_totalcharge), avg(datediff(dd,ord_bookdate,getdate()))  from tmwsuite.dbo.orderheader where ord_status = 'AVL' and ord_billto = @cliente
     and datediff(dd,ord_startdate,getdate()) >= 0
	union
	select '02.PLN', count(*),sum(ord_totalcharge),avg(datediff(dd,ord_bookdate,getdate()))   from tmwsuite.dbo.orderheader where ord_status = 'PLN'  and ord_billto = @cliente
	union
	select '03.STD',count(*),sum(ord_totalcharge), avg(datediff(dd,ord_startdate,getdate()))   from tmwsuite.dbo.orderheader where ord_status = 'STD' and ord_billto = @cliente
	union
	select '04.NO POD' ,cantidad,monto, horaspromedio from tmwsuite.dbo.paperworkcount where tipo = 'Sin Paper'
	union
	select '05.RDY 2 INV',cantidad,monto, horaspromedio  from tmwsuite.dbo.paperworkcount where tipo = 'Con Paper'
	union
	select '06.FACT HLD', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' and ord_hdrnumber in 
    (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'HLD' and ivh_invoicenumber not like 'S%' )  and ord_billto = @cliente   and ord_invoicestatus = 'PPD'

	union
	select '07.FACT HLA', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' and ord_hdrnumber in 
    (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'HLA' and ivh_invoicenumber not like 'S%' ) and ord_billto = @cliente
	union
	select '08.FACT PRN', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP'  and ord_invoicestatus = 'PPD'  and ord_hdrnumber in 
    (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'PRN' and ivh_invoicenumber not like 'S%' ) and ord_billto = @cliente


/*
---ordenes marcadas como no pod.
update #Resumencvo set  Orders = Orders + (select count(ord_hdrnumber) from invoicedetail where ivh_invoicestatus = 'NOPOD' and ivh_billto = @cliente),
Revenue = Revenue + (select sum(ivh_totalcharge) from invoicedetail where ivh_invoicestatus = 'NOPOD' and ivh_billto = @cliente)
where Estatus = '04.NO POD'  
*/



--Cargamos la variable con los dias transcurridos en el status
  select @diashld = (SELECT   avg(datediff(dd,ivh_billdate,getdate()) ) FROM        invoiceheader
                    WHERE  (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP')  and ord_billto = @cliente  and ord_invoicestatus = 'PPD' )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'HLD'))))
                           

  select @diashla = (SELECT   avg(datediff(dd,updated_dt,getdate()) ) FROM         expedite_audit_tbl
                    WHERE     (update_note LIKE '%-> HLA%') AND (activity = 'InvoiceHeader update') AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP') and ord_billto = @cliente )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'HLA'))))

  select @diasprn = (SELECT   avg(datediff(dd,ivh_printdate,getdate()) ) FROM        invoiceheader
                    WHERE  (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP') and ord_billto = @cliente  )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'PRN'))))


     

---hacemos el update de los dias transcurridos en el status.
 update #Resumencvo set lag= @diashld where estatus = '06.FACT HLD'
 update #Resumencvo set lag= @diashla where estatus = '07.FACT HLA'
 update #Resumencvo set lag= @diasprn where estatus = '08.FACT PRN'


 END

ELSE 

--OPCION PARA TRAER DATOS DE TODOS LOS CLIENTES
 
 BEGIN

	execute tmwsuite.dbo.d_orders_sinpaper_sp  
	 @ps_date = 'start', @ps_status = 'AVL', @ps_dispstatus = '', 
	@ps_billto = '' , @ps_shipper = '%', @ps_consignee = '%', @ps_orderedby = '%', 
	@pdtm_shipdate1 = {ts '1950-01-01 00:00:00.000'}, @pdtm_shipdate2 = {ts '2049-12-31 23:59:00.000'}, 
	@pdtm_deldate1 = {ts '1950-01-01 00:00:00.000'}, @pdtm_deldate2 = {ts '2049-12-31 23:59:00.000'}, @ps_rev1 = '%',
	 @ps_rev2 = '%', @ps_rev3 = '%', @ps_rev4 = '%', @ps_bookedrev1 = '%', @pdtm_schearliest_date1 = {ts '1950-01-01 00:00:00.000'}, 
	@pdtm_schearliest_date2 = {ts '2049-12-31 23:59:00.000'}, @ps_ord_status = 'UNK', @ps_PwrkMarkedYesIni = 'ALL', @ps_paperworkfilter = 'N/A', 
	@ps_bookedby='%', @ps_ordersource='%',@ps_reftable='none',@ps_reftype='UNK',@ps_refnumber='',@ps_othertype1='%', @ps_othertype2='%',@ps_othertype3='%',
	@ps_othertype4='%', @ps_cmpinvtypes='%', @ord_invoice_effectivedate1={ts '1950-01-01 00:00:00.000'}, @ord_invoice_effectivedate2={ts '2049-12-31 23:59:00.000'}

insert into #Resumencvo

	select '01.AVL',count(*),sum(ord_totalcharge), avg(datediff(dd,ord_bookdate,getdate()))   from tmwsuite.dbo.orderheader where ord_status = 'AVL' 
    and datediff(dd,ord_startdate,getdate()) >= 0
	union
	select '02.PLN', count(*),sum(ord_totalcharge),avg(datediff(dd,ord_bookdate,getdate()))   from tmwsuite.dbo.orderheader where ord_status = 'PLN'  
	union
	select '03.STD',count(*),sum(ord_totalcharge), avg(datediff(dd,ord_startdate,getdate()))  from tmwsuite.dbo.orderheader where ord_status = 'STD'  
	union
	select '04.NO POD' ,cantidad,monto,horaspromedio from tmwsuite.dbo.paperworkcount where tipo = 'Sin Paper'
	union
	select '05.RDY 2 INV',cantidad,monto,horaspromedio from tmwsuite.dbo.paperworkcount where tipo = 'Con Paper'
	union
	select '06.FACT HLD', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP'  and ord_invoicestatus = 'PPD' and ord_hdrnumber in (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'HLD' and ivh_invoicenumber not like 'S%' )
   
	union
	select '07.FACT HLA', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD'  and ord_hdrnumber in (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'HLA' and ivh_invoicenumber not like 'S%' ) 
	union
	select '08.FACT PRN', count(*),sum(ord_totalcharge), 0  from tmwsuite.dbo.orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD'  and ord_hdrnumber in (select ord_hdrnumber from tmwsuite.dbo.invoiceheader where ivh_invoicestatus = 'PRN' and ivh_invoicenumber not like 'S%' ) 
  


/*
---ordenes marcadas como no pod.
update #Resumencvo set  Orders = Orders + (select count(ord_hdrnumber) from invoicedetail where ivh_remakr= 'NOPOD'),
Revenue = Revenue + (select sum(ivh_totalcharge) from invoicedetail where ivh_invoicestatus = 'NOPOD')
where Estatus = '04.NO POD' 
*/



--Cargamos la variable con los dias transcurridos en el status
  select @diashld = (SELECT   avg(datediff(dd,ivh_billdate,getdate()) ) FROM        invoiceheader
                    WHERE  (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP') and ord_invoicestatus = 'PPD' )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'HLD'))))


  select @diashla = (SELECT   avg(datediff(dd,ivh_billdate,getdate()) ) FROM        invoiceheader
                    WHERE  (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP') )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'HLA'))))


  select @diasprn = (SELECT   avg(datediff(dd,ivh_printdate,getdate()) ) FROM        invoiceheader
                    WHERE  (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          orderheader
                            WHERE      (ord_status = 'CMP') )) AND (ord_hdrnumber IN
                          (SELECT     ord_hdrnumber
                            FROM          invoiceheader
                            WHERE      (ivh_invoicestatus = 'PRN'))))



---hacemos el update de los dias transcurridos en el status.
 update #Resumencvo set lag= @diashld where estatus = '06.FACT HLD'
 update #Resumencvo set lag= @diashla where estatus = '07.FACT HLA'
 update #Resumencvo set lag= @diasprn where estatus = '08.FACT PRN'



END








-- Asignar valores a variable de numerador, denominador y resultado de la metrica


--CASO PARA TODOS LOS PROCESOS--------------------------------------------------------------

if @modo = 'Ordenes' and @Proceso = '***TODOS***'
 BEGIN
    SELECT @ThisCount = (Select  sum(Orders) from #Resumencvo)
 END

if @modo = 'Revenue' and @Proceso = '***TODOS***'
BEGIN
   SELECT @ThisCount = (Select sum(Revenue) from #Resumencvo)
END

if @Modo = 'Lag' and @Proceso = '***TODOS***'
BEGIN
  SELECT @ThisCount = (Select avg(lag) from #Resumencvo)
END


--CASO PARA UN SOLO PROCESO EN ESPECIFICO----------------------------------------------------

if @modo = 'Ordenes' and @Proceso <> '***TODOS***'
 BEGIN
    SELECT @ThisCount = (Select  sum(Orders) from #Resumencvo
    where Estatus like @Proceso)
 END

if @modo = 'Revenue' and @Proceso <> '***TODOS***'
BEGIN
   SELECT @ThisCount = (Select sum(Revenue) from #Resumencvo
    where Estatus like @Proceso)
END

if @Modo = 'Lag' and @Proceso <> '***TODOS***'
BEGIN
  SELECT @ThisCount = (Select avg(lag) from #Resumencvo
  where Estatus like @Proceso)
END



    SELECT @ThisTotal =  1
    --CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


----DETALLES-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Detalle a Nivel de  Insumo

	IF (@ShowDetail=1)  and @Proceso = '***TODOS***'
	BEGIN
       select 
       Estatus,
       Orders,
        '$'+dbo.fnc_tmwRN_Formatnumbers(Revenue,2) as Revenue,
       Lag
        from  #Resumencvo

	END


	IF (@ShowDetail=1)  and @Proceso = '01.AVL'
	BEGIN

		select  ord_billto as Cliente ,ord_hdrnumber as Orden , 
         '$'+dbo.fnc_tmwRN_Formatnumbers(ord_totalcharge,2) as Revenue,
ord_bookedby as IngresadoPor, ord_bookdate as BookDate, ord_startdate as FechaInicio,        
        datediff(dd,ord_bookdate,ord_startdate) as Book2Start, datediff(dd,getdate(),ord_startdate)  as Start2Day , datediff(dd,ord_bookdate,getdate())  as Lag,
		year(ord_bookdate)  as Anio,
		Semana =  casT(year(ord_bookdate) as varchar) +'|'+ case when len(cast(datepart (ww,ord_bookdate) as varchar)) = 1 then '0' + (cast(datepart (ww,ord_bookdate) as varchar))  else
		(cast(datepart (ww,ord_bookdate) as varchar)) end
		from tmwsuite.dbo.orderheader 
		where ord_status = 'AVL'
        and datediff(dd,ord_startdate,getdate()) >= 0
        order by Start2Day asc

	END



	IF (@ShowDetail=2)  and @Proceso = '01.AVL'
	BEGIN
            select  ord_billto as Cliente ,
            count(ord_hdrnumber) as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ord_totalcharge),2) as Revenue,
          avg(datediff(dd,ord_bookdate,getdate())) as AvlLag
         
		from tmwsuite.dbo.orderheader 
		where ord_status = 'AVL'
         and datediff(dd,ord_bookdate,getdate()) <= 0
        group by ord_billto 
        order by Avllag desc


	END


	IF (@ShowDetail=2)  and @Proceso = '***TODOS***'
	BEGIN
            select  ord_billto as Cliente ,
            count(ord_hdrnumber) as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ord_totalcharge),2) as Revenue,
		--sum(ord_totalcharge) as Revenue,
          avg(datediff(dd,ord_bookdate,getdate())) as AvlLag
         
		from tmwsuite.dbo.orderheader 
		where 
        datediff(dd,ord_bookdate,getdate()) <= 0
        group by ord_billto 
    


	END





----------------------------------------------------------------------------------------------

	IF (@ShowDetail=1)  and @Proceso = '02.PLN'
	BEGIN
        select  ord_billto as Cliente ,ord_hdrnumber as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(ord_totalcharge,2) as Revenue,
        ord_bookdate as BookDate, ord_bookedby as IngresadoPor,ord_startdate as FechaInicio, datediff(dd,ord_bookdate,getdate())  as Lag,
		year(ord_bookdate)  as Anio,
		Semana =  casT(year(ord_bookdate) as varchar) +'|'+ case when len(cast(datepart (ww,ord_bookdate) as varchar)) = 1 then '0' + (cast(datepart (ww,ord_bookdate) as varchar))  else
		(cast(datepart (ww,ord_bookdate) as varchar)) end
		from tmwsuite.dbo.orderheader 
		where ord_status = 'PLN'
        order by Lag desc
   
	END

	IF (@ShowDetail=2)  and @Proceso = '02.PLN'
	BEGIN
            select ord_billto as Cliente ,
            count(ord_hdrnumber) as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ord_totalcharge),2) as Revenue,
          avg(datediff(dd,ord_bookdate,getdate())) as PlnLag
         
		from tmwsuite.dbo.orderheader 
		where ord_status = 'PLN'
        group by ord_billto 
        order by Plnlag desc


	END




---------------------------------------------------------------------------------

	


	IF (@ShowDetail=1)  and @Proceso = '03.STD'
	BEGIN
            select  ord_billto as Cliente ,ord_hdrnumber as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(ord_totalcharge,2) as Revenue,
         ord_bookdate as BookDate, ord_bookedby as IngresadoPor,ord_startdate as FechaInicio, 
        ord_completiondate as FechaFin,
        datediff(dd,getdate(),ord_completiondate) as EndtoDate,
        datediff(dd,ord_startdate,getdate()) as Lag,
		year(ord_bookdate)  as Anio,
		Semana =  casT(year(ord_bookdate) as varchar) +'|'+ case when len(cast(datepart (ww,ord_bookdate) as varchar)) = 1 then '0' + (cast(datepart (ww,ord_bookdate) as varchar))  else
		(cast(datepart (ww,ord_bookdate) as varchar)) end
		from tmwsuite.dbo.orderheader 
		where ord_status = 'STD'
        order by EndToDate asc

	END


	IF (@ShowDetail=2)  and @Proceso = '03.STD'
	BEGIN
            select  ord_billto as Cliente ,
            count(ord_hdrnumber) as Orden , 
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ord_totalcharge),2) as Revenue,
          avg(datediff(dd,ord_startdate,getdate())) as StartLag
         
		from tmwsuite.dbo.orderheader 
		where ord_status = 'STD'
        group by ord_billto 
        order by Startlag desc


	END



---ORDENES SIN PODS-------------------------------------------------------------------------------------------------------------------------------	

	
	IF (@ShowDetail=1)  and @Proceso = '04.NO POD'
	BEGIN

     select 
             Cliente,
             Orden,
             FechaFin,
             Lag,
         
           '$'+dbo.fnc_tmwRN_Formatnumbers(Revenue,2) AS Revenue
      from  paperworkcountdetail
       where Evidencias = 'No'


  Order by Lag desc

    END


	IF (@ShowDetail=2)  and @Proceso = '04.NO POD'
	BEGIN
       select 
             Cliente,
             count(Orden) as Ordenes,
             avg(Lag) AS Lag,
         
           '$'+dbo.fnc_tmwRN_Formatnumbers(sum(Revenue),2)  AS Revenue
      from  paperworkcountdetail
      where Evidencias = 'No'
            group by cliente
        


       Order by Lag desc


	END


---ORDENES listas para facturar-------------------------------------------------------------------------------------------------------------------------------

	IF (@ShowDetail=1)  and @Proceso = '05.RDY 2 INV'
	BEGIN
       select 
             Cliente,
             Orden,
             FechaFin,
             Lag,
         
           '$'+dbo.fnc_tmwRN_Formatnumbers(Revenue,2)  AS Revenue
      from  paperworkcountdetail
      where Evidencias = 'Yes'
         Order by Lag desc

	END



	IF (@ShowDetail=2)  and @Proceso = '05.RDY 2 INV'
	BEGIN
       select 
             Cliente,
             count(Orden) AS Ordenes,
             avg(Lag) as Lag,
         
           '$'+dbo.fnc_tmwRN_Formatnumbers(sum(Revenue),2)  AS Revenue
      from  paperworkcountdetail
      where Evidencias = 'Yes'
      GROUP BY CLIENTE
      ORDER BY LAG desc
  

	END

	----FACTURAS EN ESTATUS HLD---------------------------------------------------------------------------------------------------------------------------

	IF (@ShowDetail=1)  and @Proceso = '06.FACT HLD'
	BEGIN 





        SELECT    ivh_billto as Cliente, 
         ord_hdrnumber as Orden ,
		ivh_user_id1 as Usuario, 
        '$'+dbo.fnc_tmwRN_Formatnumbers(ivh_totalcharge,2) as Revenue,
        ivh_billdate as FechaHLD,
        datediff(dd,ivh_billdate,getdate())  as Lag

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP'  and ord_invoicestatus = 'PPD' ))
       
         and
        (ivh_invoicestatus  = 'HLD' and ivh_invoicenumber not like 'S%')
        order by datediff(dd,ivh_billdate,getdate())  desc

	

	END


		IF (@ShowDetail=2)  and @Proceso =  '06.FACT HLD'
    BEGIN	
 

        SELECT     ivh_billto as Cliente, 

        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ivh_totalcharge),2) as Revenue,
     
        avg(datediff(dd,ivh_billdate,getdate()))  as Lag,
		count(ord_hdrnumber) as Ordenes

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' ))
         and
        (ivh_invoicestatus  = 'HLD' and ivh_invoicenumber not like 'S%')
        group by ivh_billto
         
		order by  avg(datediff(dd,ivh_billdate,getdate()))  desc

	

 

	END





---FACTURAS EN ESTATUS HLA ---------------------------------------------------------------------------------------------------------------------------

	IF (@ShowDetail=1)  and @Proceso =  '07.FACT HLA'
	BEGIN
           SELECT     ivh_billto as Cliente, 
         ord_hdrnumber as Orden ,
		ivh_user_id1 as Usuario, 
        '$'+dbo.fnc_tmwRN_Formatnumbers(ivh_totalcharge,2) as Revenue,
        ivh_billdate  as toHLA,
        datediff(dd,ivh_billdate,getdate()) as Lag

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' ))
         and
        (ivh_invoicestatus  = 'HLA' and ivh_invoicenumber not like 'S%')
  
        order by  datediff(dd,ivh_billdate,getdate())  desc
 


	END


		IF (@ShowDetail=2)  and @Proceso =  '07.FACT HLA'
	BEGIN
        SELECT    ivh_billto as Cliente, 
         count(ord_hdrnumber) as Ordenes ,
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ivh_totalcharge),2) as Revenue,
        avg((datediff(dd,ivh_billdate,getdate())))  as Lag

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' ))
         and
        (ivh_invoicestatus  = 'HLA' and ivh_invoicenumber not like 'S%')
       group by ivh_billto 
       order by lag desc
      
      

	END


-----FACTURAS EN ESTATUS PRN-------------------------------------------------------------------------------------------------------------	

	IF (@ShowDetail=1)  and @Proceso =  '08.FACT PRN'
	BEGIN
        SELECT    ivh_billto as Cliente, 
         ord_hdrnumber as Orden ,
		ivh_user_id1 as Usuario, 
        '$'+dbo.fnc_tmwRN_Formatnumbers(ivh_totalcharge,2) as Revenue,
        ivh_printdate as FechaPRN,
        datediff(dd,ivh_printdate,getdate())  as Lag

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' ))
         and
        (ivh_invoicestatus  = 'PRN' and ivh_invoicenumber not like 'S%')
        order by datediff(dd,ivh_printdate,getdate()) desc
 

	END



		IF (@ShowDetail=2)  and @Proceso =  '08.FACT PRN'
	BEGIN
        SELECT     ivh_billto as Cliente, 
         count(ord_hdrnumber) as Ordenes ,
        '$'+dbo.fnc_tmwRN_Formatnumbers(sum(ivh_totalcharge),2) as Revenue,
        avg((datediff(dd,ivh_printdate,getdate())))  as Lag

        FROM      tmwsuite.dbo.invoiceheader
		WHERE    
        (ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_invoicestatus = 'PPD' ))
         and
        (ivh_invoicestatus  = 'PRN' and ivh_invoicenumber not like 'S%')
       group by ivh_billto 
       order by lag desc

	END



	
GO
