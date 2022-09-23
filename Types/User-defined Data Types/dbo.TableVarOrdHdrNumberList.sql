CREATE TYPE [dbo].[TableVarOrdHdrNumberList] AS TABLE
(
[orderHdrNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED ([orderHdrNumber])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[TableVarOrdHdrNumberList] TO [public]
GO
