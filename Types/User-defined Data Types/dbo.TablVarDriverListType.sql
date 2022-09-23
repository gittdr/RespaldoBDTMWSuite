CREATE TYPE [dbo].[TablVarDriverListType] AS TABLE
(
[driverId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED ([driverId])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TablVarDriverListType] TO [public]
GO
