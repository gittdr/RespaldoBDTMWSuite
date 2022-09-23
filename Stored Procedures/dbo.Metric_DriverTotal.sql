SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[Metric_DriverTotal]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

	-- Additional / Optional Parameters
		@Numerator varchar(20) = 'Current',			-- Seated, Unseated, Current, Total, Bloqueados, Historical
		@Denominator varchar(20) = 'Day',			-- Seated, Unseated, Current, Total, Bloqueados, Historical, Day

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

	-- parameters for Numerator Driver Count ONLY
		@NumeratorOnlyDrvType1List varchar(255) = '',
		@NumeratorOnlyDrvType2List varchar(255) = '',
		@NumeratorOnlyDrvType3List varchar(255) = '',
		@NumeratorOnlyDrvType4List varchar(255) = '',
		@NumeratorOnlyDrvCompanyList varchar(255) = '',
		@NumeratorOnlyDrvDivisionList varchar(255) = '',
		@NumeratorOnlyDrvTerminalList varchar(255) = '',
		@NumeratorOnlyDrvFleetList varchar(255) = '',
		@NumeratorOnlyDrvBranchList varchar(255) = '',
		@NumeratorOnlyDrvDomicileList varchar(255) = '',
		@NumeratorOnlyDrvTeamLeaderList varchar(255) = '',

		@NumeratorExcludeDrvType1List varchar(255) = '',
		@NumeratorExcludeDrvType2List varchar(255) = '',
		@NumeratorExcludeDrvType3List varchar(255) = '',
		@NumeratorExcludeDrvType4List varchar(255) = '',
		@NumeratorExcludeDrvCompanyList varchar(255) = '',
		@NumeratorExcludeDrvDivisionList varchar(255) = '',
		@NumeratorExcludeDrvTerminalList varchar(255) = '',
		@NumeratorExcludeDrvFleetList varchar(255) = '',
		@NumeratorExcludeDrvBranchList varchar(255) = '',
		@NumeratorExcludeDrvDomicileList varchar(255) = '',
		@NumeratorExcludeDrvTeamLeaderList varchar(255) = '',

	-- parameters for Denominator Driver Count ONLY
		@DenominatorOnlyDrvType1List varchar(255) = '',
		@DenominatorOnlyDrvType2List varchar(255) = '',
		@DenominatorOnlyDrvType3List varchar(255) = '',
		@DenominatorOnlyDrvType4List varchar(255) = '',
		@DenominatorOnlyDrvCompanyList varchar(255) = '',
		@DenominatorOnlyDrvDivisionList varchar(255) = '',
		@DenominatorOnlyDrvTerminalList varchar(255) = '',
		@DenominatorOnlyDrvFleetList varchar(255) = '',
		@DenominatorOnlyDrvBranchList varchar(255) = '',
		@DenominatorOnlyDrvDomicileList varchar(255) = '',
		@DenominatorOnlyDrvTeamLeaderList varchar(255) = '',

		@DenominatorExcludeDrvType1List varchar(255) = '',
		@DenominatorExcludeDrvType2List varchar(255) = '',
		@DenominatorExcludeDrvType3List varchar(255) = '',
		@DenominatorExcludeDrvType4List varchar(255) = '',
		@DenominatorExcludeDrvCompanyList varchar(255) = '',
		@DenominatorExcludeDrvDivisionList varchar(255) = '',
		@DenominatorExcludeDrvTerminalList varchar(255) = '',
		@DenominatorExcludeDrvFleetList varchar(255) = '',
		@DenominatorExcludeDrvBranchList varchar(255) = '',
		@DenominatorExcludeDrvDomicileList varchar(255) = '',
		@DenominatorExcludeDrvTeamLeaderList varchar(255) = '',

		@MetricCode varchar(255)= 'DriverCount'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Operador,2:Flota,3:Division

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

	Set @NumeratorOnlyDrvType1List= ',' + ISNULL(@NumeratorOnlyDrvType1List,'') + ','
	Set @NumeratorOnlyDrvType2List= ',' + ISNULL(@NumeratorOnlyDrvType2List,'') + ','
	Set @NumeratorOnlyDrvType3List= ',' + ISNULL(@NumeratorOnlyDrvType3List,'') + ','
	Set @NumeratorOnlyDrvType4List= ',' + ISNULL(@NumeratorOnlyDrvType4List,'') + ','
	Set @NumeratorOnlyDrvCompanyList= ',' + ISNULL(@NumeratorOnlyDrvCompanyList,'') + ','
	Set @NumeratorOnlyDrvDivisionList= ',' + ISNULL(@NumeratorOnlyDrvDivisionList,'') + ','
	Set @NumeratorOnlyDrvTerminalList= ',' + ISNULL(@NumeratorOnlyDrvTerminalList,'') + ','
	Set @NumeratorOnlyDrvFleetList= ',' + ISNULL(@NumeratorOnlyDrvFleetList,'') + ','
	Set @NumeratorOnlyDrvBranchList= ',' + ISNULL(@NumeratorOnlyDrvBranchList,'') + ','
	Set @NumeratorOnlyDrvDomicileList= ',' + ISNULL(@NumeratorOnlyDrvDomicileList,'') + ','
	Set @NumeratorOnlyDrvTeamLeaderList= ',' + ISNULL(@NumeratorOnlyDrvTeamLeaderList,'') + ','

	Set @NumeratorExcludeDrvType1List= ',' + ISNULL(@NumeratorExcludeDrvType1List,'') + ','
	Set @NumeratorExcludeDrvType2List= ',' + ISNULL(@NumeratorExcludeDrvType2List,'') + ','
	Set @NumeratorExcludeDrvType3List= ',' + ISNULL(@NumeratorExcludeDrvType3List,'') + ','
	Set @NumeratorExcludeDrvType4List= ',' + ISNULL(@NumeratorExcludeDrvType4List,'') + ','
	Set @NumeratorExcludeDrvCompanyList= ',' + ISNULL(@NumeratorExcludeDrvCompanyList,'') + ','
	Set @NumeratorExcludeDrvDivisionList= ',' + ISNULL(@NumeratorExcludeDrvDivisionList,'') + ','
	Set @NumeratorExcludeDrvTerminalList= ',' + ISNULL(@NumeratorExcludeDrvTerminalList,'') + ','
	Set @NumeratorExcludeDrvFleetList= ',' + ISNULL(@NumeratorExcludeDrvFleetList,'') + ','
	Set @NumeratorExcludeDrvBranchList= ',' + ISNULL(@NumeratorExcludeDrvBranchList,'') + ','
	Set @NumeratorExcludeDrvDomicileList= ',' + ISNULL(@NumeratorExcludeDrvDomicileList,'') + ','
	Set @NumeratorExcludeDrvTeamLeaderList= ',' + ISNULL(@NumeratorExcludeDrvTeamLeaderList,'') + ','

	Set @DenominatorOnlyDrvType1List= ',' + ISNULL(@DenominatorOnlyDrvType1List,'') + ','
	Set @DenominatorOnlyDrvType2List= ',' + ISNULL(@DenominatorOnlyDrvType2List,'') + ','
	Set @DenominatorOnlyDrvType3List= ',' + ISNULL(@DenominatorOnlyDrvType3List,'') + ','
	Set @DenominatorOnlyDrvType4List= ',' + ISNULL(@DenominatorOnlyDrvType4List,'') + ','
	Set @DenominatorOnlyDrvCompanyList= ',' + ISNULL(@DenominatorOnlyDrvCompanyList,'') + ','
	Set @DenominatorOnlyDrvDivisionList= ',' + ISNULL(@DenominatorOnlyDrvDivisionList,'') + ','
	Set @DenominatorOnlyDrvTerminalList= ',' + ISNULL(@DenominatorOnlyDrvTerminalList,'') + ','
	Set @DenominatorOnlyDrvFleetList= ',' + ISNULL(@DenominatorOnlyDrvFleetList,'') + ','
	Set @DenominatorOnlyDrvBranchList= ',' + ISNULL(@DenominatorOnlyDrvBranchList,'') + ','
	Set @DenominatorOnlyDrvDomicileList= ',' + ISNULL(@DenominatorOnlyDrvDomicileList,'') + ','
	Set @DenominatorOnlyDrvTeamLeaderList= ',' + ISNULL(@DenominatorOnlyDrvTeamLeaderList,'') + ','

	Set @DenominatorExcludeDrvType1List= ',' + ISNULL(@DenominatorExcludeDrvType1List,'') + ','
	Set @DenominatorExcludeDrvType2List= ',' + ISNULL(@DenominatorExcludeDrvType2List,'') + ','
	Set @DenominatorExcludeDrvType3List= ',' + ISNULL(@DenominatorExcludeDrvType3List,'') + ','
	Set @DenominatorExcludeDrvType4List= ',' + ISNULL(@DenominatorExcludeDrvType4List,'') + ','
	Set @DenominatorExcludeDrvCompanyList= ',' + ISNULL(@DenominatorExcludeDrvCompanyList,'') + ','
	Set @DenominatorExcludeDrvDivisionList= ',' + ISNULL(@DenominatorExcludeDrvDivisionList,'') + ','
	Set @DenominatorExcludeDrvTerminalList= ',' + ISNULL(@DenominatorExcludeDrvTerminalList,'') + ','
	Set @DenominatorExcludeDrvFleetList= ',' + ISNULL(@DenominatorExcludeDrvFleetList,'') + ','
	Set @DenominatorExcludeDrvBranchList= ',' + ISNULL(@DenominatorExcludeDrvBranchList,'') + ','
	Set @DenominatorExcludeDrvDomicileList= ',' + ISNULL(@DenominatorExcludeDrvDomicileList,'') + ','
	Set @DenominatorExcludeDrvTeamLeaderList= ',' + ISNULL(@DenominatorExcludeDrvTeamLeaderList,'') + ','

	Declare @NumeratorList Table (lgh_Driver varchar(15),fleet varchar(20), div varchar (10))
	Declare @DenominatorList Table (lgh_Driver varchar(15))


	 

