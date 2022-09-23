SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getTruckDetails] (@drhid AS INTEGER)
AS
BEGIN
DECLARE @count AS INTEGER
DECLARE @cnt AS INTEGER = 1
DECLARE @cntdays AS INTEGER = 1
DECLARE @asgn_id AS VARCHAR(10)
DECLARE @next_asgn_id AS VARCHAR(10)
DECLARE @asgn_endate AS DATETIME
DECLARE @today AS DATETIME = getdate()
DECLARE @day2 AS DATETIME, @day3 AS DATETIME, @day4 AS DATETIME, @day5 AS DATETIME, @day6 AS DATETIME, @day7 AS DATETIME
DECLARE @edate AS DATETIME
DECLARE @eday AS INTEGER, @lday AS INTEGER = 7
DECLARE @startdate AS DATETIME
DECLARE @enddate AS DATETIME 
DECLARE @rec AS INTEGER
DECLARE @companyID AS VARCHAR(100)
DECLARE @currentRow AS INTEGER
DECLARE @NextRow AS INTEGER
DECLARE @leadasgndate AS DATETIME

SET @companyID = (SELECT ISNULL(drh_dcid,'') FROM directroutehdr WHERE drh_id =@drhid) 

SET @day2 = (SELECT DATEADD(day,1,@today))
SET @day3 = (SELECT DATEADD(day,2,@today))
SET @day4 = (SELECT DATEADD(day,3,@today))
SET @day5 = (SELECT DATEADD(day,4,@today))
SET @day6 = (SELECT DATEADD(day,5,@today))
SET @day7 = (SELECT DATEADD(day,6,@today))

--IF EXISTS(SELECT 1 FROM sys.tables WHERE name ='DRRouteDefaults')
--BEGIN
--	SET @rec = (SELECT COUNT(*) FROM DRRouteDefaults WHERE CompanyID = @companyID)
--	IF(@rec <=0)
--	INSERT INTO DRRouteDefaults(CompanyID,CompanyName,Available,OneWay,Redispatch,Pallets,Cubes,MaxLayover) VALUES(@companyID,@companyID,'TRUE','FALSE','FALSE',45000,45000,10) 
--END 

IF EXISTS(SELECT 1 FROM sys.tables WHERE name ='DirectRouteTruckDetails')
DELETE FROM DirectRouteTruckDetails

