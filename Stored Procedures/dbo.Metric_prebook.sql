SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************
Creada por Emilio Olvera.
Revisado por: Emilio Olvera Yañez y Carlos Salvador Rodriguez J
Fecha revision: 3 Junio 2015
Version 4.0

Cuenta con revisón de matematica de calculo en base a Hoshin 2015.

Descripcion matematica Hoshin
Mide el prebook.
Mide la demanda vs la capacidad en un periodo futuro (Capacidad futura/ Demanda futura)

En la version 4.0 se agrega la posibilidad de en los parametros filtrar por Sucursal.

This Count: ordenes que inician mañana
This Total: operadores que tendremos disponibles mañana para trabajar + ordenes que se asiganaron y ya no se contemplan en los operadores disponibles

********************/





CREATE PROCEDURE [dbo].[Metric_prebook] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @SoloSucursalLista varchar(60)  = 'TODOS'     --MEX,QRO,MTE,GDA,LAD
     

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Ordenes,2:Operadores,3:Regiones


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      Set  @SoloSucursalLista = ',' + ISNULL(@SoloSucursalLista,'') + ','


 if  @SoloSucursalLista = ',TODOS,'
   BEGIN
        --NUMERADOR ::   @dateend es la fecha de mañana.   seleccionamos las ordenes que empiecen mañana 
         SELECT @ThisCount = (Select count(ord_hdrnumber) from orderheader where datediff(dd,@DateEnd,ord_startdate) = 0) 

		 --DENOMINADOR :: 
		 SELECT @ThisTotal = 
		 (select 

(select count(*) from manpowerprofile where  datediff(dd,@DateEnd,mpp_avl_date) <=  0 and mpp_id <>'TDRTD' and mpp_Status <> 'OUT')
+

(Select  count(*)  from orderheader where datediff(dd,@DateEnd,ord_startdate) = 0  
and ord_driver1 not in  (select mpp_id  from manpowerprofile where  datediff(dd,@DateEnd,mpp_avl_date) <=  0 and mpp_id <>'TDRTD' and mpp_Status <> 'OUT') ) )
      
	  
	  --  SELECT @ThisCount = (Select count(ord_hdrnumber) from orderheader where ord_status in ('AVL','PND') and datediff(dd,getdate(),ord_startdate)  <=1) 
      -- SELECT @ThisTotal = (select count(mpp_id) from manpowerprofile where mpp_Status ='AVL' and  datediff(dd,getdate(),mpp_avl_date) <= 1  and mpp_id <>'TDRTD')
 
	    SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

    
   END 
 ELSE 
 -------------------caso solo para ciertas sucurusales-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


  BEGIN

         --NUMERADOR ::   @dateend es la fecha de mañana.   seleccionamos las ordenes que empiecen mañana 
         SELECT @ThisCount = (Select count(ord_hdrnumber) from orderheader where datediff(dd,@DateEnd,ord_startdate) = 0    and  ( @SoloSucursalLista  =',,' or CHARINDEX(',' + ord_revtype2 + ',',  @SoloSucursalLista ) > 0)) 
		 

		 --DENOMINADOR :: 
		 SELECT @ThisTotal = 
		 (select 

(select count(*) from manpowerprofile where  datediff(dd,@DateEnd,mpp_avl_date) <=  0 and mpp_id <>'TDRTD' and mpp_Status <> 'OUT' 
and  ( @SoloSucursalLista  =',,' or CHARINDEX(',' + (select cmp_revtype2 from company where cmp_id = mpp_avl_cmp_id)+ ',',  @SoloSucursalLista ) > 0) )
+

(Select  count(*)  from orderheader where datediff(dd,@DateEnd,ord_startdate) = 0  and  ( @SoloSucursalLista  =',,' or CHARINDEX(',' + ord_revtype2 + ',',  @SoloSucursalLista ) > 0)
and ord_driver1 not in  (select mpp_id  from manpowerprofile where  datediff(dd,@DateEnd,mpp_avl_date) <=  0 and mpp_id <>'TDRTD' and mpp_Status <> 'OUT'
and  ( @SoloSucursalLista  =',,' or CHARINDEX(',' + (select cmp_revtype2 from company where cmp_id = mpp_avl_cmp_id)+ ',',  @SoloSucursalLista ) > 0) 
) ) )
      
	  
	  --  SELECT @ThisCount = (Select count(ord_hdrnumber) from orderheader where ord_status in ('AVL','PND') and datediff(dd,getdate(),ord_startdate)  <=1) 
      -- SELECT @ThisTotal = (select count(mpp_id) from manpowerprofile where mpp_Status ='AVL' and  datediff(dd,getdate(),mpp_avl_date) <= 1  and mpp_id <>'TDRTD')
 
	    SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


  END


