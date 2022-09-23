SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[origin_location]
	@cmp1 varchar(8),
	@cty1 int

 as
/**
 * DESCRIPTION:
	This procedure should be passed 1 point either a compnay or a city.
	It will return the country,
	State, city, and zip data .  It is used for trip type 
	matching in applying tarrifs for regions.  
	Company ids should be used if available. If a company ID is not, then pass the 
	city
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	12/23/00 created DPETE
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @jurisvalid VARCHAR(60)

SELECT @jurisvalid = ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
  FROM generalinfo 
 WHERE gi_name = 'JURISVALID'


SELECT @cmp1 = UPPER(ISNULL(@cmp1,'UNKNOWN'))
IF RTRIM(@cmp1) = '' SELECT @cmp1 = 'UNKNOWN'
SELECT @cty1 = ISNULL(@cty1,0)


CREATE TABLE #temp_1loc (
cmp1_id varchar(8) null,
ZZZ1 varchar(11) null,
TTT1 int null,
SSS1 varchar(6) null,
CCC1 varchar(50) null
)


IF @cmp1 <> 'UNKNOWN' 
  BEGIN
    INSERT INTO #temp_1loc
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
         END CCC1
    FROM dbo.statecountry cntry1  RIGHT OUTER JOIN  dbo.city cty1  ON  cntry1.stc_state_c  = cty1.cty_state ,
		 dbo.company cmp1 
    WHERE cmp1.cmp_id = @cmp1
	AND cty1.cty_code = cmp1.cmp_city
	--AND cntry1.stc_state_c =* cty1.cty_state

  END
ELSE
  BEGIN
      INSERT INTO #temp_1loc
      SELECT DISTINCT @cmp1 cmp1_id ,
	ZZZ1 = ISNULL(cty1.cty_zip,''),  
         ISNULL(cty1.cty_code,0) TTT1,   
         ISNULL(cty1.cty_state,'') SSS1,   
         CASE @JURISVALID 
              WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
              ELSE ISNULL(cntry1.stc_country_c,'') 
         END CCC1
    FROM dbo.statecountry cntry1  RIGHT OUTER JOIN  dbo.city cty1  ON  cntry1.stc_state_c  = cty1.cty_state
    WHERE  cty1.cty_code = @cty1
	--AND cntry1.stc_state_c =* cty1.cty_state
  END


SELECT * FROM #temp_1loc


GO
GRANT EXECUTE ON  [dbo].[origin_location] TO [public]
GO
