SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertGroupUsers] (@GroupSN int, @UserSN int)
AS
	SET NOCOUNT ON

	INSERT INTO MetricGroupUsers (GroupSN, UserSN) 
	SELECT @GroupSN, @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricInsertGroupUsers] TO [public]
GO
