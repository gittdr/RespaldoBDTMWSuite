SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*pts 4612 added isnull because proc was compiling with bad query plan when
	it was first called with a null,  I did this again because the source was missed in the 4.0 build*/

/*pts 3647 added isnull because proc was compiling with bad query plan when
	it was first called with a null*/

/*pts 4518 added UNION statement to provide exact match capability*/
-- JET - 2/2/00 - PTS #7140, do not retrieve where cty_fuelcreate = 1, these cities are for fuel only
-- DPETE 4/19/08 recode Pauls 40260 ..- PTS35279 - jguo - remove index hints.
-- DPETE {TS 43556 add inidication that city is valid to alk

CREATE PROC [dbo].[d_loadcity_sp] @cty varchar(25) , @number int AS 

DECLARE 
@v_commapos integer,
@orig_cty   varchar(25)

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8


IF @cty IS NULL
BEGIN
-- PTS 29320 -- BL (start)
--	SELECT 	cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
	SELECT 	cty_nmstct, cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, 
            cty_zip, cty_country, rtrim(cty_county) cty_county ,alkvalid = 'N'
-- PTS 29320 -- BL (end)
	FROM 	city -- with(index=pk_nmstct)
	WHERE 	cty_nmstct = 'UNKNOWN' 
END
ELSE
    IF EXISTS (SELECT cty_nmstct 
                 FROM city --with(index=pk_nmstct) 
                WHERE cty_nmstct like @cty + '%' AND 
                      (cty_fuelcreate = 0 OR cty_fuelcreate IS NULL)) 
    BEGIN
	select @v_commapos = CHARINDEX('%', @cty)
	IF @v_commapos > 0
	BEGIN
		SELECT @orig_cty = @cty
		select @cty = SUBSTRING(@cty, 1, @v_commapos -1) + Right(@cty, DataLength(@cty) - @v_commapos)
-- PTS 29320 -- BL (start)
--		SELECT DISTINCT cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT DISTINCT cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, 
               cty_zip, cty_country, rtrim(cty_county) cty_county , alkvalid = case isnull(cty_alk_filevalidatedyr,0) when 0 then 'N' else 'Y' end  
-- PTS 29320 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @cty + '%' AND 
                      (cty_fuelcreate = 0 OR cty_fuelcreate IS NULL)
		UNION
-- PTS 29320 -- BL (start)
--		SELECT DISTINCT cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT DISTINCT cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, 
               cty_zip, cty_country, rtrim(cty_county) cty_county , alkvalid = case isnull(cty_alk_filevalidatedyr,0) when 0 then 'N' else 'Y' end  
-- PTS 29320 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @orig_cty + '%' AND 
                      (cty_fuelcreate = 0 OR cty_fuelcreate IS NULL)
	END
	ELSE
	BEGIN
-- PTS 29320 -- BL (start)
--		SELECT 	cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, 
                cty_zip, cty_country, rtrim(cty_county) cty_county , alkvalid = case isnull(cty_alk_filevalidatedyr,0) when 0 then 'N' else 'Y' end  
-- PTS 29320 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @cty + '%' AND 
                      (cty_fuelcreate = 0 OR cty_fuelcreate IS NULL)
	END

    END	
    ELSE
    BEGIN
-- PTS 29320 -- BL (start)
--	SELECT 	cty_nmstct , cty_code , cty_name, cty_state, cty_zip, cty_country 
	SELECT 	cty_nmstct , cty_code , rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, 
            cty_zip, cty_country, rtrim(cty_county) cty_county,alkvalid = 'N' 
-- PTS 29320 -- BL (end)
	FROM 	city --with(index=pk_nmstct)
	WHERE 	cty_nmstct = 'UNKNOWN' 
    END

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadcity_sp] TO [public]
GO
