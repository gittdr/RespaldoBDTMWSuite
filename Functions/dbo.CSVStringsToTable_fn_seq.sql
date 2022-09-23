SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  FUNCTION [dbo].[CSVStringsToTable_fn_seq](@array VARCHAR(8000))
RETURNS @Table TABLE(value VARCHAR(100),seq int identity) 
AS
BEGIN
	DECLARE	@separator_position	INTEGER,
			@array_value		VARCHAR(8000)  

	SET @array = @array + ','
	
	WHILE PATINDEX('%,%', @array) <> 0 
	BEGIN
		SELECT @separator_position = PATINDEX('%,%', @array)
		SELECT @array_value = LEFT(@array, @separator_position - 1)
	
		INSERT @Table (value)
		VALUES(@array_value)

		SELECT @array = STUFF(@array, 1, @separator_position, '')
	END
	RETURN
END
GO
GRANT REFERENCES ON  [dbo].[CSVStringsToTable_fn_seq] TO [public]
GO
GRANT SELECT ON  [dbo].[CSVStringsToTable_fn_seq] TO [public]
GO
