SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[RemoveAccentMarks] ( @Cadena VARCHAR(100) )
    RETURNS VARCHAR(100)
AS 
BEGIN
 
    --Replace accent marks
    RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Cadena, 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u') 
END
GO
