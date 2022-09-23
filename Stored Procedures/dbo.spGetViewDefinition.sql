SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetViewDefinition] 
	@ViewName VARCHAR(255)
AS
BEGIN
SELECT sm.definition
FROM sys.sql_modules AS sm
JOIN sys.objects AS o ON sm.object_id = o.object_id
where OBJECT_NAME(sm.object_id) = @ViewName collate SQL_Latin1_General_CP1_CI_AS
ORDER BY o.type;
END
GO
GRANT EXECUTE ON  [dbo].[spGetViewDefinition] TO [public]
GO
