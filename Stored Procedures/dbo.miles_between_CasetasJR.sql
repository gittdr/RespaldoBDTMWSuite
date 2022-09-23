SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[miles_between_CasetasJR]
	@type		tinyint, 
	@o_cmp		char (8),
	@d_cmp		char (8),
	@o_cty		integer,
	@d_cty		integer,
	@o_zip		char (14),
	@d_zip		char (14),
	@haztype           int,
	@Casetas	money output,
	@kilometros integer output
/*PTS 23162 CGK 9/14/2004*/

AS


DECLARE	/* @o_use char ( 3 ),
	@d_use char ( 3 ),
	@o_use1 char ( 1 ),
	@d_use1 char ( 1 ),
	@origin char ( 50 ),
	@destination char ( 50 ),
	@i		tinyint,
	@j		tinyint,
	@temp	char ( 50 ), */
	@o_cmp_address VARCHAR(50),
	@d_cmp_address VARCHAR(50),
	@ignore_miles varchar(3),
	@so_cmp_address VARCHAR(50),
	@so_cmp		char (8),
	@so_cty		integer,
	@so_zip		char (14),
	@sd_cmp_address VARCHAR(50),
	@sd_cmp		char (8),
	@sd_cty		integer,
	@sd_zip		char (14),
	@hold_ozip	varchar(40),
	@hold_dzip	varchar(40),
	@bidirectional_miles varchar(3), --MRH 37089
    @reverse_distance char(1),          --TGRIFFIT 42169
    @loop_count int                     --TGRIFFIT 42169
    
    
SELECT @haztype = IsNull (@haztype,0) /*PTS 23162 CGK 9/14/2004*/

SELECT	@ignore_miles = UPPER(LTRIM(RTRIM(gi_string1))) 
  FROM	generalinfo 
 WHERE	gi_name = 'RETURN0MILES' AND
		gi_datein = (SELECT	MAX(gi_datein) 
					   FROM	generalinfo 
					  WHERE	gi_name = 'RETURN0MILES')

/* SELECT	@o_use = 'OZC',
		@d_use = @o_use */

IF @o_cmp <> '' AND @o_cmp <> 'UNKNOWN'
	-- PTS 18585 - DJM - Modified SQL to build Address string that matches the format actually
	--	used in table so the SQL can find the cached mileage.
	-- PTS 37665 - EMK - Used passed in zip if blank company zip
	SELECT	@o_cty = company.cmp_city,
			@o_zip = Case
						When IsNull(company.cmp_zip,'') = '' THEN @o_zip
						ELSE company.cmp_zip
					 END,
			@o_cmp_address = CASE
						WHEN ISNULL(company.cmp_mapaddress, '') = '' THEN @o_cmp
						ELSE company.cmp_mapaddress + '; ' + CONVERT(VARCHAR(10), company.cmp_city)
					 END
	  FROM	company 
	 WHERE	company.cmp_id = @o_cmp


/*IF @o_cmp_address <> '' 
   SELECT @o_cmp_address = @o_cmp_address + '; ' + CONVERT(VARCHAR(10), @o_cty)
ELSE
   SELECT @o_cmp_address = @o_cmp*/

IF @d_cmp <> '' AND @d_cmp <> 'UNKNOWN'
	-- PTS 18585 - DJM - Modified SQL to build Address string that matches the format actually
	--	used in table so the SQL can find the cached mileage.
	-- PTS 37665 - EMK - Used passed in zip if blank company zip
	SELECT	@d_cty = company.cmp_city,
			@d_zip = Case
						When IsNull(company.cmp_zip,'') = '' THEN @d_zip
						ELSE company.cmp_zip
					 END,
			@d_cmp_address = CASE 
						WHEN ISNULL(company.cmp_mapaddress, '') = '' THEN @d_cmp
						ELSE company.cmp_mapaddress + '; ' + CONVERT(VARCHAR(10), company.cmp_city)
					 END
	  FROM	company 
	 WHERE	company.cmp_id = @d_cmp


/*IF @d_cmp_address <> ''
   SELECT @d_cmp_address = @d_cmp_address + '; ' + CONVERT(VARCHAR(10), @d_cty)
ELSE
   SELECT @d_cmp_address = @d_cmp*/

SELECT @o_zip = RTRIM( ISNULL( @o_zip, '' ) )
/*IF @o_zip IS NULL
	SELECT @o_zip = ''
ELSE
	-- RE - 2/25/02 - PTS #13443
	--SELECT @o_zip = SUBSTRING ( @o_zip, 1, 5 )
	SELECT @o_zip = RTRIM( @o_zip )*/

