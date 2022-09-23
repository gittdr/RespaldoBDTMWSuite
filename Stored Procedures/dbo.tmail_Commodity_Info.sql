SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_Commodity_Info] @cmp_code varchar(8)

AS

	SELECT * 
	FROM commodity (NOLOCK) 
	WHERE cmd_Code = @cmp_code

GO
GRANT EXECUTE ON  [dbo].[tmail_Commodity_Info] TO [public]
GO
