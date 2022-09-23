SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[origindest_location]
	@cmp1 varchar(8),
	@cmp2 varchar(8),
	@cty1 int,
	@cty2 int

 as
/*
This procedure should be passed 2 points either two companies or
2 cities or a company and a city.  It will return the country,
State, city, and zip data for both.  It is used for trip type 
matching in applying tarrifs.  Any trip has an origin and destination.
The trip type examines where these are and matched to the trip type
defintions.

Company ids should be used if available. If a company ID is not, then pass the 
city


MODIFICATION LOG

12/23/00 created DPETE

To pass 2 companies
   exec  twopoint_locationinfo 'DET1','CHIC1',0,0
To pass 2 cities
    exec  twopoint_locationinfo 'UNKNOWN','UNKNOWN',89324,15663
To pass a company and a city
    exec  twopoint_locationinfo 'DET!','UNKNOWN',89324,0
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
*/

DECLARE @jurisvalid VARCHAR(60)

SELECT @jurisvalid = ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
  FROM generalinfo 
 WHERE gi_name = 'JURISVALID'

SELECT @cmp1 = UPPER(ISNULL(@cmp1,'UNKNOWN'))
IF RTRIM(@cmp1) = '' SELECT @cmp1 = 'UNKNOWN'
SELECT @cmp2 = UPPER(ISNULL(@cmp2,'UNKNOWN'))
IF RTRIM(@cmp2) = '' SELECT @cmp2 = 'UNKNOWN'
SELECT @cty1 = ISNULL(@cty1,0)
SELECT @cty2 = ISNULL(@cty2,0)
If @cmp1 = 'UNKNOWN' and @cmp2 <> 'UNKNOWN'
  BEGIN
    SELECT @cmp1 = @cmp2
    SELECT @cmp2 = 'UNKNOWN'
  END
IF @cty1 = 0 and @cty2 > 0
  BEGIN
    SELECT @cty1 = @cty2
    SELECT @cty2 = 0
  END


CREATE TABLE #temp_2loc (
cmp1_id varchar(8) null,
ZZZ1 varchar(11) null,
TTT1 int null,
SSS1 varchar(6) null,
CCC1 varchar(50) null,
cmp2_id varchar(8) null,
ZZZ2 varchar(11) null,
TTT2 int null,
SSS2 varchar(6) null,
CCC2 varchar(50) null
)


IF @cmp1 <> 'UNKNOWN' and @cmp2 <> 'UNKNOWN'
  BEGIN
    INSERT INTO #temp_2loc
    SELECT DISTINCT cmp1.cmp_id ,
	ZZZ1 = 
	  CASE 
	    WHEN ISNULL(cmp1.cmp_zip,'') > '' THEN cmp1.cmp_zip
	    ELSE ISNULL(cty1.cty_zip,'')
	  END ,  
         ISNULL(cmp1.cmp_city,0) TTT1,   
         ISNULL(cty1.cty_state,'') SSS1, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
              ELSE ISNULL(cntry1.stc_country_c,'') 
         END CCC1, 
	cmp2.cmp_id,
	ZZZ2 = 
	  CASE 
	    WHEN ISNULL(cmp2.cmp_zip,'') > '' THEN cmp2.cmp_zip
	    ELSE ISNULL(cty2.cty_zip,'')
	  END ,    
         ISNULL(cmp2.cmp_city,0) TTT2,   
         ISNULL(cty2.cty_state,'') SSS2, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty2.cty_country, '') 
              ELSE ISNULL(cntry2.stc_country_c,'') 
         END CCC2 
    FROM dbo.statecountry cntry1  RIGHT OUTER JOIN  dbo.city cty1  ON  cntry1.stc_state_c  = cty1.cty_state ,
		 dbo.statecountry cntry2  RIGHT OUTER JOIN  dbo.city cty2  ON  cntry2.stc_state_c  = cty2.cty_state ,
		 dbo.company cmp1,
		 dbo.company cmp2 
    WHERE cmp1.cmp_id = @cmp1
	AND cty1.cty_code = cmp1.cmp_city
	AND cmp2.cmp_id = @cmp2
	AND cty2.cty_code = cmp2.cmp_city
--	AND cntry1.stc_state_c =* cty1.cty_state
--	AND cntry2.stc_state_c =* cty2.cty_state
  END
IF @cmp1 <> 'UNKNOWN' and @cmp2 = 'UNKNOWN'
  BEGIN
      INSERT INTO #temp_2loc
      SELECT DISTINCT cmp1.cmp_id ,
	ZZZ1 = 
	  CASE 
	    WHEN ISNULL(cmp1.cmp_zip,'') > '' THEN cmp1.cmp_zip
	    ELSE ISNULL(cty1.cty_zip,'')
	  END ,  
         ISNULL(cmp1.cmp_city,0) TTT1,   
         ISNULL(cty1.cty_state,'') SSS1, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
              ELSE ISNULL(cntry1.stc_country_c,'') 
         END CCC1, 
	@cmp2 cmp2_id,
	ZZZ2 = ISNULL(cty2.cty_zip,''),    
         ISNULL(cty2.cty_code,0) TTT2,   
         ISNULL(cty2.cty_state,'') SSS2, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty2.cty_country, '') 
              ELSE ISNULL(cntry2.stc_country_c,'') 
         END CCC2 
    FROM dbo.statecountry cntry1  RIGHT OUTER JOIN  dbo.city cty1  ON  cntry1.stc_state_c  = cty1.cty_state ,
		 dbo.statecountry cntry2  RIGHT OUTER JOIN  dbo.city cty2  ON  cntry2.stc_state_c  = cty2.cty_state ,
		 dbo.company cmp1  
    WHERE cmp1.cmp_id = @cmp1
	AND cty1.cty_code = cmp1.cmp_city
	AND cty2.cty_code = @cty2
--	AND cntry1.stc_state_c =* cty1.cty_state
--	AND cntry2.stc_state_c =* cty2.cty_state

  END
IF @cmp1 = 'UNKNOWN' and @cmp2 = 'UNKNOWN'
  BEGIN
      INSERT INTO #temp_2loc
      SELECT DISTINCT @cmp1 cmp1_id ,
	ZZZ1 = ISNULL(cty1.cty_zip,''),  
         cty1.cty_code TTT1,   
         ISNULL(cty1.cty_state,'') SSS1, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
              ELSE ISNULL(cntry1.stc_country_c,'') 
         END CCC1, 
	 @cmp2 cmp2_id,
	 ZZZ2 = ISNULL(cty2.cty_zip,''),    
         cty2.cty_code TTT2,   
         ISNULL(cty2.cty_state,'') SSS2, 
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty2.cty_country, '') 
              ELSE ISNULL(cntry2.stc_country_c,'') 
         END CCC2 
      FROM	dbo.statecountry cntry1  RIGHT OUTER JOIN  dbo.city cty1  ON  cntry1.stc_state_c  = cty1.cty_state ,
			dbo.statecountry cntry2  RIGHT OUTER JOIN  dbo.city cty2  ON  cntry2.stc_state_c  = cty2.cty_state  
      WHERE  cty1.cty_code = @cty1
	AND cty2.cty_code = @cty2
--	AND cntry1.stc_state_c =* cty1.cty_state
--	AND cntry2.stc_state_c =* cty2.cty_state

  END

SELECT * FROM #temp_2loc


GO
GRANT EXECUTE ON  [dbo].[origindest_location] TO [public]
GO
