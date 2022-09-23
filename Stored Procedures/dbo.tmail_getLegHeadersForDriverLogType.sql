SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[tmail_getLegHeadersForDriverLogType]  
							@CheckDateTime as DateTime,  
							@MinStartDate as DateTime,  
							@LoadDescriptionChanged as int,  
							@DriverlogtypeList as varchar(500),  
							@LegHeaderStatusList as varchar(500),
							@CMPMinUpdateDate AS DATETIME
AS  
BEGIN  
 SET NOCOUNT ON;  


 DECLARE @work VARCHAR(500)    
 -------------------------------------------------------------------------------  
 -- Array delimited support  
 DECLARE @TempList table  
		 (  
		  Driverlogtype varchar(50)  
		 )  
 DECLARE @Driverlogtype varchar(20), @Pos int

 SET @DriverlogtypeList = LTRIM(RTRIM(@DriverlogtypeList))+ ','  
 SET @Pos = CHARINDEX(',', @DriverlogtypeList, 1)  
  
	IF REPLACE(@DriverlogtypeList, ',', '') <> ''  
		BEGIN  
			WHILE @Pos > 0  
				BEGIN  
					------------------------------------------------------------
					SET @Driverlogtype = LTRIM(RTRIM(LEFT(@DriverlogtypeList, @Pos - 1)))  
					------------------------------------------------------------
					IF @Driverlogtype <> ''  
						BEGIN  
							INSERT INTO @TempList 
										(Driverlogtype) 
								 VALUES 
										(CAST(@Driverlogtype AS varchar))  
						END  
					------------------------------------------------------------
					SET @DriverlogtypeList = RIGHT(@DriverlogtypeList, LEN(@DriverlogtypeList) - @Pos)  
					SET @Pos = CHARINDEX(',', @DriverlogtypeList, 1)  
					------------------------------------------------------------
					SET @work = REPLACE (@DriverlogtypeList,',','')
					-- Note: Replace does not change then original value of 
					--       @DriverlogtypeList
					IF @work  = ''
						BEGIN
							SET @Pos = 0
						END
					------------------------------------------------------------
				END  
		END  
  
 -------------------------------------------------------------------------------
 -- Second delimited array of leg header status  
 -- 02/14/2012  
	DECLARE @TempStatusList table  
			(  
			 LegHeaderStatus varchar(50)  
			)  
	DECLARE @LegHeaderStatus varchar(20), @LHPos int  

	SET @LegHeaderStatusList = LTRIM(RTRIM(@LegHeaderStatusList))+ ','  
	SET @LHPos = CHARINDEX(',', @LegHeaderStatusList, 1)  
	----------------------------------------------------------------------------
	IF REPLACE(@LegHeaderStatusList, ',', '') <> ''  
		BEGIN  
			WHILE @LHPos > 0  
				BEGIN  
					------------------------------------------------------------
					SET @LegHeaderStatus = LTRIM(RTRIM(LEFT(@LegHeaderStatusList, @LHPos - 1)))  
					------------------------------------------------------------
					IF @LegHeaderStatus <> ''  
						BEGIN  
							INSERT INTO @TempStatusList (LegHeaderStatus) VALUES (CAST(@LegHeaderStatus AS varchar))  
						END  
					------------------------------------------------------------
					SET @LegHeaderStatusList = RIGHT(@LegHeaderStatusList, LEN(@LegHeaderStatusList) - @LHPos)  
					SET @LHPos = CHARINDEX(',', @LegHeaderStatusList, 1)  
					------------------------------------------------------------
					SET @work = REPLACE (@LegHeaderStatusList,',','')
					-- Note: Replace does not change then original value of 
					--       @LegHeaderStatusList
					IF @work  = ''
						BEGIN
							SET @Pos = 0
						END
					------------------------------------------------------------
				END  
		END  
   
	-------------------------------------------------------------------------------
	SELECT 
			legheader.lgh_number,  
			start_city.cty_GMTDelta start_cty_GMTDelta,  
			dbo.ToZulu( legheader.lgh_startdate, 
						start_city.cty_GMTDelta, 
						CASE  start_city.cty_DSTApplies 
							WHEN 'Y' THEN 1 
							ELSE 0 
						END,
						0) lgh_startdate_GMT,
			convert(varchar(10),start_city.cty_code) + '-' + start_city.cty_name + ', ' + start_city.cty_state AS start_cty_info,
			legheader.lgh_startdate,  
			end_city.cty_GMTDelta end_cty_GMTDelta,  
			dbo.ToZulu( legheader.lgh_enddate, 
						end_city.cty_GMTDelta, 
						CASE  end_city.cty_DSTApplies 
							WHEN 'Y' THEN 1 
							ELSE 0 
						END,
						0) lgh_enddate_GMT,  
			convert(varchar(10),end_city.cty_code) + '-' + end_city.cty_name + ', ' + end_city.cty_state AS end_cty_info,
			legheader.lgh_enddate,  
			legheader.lgh_tractor,  
			orderheader.ord_number,				-- This is the order number visible to client
			legheader.ord_hdrnumber,			-- This is the unique identifier order number that TotalMail uses.  Not visible.
			orderheader.ord_originpoint,
			orderheader.ord_destpoint,  
			orderheader.cmd_code,  
			commodity.cmd_name,  
			legheader.mfh_number,
			legheader.lgh_driver1,
			legheader.lgh_driver2
	FROM 
			legheader WITH (NOLOCK)  
			INNER JOIN orderheader WITH (NOLOCK) ON  
				legheader.ord_hdrnumber = orderheader.ord_hdrnumber  
			INNER JOIN commodity WITH (NOLOCK) ON  
				orderheader.cmd_code = commodity.cmd_code  
			INNER JOIN manpowerprofile WITH (NOLOCK) ON  
				manpowerprofile.mpp_id = legheader.lgh_driver1  
			INNER JOIN city  AS start_city WITH (NOLOCK) ON 
				lgh_startcity = start_city.cty_code  
			INNER JOIN city AS end_city WITH (NOLOCK) ON 
				lgh_endcity = end_city.cty_code  
			INNER JOIN @TempList AS t ON 
				t.Driverlogtype = manpowerprofile.mpp_driverlogtype  
			INNER JOIN @TempStatusList AS tsl ON 
				tsl.LegHeaderStatus = legheader.lgh_outstatus  
	  WHERE 
			-- If either one of these OR blocks is true the data will be selected.
			--------------------------------------------------------------------
			( 
				(legheader.lgh_updatedon > @CheckDateTime)  
				AND  
				(legheader.lgh_startdate > @MinStartDate)  
				--AND  
				--(legheader.lgh_outstatus IN ('STD', 'CMP'))  
			)
			--------------------------------------------------------------------
		OR  
			--------------------------------------------------------------------
			(
				--(  
				-- legheader.lgh_outstatus IN ('STD', 'CMP')  
				--)  
				--AND  
				(legheader.lgh_startdate > @MinStartDate)  
				AND 
				(@LoadDescriptionChanged = 1)  
			)
			--------------------------------------------------------------------
		OR
			--------------------------------------------------------------------
			(
				(legheader.lgh_startdate > @MinStartDate)
				AND
				(legheader.lgh_outstatus = 'CMP')
				AND
				(legheader.lgh_enddate > @CMPMinUpdateDate )
			)
			-------------------------------------------------------------------- 
    
 END  
GO
GRANT EXECUTE ON  [dbo].[tmail_getLegHeadersForDriverLogType] TO [public]
GO
