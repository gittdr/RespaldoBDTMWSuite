SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   Procedure [dbo].[sp_TTSTMWGetLoginMethod]

As

Select gia_value as Value
From   MR_GeneralInfoAdmin
Where  gia_key = 'LoginMethod'
       



GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWGetLoginMethod] TO [public]
GO
