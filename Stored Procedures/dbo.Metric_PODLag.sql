SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_PODLag] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @Modo  varchar(20)  = 'SOBREDIAS'                                      --SOBREDIAS,PORRECABAR
     
    --  @noproyecto varchar(255) = ''
       

)

AS
	SET NOCOUNT ON  


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:General,2:Proyecto,3:Terminal,4:Operador,5:AñosPasados



	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #PodLAgt( Orden  varchar(80), Proyecto varchar(50), Terminal varchar(50), Operador varchar(500), Tipo varchar (100), Detalle varchar(500), Fechafinorden datetime, fechaPOD datetime , PODLAG int)
	--Cargamos la tabla temporal con los datos de la consulta de la tabla de litigios

IF @MODO = 'SOBREDIAS'
BEGIN

      INSERT INTO #PODLagt
        select
        [Order Number],
        Proyecto = [Drvtype3] ,
        Terminal = replace(isnull([RevType2 Name],'N/A'),'','N/A'),
        [Driver Name],
        tipo = (select name from  labelfile where labelfile.abbr = vista_evidencias.abbr and labeldefinition = 'paperwork'),
        detalle = head,
        fechaterminoorden = [Delivery Date],
		fecharecepcion = [PaperWork Received Date],
		PODLag =  difdias
        from vista_evidencias 
        where 
        year ([PaperWork Received Date]) = year(@datestart)
        and month ([PaperWork Received Date]) = month(@datestart)
        and day ([PaperWork Received Date])  = day(@datestart)
        and difdias > 10
END

ELSE IF @MODO = 'PORRECABAR'
BEGIN

      INSERT INTO #PODLagt
        select
        [Order Number],
        Proyecto = [Drvtype3] ,
        Terminal = replace(isnull([RevType2 Name],'N/A'),'','N/A'),
        [Driver Name],
        tipo = (select name from  labelfile where labelfile.abbr = vista_evidencias.abbr and labeldefinition = 'paperwork'),
        detalle = head,
        fechaterminoorden = [Delivery Date],
		fecharecepcion = [PaperWork Received Date],
		PODLag =  difdias
        from vista_evidencias 
        where status = 'No Entregadas'
        and [paperwork received date] is null
        order by [delivery date] desc

END


        -- Asignar valores a variable de numerador, denominador y resultado de la metrica

    
        SELECT @ThisCount = (Select  count(Orden) from #PODLagt)
        SELECT @ThisTotal =  CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
        SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


if @modo = 'SOBREDIAS' 
BEGIN
----DETALLE GENERAL-----------------------

	IF (@ShowDetail=1)  

	BEGIN
		Select Orden, Proyecto, Terminal, Operador,Tipo,Fechafinorden, fechaPOD,PODLAG 
        from #PODLagt
  
        order by PODLag desc
      
	END

---DETALLE POR PROYECTO----------------------------------

 	IF (@ShowDetail=2)  

	BEGIN
		Select 
        Proyecto,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
     
        group by Proyecto
       order by PODLag desc
	END


----DETALE POR TERMINAL--------------------------------------------

  	IF (@ShowDetail=3)  

	BEGIN
		Select 
        Terminal,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
        
        group by Terminal
       order by PODLag desc
	END

 ----DETALE POR OPERADOR--------------------------------------------

  	IF (@ShowDetail=4)  

	BEGIN
		Select 
        Operador,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
        
        group by operador
       order by PODLag desc
	END


----DETALE POR años pasados-------------------------------------------

	IF (@ShowDetail=5)  

	BEGIN
		Select Orden, Proyecto, Terminal, Operador,Tipo,Fechafinorden, fechaPOD,PODLAG 
        from #PODLagt
        where year(fechafinorden) < year(getdate())
        order by PODLag desc
      
	END

----*****************************************************************************************
END

else if @modo = 'PORRECABAR'
 
BEGIN
----DETALLE GENERAL-----------------------

	IF (@ShowDetail=1)  

	BEGIN
		Select Orden, Proyecto, Terminal, Operador,Tipo,Fechafinorden,PODLAG 
        from #PODLagt
  
        order by PODLag desc
      
	END

---DETALLE POR PROYECTO----------------------------------

 	IF (@ShowDetail=2)  

	BEGIN
		Select 
        Proyecto,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
     
        group by Proyecto
       order by PODLag desc
	END


----DETALE POR TERMINAL--------------------------------------------

  	IF (@ShowDetail=3)  

	BEGIN
		Select 
        Terminal,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
        
        group by Terminal
       order by PODLag desc
	END

 ----DETALE POR OPERADOR--------------------------------------------

  	IF (@ShowDetail=4)  

	BEGIN
		Select 
        Operador,
        Ordenes  = count(orden),
        PODLAG =  avg(PODLAG)
        from #PODLagt
  
        
        group by operador
       order by PODLag desc
	END


----DETALE POR años pasados-------------------------------------------

	IF (@ShowDetail=5)  

	BEGIN
		Select Orden, Proyecto, Terminal, Operador,Tipo,Fechafinorden,PODLAG 
        from #PODLagt
        where year(fechafinorden) < year(getdate())
        order by PODLag desc
      
	END

------------------------------------------------------------------
END
GO