-- Asignar valores a variable de numerador, denominador y resultado de la metrica



--Detalles a nivel orden
   	IF (@ShowDetail=1) 
	BEGIN
       (Select 
        ord_hdrnumber as orden
        ,ord_Status as Status
        ,ord_billto as Cliente
        ,ord_shipper +'-'+ord_consignee as [Origen-Destino]
        ,ord_startdate
           from orderheader where ord_status in ('AVL','PND') and datediff(dd,getdate(),ord_startdate) <=1) 
        order by ord_startdate
    END

--Detalles a nivel operador
	IF (@ShowDetail=2) 
	BEGIN
	   (select mpp_id, mpp_firstname+''+mpp_lastname as Operador,mpp_avl_date as FechaDispo, mpp_avl_cmp_id as CompDispo  from manpowerprofile where mpp_Status ='AVL' and  datediff(dd,getdate(),mpp_avl_date) <= 1 and mpp_id <>'TDRTD'  )    
       order by mpp_Avl_date
	END

--Detales a nivel region
   	IF (@ShowDetail=3) 
	BEGIN

       declare  @orden table (Region varchar(20), Ordenes int)
       declare  @operador  table (Region varchar(20),Operadores int)
       declare  @operador2  table (Region2 varchar(20),Ordenes int,Operadores2 int)
       declare  @total  table (Region varchar(20),Ordenes int, Operadores int)


    ----ORDENES---------------------------------------------------------------------------------------------------------------------   
       insert into @orden

       Select 
        (select cty_region1 from  city where  cty_code  = (select cmp_city from company where ord_shipper = cmp_id)) as Region
        ,count(ord_hdrnumber) as Ordenes
           from orderheader where ord_status in ('AVL','PND') and datediff(dd,getdate(),ord_startdate) <=1 
           group by  ord_shipper
   
    ---ACTUALIZAR EL TOTAL
       insert into  @total
        select 
         Region
         ,sum(Ordenes) as Ordenes
         ,0
         from @orden
        group by Region

    ----OPERADOR-----------------------------------------------------------------------------------------------------------------------  
      insert into @operador

           Select 
        (select cty_region1 from  city where  cty_code  = (select cmp_city from company where  mpp_avl_cmp_id = cmp_id)) as Region
        ,count(mpp_id) as Operadores
        from manpowerprofile where mpp_Status ='AVL' and  datediff(dd,getdate(),mpp_avl_date) <= 1 and mpp_id <>'TDRTD'   
        group by  mpp_avl_cmp_id

      ---ACTUALIZAR EL OP2
       insert into  @operador2
        select 
         Region
         ,0
         ,sum(Operadores) 
         from @operador
        group by Region

    ----TOTALES-----------------------------------------------------------------------------------------------------------------------  
       update @total set Operadores = (select Operadores2 from @Operador2 a where region2 = region)

       select Region,Ordenes,Operadores, dbo.fnc_TMWRN_FormatNumbers(100*(cast(Ordenes as float)/cast(Operadores as float) ),2)+ '%' as Prebook from @total   

    END





GO
