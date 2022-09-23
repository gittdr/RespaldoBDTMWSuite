SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****
Autor: Emolvera
Fecha creacion: 26/11/2015
metrica que calcula el margen y el ingreso de proyectos LAAD
*****/

CREATE  PROCEDURE [dbo].[Metric_LADMargenProyecto] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	
	--PARAMETROS PROPIOS DE LA METRICA
	@Modo Varchar(255) = 'Ingreso',     -- INGRESO, MARGEN
    @Regional  varchar(20)  = 'TODAS'   -- TODAS, CDJ, TOL, MAZ, HER, GDLA, MAN, TIJ
)




AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Regional,2:TipoProyecto,3:ProyectoDetalle



	-- Creación de la tabla temporal

	CREATE TABLE #Margproy (Proyecto varchar(30), TipoProyecto varchar(50), Ingreso Float, Gasto Float, FechaInicio datetime, Regional varchar(4))

	-- Carga de la tabla temporal en el  caso  de que el numerador sea salidas de almacen
	

      INSERT INTO #Margproy

           select 
		   Proyecto,
		   TipoProyecto,
		   Ingreso,
		   Gasto,
		   FechaInicio,
		   substring( Proyecto,1,3) as Regional
		   
		   from [172.24.16.113].TDR.dbo.Vista_margenproyecto 
           where
           (fechainicio >= @DateStart ) and  (fechainicio <= dateadd(mi,-1,@DateEnd)) 
    



 
-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    if @modo = 'Ingreso'
	 begin
	     SELECT @ThisCount = (Select sum(Ingreso) from #Margproy  )
         SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
         SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	 end
    
    if @modo = 'Margen'
	 begin
	     SELECT @ThisCount = ( Select  (sum(Ingreso)- sum(gasto))  / sum(Ingreso+ 0.000000001) from #Margproy (nolock))
         SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
         SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	 end
    

    



	
--Detalle a Nivel de Regional

	IF (@ShowDetail=1) 
	BEGIN
	   select Regional,
	   dbo.fnc_TMWRN_FormatNumbers( 100* ((sum(Ingreso) - sum(gasto))  / (sum(Ingreso)+0.000000001)),2) + '%'  as Margen, 
		 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Ingreso) ,2)   as Ingreso,
		 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Gasto) ,2)   as Gasto
		  from  #Margproy
	   group by Regional
	   order by ((sum(Ingreso) - sum(gasto))  / (sum(Ingreso)+000000.1)) desc
	END


		--Detalle a Nivel Tipo de Proyecto

	IF (@ShowDetail=2) 
	BEGIN
	   select TipoProyecto,
	   dbo.fnc_TMWRN_FormatNumbers( 100* ((sum(Ingreso) - sum(gasto))  / (sum(Ingreso)+0.000000001)),0) + '%'  as Margen, 
		 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Ingreso) ,2)   as Ingreso,
		 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Gasto) ,2)   as Gasto
		  from  #Margproy
	   group by TipoProyecto
	   order by ((sum(Ingreso) - sum(gasto))  / (sum(Ingreso)+000000.1)) desc
	END



	--Detalle a Nivel de Proyecto

	IF (@ShowDetail=3) 
	BEGIN
	    
	 
	   select 
	   
	   Regional,
	   Proyecto,
	   TipoProyecto,
	   
	    dbo.fnc_TMWRN_FormatNumbers( 100*((Ingreso - gasto)  / (Ingreso+0.000000001)),2) + '%' as Margen,
		 
	     '$' + dbo.fnc_TMWRN_FormatNumbers((Ingreso) ,2)   as Ingreso,
		 '$' + dbo.fnc_TMWRN_FormatNumbers((Gasto) ,2)   as Gasto,
		 Convert(varchar(10),CONVERT(date,FechaInicio,106),103) as FechaInicio
		   from  #Margproy
		order by ((Ingreso- gasto)  / (Ingreso+0.000000001) ) desc
	
	END

GO
