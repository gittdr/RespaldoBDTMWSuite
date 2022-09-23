SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdCheckExistsDataSources] (@Caption varchar(20))
AS
	SET NOCOUNT ON
	
	IF EXISTS(SELECT * FROM rnExternalDataSource WHERE Caption = @Caption) SELECT 1 ELSE SELECT 0
GO
GRANT EXECUTE ON  [dbo].[rnwdCheckExistsDataSources] TO [public]
GO
