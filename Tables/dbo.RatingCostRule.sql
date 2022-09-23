CREATE TABLE [dbo].[RatingCostRule]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NOT NULL,
[CreateInvoiceDetail] [bit] NOT NULL,
[CreatePayDetail] [bit] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_RatingCostRule_IsActive] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostRule] ADD CONSTRAINT [PK_RatingCostRule] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostRule] ADD CONSTRAINT [UX_RatingCostRule] UNIQUE NONCLUSTERED ([tar_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RatingCostRule] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostRule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostRule] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostRule] TO [public]
GO
