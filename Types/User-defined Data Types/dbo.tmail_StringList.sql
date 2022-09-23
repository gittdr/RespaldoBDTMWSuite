CREATE TYPE [dbo].[tmail_StringList] AS TABLE
(
[Val] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[tmail_StringList] TO [public]
GO
