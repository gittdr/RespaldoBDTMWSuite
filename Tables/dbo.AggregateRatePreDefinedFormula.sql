CREATE TABLE [dbo].[AggregateRatePreDefinedFormula]
(
[AggregateRatePreDefinedFormulaId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AggregateRatePreDefinedFormula] ADD CONSTRAINT [PK_AggregateRatePreDefinedFormulaId] PRIMARY KEY CLUSTERED ([AggregateRatePreDefinedFormulaId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AggregateRatePreDefinedFormula] TO [public]
GO
GRANT INSERT ON  [dbo].[AggregateRatePreDefinedFormula] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AggregateRatePreDefinedFormula] TO [public]
GO
GRANT SELECT ON  [dbo].[AggregateRatePreDefinedFormula] TO [public]
GO
GRANT UPDATE ON  [dbo].[AggregateRatePreDefinedFormula] TO [public]
GO
