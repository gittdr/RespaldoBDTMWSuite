SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_upd_ord_comment](
   @not_number INT,
   @ordnum VARCHAR (12),
   @comment VARCHAR(254),
   @prefix VARCHAR(30),
   @suffix VARCHAR(30)
)
AS
/* 05/24/01 DAG: Converting for international date format */
/* 02/01/03 DWG: Calls tmail_upd_ord_comment1 */

	EXEC dbo.tmail_upd_ord_comment1 @not_number, @ordnum, @comment, @prefix, @suffix, '0'


GO
GRANT EXECUTE ON  [dbo].[tmail_upd_ord_comment] TO [public]
GO
