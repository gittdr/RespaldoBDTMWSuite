SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_DieselRend] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,  
    @Flota varchar(200)			--        TODAS, NOMBRE DE LAS FLOTAS SEPARADOS POR COMA
 

)
AS
	SET NOCOUNT ON  -- PTS46367

    declare @difdate  int
    declare @PDateStart datetime
	declare @PDateEnd datetime 


	--INICIALIZACION DE PARAMETROS ESTANDAR.
    --inicializamos las variables de las  fechas con una semana antes para comparar


      Set @Difdate = datediff(d,@DateEnd, @DateStart)

     if @difdate < 0 
       begin

         Set @PdateStart= dateadd(dd,@Difdate,@DateStart)
         Set @Pdateend = dateadd(dd,@DifDate,@DateEnd)
       end
    else if @difdate > -1
        begin
          Set @PdateStart= dateadd(dd,-1,@datestart) 
         Set @Pdateend =   @datestart
        end






	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Flota,2:Unidad,3:Operador,4:Movimiento



	-- Create Temp Table
	CREATE TABLE #Rendimientos(
		Movimiento	Integer,
		Litros		decimal(10,2),
		KMS			decimal (10,2),
		Unidad		VARCHAR(50),
		Proyecto	VARCHAR(5),
		NomProy		VARCHAR(20),
		Flota		VARCHAR(20),
		Abbr		Varchar(20),
        Ejes       int,
        Motor      varchar(20),
        RendCarg  float,
        RendVacio float)


--creamos tabla con valores de una semana antes para poder comparar
	CREATE TABLE #PRendimientos(
		PMovimiento	Integer,
		PLitros		decimal(10,2),
		PKMS			decimal (10,2),
		PUnidad		VARCHAR(50),
		PProyecto	VARCHAR(5),
		PNomProy		VARCHAR(20),
		PFlota		VARCHAR(20),
		PAbbr		Varchar(20),
        PEjes       int,
        PMotor      varchar(20),
        PRendCarg  float,
        PRendVacio float)



	-- Initialize Temp Table
	
     SET @Flota = ',' + ISNULL(@Flota,'') + ','

      INSERT INTO #Rendimientos
	
      Exec sp_ValesVsKMs @DateStart, @DateEnd 

     if @Flota <> ',TODAS,' 
       BEGIN
          delete #Rendimientos where (@Flota =',,' or CHARINDEX(',' + IsNull(Abbr,'') + ',', @Flota) = 0)   
       END

--pasamos valores a tabla de una semana antes para comparar
       INSERT INTO #PRendimientos
	
      Exec sp_ValesVsKMs  @PDateStart, @PDateEnd 

     if @Flota <> ',TODAS,'
       BEGIN
          delete #PRendimientos where (@Flota =',,' or CHARINDEX(',' + IsNull(PAbbr,'') + ',', @Flota) = 0)   
       END


----CALCULO DE LOS RESULTADOS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	SELECT @ThisCount = sum(KMS)/(sum(Litros))  FROM #Rendimientos

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

