SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[Metric_PRL] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

	--PARAMETROS PROPIOS DE LA METRICA
    --@Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Proyectos,2:Faltantes,3:Sobrantes,4:Completas


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #PRL
    (Unidad varchar(50),
     TipoUni int,
     Descripcion varchar(500),
     Proyecto varchar(220),
     LLantas int,
     LlantasReg int,
     Diferencia int )

 

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #PRL


     select 

		Unidad = id_unidad,
        TipoUni =    (SELECT   isnull(tdrsilt.dbo.mtto_unidades.tipo_unidad,'')        
          FROM tdrsilt.dbo.mtto_unidades  
          WHERE  tdrsilt.dbo.mtto_unidades.id_unidad =  tdrsilt.dbo.rep_mtto_unidades.id_unidad ),
		Descripcion = descripcion,
		Proyecto =Depto,
		Llantas = [LL Op],
		LlantasReg = (select count(no_economico) from tdrsilt.dbo.reporte_llantas where tdrsilt.dbo.reporte_llantas.id_unidad = tdrsilt.dbo.rep_mtto_unidades.id_unidad),
		Diferencia = [LL Op] -  (select count(no_economico) from tdrsilt.dbo.reporte_llantas where tdrsilt.dbo.reporte_llantas.id_unidad = tdrsilt.dbo.rep_mtto_unidades.id_unidad)

     from  tdrsilt.dbo.rep_mtto_unidades

		 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(LlantasReg) from #PRL)
    SELECT @ThisTotal = (Select sum(Llantas) from #PRL)
   

    --SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de por proyecto



IF (@ShowDetail=1) 
	BEGIN
		Select  
        Proyecto, 
        DebeTener  = sum(Llantas),
        Llantasreg = sum  (LlantasReg), 
        Diferencia = sum(Diferencia * -1),
        PRL =   dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%',

        Trac=  (select case (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') when '0.00%' then '' else (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') end from #PRL tmd  where TipoUni = 1 and #PRL.Proyecto = tmd.Proyecto),
        Rem =  (select case (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') when '0.00%' then '' else (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') end from #PRL tme  where TipoUni = 2 and #PRL.Proyecto = tme.Proyecto),
        Dolly =(select case (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') when '0.00%' then '' else (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') end from #PRL tmdo where TipoUni = 6 and #PRL.Proyecto = tmdo.Proyecto),
        Ther = (select case (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') when '0.00%' then '' else (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') end from #PRL tmdt where TipoUni = 4 and #PRL.Proyecto = tmdt.Proyecto),
        Pipa = (select case (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') when '0.00%' then '' else (dbo.fnc_TMWRN_FormatNumbers( (cast(sum(LlantasReg) as float) / cast(sum(Llantas) as float) *100 ),2) +'%') end from #PRL tmpi where TipoUni = 3 and #PRL.Proyecto = tmpi.Proyecto)

        	From  #PRL

        group by Proyecto 
        order by Proyecto
	END
 


--Detalle a Nivel de Unidades con llantas faltantes


IF (@ShowDetail=2) 
	BEGIN
		Select  
        Unidad, Descripcion, Proyecto, Llantas, LlantasReg, Faltantes =Diferencia
		From  #PRL
        where diferencia > 0
        order by Diferencia DESC

	END



--Detalle a Nivel de Unidades con llantas sobrantes

	IF (@ShowDetail=3) 
	BEGIN
		Select  
            Unidad, Descripcion, Proyecto, Llantas, LlantasReg, Sobrantes = (Diferencia * -1)
		From  #PRL
        where diferencia < 0
        order by (Diferencia * -1) DESC

	END



--Detalle a Nivel de Unidades con llantas  completas
	IF (@ShowDetail=4) 
	BEGIN
       Select
		Unidad, Descripcion, Proyecto, Llantas
		From  #PRL
        where diferencia = 0
        order by Unidad

	END

GO
