SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_order_comments2_sp] (@ordnum VARCHAR (12), @NoWrapFlag VARCHAR(30))
AS

	EXEC dbo.tmail_order_comments_sp @ordnum

GO
GRANT EXECUTE ON  [dbo].[tmail_order_comments2_sp] TO [public]
GO
