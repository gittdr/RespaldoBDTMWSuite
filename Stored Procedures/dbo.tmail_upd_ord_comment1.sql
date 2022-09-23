SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_upd_ord_comment1](
   @not_number INT,
   @ordnum VARCHAR (12),
   @comment VARCHAR(254),
   @prefix VARCHAR(30),
   @suffix VARCHAR(30),
   @Flags VARCHAR(12)
)
AS

EXEC dbo.tmail_upd_ord_comment2 @not_number, @ordnum, @comment, @prefix, @suffix, @Flags, 'NONE'



GO
GRANT EXECUTE ON  [dbo].[tmail_upd_ord_comment1] TO [public]
GO
