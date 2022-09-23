SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_SplitString]
( @String                  VARCHAR(MAX)
, @Delimiter               CHAR(1)
) RETURNS @Table TABLE (seqno  int, items VARCHAR(MAX) NULL)

AS
/**
*
* NAME:
* dbo.fn_SplitString
*
* TYPE:
* Function
*
* DESCRIPTION:
* Function Procedure used for splitting comma delimited string
*
* RETURNS:
*
* RESULT SETS:
*
* PARAMETERS:
* 001 @String       VARCHAR(MAX)
* 002 @Delimiter    CHAR(1)
*
* REVISION HISTORY:
* PTS 83007 DTG 10/13/14 - Initial version (from Suprakash)
*
**/

BEGIN
   DECLARE @idx   INT
   DECLARE @seqno INT
   DECLARE @slice VARCHAR(MAX)

   IF LEN(@String) < 1 OR @String IS NULL
      RETURN

   IF RIGHT(@String,LEN(@String)) != @Delimiter
      SELECT @String = @String + @Delimiter

   SELECT @seqno = 0
   SELECT @idx = 1
   WHILE @idx != 0
   BEGIN
      SET @idx = CHARINDEX(@Delimiter,@String)
      IF @idx != 0
         SET @slice = LEFT(@String, @idx - 1)
      ELSE
         SET @slice = @String

      IF(LEN(@slice)>0)
      BEGIN
         SELECT @seqno = @seqno + 1
         INSERT INTO @Table(seqno, Items) VALUES(@seqno, @slice)
      END

      SET @String = RIGHT(@String,LEN(@String) - @idx)
      IF LEN(@String) = 0 BREAK
   END

   RETURN
END

GO
GRANT REFERENCES ON  [dbo].[fn_SplitString] TO [public]
GO
GRANT SELECT ON  [dbo].[fn_SplitString] TO [public]
GO
