SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Extra_Info_Get_Header_List_sp] AS
BEGIN
/* Returns a list of tabs and columns defined under a particular header
*/
SELECT	EXTRA_INFO_HEADER.EXTRA_ID,
EXTRA_INFO_HEADER.TABLE_NAME,
EXTRA_INFO_HEADER.WIN_TITLE
FROM	EXTRA_INFO_HEADER
ORDER BY EXTRA_INFO_HEADER.TABLE_NAME
END
GO
GRANT EXECUTE ON  [dbo].[Extra_Info_Get_Header_List_sp] TO [public]
GO