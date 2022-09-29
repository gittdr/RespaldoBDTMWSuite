SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Extra_Info_Get_Tab_List_sp](@Extra_ID INTEGER) AS
BEGIN
/* Returns a list of tabs and columns defined under a particular header
*/
SELECT	EXTRA_INFO_TAB.TAB_ID,
EXTRA_INFO_TAB.TAB_NAME
FROM	EXTRA_INFO_TAB
WHERE	EXTRA_INFO_TAB.EXTRA_ID = @Extra_ID
ORDER BY EXTRA_INFO_TAB.TAB_NAME
END
GO
GRANT EXECUTE ON  [dbo].[Extra_Info_Get_Tab_List_sp] TO [public]
GO