----------------------Numerador Total---------------------------------------------------------------------------------------
	



			Insert into @NumeratorList (lgh_Driver)
			Select Driver
			from dbo.fnc_TMWRN_DriverCount3 
				(
					@Numerator,@NumeratorOnlyDrvType1List,@NumeratorOnlyDrvType2List
					,@NumeratorOnlyDrvType3List,@NumeratorOnlyDrvType4List
					,@NumeratorOnlyDrvCompanyList,@NumeratorOnlyDrvDivisionList
					,@NumeratorOnlyDrvTerminalList,@NumeratorOnlyDrvFleetList,@NumeratorOnlyDrvBranchList
					,@NumeratorOnlyDrvDomicileList,@NumeratorOnlyDrvTeamLeaderList
					,@NumeratorExcludeDrvType1List,@NumeratorExcludeDrvType2List
					,@NumeratorExcludeDrvType3List,@NumeratorExcludeDrvType4List
					,@NumeratorExcludeDrvCompanyList,@NumeratorExcludeDrvDivisionList
					,@NumeratorExcludeDrvTerminalList,@NumeratorExcludeDrvFleetList
					,@NumeratorExcludeDrvBranchList,@NumeratorExcludeDrvDomicileList
					,@NumeratorExcludeDrvTeamLeaderList,@DateStart
				)
	