---------------DETALLE DE LOS RESULTADOS-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--RENDIMIENTO A NIVEL DE FLOTA

	IF (@ShowDetail=1) 
	BEGIN
		Select 
        Flota =  replace(Flota,'SWAT','WM SLP'), 
        KMS = dbo.fnc_TMWRN_FormatNumbers(sum(KMS),2), 
        Litros =  dbo.fnc_TMWRN_FormatNumbers(sum(Litros),2), 
        [KmXLtr]=  case when sum(litros) = 0 then dbo.fnc_TMWRN_FormatNumbers(0,2)
        else  dbo.fnc_TMWRN_FormatNumbers( sum(KMS) / replace(sum(Litros),0,1),2) end
        --valor del rendimiento de una semana antes
        --,RendPas = (select  dbo.fnc_TMWRN_FormatNumbers(  sum(PKMS)/replace(sum(PLitros),0,1),2)  from #PRendimientos where PFlota = Flota)
        
       ,RendPas = (select case when sum(plitros) = 0 then dbo.fnc_TMWRN_FormatNumbers(0,2)
        else  dbo.fnc_TMWRN_FormatNumbers(sum(PKMS) /replace(sum(PLitros),0,1),2) end  from #PRendimientos where PFlota = Flota)

        ,Variacion = dbo.fnc_TMWRN_FormatNumbers((case when sum(litros) = 0  then 0 else  ( sum(KMS) / replace(sum(Litros),0,1)) end ) - ((select case when sum(plitros) = 0 then 0
        else  (sum(PKMS) /replace(sum(PLitros),0,1)) end  from #PRendimientos where PFlota = Flota) ),2)

       ,VarPorCiento =  dbo.fnc_TMWRN_FormatNumbers( (100*
        ((case when sum(litros) = 0  then 0 else  ( sum(KMS) / replace(sum(Litros),0,1)) end ) - (select case when sum(plitros) = 0 then 0
        else  (sum(PKMS) /replace(sum(PLitros),0,1)) end  from #PRendimientos where PFlota = Flota) ) / (select case when sum(plitros) = 0 then 0
        else  (sum(PKMS) /replace(sum(PLitros),0,1)) end  from #PRendimientos where PFlota = Flota)) ,2) + '%'

        ,Participacion = dbo.fnc_TMWRN_FormatNumbers(100*(sum(KMS) / (select sum(Kms) from #rendimientos)),2) +'%'
		From #Rendimientos
        group by flota
        order by (sum(KMS)/replace(sum(Litros),0,1)) desc


	END

 --RENDIMIENTO A NIVEL DE UNIDAD

	IF (@ShowDetail=2) 
	BEGIN
		Select 
        Unidad,
        Flota =  replace(Flota,'SWAT','WM SLP'), 
        KMS = dbo.fnc_TMWRN_FormatNumbers(sum(KMS),2), 
        Litros =  dbo.fnc_TMWRN_FormatNumbers(sum(Litros),2), 
		
        [KmXLtr]=  case when sum(litros) = 0 then dbo.fnc_TMWRN_FormatNumbers(0,2)
          else  dbo.fnc_TMWRN_FormatNumbers( sum(KMS) / replace(sum(Litros),0,1),2) end,

        RendPas = (select case when sum(plitros) = 0 then dbo.fnc_TMWRN_FormatNumbers(0,2)
        else  dbo.fnc_TMWRN_FormatNumbers(sum(PKMS) /replace(sum(PLitros),0,1),2) end  from #PRendimientos where PUnidad = Unidad),
		
       Variacion = dbo.fnc_TMWRN_FormatNumbers((case when sum(litros) = 0  then 0 else  ( sum(KMS) / replace(sum(Litros),0,1)) end ) - ((select case when sum(plitros) = 0 then 0
        else  (sum(PKMS) /replace(sum(PLitros),0,1)) end  from #PRendimientos where PUnidad = Unidad) ),2),
		
        VarPorCiento = 
		
		(select case when sum(PLitros) = 0 then '0%' else
		
		( dbo.fnc_TMWRN_FormatNumbers( (100*
        ((case when sum(litros) = 0   then 0 else  ( sum(KMS) / replace(sum(Litros),0,1)) end ) - 
		(select case when sum(plitros) = 0 then 0 else  (sum(PKMS) /replace(sum(PLitros),0,1)) end  from #PRendimientos where PUnidad = Unidad) ) 
		
		
		/
		
	   replace( (select (sum(PKMS) /sum(PLitros))   from #PRendimientos where PUnidad = Unidad),0,1))
		
		
		
		 ,2) + '%')
		 
		 end from #PRendimientos where PUnidad = Unidad)
		 ,
		
        Participacion = dbo.fnc_TMWRN_FormatNumbers(100*(sum(KMS) / (select sum(pKms) from #Prendimientos)),2) +'%'


		From #Rendimientos
        group by flota,unidad
       order by flota desc ,(sum(KMS)/(sum(Litros))) desc

     END

/*
  --RENDIMIENTO A NIVEL De Operador

	IF (@ShowDetail=3) 
	BEGIN
		Select 
       (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select trc_Driver from tractorprofile where trc_Number = Unidad)) as Operador,
         replace(Flota,'SWAT','WM SLP') as Flota, 
        dbo.fnc_TMWRN_FormatNumbers(sum(KMS),2) as KMS, 
         dbo.fnc_TMWRN_FormatNumbers(sum(Litros),2) as Litros
        ,dbo.fnc_TMWRN_FormatNumbers(sum(KMS) / replace(sum(Litros),0,1),2)   as [KmXLtr]
      --  dbo.fnc_TMWRN_FormatNumbers(  sum(KMS)/replace(sum(Litros),0,1),2) as [KmXLtr]
        --valor del rendimiento de una semana antes
        ,RendPas = (select  dbo.fnc_TMWRN_FormatNumbers(  sum(PKMS)/replace(sum(PLitros),0,1),2)  from #PRendimientos where PUnidad = Unidad)
        ,Variacion = dbo.fnc_TMWRN_FormatNumbers(  sum(KMS)/replace(sum(Litros),0,1) -  (select  sum(PKMS)/replace(sum(PLitros),0,1)  from #PRendimientos where PUnidad = Unidad),2)
        ,VarPorCiento =  dbo.fnc_TMWRN_FormatNumbers( (100*(  sum(KMS)/replace(sum(Litros),0,1) - 
        (select  sum(PKMS)/replace(sum(PLitros),0,1)  from #PRendimientos where PUnidad = Unidad))/ (select   case when sum(PKMS) = 0 then 1 else sum(PKMS)/replace(sum(PLitros),0,1)end  from #PRendimientos where PUnidad = Unidad)) ,2) + '%'
		From #Rendimientos
        group by flota,unidad
       order by flota desc ,(sum(KMS)/replace(sum(Litros),0,1)) desc

     END

IF @Difdate > 60

*/
	IF (@ShowDetail=3) 
	BEGIN
		Select 
       (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select trc_Driver from tractorprofile where trc_Number = Unidad)) as Operador,
         replace(Flota,'SWAT','WM SLP') as Flota, 
        dbo.fnc_TMWRN_FormatNumbers(sum(KMS),2) as KMS, 
         dbo.fnc_TMWRN_FormatNumbers(sum(Litros),2) as Litros
        ,dbo.fnc_TMWRN_FormatNumbers(sum(KMS) / replace(sum(Litros),0,1),2)   as [KmXLtr]
      --  dbo.fnc_TMWRN_FormatNumbers(  sum(KMS)/replace(sum(Litros),0,1),2) as [KmXLtr]
		From #Rendimientos
        group by flota,unidad
       order by flota desc ,(sum(KMS)/replace(sum(Litros),0,1)) desc

     END


  --RENDIMIENTO A NIVEL DE MOVIMIENTO

	IF (@ShowDetail=4) 
	BEGIN
		Select Movimiento as Movimiento,Unidad,replace(Flota,'SWAT','WM SLP')  as Flota,
         dbo.fnc_TMWRN_FormatNumbers(KMS,2) as KMS, 
         dbo.fnc_TMWRN_FormatNumbers(Litros,2) as Litros, 
         dbo.fnc_TMWRN_FormatNumbers((KMS) / replace((Litros),0,1),2)   as [KmXLtr]
		From #Rendimientos
        --order by Movimiento
        --group  by movimiento
        order by ((KMS)/replace((Litros),0,1)) desc


	END
GO
