SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[Metric_DeudaOperadores] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

	--PARAMETROS PROPIOS DE LA METRICA
   -- @Modo  varchar(20)  = 'RESUELTOS'                     --RESUELTOS,MONTOARREGLO
     
    --  @noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Concepto,2:Operador,3:Proyecto,4:Detalle



	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #DeudaOp(Concepto varchar(255), Descripcion varchar(900), Fecha datetime, Operador varchar(600), Flota varchar(200),
    Balance float )
	     
	--Cargamos la tabla temporal con los datos de la consulta de la tabla de litigios

      INSERT INTO #DeudaOp
        
		
		SELECT  		Concepto = standingdeduction.sdm_itemcode,		Descripcion = standingdeduction.std_description,		Fecha = std_issuedate,		Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = asgn_id),         Flota = (Select name from labelfile where labeldefinition = 'Fleet' and abbr = (select mpp_fleet from manpowerprofile where mpp_id = asgn_id)),		Balance = standingdeduction.std_balance		--,standingdeduction.std_status		--,standingdeduction.std_balance * (case when standingdeduction.std_startbalance = 0 and dbo.standingdeduction.std_endbalance = 0 then -1 when stdmaster.sdm_minusbalance = 'N' then 1 else -1 end) cabs_balance, standingdeduction.std_startbalance - standingdeduction.std_endbalance cabs_issueamount,		FROM standingdeduction join manpowerprofile on standingdeduction.asgn_id = manpowerprofile.mpp_id		join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode		WHERE standingdeduction.asgn_type = 'DRV'		and 'UNKNOWN' in ('UNKNOWN', standingdeduction.asgn_id)		and standingdeduction.sdm_itemcode in ('ACC','LIQUID','ALIMEN', 'ISPTAM', 'ANTI', 'CONTEQ', 'CREDEN', 'DEF', 'DENT', 'DEVO', 'DIESEL', 'EQSEG', 'EVID','FMERC', 'EQUIPO', 'DEP', 'INC','LAB','LIC','LEC','LLANT','LOD','LUC','MEMB','OFTAL','PREPER','PROMO','CEMS','INFOAM','IAVE','UNIFOR','ZAPA', 'IMSSAM', 'INF')		and standingdeduction.std_status in ('INI','DRN','HLD','XXX','XXX','XXX','XXX')		and standingdeduction.std_issuedate between {ts '1950-01-01 00:00:00.000'} and {ts '2049-12-31 23:59:59.992'}		--itemCode considerados que se quitaron a peticion de Karla 12-02-2013 		--'SEGVID', 'PATGAM', 'PATKRA', 'PATMTY', 'PATOAX', 'PATSAY', 'PATTOR', 'PRIMVA', 'PAGARE', 'COMPE', 'PA', 'FONA', 'INF', 'VACAS', 'BONO', 'AGNALD','AGUINA',--'ACC','LIQUID','ALIMEN','ISPTAM','ANTI','CONTEQ','CREDEN','DEF','DENT','DEVO','DIESEL','EQSEG','EVID',		'FPGAM','FPHER','FPJMX','FPKFT','FPMTY','FPSAYE','FPSAOX','FPST','FPGDL','FMERC','EQUIPO','FALTA','DEP','IMSSA','RISTRA','INC','ISRAGU','LAB','LIC','LEC','LLANT','LOD','LUC','MEMB','OFTAL','INSTRU','PREPER','PROMO','IMSSRE','CEMS','INFOAM','PATGDJ','PATHER','PATJUM','PATMEX','IAVE','TMPEXT','UNIFOR','ZAPA'		and 'UNK' in ('UNK', manpowerprofile.mpp_type1)		and 'UNK' in ('UNK', manpowerprofile.mpp_type2)		and 'UNK' in ('UNK', manpowerprofile.mpp_type3)		and 'UNK' in ('UNK', manpowerprofile.mpp_type4)		and 'UNK' in ('UNK', manpowerprofile.mpp_company)		and 'UNK' in ('UNK', manpowerprofile.mpp_fleet)		and 'UNK' in ('UNK', manpowerprofile.mpp_division)		and 'UNK' in ('UNK', manpowerprofile.mpp_domicile )		and 'X' in ('X', manpowerprofile.mpp_actg_type)        --and standingdeduction.std_closedate between {ts '1950-01-01 00:00:00.000'} and {ts '2049-12-31 23:59:59.992'}

   
    --Asignar valores al numerador y al denominador

    SELECT @ThisCount = (Select sum(Balance) from #DeudaOp  )
 
    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
    
    --Calculo del valor final de la metrica, resultado 


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

--Vista de resultados detalle

	IF (@ShowDetail=1)  --a nivel del concepto

	BEGIN
		Select 
        Concepto = (select sdm_description    FROM stdmaster  where concepto =  sdm_itemcode),
        Cantidad = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(balance),2)
        from #DeudaOp
        group by Concepto
        order by cast(sum(balance) as int) desc 
	END

 IF (@ShowDetail=2)  --a nivel del operador

	BEGIN
		Select 
        Operador,
        Cantidad = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(balance),2)
        from #DeudaOp
        group by Operador
        order by cast(sum(balance) as int) desc 
	END


 IF (@ShowDetail=3)  --a nivel de Flota

		BEGIN
		Select 
        Flota,
        Cantidad = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(balance),2)
        from #DeudaOp
        group by Flota
        order by cast(sum(balance) as int) desc 
	END




 IF (@ShowDetail=4)  --a nivel de detalle

	BEGIN
		Select 
        Concepto = (select sdm_description    FROM stdmaster  where concepto =  sdm_itemcode),
        Descripcion,
        Fecha,
        Operador,
        Flota,
        Balance = '$' + dbo.fnc_TMWRN_FormatNumbers((balance),2)
        from #DeudaOp
        order by flota, fecha DESC
        
	END

GO
