SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_DriverTurnoverPct] 
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
-- DETAILOPTIONS=1:Division,2:Flota,3:Operador


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



	--this count son las bajas del periodo
	SELECT  @ThisCount = (	
							SELECT COUNT(*) 
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
									AND (
											(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
											OR
											(
												@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
												AND
												DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
											)
										)
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
						)

-- this total son los operadores actuales en el periodo
	SELECT  @ThisTotal = (	
							SELECT COUNT(*) 
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_terminationdt > @DateEnd
									AND mpp_hiredate <= @DateEnd
									AND (
											(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
											OR
											(
												@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
												AND
												DATEDIFF(day,mpp_hiredate, GETDATE()) > @ProbationaryPeriodDays
											)
										)
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
						)
	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE ((@ThisCount / @ThisTotal) )END 



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


IF (@ShowDetail = 1)
	BEGIN


create table #div  (Division varchar(20), Bajas int, Totales int)
insert into #div

		SELECT 	
               ( case  
                when mpp_fleet in ('01','08') then 'Abierto'
                when mpp_fleet in ('04','10','11','12','16','03') then 'Dedicado'               
                when mpp_fleet in ('02','05','14','15','20') then 'Especializado' end) as Division,
		        sum (CASE WHEN mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd then 1 else  0 end) as Bajas,
                sum (CASE WHEN mpp_hiredate  <=  @DateEnd   AND mpp_terminationdt > @DateEnd then 1 else  0 end) as Totales
        

              -- dbo.fnc_TMWRN_FormatNumbers(100* sum (CASE WHEN mpp_hiredate  >= @DateStart AND mpp_hiredate < @DateEnd then 1 else  0 end) /
               -- sum (CASE WHEN mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd then 1 else  0 end),2) + '%'
  -- as Rotacion
            
                FROM   	manpowerprofile (NOLOCK)
		WHERE  
          -- mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
             
			 (
					(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
					OR
					(
						@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
						AND
						DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
					)
				)
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
           -- AND  (select name from labelfile where (abbr =  mpp_fleet) and labeldefinition = 'fleet' ) <> 'UNKNOWN'
      group by     ( case  
                when mpp_fleet in ('01','08') then 'Abierto'
                when mpp_fleet in ('04','10','11','12','16','03') then 'Dedicado'               
                when mpp_fleet in ('02','05','14','15','20') then 'Especializado' end)
  --  order by rotacion desc

select Division, Bajas, Totales, dbo.fnc_TMWRN_FormatNumbers(100* Bajas/Totales,2) + '%'  as Rotacion from #div where bajas > 0 and totales > 0
order by Rotacion DESC

	END
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


IF (@ShowDetail = 2)
	BEGIN


create table #flota  (Flota varchar(20), Bajas int, Totales int)
insert into #flota

		SELECT 	
               (select name from labelfile where (abbr =  mpp_fleet) and labeldefinition = 'fleet' ) as Flota,
		        sum (CASE WHEN mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd then 1 else  0 end) as Bajas,
                sum (CASE WHEN mpp_hiredate  <=  @DateEnd   AND mpp_terminationdt > @DateEnd then 1 else  0 end) as Totales
        

              -- dbo.fnc_TMWRN_FormatNumbers(100* sum (CASE WHEN mpp_hiredate  >= @DateStart AND mpp_hiredate < @DateEnd then 1 else  0 end) /
               -- sum (CASE WHEN mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd then 1 else  0 end),2) + '%'
  -- as Rotacion
            
                FROM   	manpowerprofile (NOLOCK)
		WHERE  
          -- mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
             
			 (
					(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
					OR
					(
						@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
						AND
						DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
					)
				)
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
           -- AND  (select name from labelfile where (abbr =  mpp_fleet) and labeldefinition = 'fleet' ) <> 'UNKNOWN'
       group by mpp_fleet
  --  order by rotacion desc

select Flota, Bajas, Totales, dbo.fnc_TMWRN_FormatNumbers(100* Bajas/Totales,2) + '%'  as Rotacion from #flota where bajas > 0 and totales > 0
order by Bajas/totales desc
 
	END
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	
	IF (@ShowDetail = 3)
	BEGIN
		SELECT 	    (select name from labelfile where (abbr =  mpp_fleet) and labeldefinition = 'fleet' ) as Flota,
                mpp_teamleader as Lider,
				mpp_terminal as Terminal,
		       	mpp_id as DriverID,
		       	mpp_lastfirst as Nombre,
		       	mpp_terminationdt as [Fecha Terminacion],
		       	mpp_hiredate as [Fecha Contratacion],
		       	Status = CASE WHEN mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd THEN 'TERMINATED' ELSE 'WORKING' END
		FROM   	manpowerprofile (NOLOCK) 
		WHERE  	( (mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd) OR (mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd) )
			AND (
					(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
					OR
					(
						@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
						AND
						DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
					)
				)
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
        order by flota
	END
	

GO
GRANT EXECUTE ON  [dbo].[Metric_DriverTurnoverPct] TO [public]
GO
