CREATE TYPE [dbo].[IntInParm] AS TABLE
(
[intItem] [int] NOT NULL,
PRIMARY KEY CLUSTERED ([intItem])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[IntInParm] TO [public]
GO
GRANT REFERENCES ON TYPE:: [dbo].[IntInParm] TO [public]
GO
GRANT VIEW DEFINITION ON TYPE:: [dbo].[IntInParm] TO [public]
GO
