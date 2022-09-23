SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vTTSTMW_YesNo]

as

Select 'Yes' as Type

Union

Select 'No' as Type

GO
GRANT SELECT ON  [dbo].[vTTSTMW_YesNo] TO [public]
GO
