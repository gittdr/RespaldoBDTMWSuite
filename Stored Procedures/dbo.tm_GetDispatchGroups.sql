SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_GetDispatchGroups]

AS

SET NOCOUNT ON

	SELECT Name 
	FROM tblDispatchGroup (NOLOCK)

GO
GRANT EXECUTE ON  [dbo].[tm_GetDispatchGroups] TO [public]
GO
