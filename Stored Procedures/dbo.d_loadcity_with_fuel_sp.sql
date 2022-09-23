SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
-- JET - 2/2/00 - PTS #7140, new stored procedure that will support the retrieval of all cities
* JET - 2/2/00 - PTS #7140, new stored procedure that will support the retrieval of all cities
 * 4/19/08 40260 recode Pauls ...11/30/06 - PTS35279 - jguo - remove index hints and double quotes.
*/

CREATE PROC [dbo].[d_loadcity_with_fuel_sp] @cty varchar(25) , @number int AS 

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
	-- PTS 29399 -- BL (start)
--	SELECT 	cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
	SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, cty_zip, cty_country, rtrim(cty_county) cty_county
	-- PTS 29399 -- BL (end)
	FROM 	city --with(index=pk_nmstct)
	WHERE 	cty_nmstct = 'UNKNOWN' 
	-- PTS 29399 -- BL (start)
    --JLB PTS 32325 do not sort in SQL as it creates large performance problems sort added to the datawindow
    --order by  cty_name, cty_state, cty_county
	-- PTS 29399 -- BL (end)
END
ELSE
    IF EXISTS ( SELECT cty_nmstct FROM city --with(index=pk_nmstct) 
    WHERE cty_nmstct like @cty + '%') 
    BEGIN
	select @v_commapos = CHARINDEX('%', @cty)
	IF @v_commapos > 0
	BEGIN
		SELECT @orig_cty = @cty
		select @cty = SUBSTRING(@cty, 1, @v_commapos -1) + Right(@cty, DataLength(@cty) - @v_commapos)
		-- PTS 29399 -- BL (start)
--		SELECT DISTINCT cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, cty_zip, cty_country, rtrim(cty_county) cty_county
		-- PTS 29399 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @cty + '%'
		UNION
		-- PTS 29399 -- BL (start)
--		SELECT DISTINCT cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, cty_zip, cty_country, rtrim(cty_county) cty_county
		-- PTS 29399 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @orig_cty + '%'
		-- PTS 29399 -- BL (start)
    --JLB PTS 32325 do not sort in SQL as it creates large performance problems sort added to the datawindow
    --order by  cty_name, cty_state, cty_county
		-- PTS 29399 -- BL (end)
	END
	ELSE
	BEGIN
		-- PTS 29399 -- BL (start)
--		SELECT 	cty_nmstct , cty_code, cty_name, cty_state, cty_zip, cty_country 
		SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, cty_zip, cty_country, rtrim(cty_county) cty_county
		-- PTS 29399 -- BL (end)
		FROM 	city --with(index=pk_nmstct)
		WHERE 	cty_nmstct like @cty + '%'
		-- PTS 29399 -- BL (start)
    --JLB PTS 32325 do not sort in SQL as it creates large performance problems sort added to the datawindow
    --order by  cty_name, cty_state, cty_county
		-- PTS 29399 -- BL (end)
	END

    END	
    ELSE
    BEGIN
	-- PTS 29399 -- BL (start)
--	SELECT 	cty_nmstct , cty_code , cty_name, cty_state, cty_zip, cty_country 
	SELECT 	cty_nmstct , cty_code, rtrim(cty_name) cty_name, rtrim(cty_state) cty_state, cty_zip, cty_country, rtrim(cty_county) cty_county
	-- PTS 29399 -- BL (end)
	FROM 	city --with(index=pk_nmstct)
	WHERE 	cty_nmstct = 'UNKNOWN' 
	-- PTS 29399 -- BL (start)
    --JLB PTS 32325 do not sort in SQL as it creates large performance problems sort added to the datawindow
    --order by  cty_name, cty_state, cty_county
	-- PTS 29399 -- BL (end)
    END

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadcity_with_fuel_sp] TO [public]
GO
