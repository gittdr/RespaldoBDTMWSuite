SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[Metric_Accidentes] (
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
-- DETAILOPTIONS=1:Estado,2:Unidad,3:Flota,4:Operador,5:Concepto,6:StatusPago,7:Accidente


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Accidentes (Fecha datetime, IdAccidente varchar(10), Estado varchar (30), Unidad varchar(10) , Flota varchar(200), Renglon int, Operador varchar(255), Concepto varchar(255),
    Beneficiario varchar(255), StatusPago varchar(50), Observaciones varchar(255), Monto float)


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de accidente_costo_Gasto


      INSERT INTO #Accidentes

       SELECT    

      
		Fecha = (select  tdrsilt.dbo.accidente_accidente.Fecha from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente),
		IdAccidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente ,
		EstadoAc = isnull((select desc_Edo from tdrsilt.dbo.general_Estado where tdrsilt.dbo.general_Estado.abrev_edo = 
			(select  tdrsilt.dbo.accidente_accidente.Estado_Plaza from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente)), (select desc_Edo from tdrsilt.dbo.general_Estado where tdrsilt.dbo.general_Estado.ab_qtracs = (select  tdrsilt.dbo.accidente_accidente.Estado_Plaza from tdrsilt.dbo.accidente_accidente where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente)) ) ,
		Unidad = (select  tdrsilt.dbo.accidente_accidente.id_unidad from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente),    
	    Flota = (Select name from labelfile with (nolock) where labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile with (nolock) where trc_number = ((select  tdrsilt.dbo.accidente_accidente.id_unidad from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente)))),
        Renglon =tdrsilt.dbo.accidente_costo_gasto.renglon ,
		Operador = (SELECT  nombre from  tdrsilt.dbo.personal_personal with (nolock) where tdrsilt.dbo.personal_personal.id_personal =  (select  tdrsilt.dbo.accidente_accidente.id_personal  from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente)),
		Concepto = (SELECT   tdrsilt.dbo.accidente_gasto.descripcion     FROM tdrsilt.dbo.accidente_gasto  with (nolock) where tdrsilt.dbo.accidente_gasto.id_gasto  = tdrsilt.dbo.accidente_costo_gasto.id_gasto) , 
		Beneficiario = case tdrsilt.dbo.accidente_costo_gasto.id_gasto when 2 then 'Tercero' when 1 then 'Propios' else  tdrsilt.dbo.accidente_costo_gasto.beneficiario end,  
		StatusPago = case tdrsilt.dbo.accidente_costo_gasto.status_pago when 1 then 'Pendiente' when 2 then 'Parcial' when 3 then 'Liquidado' end,        
		Observaciones = tdrsilt.dbo.accidente_costo_gasto.Observaciones ,  
		Monto = tdrsilt.dbo.accidente_costo_gasto.monto   
		FROM tdrsilt.dbo.accidente_costo_gasto   with (nolock)
        where  ( tdrsilt.dbo.accidente_costo_gasto.id_area = 1 ) 
        and  
        -- Validacion de fechas 
		(select  tdrsilt.dbo.accidente_accidente.Fecha from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente) >= @DateStart  and
		(select  tdrsilt.dbo.accidente_accidente.Fecha from tdrsilt.dbo.accidente_accidente with (nolock) where tdrsilt.dbo.accidente_accidente.id_accidente = tdrsilt.dbo.accidente_costo_gasto.id_accidente) < @DateEnd 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(Monto) from #Accidentes)

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Estado

	IF (@ShowDetail=1) 
	BEGIN
		Select Estado, 
        CuentaAcc =  count(IdAccidente),
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by Estado
        order by sum(Monto) DESC
      
	END

--Detalle a Nivel de  Unidad

  	IF (@ShowDetail=2) 
	BEGIN
		Select Unidad, 
        CuentAcc =  count(IdAccidente),
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by Unidad
         order by sum(Monto) DESC
      
	END


--Detalle a Nivel de Flota

  	IF (@ShowDetail=3) 
	BEGIN
		Select 
        Flota, 
        CuentaAcc =  count(IdAccidente),
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by Flota
         order by sum(Monto) DESC
      
	END
 

--Detalle a Nivel de  Operador

  	IF (@ShowDetail=4) 
	BEGIN
		Select Operador, 
        CuentaAcc =  count(IdAccidente),
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by Operador
         order by sum(Monto) DESC
      
	END

--Detalle a Nivel de  Concepto 


  	IF (@ShowDetail=5) 
	BEGIN
		Select Concepto, 
        CuentaAcc =  count(IdAccidente),
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by Concepto
        order by sum(Monto) DESC
      
	END


--Detalle a Nivel de  EstadoPago

  	IF (@ShowDetail=6) 
	BEGIN
		Select EstadoPago,
        CuentaAcc =  count(IdAccidente), 
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Monto),2)
		From  #Accidentes
        group by  EstadoPago
        order by sum(Monto) DESC
      
	END
	
--Detalle a Nivel de  Accidente

  	IF (@ShowDetail=7) 
	BEGIN
		Select IdAccidente, Fecha,  Estado, Unidad, Operador, Concepto,
    Beneficiario , StatusPago , Observaciones,  
        Monto = '$' + dbo.fnc_TMWRN_FormatNumbers((Monto),2)
		From  #Accidentes
    
    order by idaccidente, renglon
      
	END
	
GO
