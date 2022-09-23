SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[paperworkcheckedin] (@lgh_number int) as
	
declare @ret int
exec @ret = fnc_paperworkcheckedin @lgh_number
select @ret

GO
GRANT EXECUTE ON  [dbo].[paperworkcheckedin] TO [public]
GO
