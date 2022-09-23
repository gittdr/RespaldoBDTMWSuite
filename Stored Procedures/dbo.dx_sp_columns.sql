SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[dx_sp_columns] (@proc_name varchar(255))
as

SELECT  syscolumns.name, systypes.name AS type, syscolumns.length, syscolumns.isoutparam,
syscolumns.isnullable, sysobjects.name AS proc_name 
FROM syscolumns INNER JOIN 
sysobjects ON syscolumns.id = sysobjects.id LEFT OUTER JOIN 
systypes ON syscolumns.xtype = systypes.xtype 
WHERE     (sysobjects.name LIKE @proc_name)
ORDER BY sysobjects.name, syscolumns.colorder 

GO
GRANT EXECUTE ON  [dbo].[dx_sp_columns] TO [public]
GO
