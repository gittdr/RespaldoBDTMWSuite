SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ttr_gettriptypes]
	@cmp1 varchar(8),
	@cmp2 varchar(8),
	@cty1 int,
	@cty2 int

 as

/**
 * 
 * NAME:
 * dbo.d_ttr_gettriptypes
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves matching trip types for tarriff applications.
 *
 * RETURNS: 
 * 	ttr_number int
 * 	ttr_code varchar(10)
 * 
 *
 * RESULT SETS: 
 * All columns in the #temp_candidates temp table.
 *
 * PARAMETERS:
 * 001 - @cmp1, varchar(8), input;
 *       This parameter is the first company code to be matched to.
 * 002 - @cmp2 varchar(8), input;
 *	 	 This parameter is the second company code to be matched to.
 * 003 - @cty1, int input not null;
 *       This parameter is the first city code to be matched to.
 * 004 - @cty2 int input not null;
 *	 	 This parameter is the second city code to be matched to.
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 *
 * To pass 2 companies exec  twopoint_locationinfo 'DET1','CHIC1',0,0
 * To pass 2 cities exec  twopoint_locationinfo 'UNKNOWN','UNKNOWN',89324,15663
 * To pass a company and a city exec twopoint_locationinfo 'DET!','UNKNOWN',89324,0
 *
 * REVISION HISTORY:
 * PTS 35676 01/22/07 EMK -  Created
 *
 *	
 **/


DECLARE @jurisvalid VARCHAR(60)
DECLARE @sqlstring NVARCHAR(4000)

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

-- Table for company/city match
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

-- Find the matching companies or cities 
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
    FROM (SELECT cmp_id,cmp_zip,cmp_city,dummykey=0 FROM company where cmp_id=@cmp1) AS cmp1
		JOIN  (SELECT cmp_id,cmp_zip,cmp_city,dummykey=0 FROM company where cmp_id=@cmp2) AS cmp2 on cmp1.dummykey=cmp2.dummykey
		JOIN city AS cty1 ON cmp1.cmp_city = cty1.cty_code
		JOIN city AS cty2 ON cmp2.cmp_city = cty2.cty_code
		RIGHT OUTER JOIN statecountry AS cntry1 ON cty1.cty_state = cntry1.stc_state_c
		RIGHT OUTER JOIN statecountry AS cntry2 ON cty2.cty_state = cntry2.stc_state_c
    WHERE cmp1.cmp_id = @cmp1
			AND cmp2.cmp_id = @cmp2
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
    FROM dbo.company cmp1
		--JOIN city AS cty1 ON cmp1.cmp_city = cty1.cty_code
		JOIN (SELECT cty_code,cty_state,cty_zip,cty_country,dummykey=0 FROM city where cty_code = @cty1) AS cty1 ON cmp1.cmp_city = cty1.cty_code
		JOIN (SELECT cty_code,cty_state,cty_zip,cty_country,dummykey=0 FROM city where cty_code = @cty2) AS cty2 ON cty2.dummykey=cty1.dummykey
		RIGHT OUTER JOIN statecountry AS cntry1 ON cty1.cty_state = cntry1.stc_state_c
		RIGHT OUTER JOIN statecountry AS cntry2 ON cty2.cty_state = cntry2.stc_state_c
    WHERE cmp1.cmp_id = @cmp1
		AND cty2.cty_code = @cty2

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
      FROM 
		(SELECT cty_code,cty_state,cty_zip,cty_country,dummykey=0 FROM city where cty_code = @cty1) AS cty1
		JOIN (SELECT cty_code,cty_state,cty_zip,cty_country,dummykey=0 FROM city where cty_code = @cty2) AS cty2 ON cty2.dummykey=cty1.dummykey
		RIGHT OUTER JOIN statecountry AS cntry1 ON cty1.cty_state = cntry1.stc_state_c
		RIGHT OUTER JOIN statecountry AS cntry2 ON cty2.cty_state = cntry2.stc_state_c
      WHERE  cty1.cty_code = @cty1 AND cty2.cty_code = @cty2
  END

-- Table to regions that match location found above
CREATE TABLE #temp_candidates (
ttr_number int null,
ttr_code varchar(10) null
)


DECLARE @ttr_number int
DECLARE @ttr_filter varchar(5000)
DECLARE @ttr_code varchar(10)
DECLARE @ParmDefinition NVARCHAR(500)


-- Step through all the candidates and apply the filter to the location found above
-- If we return a row, its a match and will be put into the output table

--Create a cursor based on the select statement below
DECLARE ttrfilter_cursor CURSOR FOR 

SELECT ttrheader.ttr_number,ttrf_filter,ttr_code
	FROM ttrfilter, ttrheader
	WHERE  ttrfilter.ttr_number = ttrheader.ttr_number  and  
		ttrfilter.ttrd_terminusnbr = 2 AND  
        ttrheader.ttr_billto in (@cmp1,'UNKNOWN') 

--Populate the cursor based on the select statement above  
OPEN ttrfilter_cursor 

--Execute the initial fetch of variable population 
FETCH NEXT FROM ttrfilter_cursor INTO @ttr_number, @ttr_filter, @ttr_code 
  
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0
	BEGIN
		SET @sqlstring = 'INSERT INTO #temp_candidates SELECT @p_ttr_number, @p_ttr_code from #temp_2loc WHERE ' + @ttr_filter
		SET @ParmDefinition = N'@p_ttr_number int, @p_ttr_code varchar(10)'

		execute sp_executesql @sqlstring, @ParmDefinition, @ttr_number, @ttr_code

		FETCH NEXT FROM ttrfilter_cursor INTO @ttr_number, @ttr_filter, @ttr_code 
	END

CLOSE ttrfilter_cursor
DEALLOCATE ttrfilter_cursor

--Return all the rows
select ttr_number,ttr_code from #temp_candidates

drop table #temp_candidates
drop table #temp_2loc

GO
GRANT EXECUTE ON  [dbo].[d_ttr_gettriptypes] TO [public]
GO
