SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [dbo].[CSVStringGetParm_fn](
    @csv varchar(8000),
    @parm varcHar(255)
)
RETURNS varchar(255)

AS BEGIN
	--Given a comma separated string of key/value pairs, finds desired key and returns associated value
	--String in the form of parm1=value1,parm2=value2...
	
	DECLARE @value varchar(255)
	DECLARE @tbl TABLE (value VARCHAR(255))
	DECLARE @keyvaluepair varchar(255)
	DECLARE @valuestart int
	
    SET @value = null
    
	if not isnull(@csv, '') = '' BEGIN
		--create csv table
		INSERT @tbl(value) SELECT * FROM CSVStringsToTable_fn(@csv)
		
		--Find the source value within the rule
		SELECT	@keyvaluepair = value
		FROM	@tbl
		WHERE	value like @parm + '=%'
		
		IF @keyvaluepair IS NOT NULL BEGIN
			SELECT @valuestart = CHARINDEX('=', @keyvaluepair) + 1
			IF @valuestart <= LEN(@keyvaluepair) BEGIN
				SELECT @value = SUBSTRING(@keyvaluepair, @valuestart, LEN(@keyvaluepair) - @valuestart + 1)
			END
		END
	END

   RETURN @value
END
GO
GRANT EXECUTE ON  [dbo].[CSVStringGetParm_fn] TO [public]
GO
