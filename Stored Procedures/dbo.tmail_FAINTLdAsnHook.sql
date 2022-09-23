SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[tmail_FAINTLdAsnHook] @sLghNum varchar(10)

AS
IF ISNUMERIC(@sLghNum)<> 0
	IF NOT EXISTS (SELECT * 
					FROM FAINT (NOLOCK)
					WHERE lgh_number = CONVERT(int, @sLghNum))
		insert into FAINT (lgh_number)
		VALUES(CONVERT(int, @sLghNum))
SELECT @sLghNum lgh_number
GO
GRANT EXECUTE ON  [dbo].[tmail_FAINTLdAsnHook] TO [public]
GO
