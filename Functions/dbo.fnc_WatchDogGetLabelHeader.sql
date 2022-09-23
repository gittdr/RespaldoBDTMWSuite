SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_WatchDogGetLabelHeader] (@LabelDefinition varchar(255))
Returns varchar(255)

As 
Begin

Declare @LabelHeader varchar(255)

Select 
	@LabelHeader = 
        Min(userlabelname) 
From    labelfile (NOLOCK)
Where  
	labeldefinition = @LabelDefinition

Set @LabelHeader = IsNull(@LabelHeader,@LabelDefinition)

Return @LabelHeader

End






GO
