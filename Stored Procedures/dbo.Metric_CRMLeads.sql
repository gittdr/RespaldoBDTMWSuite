SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************
Creada por Emilio Olvera 4/6/2015
Revisado por: Emilio Olvera Yañez y Carlos Salvador Rodriguez J
Fecha revision: 3 Junio 2015

Cuenta con revisón de matematica de calculo en base a Hoshin 2015.

Descripcion matematica Hoshin
Mide el prebook.
Mide la demanda vs la capacidad en un periodo futuro (Capacidad futura/ Demanda futura)

This Count: LEADS ingresados
This Total: periodo

********************/




CREATE  PROCEDURE [dbo].[Metric_CRMLeads] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    --@Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO
     
     @sucursal varchar(50) = 'Todos'                 --MEX,QRO,MTE,GDA,LAD
     
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:General,2:Unidad,3:Flota,4:Operador,5:Concepto,6:StatusPago,7:Accidente



	-- Creación de la tabla temporal

	CREATE TABLE #LeadsCRM (cmp_id varchar(10), cmp_createdate datetime, cmp_revtype2 varchar(10))


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de accidente_costo_Gasto


	if @sucursal = 'Todos'
	 begin

      INSERT INTO #LeadsCRM

    	   select cmp_id, cmp_createdate, cmp_revtype2 from company where cmp_crmtype = 'LEAD' and (cmp_createdate between @DateStart and @DateEnd)
		   select cmp_id, cmp_createdate, cmp_revtype2 from  companycrmwork  where cmp_crmtype = 'LEAD' and (cmp_createdate between @DateStart and @DateEnd)
      end
    else 
	 	 begin

      INSERT INTO #LeadsCRM

    	   select cmp_id, cmp_createdate, cmp_revtype2 from company where cmp_crmtype = 'LEAD' and (cmp_createdate between @DateStart and @DateEnd)
		   and cmp_revtype2 = @sucursal

		   select cmp_id, cmp_createdate, cmp_revtype2 from  companycrmwork  where cmp_crmtype = 'LEAD' and (cmp_createdate between @DateStart and @DateEnd)
		   and cmp_revtype2 = @sucursal
      end
  

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select count(*) from #LeadsCRM)

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Estado

	IF (@ShowDetail=1) 
	BEGIN
		Select * from #LeadsCRM
	END

GO
