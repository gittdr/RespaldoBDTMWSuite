CREATE TYPE [dbo].[TMWTable_VarChar8] AS TABLE
(
[KeyField] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TMWTable_VarChar8] TO [public]
GO
