CREATE TABLE [dbo].[CostAllocationFormula]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source] [int] NOT NULL,
[Formula] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedDate] [datetime2] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CostAllocationFormula] ADD CONSTRAINT [PK_CostAllocationFormula] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CostAllocationFormula] TO [public]
GO
GRANT INSERT ON  [dbo].[CostAllocationFormula] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CostAllocationFormula] TO [public]
GO
GRANT SELECT ON  [dbo].[CostAllocationFormula] TO [public]
GO
GRANT UPDATE ON  [dbo].[CostAllocationFormula] TO [public]
GO
