SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  proc [dbo].[dx_get_table_desc_sp] @dbtable varchar(50)
AS

SELECT   value
FROM   ::fn_listextendedproperty(NULL, 'user', 'dbo', 'TABLE', @dbtable, default, NULL)

GO
GRANT EXECUTE ON  [dbo].[dx_get_table_desc_sp] TO [public]
GO
