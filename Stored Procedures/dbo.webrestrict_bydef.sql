SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[webrestrict_bydef](@labeldef VARCHAR(20), @restricts VARCHAR(254) OUT)
AS

DECLARE @abbrs VARCHAR(6)

SELECT @restricts = ','

DECLARE restrictions CURSOR FOR
        SELECT lbl_abbr 
          FROM webrestrict
         WHERE lbl_def = @labeldef AND
               login = USER

OPEN restrictions

FETCH NEXT FROM restrictions INTO @abbrs
WHILE @@FETCH_STATUS = 0
BEGIN
     IF @abbrs IS NOT NULL 
        SELECT @restricts = @restricts + ',' + @abbrs
    
     FETCH NEXT FROM restrictions INTO @abbrs
END

SELECT @restricts = @restricts + ','

CLOSE restrictions

DEALLOCATE restrictions

GO
GRANT EXECUTE ON  [dbo].[webrestrict_bydef] TO [public]
GO
