CREATE TABLE [dbo].[AggregateRateFormulaSource]
(
[AggregateRateFormulaSourceId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AggregateRateFormulaSource] ADD CONSTRAINT [PK_AggregateRateFormulaSourceId] PRIMARY KEY CLUSTERED ([AggregateRateFormulaSourceId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AggregateRateFormulaSource] TO [public]
GO
GRANT INSERT ON  [dbo].[AggregateRateFormulaSource] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AggregateRateFormulaSource] TO [public]
GO
GRANT SELECT ON  [dbo].[AggregateRateFormulaSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[AggregateRateFormulaSource] TO [public]
GO
