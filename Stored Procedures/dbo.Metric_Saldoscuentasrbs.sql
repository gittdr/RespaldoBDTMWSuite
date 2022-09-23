SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_Saldoscuentasrbs] (
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
-- DETAILOPTIONS=1:Cuentas


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #RBSS
    (anio int,
     periodo int,
     cuenta varchar(15),
     desccuenta varchar(500),
     aliascuenta varchar(200),
     Saldo float )

 

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #RBSS

      SELECT     Año, [Id. de período], [Número de cuenta], [Descripción cuenta], [Alias de cuenta], [Monto débito] - [Monto crédito] AS Saldo
      FROM      TDR.dbo.AccountSummary
      WHERE     (Año = year(getdate())) AND ([Número de cuenta] LIKE '08%') AND  SUBSTRING([Número de cuenta], 7, 9) IN ('6100-0001', '6100-0002', '6100-0003', '6100-0004', '6100-0005', 
                      '6100-0006', '6100-0007', '6100-0008', '6100-0009', '6100-0010', '6300-0001', '6300-0002', '6300-0003')
       and [Id. de período] = month(@DateStart)



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(saldo)  from #RBSS)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Unidades  revisadas por dia


IF (@ShowDetail=1) 
	BEGIN
		Select 
         Periodo =   cast(periodo as varchar)  + '-' + cast(anio as varchar)
        ,Cuenta
        ,Descripcion = desccuenta
        ,AliasCuenta = aliascuenta
        ,Saldo = '$' + dbo.fnc_TMWRN_FormatNumbers(saldo,2)
          from #RBSS
        order by  cast(saldo as int) desc
      
	END

GO
