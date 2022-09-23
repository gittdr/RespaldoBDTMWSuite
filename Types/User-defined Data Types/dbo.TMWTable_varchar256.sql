CREATE TYPE [dbo].[TMWTable_varchar256] AS TABLE
(
[KeyField] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TMWTable_varchar256] TO [public]
GO
