SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCommTag] @SelectedMCommSN int, 
				@Field int
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Max(ISNULL(Tag, '')) as Tag FROM tblMCommTags
	WHERE SelectedMCommSN = @SelectedMCommSN
	AND MCommFieldIdx = @Field

GO
GRANT EXECUTE ON  [dbo].[tm_GetMCommTag] TO [public]
GO