SELECT @d_zip = RTRIM( ISNULL( @d_zip, '' ) )

/*IF @d_zip IS NULL
	SELECT @d_zip = ''
ELSE
	-- RE - 2/25/02 - PTS #13443
	--SELECT @d_zip = SUBSTRING ( @d_zip, 1, 5 )
	SELECT @d_zip = RTRIM( @d_zip )*/

--do swaps
-- MRH 37089
--PTS 28634	JZ	6/27/2005
select @hold_ozip = @o_zip
select @hold_dzip = @d_zip
if IsNumeric(@o_zip) <> 0
begin
	select @hold_ozip = '000000000' + @o_zip
	select @hold_ozip = substring(@hold_ozip, len(@hold_ozip) -9, 10)
end

if IsNumeric(@d_zip) <> 0
begin
	select @hold_dzip = '000000000' + @d_zip
	select @hold_dzip = substring(@hold_dzip, len(@hold_dzip) -9, 10)
end

SELECT	@bidirectional_miles = left(UPPER(LTRIM(RTRIM(gi_string1))), 1) 
  FROM	generalinfo 
 WHERE	gi_name = 'DistanceCacheOneWay' AND
		gi_datein = (SELECT	MAX(gi_datein) 
					   FROM	generalinfo 
					  WHERE	gi_name = 'DistanceCacheOneWay')

If @bidirectional_miles <> 'Y'
begin
	if @o_cmp_address > @d_cmp_address 
		select @sd_cmp_address = @o_cmp_address, @so_cmp_address = @d_cmp_address
	else
		select @so_cmp_address = @o_cmp_address, @sd_cmp_address = @d_cmp_address

	if @hold_ozip > @hold_dzip
		select @sd_zip = @o_zip, @so_zip = @d_zip
	else
		select @so_zip = @o_zip, @sd_zip = @d_zip
	
	if @o_cty > @d_cty
		select @sd_cty = @o_cty, @so_cty = @d_cty
	else
		select @so_cty = @o_cty, @sd_cty = @d_cty
end else
begin
	select @so_cmp_address = @o_cmp_address, @sd_cmp_address = @d_cmp_address
	select @so_zip = @o_zip, @sd_zip = @d_zip
	select @so_cty = @o_cty, @sd_cty = @d_cty
end -- Bidirectional miles.

-- TGRIFFIT 42169
CREATE TABLE #results
(
    r_otype char(1),
    r_dtype char(1),
    r_miles float,
    r_hours decimal(6,2),
    r_tollcost money,
    r_updatedon datetime,
    r_updatedby varchar(20),
    r_mt_identity int,
    r_order int
)
-- END TGRIFFIT 42169

if left( @ignore_miles, 1 )='Y'

    insert into #results(r_otype, r_dtype, r_miles, r_hours, r_order)
	select convert(char(1),'C'),
		convert(char(1),'C'),
		convert(float,0),
		convert(int,0),
        1
