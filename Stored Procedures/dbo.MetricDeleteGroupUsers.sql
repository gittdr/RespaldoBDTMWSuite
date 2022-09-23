SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteGroupUsers] (@GroupSN int, @UserSN int)
AS
	SET NOCOUNT ON

	IF @GroupSN <> -1
		DELETE MetricGroupUsers WHERE UserSN = @UserSN AND GroupSN = @GroupSN 
	ELSE
		DELETE MetricGroupUsers WHERE UserSN = @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteGroupUsers] TO [public]
GO
