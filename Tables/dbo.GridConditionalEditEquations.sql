CREATE TABLE [dbo].[GridConditionalEditEquations]
(
[GridName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[Operand] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EquationColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EquationColumnValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConditionGroupID] [int] NOT NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GridLayoutID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ConditionGroupIndex] ON [dbo].[GridConditionalEditEquations] ([ConditionGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridIndex] ON [dbo].[GridConditionalEditEquations] ([GridName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridAndColumnIndex] ON [dbo].[GridConditionalEditEquations] ([GridName], [ColumnName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridAndColumnAndLayoutIdIndex] ON [dbo].[GridConditionalEditEquations] ([GridName], [ColumnName], [GridLayoutID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GridConditionalEditEquations] ADD CONSTRAINT [uq_namesSequenceAndLayoutId] UNIQUE NONCLUSTERED ([GridName], [ColumnName], [Sequence], [GridLayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GridConditionalEditEquations] TO [public]
GO
GRANT INSERT ON  [dbo].[GridConditionalEditEquations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GridConditionalEditEquations] TO [public]
GO
GRANT SELECT ON  [dbo].[GridConditionalEditEquations] TO [public]
GO
GRANT UPDATE ON  [dbo].[GridConditionalEditEquations] TO [public]
GO