else
-- TGRIFFIT 42169
BEGIN

    SET @loop_count = 0
   
    SELECT	@reverse_distance = left(UPPER(LTRIM(RTRIM(gi_string1))), 1) 
    FROM	generalinfo 
    WHERE	gi_name = 'DistanceReverseCheck' AND
            gi_datein = (SELECT	MAX(gi_datein) 
                      FROM	generalinfo 
                      WHERE	gi_name = 'DistanceReverseCheck')
                       
    WHILE @loop_count < 2
    BEGIN     
        
        SET @loop_count = @loop_count + 1
    
        insert into #results
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count --TGRIFFIT 42169
          FROM	mileagetable  
         WHERE	-- O Company to D Company
                (( mileagetable.mt_origintype = 'O' ) AND  
                 ( mileagetable.mt_origin = @so_cmp_address) AND  
                 ( mileagetable.mt_destinationtype = 'O' ) AND  
                 ( mileagetable.mt_destination = @sd_cmp_address) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O Company to D Zip
        where		(( mileagetable.mt_origintype = 'O' ) AND  
                 ( mileagetable.mt_origin = @o_cmp_address ) AND  
                 ( mileagetable.mt_destinationtype = 'Z' ) AND  
                 ( mileagetable.mt_destination = @d_zip ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O Company to D City
        where		(( mileagetable.mt_origintype = 'C' ) AND  
                 ( mileagetable.mt_origin = CONVERT( VARCHAR( 10 ), @d_cty) ) AND  
                 ( mileagetable.mt_destinationtype = 'O' ) AND  
                 ( mileagetable.mt_destination = @o_cmp_address ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O Zip to D Company
        where		(( mileagetable.mt_origintype = 'O' ) AND  
                 ( mileagetable.mt_origin = @d_cmp_address ) AND  
                 ( mileagetable.mt_destinationtype = 'Z' ) AND  
                 ( mileagetable.mt_destination = @o_zip ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O Zip to D Zip
        where		(( mileagetable.mt_origintype = 'Z' ) AND  
                 ( mileagetable.mt_origin = @so_zip) AND  
                 ( mileagetable.mt_destinationtype = 'Z' ) AND  
                 ( mileagetable.mt_destination = @sd_zip) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O Zip to D City
        where		(( mileagetable.mt_origintype = 'C' ) AND  
                 ( mileagetable.mt_origin = CONVERT( VARCHAR( 10 ), @d_cty) ) AND  
                 ( mileagetable.mt_destinationtype = 'Z' ) AND  
                 ( mileagetable.mt_destination = @o_zip ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O City to D Company
        where		(( mileagetable.mt_origintype = 'C' ) AND  
                 ( mileagetable.mt_origin = CONVERT( VARCHAR( 10 ), @o_cty) ) AND  
                 ( mileagetable.mt_destinationtype = 'O' ) AND  
                 ( mileagetable.mt_destination = @d_cmp_address ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O City to D Zip
        where		(( mileagetable.mt_origintype = 'C' ) AND  
                 ( mileagetable.mt_origin = CONVERT( VARCHAR( 10 ), @o_cty) ) AND  
                 ( mileagetable.mt_destinationtype = 'Z' ) AND  
                 ( mileagetable.mt_destination = @d_zip ) AND 
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
        UNION
        SELECT	mileagetable.mt_origintype otype,
                mileagetable.mt_destinationtype dtype,
                mileagetable.mt_miles miles,
                mileagetable.mt_hours hours,
                mileagetable.mt_tolls_cost tollcost,
                mileagetable.mt_updatedon updatedon, 
                mileagetable.mt_updatedby updatedby,
                mileagetable.mt_identity mt_indentity /* PTS 35796 EMK */
                ,@loop_count
          FROM	mileagetable  
                -- O City to D City
        where		(( mileagetable.mt_origintype = 'C' ) AND  
                 ( mileagetable.mt_origin = CONVERT( VARCHAR( 10 ), @so_cty)) AND  
                 ( mileagetable.mt_destinationtype = 'C' ) AND  
                 ( mileagetable.mt_destination = CONVERT( VARCHAR( 10 ), @sd_cty)) AND  
                 ( mileagetable.mt_type = @type ) AND
                 (IsNull (mileagetable.mt_haztype,0) = @haztype )) /*PTS 23162 CGK*/
                 
        
        IF @reverse_distance = 'Y' AND @bidirectional_miles = 'Y' AND @loop_count = 1
            -- Check B to A mileage as well (just in case A to B mileage not found).
            -- Reverse the variables.
            SELECT 
               @so_cmp_address = @d_cmp_address, 
               @sd_cmp_address = @o_cmp_address,
               @so_zip = @d_zip, 
               @sd_zip = @o_zip,
               @so_cty = @d_cty, 
               @sd_cty = @o_cty,
               @o_cmp_address = @d_cmp_address,
               @d_cmp_address = @o_cmp_address,
               @o_zip = @d_zip, 
               @d_zip = @o_zip,
               @o_cty = @d_cty, 
               @d_cty = @o_cty
        ELSE
            -- exit loop
            SET @loop_count = 2
                
    END -- end loop
        
END

-- TGRIFFIT - return DISTINCT rows and make sure results are ordered A to B (1) before B to A (2).

-- To use ORDER BY items with DISTINCT, the order by items must appear in the select. This defeats the purpose
-- of the DISTINCT - we don't want the same row returned twice if the only difference is the r_order value.
-- Instead, delete the duplicate rows where the r_order = 2

DELETE FROM #results
WHERE r_order = 2 
AND r_mt_identity IN
(SELECT r_mt_identity
 FROM #results
 WHERE r_order = 1)

SELECT  @casetas = r_tollcost, @kilometros = r_miles
FROM #results
ORDER BY r_order ASC


select @casetas		= IsNull(@casetas,0)
select @kilometros	= IsNull(@kilometros,0)


return 0

DROP TABLE #results
	
-- END TGRIFFIT 42169
		
GO
