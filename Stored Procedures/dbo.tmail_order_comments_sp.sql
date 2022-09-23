SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_order_comments_sp] @ordnum VARCHAR (12) AS
BEGIN

DECLARE 	@comments CHAR(255),
		@len smallint,
		@pos smallint,
		@poscrlf smallint,
		@orig_comments VARCHAR(255)

SELECT	@comments = ord_remark, @orig_comments = ord_remark
FROM	orderheader(NOLOCK)
WHERE 	ord_number = @ordnum

SELECT @len = datalength(RTRIM(@comments))

CREATE TABLE #t(
	ord_remark char(38))

SELECT @pos = 1
WHILE @pos <= @len
	BEGIN
	-- Check if there are any CRLFs on this line, and if so, delete them and pad.
	SELECT @poscrlf = 0
	SELECT @poscrlf = CHARINDEX(CHAR(13)+CHAR(10), substring(@comments, @pos, 39))
	IF ISNULL(@poscrlf, 0) > 0
		BEGIN
		SELECT @comments = STUFF (@comments, @pos + @poscrlf - 1, 2, SPACE ( 39 - @poscrlf ))
		SELECT @len = datalength(RTRIM(@comments))
		END
	INSERT #t 
	VALUES (substring ( @comments, @pos, 38 ))
	
	SELECT @pos = @pos + 38
	END

SELECT *, @orig_comments AS ord_remarkNoWrap 
FROM #t

DROP TABLE #t

END    /* end of the proc    */

GO
GRANT EXECUTE ON  [dbo].[tmail_order_comments_sp] TO [public]
GO
