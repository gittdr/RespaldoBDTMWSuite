SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_SaldosporCuenta] (
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
     
      @cuentas varchar(500) = ''         ---Numeros de cuentas que se vab a reportar
       


)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Cuentas


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
     SET @cuentas = ',' + ISNULL(@cuentas,'') + ','


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

      SELECT     Año, [Id. de período], [Número de cuenta], [Descripción cuenta], [Alias de cuenta],  [Saldo del período] AS Saldo
      FROM      TDR.dbo.AccountSummary
      WHERE     (Año = year(getdate()))  AND   

((@cuentas =',,' or CHARINDEX(',' + IsNull([Número de cuenta],0) + ',', @cuentas) > 0))

       and [Id. de período] =   (SELECT   max([Id. de período])   FROM      TDR.dbo.AccountSummary    WHERE     (Año = year(getdate())) AND ((@cuentas =',,' or CHARINDEX(',' + IsNull([Número de cuenta],0) + ',', @cuentas) > 0)))


if (select max([periodo])from #RBSS)  = 1 
  begin
       update #RBSS  set Saldo  =  saldo +  (select [Saldo del período]  FROM      TDR.dbo.AccountSummary
       WHERE     (Año = year(getdate())-1)  AND ( [Número de cuenta] = cuenta )

       and [Id. de período] =   (SELECT   replace((max([Id. de período]) -1),0,12)  FROM      TDR.dbo.AccountSummary    WHERE     (Año = year(getdate())-1) AND  (@cuentas =',,' or CHARINDEX(',' + IsNull([Número de cuenta],0) + ',', @cuentas) > 0)))
  end

else
  begin
      update #RBSS  set Saldo  =  saldo +  (select [Saldo del período]  FROM      TDR.dbo.AccountSummary
       WHERE     (Año = year(getdate()))  AND ( [Número de cuenta] = cuenta )

       and [Id. de período] =   (SELECT   (max([Id. de período]) -1)  FROM      TDR.dbo.AccountSummary    WHERE     (Año = year(getdate())) AND  ((@cuentas =',,' or CHARINDEX(',' + IsNull([Número de cuenta],0) + ',', @cuentas) > 0))))

  end


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
