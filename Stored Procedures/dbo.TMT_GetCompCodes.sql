SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
MB  05/07/2009 Expand String @SQL to 4000
MRH 05/19/2010 Revsised to use transman connection.
*/
create proc [dbo].[TMT_GetCompCodes]
as
SELECT CODE, DESCRIP FROM VIEW_CMPONENT WHERE LEN(CODE) <= 7 ORDER BY CODE
GO
GRANT EXECUTE ON  [dbo].[TMT_GetCompCodes] TO [public]
GO
