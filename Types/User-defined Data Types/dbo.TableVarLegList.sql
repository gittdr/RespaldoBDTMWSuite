CREATE TYPE [dbo].[TableVarLegList] AS TABLE
(
[legNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED ([legNumber])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TableVarLegList] TO [public]
GO
