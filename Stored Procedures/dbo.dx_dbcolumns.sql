SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_dbcolumns]
	@table nvarchar(50),
	@column nvarchar(50)
AS 
begin
    SELECT     dbo.sysobjects.name AS tableName, dbo.syscolumns.name AS columnName, dbo.systypes.name AS typeName, dbo.syscolumns.length
    FROM         dbo.sysobjects 
        INNER JOIN
            dbo.syscolumns ON dbo.sysobjects.id = dbo.syscolumns.id 
        INNER JOIN
            dbo.systypes ON dbo.syscolumns.xtype = dbo.systypes.xtype
    WHERE   (dbo.sysobjects.name like @table) AND (dbo.syscolumns.name like @column)
end

GO
GRANT EXECUTE ON  [dbo].[dx_dbcolumns] TO [public]
GO
