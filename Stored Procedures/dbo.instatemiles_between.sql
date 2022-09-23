SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[instatemiles_between] 
	@type		tinyint, 
	@o_cmp		char (8),
	@d_cmp		char (8),
	@o_cty		integer,
	@d_cty		integer,
	@o_zip		char (10),
	@d_zip		char (10)

AS

CREATE TABLE #tmiles
	(otype	char(1),
	dtype	char(1),
	totalmiles integer null,  -- was freemiles PTS 33706
	tollmiles integer null,
	state	char(2) null)
	

DECLARE	@o_use	char(3),
	@d_use	char(3),
	@o_use1	char(1),
	@d_use1	char(1),
	@origin	char(10),
	@destination char(10),
	@i 	tinyint,
	@j 	tinyint,
	@temp 	char(10)

SELECT	@o_use = 'OZC',
	@d_use = 'OZC'

/* We now look up the city for the company only when the city passed in is invalid.
   (We used to look it up when the city or zip was invalid).
   We look up the zip from the city file if the zip is invalid.
   We handle origin and destination the same way. pts #3247 */
IF @o_cmp > '' AND @o_cmp <> 'UNKNOWN' AND (@o_cty <= 0 OR @o_cty IS null)
	SELECT @o_cty = company.cmp_city,
		@o_zip = company.cmp_zip
	FROM company 
	WHERE company.cmp_id = @o_cmp

IF @o_cty > 0 AND (@o_zip = '' OR @o_zip IS null)
	SELECT @o_zip = city.cty_zip
	FROM city
	WHERE city.cty_code = @o_cty

IF @d_cmp > '' AND @d_cmp <> 'UNKNOWN' AND (@d_cty <= 0 OR @d_cty IS null)
	SELECT @d_cty = company.cmp_city,
		@d_zip = company.cmp_zip
	FROM company 
	WHERE company.cmp_id = @d_cmp

IF @d_cty > 0 AND (@d_zip = '' OR @d_zip IS null)
	SELECT @d_zip = city.cty_zip
	FROM city
	WHERE city.cty_code = @d_cty
/* end pts#3247 */

IF @o_zip IS null
	SELECT @o_zip = ''
ELSE
	SELECT @o_zip = SUBSTRING(@o_zip, 1, 5)

IF @d_zip IS null
	SELECT @d_zip = ''
ELSE
	SELECT @d_zip = SUBSTRING(@d_zip, 1, 5)

SELECT	@i = 1

WHILE @i <= 3
	BEGIN

	SELECT @j = 1
	WHILE @j <= 3
		BEGIN
		SELECT @o_use1 = SUBSTRING(@o_use, @i, 1)
		IF @o_use1 = 'C'
			SELECT @origin = CONVERT(CHAR(10), @o_cty)
		ELSE IF @o_use1 = 'O'
			SELECT @origin = @o_cmp
		ELSE IF @o_use1 = 'Z'
			SELECT @origin = @o_zip

		SELECT @d_use1 = SUBSTRING(@d_use, @j, 1)
		IF @d_use1 = 'C'
			SELECT @destination = CONVERT(CHAR(10), @d_cty)
		ELSE IF @d_use1 = 'O' 
			SELECT @destination = @d_cmp 
		ELSE IF @d_use1 = 'Z'
			SELECT @destination = @d_zip 

/* remove sort jude 7/29
		IF @o_use1 = 'C' AND @d_use1 = 'C' 
			BEGIN
			IF CONVERT(integer, @origin) > CONVERT(integer, @destination)
				SELECT @temp = @origin,
					@origin = @destination,
					@destination = @temp
			END
		ELSE
			IF (@o_use1 + @origin) > (@d_use1 + @destination)
				SELECT @temp = @o_use1,
					@o_use1 = @d_use1,
					@d_use1 = @temp,
					@temp = @origin,
					@origin = @destination,
					@destination = @temp
*/

		INSERT INTO #tmiles
		SELECT	@o_use1,
			@d_use1,
			--		sm.sm_freemiles, PTS 33706
			sm.sm_miles,
			sm.sm_tollmiles,
			sm.sm_state
		FROM statemiles sm
		WHERE sm.sm_origintype = @o_use1 AND  
			sm.sm_origin = @origin AND  
			sm.sm_destinationtype = @d_use1 AND  
			sm.sm_destination = @destination AND 
			sm.sm_type = @type
		SELECT @j = @j + 1
		END
	SELECT @i = @i + 1
END

SELECT * from #tmiles
DROP TABLE #tmiles

GO
GRANT EXECUTE ON  [dbo].[instatemiles_between] TO [public]
GO
