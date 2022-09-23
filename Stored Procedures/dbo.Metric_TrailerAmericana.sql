SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_TrailerAmericana]
	(
        @Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

	-- Additional / Optional Parameters
		@Numerator varchar(20) = 'TOTAL',			-- TOTAL
		@Denominator varchar(20) = 'Day',			-- Current, Total, Historical, OOS, Day
        @Mode varchar(100) = 'Normal',               -- Normal

	-- filtering parameters: includes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',

	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',
		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',

	-- parameters for Numerator Trailer Count ONLY
		@NumeratorOnlyTrlType1List varchar(255) = '',
		@NumeratorOnlyTrlType2List varchar(255) = '',
		@NumeratorOnlyTrlType3List varchar(255) = '',
		@NumeratorOnlyTrlType4List varchar(255) = '',
		@NumeratorOnlyTrlCompanyList varchar(255) = '',
		@NumeratorOnlyTrlDivisionList varchar(255) = '',
		@NumeratorOnlyTrlTerminalList varchar(255) = '',
		@NumeratorOnlyTrlFleetList varchar(255) = '',
		@NumeratorOnlyTrlBranchList varchar(255) = '',

		@NumeratorExcludeTrlType1List varchar(255) = '',
		@NumeratorExcludeTrlType2List varchar(255) = '',
		@NumeratorExcludeTrlType3List varchar(255) = '',
		@NumeratorExcludeTrlType4List varchar(255) = '',
		@NumeratorExcludeTrlCompanyList varchar(255) = '',
		@NumeratorExcludeTrlDivisionList varchar(255) = '',
		@NumeratorExcludeTrlTerminalList varchar(255) = '',
		@NumeratorExcludeTrlFleetList varchar(255) = '',
		@NumeratorExcludeTrlBranchList varchar(255) = '',

	-- parameters for Denominator Trailer Count ONLY
		@DenominatorOnlyTrlType1List varchar(255) = '',
		@DenominatorOnlyTrlType2List varchar(255) = '',
		@DenominatorOnlyTrlType3List varchar(255) = '',
		@DenominatorOnlyTrlType4List varchar(255) = '',
		@DenominatorOnlyTrlCompanyList varchar(255) = '',
		@DenominatorOnlyTrlDivisionList varchar(255) = '',
		@DenominatorOnlyTrlTerminalList varchar(255) = '',
		@DenominatorOnlyTrlFleetList varchar(255) = '',
		@DenominatorOnlyTrlBranchList varchar(255) = '',

		@DenominatorExcludeTrlType1List varchar(255) = '',
		@DenominatorExcludeTrlType2List varchar(255) = '',
		@DenominatorExcludeTrlType3List varchar(255) = '',
		@DenominatorExcludeTrlType4List varchar(255) = '',
		@DenominatorExcludeTrlCompanyList varchar(255) = '',
		@DenominatorExcludeTrlDivisionList varchar(255) = '',
		@DenominatorExcludeTrlTerminalList varchar(255) = '',
		@DenominatorExcludeTrlFleetList varchar(255) = '',
		@DenominatorExcludeTrlBranchList varchar(255) = '',

		@MetricCode varchar(255)= 'TrailerCount'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Cajas

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	Set @NumeratorOnlyTrlType1List= ',' + ISNULL(@NumeratorOnlyTrlType1List,'') + ','
	Set @NumeratorOnlyTrlType2List= ',' + ISNULL(@NumeratorOnlyTrlType2List,'') + ','
	Set @NumeratorOnlyTrlType3List= ',' + ISNULL(@NumeratorOnlyTrlType3List,'') + ','
	Set @NumeratorOnlyTrlType4List= ',' + ISNULL(@NumeratorOnlyTrlType4List,'') + ','
	Set @NumeratorOnlyTrlCompanyList= ',' + ISNULL(@NumeratorOnlyTrlCompanyList,'') + ','
	Set @NumeratorOnlyTrlDivisionList= ',' + ISNULL(@NumeratorOnlyTrlDivisionList,'') + ','
	Set @NumeratorOnlyTrlTerminalList= ',' + ISNULL(@NumeratorOnlyTrlTerminalList,'') + ','
	Set @NumeratorOnlyTrlFleetList= ',' + ISNULL(@NumeratorOnlyTrlFleetList,'') + ','
	Set @NumeratorOnlyTrlBranchList= ',' + ISNULL(@NumeratorOnlyTrlBranchList,'') + ','

	Set @NumeratorExcludeTrlType1List= ',' + ISNULL(@NumeratorExcludeTrlType1List,'') + ','
	Set @NumeratorExcludeTrlType2List= ',' + ISNULL(@NumeratorExcludeTrlType2List,'') + ','
	Set @NumeratorExcludeTrlType3List= ',' + ISNULL(@NumeratorExcludeTrlType3List,'') + ','
	Set @NumeratorExcludeTrlType4List= ',' + ISNULL(@NumeratorExcludeTrlType4List,'') + ','
	Set @NumeratorExcludeTrlCompanyList= ',' + ISNULL(@NumeratorExcludeTrlCompanyList,'') + ','
	Set @NumeratorExcludeTrlDivisionList= ',' + ISNULL(@NumeratorExcludeTrlDivisionList,'') + ','
	Set @NumeratorExcludeTrlTerminalList= ',' + ISNULL(@NumeratorExcludeTrlTerminalList,'') + ','
	Set @NumeratorExcludeTrlFleetList= ',' + ISNULL(@NumeratorExcludeTrlFleetList,'') + ','
	Set @NumeratorExcludeTrlBranchList= ',' + ISNULL(@NumeratorExcludeTrlBranchList,'') + ','

	Set @DenominatorOnlyTrlType1List= ',' + ISNULL(@DenominatorOnlyTrlType1List,'') + ','
	Set @DenominatorOnlyTrlType2List= ',' + ISNULL(@DenominatorOnlyTrlType2List,'') + ','
	Set @DenominatorOnlyTrlType3List= ',' + ISNULL(@DenominatorOnlyTrlType3List,'') + ','
	Set @DenominatorOnlyTrlType4List= ',' + ISNULL(@DenominatorOnlyTrlType4List,'') + ','
	Set @DenominatorOnlyTrlCompanyList= ',' + ISNULL(@DenominatorOnlyTrlCompanyList,'') + ','
	Set @DenominatorOnlyTrlDivisionList= ',' + ISNULL(@DenominatorOnlyTrlDivisionList,'') + ','
	Set @DenominatorOnlyTrlTerminalList= ',' + ISNULL(@DenominatorOnlyTrlTerminalList,'') + ','
	Set @DenominatorOnlyTrlFleetList= ',' + ISNULL(@DenominatorOnlyTrlFleetList,'') + ','
	Set @DenominatorOnlyTrlBranchList= ',' + ISNULL(@DenominatorOnlyTrlBranchList,'') + ','

	Set @DenominatorExcludeTrlType1List= ',' + ISNULL(@DenominatorExcludeTrlType1List,'') + ','
	Set @DenominatorExcludeTrlType2List= ',' + ISNULL(@DenominatorExcludeTrlType2List,'') + ','
	Set @DenominatorExcludeTrlType3List= ',' + ISNULL(@DenominatorExcludeTrlType3List,'') + ','
	Set @DenominatorExcludeTrlType4List= ',' + ISNULL(@DenominatorExcludeTrlType4List,'') + ','
	Set @DenominatorExcludeTrlCompanyList= ',' + ISNULL(@DenominatorExcludeTrlCompanyList,'') + ','
	Set @DenominatorExcludeTrlDivisionList= ',' + ISNULL(@DenominatorExcludeTrlDivisionList,'') + ','
	Set @DenominatorExcludeTrlTerminalList= ',' + ISNULL(@DenominatorExcludeTrlTerminalList,'') + ','
	Set @DenominatorExcludeTrlFleetList= ',' + ISNULL(@DenominatorExcludeTrlFleetList,'') + ','
	Set @DenominatorExcludeTrlBranchList= ',' + ISNULL(@DenominatorExcludeTrlBranchList,'') + ','

	Declare @NumeratorList Table (Caja varchar(12), Fechaentrada datetime, Fechasalida datetime, regionprior varchar(5), regionnext varchar(5) )



----------NUMERADOR CUENTA CAJAS AMERICANAS TOTAL-----------------------------------------------------------------------------------------------------------------------------


			Insert into @NumeratorList (Caja,fechaentrada,fechasalida)
		    select
            Caja = exp_id
            ,Fechaentrada = exp_lastdate
            ,Fechasalida  =  exp_expirationdate
             
            from expiration where exp_idtype = 'TRL' and exp_code = 'FIAN' and exp_COMPLETED = 'N'

update @NumeratorList set regionprior = ( select max(trl_prior_region1) from trailerprofile where trl_id = caja )
update @NumeratorList set regionnext = ( select max(trl_next_region1) from trailerprofile where trl_id  = caja)


---------ASIGNACION DE LOS RESULTADOS A LAS VARIBLES TOTALES TRAILER COUNT----------------------------------------------------------------------------------------------------------------------------



	-- set the Metric Numerator & Denominator values
	Set @ThisCount = (Select count(caja) from @NumeratorList)

set  @ThisTotal =
		Case When @Denominator = 'Day' then 
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
        END	

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / 1 END 


-----------------VISTA DETALLES DE LA METRICA TRAILER COUNT-----------------------------------------------------------------------------------------------------------

--DETALLE A NIVEL DE REMOLQUE

	If @ShowDetail = 1
		BEGIN
			Select 
            Caja
            ,FechaEntrada
            ,FechaSalida
            ,DiasTranscurridos = datediff(dd,FechaEntrada,Getdate())
            ,Ubicacion = replace(regionnext,'UNK',regionprior)
			From @NumeratorList
            order by datediff(dd,FechaEntrada,Getdate()) desc

		END






-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'TrailerCount',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Trailer Count Metrics',
		@sCaptionFull = 'Trailer Count Metrics',
		@sProcedureName = 'Metric_TrailerCount',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
