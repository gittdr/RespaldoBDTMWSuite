SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ttr_getregions] 	@cmp1 VARCHAR(8),
	                                @cty1 INTEGER	
AS
DECLARE @jurisvalid VARCHAR(60),
        @ZZZ1       VARCHAR(11),
        @TTT1       INTEGER,
        @SSS1       VARCHAR(6),
        @CCC1       VARCHAR(50)

-- Table to regions that match location found above
DECLARE @include_regions TABLE (
   ttr_number INTEGER NULL,
   ttr_code   VARCHAR(30) NULL
)

DECLARE @exclude_regions TABLE (
   ttr_number INTEGER NULL
)


SELECT @jurisvalid = ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
  FROM generalinfo 
 WHERE gi_name = 'JURISVALID'

SELECT @cmp1 = UPPER(ISNULL(@cmp1,'UNKNOWN'))
IF RTRIM(@cmp1) = '' SELECT @cmp1 = 'UNKNOWN'
SELECT @cty1 = ISNULL(@cty1,0)

-- Find the matching company or city 
IF @cmp1 <> 'UNKNOWN'
BEGIN 
   SELECT @ZZZ1 = CASE 
                     WHEN ISNULL(cmp1.cmp_zip,'') > '' THEN cmp1.cmp_zip
                     ELSE ISNULL(cty1.cty_zip,'')
                  END ,  
          @TTT1 = ISNULL(cmp1.cmp_city,0),   
          @SSS1 = ISNULL(cty1.cty_state,''), 
          @CCC1 = CASE @JURISVALID 
                     WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
                     ELSE ISNULL(cntry1.stc_country_c,'') 
                  END
     FROM dbo.company cmp1 JOIN city AS cty1 ON cty1.cty_code = cmp1.cmp_city   
                           RIGHT OUTER JOIN statecountry AS cntry1 ON cntry1.stc_state_c = cty1.cty_state
    WHERE cmp1.cmp_id = @cmp1
END
ELSE
BEGIN
   SELECT @ZZZ1 = ISNULL(cty1.cty_zip,''),  
          @TTT1 = ISNULL(cty1.cty_code,0),   
          @SSS1 = ISNULL(cty1.cty_state,''),   
          @CCC1 = CASE @JURISVALID 
                     WHEN 'Y' THEN ISNULL(cty1.cty_country, '') 
                     ELSE ISNULL(cntry1.stc_country_c,'') 
                  END
     FROM dbo.city cty1 RIGHT OUTER JOIN statecountry AS cntry1 ON cntry1.stc_state_c = cty1.cty_state   
    WHERE  cty1.cty_code = @cty1
END

INSERT INTO @include_regions
   SELECT d.ttr_number, h.ttr_code
     FROM ttrdetail d JOIN ttrheader h ON d.ttr_number = h.ttr_number AND
                                          h.ttr_billto IN (@cmp1, 'UNKNOWN')
    WHERE ((d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'I' AND d.ttrd_level = 'ZIP' AND (d.ttrd_value = LEFT(@ZZZ1, 3) OR d.ttrd_value = @ZZZ1)) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'M' AND d.ttrd_level = 'ZIP' AND (d.ttrd_value = LEFT(@zzz1, 3) OR d.ttrd_value = @ZZZ1)) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'N' AND d.ttrd_level = 'ZIP' AND d.ttrd_value = 'ALL') OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'E' AND d.ttrd_level = 'ZIP'))
   INTERSECT
   SELECT d.ttr_number, h.ttr_code
     FROM ttrdetail d JOIN ttrheader h ON d.ttr_number = h.ttr_number AND
                                          h.ttr_billto IN (@cmp1, 'UNKNOWN')
    WHERE ((d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'I' AND d.ttrd_level = 'CITY' AND d.ttrd_intvalue = @TTT1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'M' AND d.ttrd_level = 'CITY' AND d.ttrd_intvalue = @TTT1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'N' AND d.ttrd_level = 'CITY' AND d.ttrd_value = 'ALL') OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'E' AND d.ttrd_level = 'CITY'))
   INTERSECT
   SELECT d.ttr_number, h.ttr_code
     FROM ttrdetail d JOIN ttrheader h ON d.ttr_number = h.ttr_number AND
                                          h.ttr_billto IN (@cmp1, 'UNKNOWN')
    WHERE ((d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'I' AND d.ttrd_level = 'STATE' AND d.ttrd_value = @SSS1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'M' AND d.ttrd_level = 'STATE' AND d.ttrd_value = @SSS1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'N' AND d.ttrd_level = 'STATE' AND d.ttrd_value = 'ALL') OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'E' AND d.ttrd_level = 'STATE'))
   INTERSECT
   SELECT d.ttr_number, h.ttr_code
     FROM ttrdetail d JOIN ttrheader h ON d.ttr_number = h.ttr_number AND
                                          h.ttr_billto IN (@cmp1, 'UNKNOWN')
    WHERE ((d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'I' AND d.ttrd_level = 'CNTRY' AND d.ttrd_value = @CCC1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'M' AND d.ttrd_level = 'CNTRY' AND d.ttrd_value = @CCC1) OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'N' AND d.ttrd_level = 'CNTRY' AND d.ttrd_value = 'ALL') OR
           (d.ttrd_terminusnbr = 1 AND d.ttrd_include_or_exclude = 'E' AND d.ttrd_level = 'CNTRY'))

INSERT INTO @exclude_regions
   SELECT ttr_number
     FROM ttrheader
    WHERE ttr_billto IN (@cmp1, 'UNKNOWN') AND
          ttr_number IN (SELECT ttr_number
                           FROM ttrdetail
                          WHERE ttrd_terminusnbr = 1 AND
                                ttrd_include_or_exclude = 'E' AND
                                ttrd_level = 'ZIP' AND 
                                (ttrd_value = @ZZZ1 OR ttrd_value = LEFT(@ZZZ1, 3)))
   UNION ALL
   SELECT ttr_number
     FROM ttrheader
    WHERE ttr_billto IN (@cmp1, 'UNKNOWN') AND
          ttr_number IN (SELECT ttr_number 
                           FROM ttrdetail
                          WHERE ttrd_terminusnbr = 1 AND
                                ttrd_include_or_exclude = 'E' AND
                                ttrd_level = 'CITY' AND
                                ttrd_intvalue = @TTT1)
   UNION ALL
   SELECT ttr_number
     FROM ttrheader
    WHERE ttr_billto IN (@cmp1, 'UNKNOWN') AND
          ttr_number IN (SELECT ttr_number
                           FROM ttrdetail
                          WHERE ttrd_terminusnbr = 1 AND
                                ttrd_include_or_exclude = 'E' AND
                                ttrd_level = 'STATE' AND
                                ttrd_value = @SSS1)
   UNION ALL
   SELECT ttr_number
     FROM ttrheader
    WHERE ttr_billto IN (@cmp1, 'UNKNOWN') AND
          ttr_number IN (SELECT ttr_number
                           FROM ttrdetail
                          WHERE ttrd_terminusnbr = 1 AND
                                ttrd_include_or_exclude = 'E' AND
                                ttrd_level = 'CNTRY' AND
                                ttrd_value = @CCC1)
             
--Return all the rows
SELECT ttr_number, ttr_code
  FROM @include_regions
 WHERE ttr_number NOT IN (SELECT ttr_number
                            FROM @exclude_regions)
ORDER BY ttr_code

GO
GRANT EXECUTE ON  [dbo].[d_ttr_getregions] TO [public]
GO