UPDATE @NumeratorList set div =(select mpp_type4 from manpowerprofile with (nolock) where lgh_driver = manpowerprofile.mpp_id)
UPDATE @NumeratorList set fleet = (select name from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select mpp_fleet from manpowerprofile where manpowerprofile.mpp_id = lgh_driver))


--------------------CALCULO DEL TOTAL----------------------------------------------------------------------------------------------------------------------------------------------------
   
	
	
	-- set the Metric Numerator & Denominator values
	Set @ThisCount = (Select count(lgh_Driver) from @NumeratorList)

	Set @ThisTotal =
		Case When @Denominator = 'Day' then 
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		Else
			(Select count(lgh_Driver) from @DenominatorList)
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	-- Show Detail if necessary
	

------------------------DETALLES------------------------------------------------------------------------------------------------------------------------------------------------------------


--NIVEL OPERADOR

	If @ShowDetail = 1
		BEGIN
			Select Operador = lgh_Driver,
             NombreOperador = (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile with (nolock) where mpp_id = lgh_Driver),
            Flota = fleet,
            Division = (select mpp_type4 from manpowerprofile  with (nolock)where lgh_driver = manpowerprofile.mpp_id),
            Tractor = replace((select mpp_tractornumber from manpowerprofile  with (nolock)where lgh_driver = manpowerprofile.mpp_id),'UNKNOWN','SIN TRC.')
			From @NumeratorList
		END

---NIVEL FLOTA

	If @ShowDetail = 2
		BEGIN
			Select 
            Flota = replace(fleet,'UNKNOWN','Sin Flota'),
            Operadores = count(lgh_Driver)
			From @NumeratorList
            group by fleet
            order by   count(lgh_Driver) DESC
		END


---NIVEL DIVISION

If @ShowDetail = 3
		BEGIN
			Select 
            Division = REPLACE(div,'UNK','Sin DIV'),
            Operadores = count(lgh_Driver)
			From @NumeratorList
            group by div
            order by   count(lgh_Driver) DESC
		END





	SET NOCOUNT OFF

-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'DriverCount',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Driver Count Metrics',
		@sCaptionFull = 'Driver Count Metrics',
		@sProcedureName = 'Metric_DriverCount',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
