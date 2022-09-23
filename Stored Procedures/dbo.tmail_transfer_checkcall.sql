SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_transfer_checkcall] AS
			EXEC dbo.tm_transfer_checkcall_xfc
			EXEC dbo.tmail_transfer_checkcall_xfc
GO
GRANT EXECUTE ON  [dbo].[tmail_transfer_checkcall] TO [public]
GO