select ROW_NUMBER() over(order by asgn_id,asgn_date) as rn, * into  #temp from assetassignment  where asgn_type ='TRL' AND asgn_enddate >= @today 
AND asgn_enddate < DATEADD(day,7,@today) 
order by  rn 
SET @count = (select count(*) from #temp )

WHILE @cnt <= @count
	BEGIN
	    SET @currentRow = (SELECT TOP(1) rn FROM #temp ORDER BY rn)
		SET @NextRow = @currentRow + 1
		SET @asgn_id = (SELECT TOP(1) asgn_id FROM #temp ORDER BY asgn_id,asgn_date)
		--SET @next_asgn_id = (SELECT TOP(1) LEAD(asgn_id) OVER (ORDER BY asgn_id) FROM #temp ORDER BY  asgn_id,asgn_date)
		SET @next_asgn_id = (SELECT  asgn_id FROM #temp WHERE  rn = @NextRow )
		SET @asgn_endate = (SELECT TOP(1)  asgn_enddate FROM #temp WHERE asgn_enddate >= @today AND asgn_enddate < DATEADD(day,7,@today) AND asgn_id = @asgn_id ORDER BY  asgn_id,asgn_date)
		
		IF(CAST(@asgn_endate AS DATE) = CAST(@today AS DATE))
			 SET @eday = 1
		IF(CAST(@asgn_endate AS DATE) = CAST(@day2 AS DATE))
			 SET @eday = 2
		IF(CAST(@asgn_endate AS DATE) = CAST(@day3 AS DATE))
			 SET @eday = 3
		IF(CAST(@asgn_endate AS DATE) = CAST(@day4 AS DATE))
			 SET @eday = 4
		IF(CAST(@asgn_endate AS DATE) = CAST(@day5 AS DATE))
			 SET @eday = 5
		IF(CAST(@asgn_endate AS DATE) = CAST(@day6 AS DATE))
			 SET @eday = 6
		IF(CAST(@asgn_endate AS DATE) = CAST(@day7 AS DATE))
			 SET @eday = 7

		IF(@asgn_id = @next_asgn_id)
		BEGIN
			 SET @leadasgndate = (SELECT  asgn_date FROM #temp WHERE  rn = @NextRow )
			 SET @lday = (SELECT TOP (1) DATEDIFF(day,asgn_enddate,@leadasgndate)+1 FROM #temp WHERE asgn_id =@asgn_id)
			-- Lead(asgn_date) over (order by asgn_id,asgn_date)) 
		     INSERT INTO DirectRouteTruckDetails
			 ([drh_id],[trl_id],[trl_type],[trl_gps_latitude],[trl_gps_longitude],[address],[companyID],[city],[state],[zipcode],[Estart],[Eday],[Lday],[LatFinish],[trl_terminal],
			  [Updated_on],[trl_app_eqcodes])
			 
			 SELECT TOP(1) @drhid,trl_id,trl_type1,trl_gps_latitude,trl_gps_longitude,cmp_address1,company.cmp_id,cty_name,cmp_state,cmp_zip,@asgn_endate AS [Estart],@eday AS [eday],@lday AS [lday],@asgn_endate as [LatFinish],
			 trl_terminal, @today,trl_app_eqcodes
			 FROM city,company,trailerprofile 
			 RIGHT OUTER JOIN #temp ON trl_id=asgn_id
			 WHERE   asgn_id=@asgn_id AND asgn_type ='TRL'	AND trailerprofile.trl_avail_cmp_id = company.cmp_id AND cmp_city=city.cty_code		  
			 SET @lday = 7
			 DELETE TOP (1) FROM #temp
			
		END
		ELSE
		BEGIN
			--SET @lday = @lday - @eday
			INSERT INTO DirectRouteTruckDetails
			([drh_id],[trl_id],[trl_type],[trl_gps_latitude],[trl_gps_longitude],[address],[companyID],[city],[state],[zipcode],[Estart],[Eday],[Lday],[LatFinish],[trl_terminal],[Updated_on],
			 [trl_app_eqcodes])
			 
			SELECT TOP(1) @drhid,trl_id,trl_type1,trl_gps_latitude,trl_gps_longitude,cmp_address1,company.cmp_id,cty_name,cmp_state,cmp_zip,@asgn_endate AS [Estart],@eday AS [eday],@lday AS [lday],@asgn_endate as [LatFinish],
			trl_terminal, @today,[trl_app_eqcodes]
			FROM city,company,trailerprofile RIGHT OUTER JOIN #temp ON trl_id=asgn_id  
			WHERE  asgn_id=@asgn_id AND asgn_type ='TRL' AND trl_status not in ('OUT','INSHOP') AND trailerprofile.trl_avail_cmp_id = company.cmp_id AND cmp_city=city.cty_code order by asgn_id

			SET @lday = 7			 
			DELETE TOP (1) FROM #temp 
		END 
		SET @currentRow =@NextRow
		SET @cnt = @cnt + 1
	END
	SET @eday = 1
	INSERT INTO DirectRouteTruckDetails
					([drh_id],[trl_id],[trl_type],[trl_gps_latitude],[trl_gps_longitude],[address],[companyID],[city],[state],[zipcode],[Estart],[Lday],[LatFinish],[trl_terminal],
					[Updated_on],[trl_app_eqcodes],[Eday])
			 
	SELECT  @drhid,trl_id,trl_type1,trl_gps_latitude,trl_gps_longitude,cmp_address1,company.cmp_id,cty_name,cmp_state,cmp_zip,'2017-04-20 00:01:00.000'  AS [Estart],
	7 AS [Lday],@asgn_endate as [LatFinish],trl_terminal,
	@today,trl_app_eqcodes,
	CASE  trl_avail_date WHEN @today THEN  1
	 WHEN @day2 THEN  2
	 WHEN  @day3 THEN 3
	 WHEN  @day4 THEN  4
	 WHEN  @day5 THEN  5
	 WHEN  @day6 THEN  6
	 WHEN @day7 THEN 7
	 ELSE @eday 
	END 
	
	FROM city,company,trailerprofile
	WHERE   trl_status = 'AVL' AND  
	trl_avail_date <= @today AND trailerprofile.trl_avail_cmp_id =@companyID 
	AND trailerprofile.trl_avail_cmp_id = company.cmp_id AND cmp_city=city.cty_code
	AND trl_id NOT IN (SELECT trl_id from DirectRouteTruckDetails )
	
	SET @lday = 7		

	exec DirecRoutePostProcess
	
	
END
GO
GRANT EXECUTE ON  [dbo].[getTruckDetails] TO [public]
GO
