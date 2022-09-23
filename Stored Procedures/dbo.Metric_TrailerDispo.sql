SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_TrailerDispo]
	(
        @Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

	-- Additional / Optional Parameters
		@Numerator varchar(20) = 'Current',			-- Current
		@Denominator varchar(20) = 'Total',			-- Total
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
-- DETAILOPTIONS=1:No Disponibles,2:Disponibles

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

	Declare @NumeratorList Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20) )
	Declare @DenominatorList Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20) )




----------NUMERADOR CUENTA TRAILERS CURRENT----------------------------------------------------------------------------------------------------------------------------


			Insert into @NumeratorList (lgh_Trailer)
			Select SUBSTRING(Trailer,1,10)
			from dbo.fnc_TMWRN_TrailerCount3 
					(
						'CURRENT',@NumeratorOnlyTrlType1List,@NumeratorOnlyTrlType2List
						,@NumeratorOnlyTrlType3List,@NumeratorOnlyTrlType4List
						,@NumeratorOnlyTrlCompanyList,@NumeratorOnlyTrlDivisionList
						,@NumeratorOnlyTrlTerminalList,@NumeratorOnlyTrlFleetList,@NumeratorOnlyTrlBranchList
						,@NumeratorExcludeTrlType1List,@NumeratorExcludeTrlType2List
						,@NumeratorExcludeTrlType3List,@NumeratorExcludeTrlType4List
						,@NumeratorExcludeTrlCompanyList,@NumeratorExcludeTrlDivisionList
						,@NumeratorExcludeTrlTerminalList,@NumeratorExcludeTrlFleetList
						,@NumeratorExcludeTrlBranchList,@DateStart
					)

update @NumeratorList set fleet = (select max(name) from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select max(trl_fleet) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @NumeratorList set div = (select max(trl_type4) from trailerprofile with (nolock) where lgh_trailer = trailerprofile.trl_number)
update @NumeratorList set subtipo = ( select max(name) from labelfile with (nolock) where labeldefinition = 'TrlType1' and abbr = (select max(trl_type1) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @NumeratorList set tipo = (select max( trl_equipmenttype) from trailerprofile with (nolock) where trailerprofile.trl_number = lgh_trailer)


	
----------DENOMINADOR CUENTA TRAILERS TOTAL-----------------------------------------------------------------------------------------------------------------------------


			Insert into @DenominatorList (lgh_Trailer)
			Select SUBSTRING(Trailer,1,10)
			from dbo.fnc_TMWRN_TrailerCount3 
					(
					'TOTAL',@DenominatorOnlyTrlType1List,@DenominatorOnlyTrlType2List
					,@DenominatorOnlyTrlType3List,@DenominatorOnlyTrlType4List
					,@DenominatorOnlyTrlCompanyList,@DenominatorOnlyTrlDivisionList
					,@DenominatorOnlyTrlTerminalList,@DenominatorOnlyTrlFleetList,@DenominatorOnlyTrlBranchList
					,@DenominatorExcludeTrlType1List,@DenominatorExcludeTrlType2List
					,@DenominatorExcludeTrlType3List,@DenominatorExcludeTrlType4List
					,@DenominatorExcludeTrlCompanyList,@DenominatorExcludeTrlDivisionList
					,@DenominatorExcludeTrlTerminalList,@DenominatorExcludeTrlFleetList
					,@DenominatorExcludeTrlBranchList,@DateStart
					)

update @DenominatorList set fleet = (select max(name) from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select max(trl_fleet) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @DenominatorList set div = (select max(trl_type4) from trailerprofile with (nolock) where lgh_trailer = trailerprofile.trl_number)
update @DenominatorList set subtipo = ( select max(name) from labelfile with (nolock) where labeldefinition = 'TrlType1' and abbr = (select max(trl_type1) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @DenominatorList set tipo = (select max( trl_equipmenttype) from trailerprofile with (nolock) where trailerprofile.trl_number = lgh_trailer)


---------ASIGNACION DE LOS RESULTADOS A LAS VARIBLES TOTALES TRAILER COUNT----------------------------------------------------------------------------------------------------------------------------



	-- set the Metric Numerator & Denominator values
	Set @ThisCount = (Select count(lgh_Trailer) from @NumeratorList)

set  @ThisTotal =
		Case When @Denominator = 'Day' then 
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		Else
			(Select count(lgh_trailer) from @DenominatorList)
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / 1 END 


-----------------VISTA DETALLES DE LA METRICA TRAILER DISPO-----------------------------------------------------------------------------------------------------------

----------------DETALLE TRAILERS NO DISPONIBLES--------------------------------------------------------------------------------------------------------------------------------------------------------
	

  IF @ShowDetail = 1
		BEGIN
			Select
            Remolque = lgh_trailer
            ,DiasInactivo = (select  datediff(d,exp_creatdate,getdate())  from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N'))
            ,Flota = replace(isnull(fleet,'Sin Flota'),'UNKNOWN','N.A')
            ,Division = replace(isnull(div,'Sin División'),'UNKNOWN','N.A')
           ,Razon = ( select name from labelfile with (nolock) where labeldefinition = 'TrlExp' and abbr = (select  exp_code from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N')))
            ,ComentarioTMW = (select  exp_description from expiration  with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N'))

			From @DenominatorList where lgh_trailer not in (Select lgh_trailer From @NumeratorList) 
            --and (select name from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select trl_fleet from trailerprofile where trailerprofile.trl_number = lgh_trailer)) <> '17'
            Order by   DiasInactivo desc
		END




----------------DETALLE TRAILERS DISPONIBLES--------------------------------------------------------------------------------------------------------------------------------------------------------
	
	If @ShowDetail = 2
		BEGIN
			Select 
            Remolque = lgh_trailer
            ,Tipo = replace(isnull(tipo,'Sin Tipo'),'UNKNOWN','N.A')
            ,SubTipo = replace(isnull(subtipo,'Sin Tipo'),'UNKNOWN','N.A')
            ,Flota = replace(isnull(fleet,'Sin Flota'),'UNKNOWN','N.A')
            ,Division = replace(isnull(div,'Sin División'),'UNKNOWN','N.A')
            
			From @NumeratorList
            order by Remolque

		END

	SET NOCOUNT OFF

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
