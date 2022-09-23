SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[Metric_DrvAltasBajas] 
	(
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

		--Additional/Optional Parameters
		@modo varchar(10) = '',                 --------------ALTAS,BAJAS
		@OnlyDrvClass1List varchar(128) ='',
		@OnlyDrvClass2List varchar(128) ='',
		@OnlyDrvClass3List varchar(128) ='',
		@OnlyDrvClass4List varchar(128) ='',
		@OnlyDrvTerminalList varchar(255)='',
		@OnlyTeamLeaderList varchar(255)='',
		--@UseDriverTotal char(1)='N',
		@OnlyDrvFleetList varchar(128)='',
		@OnlyDrvDivisionList varchar(128)='',
		@OnlyDrvDomicileList varchar(128)='',
		@OnlyDrvCompanyList varchar(128)='',
		@ExcludeDriversWithinProbationaryPeriodYN varchar(1)='N',
		@ProbationaryPeriodDays int = 60
	)
AS



	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Detalle


	Set @OnlyDrvClass1List= ',' + ISNULL(@OnlyDrvClass1List,'') + ','
	Set @OnlyDrvClass2List= ',' + ISNULL(@OnlyDrvClass2List,'') + ','
	Set @OnlyDrvClass3List= ',' + ISNULL(@OnlyDrvClass3List,'') + ','
	Set @OnlyDrvClass4List= ',' + ISNULL(@OnlyDrvClass4List,'') + ','
	Set @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
	Set @OnlyDrvFleetList = ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	Set @OnlyDrvDivisionList = ',' + ISNULL(@OnlyDrvDivisionList,'') + ','	
	Set @OnlyDrvDomicileList = ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	Set @OnlyDrvCompanyList = ',' + ISNULL(@OnlyDrvCompanyList,'') + ','	




	if @modo = 'bajas' 
	begin

	--this count son las bajas del periodo
	SELECT  @ThisCount = (	
							SELECT COUNT(*) 
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
							

										/*
									AND (@OnlyDrvClass1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvClass1List) >0)
									AND (@OnlyDrvClass2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvClass2list) >0)
									AND (@OnlyDrvClass3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvClass3List) >0)
									AND (@OnlyDrvClass4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvClass4List) >0)
									AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
									AND (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
									AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
									AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0)
									AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
									AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
		
		*/
	
						)

    end

	else if @modo = 'altas' 
	begin

	--this count son las bajas del periodo
	SELECT  @ThisCount = 

	(	
							SELECT COUNT(*) 
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_hiredate >= @DateStart AND mpp_hiredate < @DateEnd
						

								AND (
											(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
											OR
											(
												@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
												AND
												DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
											)
										)
				
		
	
						)
					
    end







    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


IF (@ShowDetail = 1 and @modo = 'bajas')
	BEGIN

	
							SELECT 
							mpp_id as id,
							mpp_firstname +' ' + mpp_lastname as Operador, 
							mpp_terminationdt as fechasalida,
							(select name from labelfile where labeldefinition = 'fleet' and abbr = mpp_fleet) as Flota,
							   ( case  
                when mpp_fleet in ('01','08') then 'Abierto'
                when mpp_fleet in ('04','10','11','12','16','03') then 'Dedicado'               
                when mpp_fleet in ('02','05','14','15','20') then 'Especializado' end) as Division
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd



END


IF (@ShowDetail = 1 and @modo = 'altas')
	BEGIN

	
							SELECT 
							mpp_id as id,
							mpp_firstname +' ' + mpp_lastname as Operador, 
							mpp_hiredate as fechacontratacion,
							(select name from labelfile where labeldefinition = 'fleet' and abbr = mpp_fleet) as Flota,
							   ( case  
                when mpp_fleet in ('01','08') then 'Abierto'
                when mpp_fleet in ('04','10','11','12','16','03') then 'Dedicado'               
                when mpp_fleet in ('02','05','14','15','20') then 'Especializado' end) as Division
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_hiredate >= @DateStart AND mpp_hiredate < @DateEnd



END
GO
