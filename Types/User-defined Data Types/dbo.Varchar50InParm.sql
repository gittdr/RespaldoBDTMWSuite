CREATE TYPE [dbo].[Varchar50InParm] AS TABLE
(
[VarcharItem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED ([VarcharItem])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[Varchar50InParm] TO [public]
GO
GRANT REFERENCES ON TYPE:: [dbo].[Varchar50InParm] TO [public]
GO
GRANT VIEW DEFINITION ON TYPE:: [dbo].[Varchar50InParm] TO [public]
GO
