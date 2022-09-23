CREATE TYPE [dbo].[TMWTable_ClassificationType] AS TABLE
(
[Type] [smallint] NOT NULL,
[Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TMWTable_ClassificationType] TO [public]
GO
