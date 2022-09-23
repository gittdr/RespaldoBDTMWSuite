SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebSQLViews]
AS
	SELECT 
		name 
	FROM sysobjects	
	WHERE type = 'V' AND name <> 'WebSQLViews'
GO
GRANT SELECT ON  [dbo].[WebSQLViews] TO [public]
GO
