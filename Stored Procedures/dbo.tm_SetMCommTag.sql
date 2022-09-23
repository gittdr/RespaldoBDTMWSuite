SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetMCommTag] @SelectedMCommSN int, 
				@Field int,
				@Tag varchar(16)
AS

-- Clean up any preexisting (assumed outdated) entry
DELETE FROM tblMCommTags
	WHERE SelectedMCommSN = @SelectedMCommSN
	AND MCommFieldIdx = @Field

IF ISNULL(@Tag,'')<>''
	INSERT INTO tblMCommTags
		(SelectedMCommSN, MCommFieldIdx, Tag)
		VALUES
		(@SelectedMCommSN, @Field, @Tag)

GO
GRANT EXECUTE ON  [dbo].[tm_SetMCommTag] TO [public]
GO
