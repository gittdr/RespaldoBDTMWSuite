SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[TMWTemp_EnsureColumn] @TableName varchar(50), @ColumnName varchar(50), @ColumnType varchar(100), @DefaultName varchar(1000), @DefaultVal varchar(1000)
as
begin
	if not exists (select * from INFORMATION_SCHEMA.COLUMNS c where c.TABLE_NAME = @TableName and c.COLUMN_NAME = @ColumnName)
		BEGIN
		DECLARE @DdlCmd varchar(MAX);
		SELECT @DdlCmd  = 'ALTER TABLE '+@TableName +' ADD ' + @ColumnName + ' ' + @ColumnType;
		if not (@DefaultVal is NULL)
			BEGIN
			IF @DefaultName IS NULL
				BEGIN
				SELECT @DdlCmd = @DdlCmd + ' DEFAULT ' + @DefaultVal 
				END
			ELSE
				BEGIN
				SELECT @DdlCmd = @DdlCmd + ' CONSTRAINT ' + @DefaultName + ' DEFAULT ' + @DefaultVal
				END
			END
		-- SELECT @DdlCmd 
		EXEC (@DdlCmd);
		END
end
GO
GRANT EXECUTE ON  [dbo].[TMWTemp_EnsureColumn] TO [public]
GO
