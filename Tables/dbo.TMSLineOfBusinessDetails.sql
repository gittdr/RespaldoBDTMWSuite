CREATE TABLE [dbo].[TMSLineOfBusinessDetails]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[BranchID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldDefinition] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLineOfBusinessDetails] ADD CONSTRAINT [PK_TMSLineOfBusinessDetails] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLineOfBusinessDetails] ADD CONSTRAINT [UC_TMSLineOfBusinessDetails_BranchID_FieldName] UNIQUE NONCLUSTERED ([BranchID], [FieldName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLineOfBusinessDetails] ADD CONSTRAINT [FK_branch_TMSLineOfBusinessDetails] FOREIGN KEY ([BranchID]) REFERENCES [dbo].[branch] ([brn_id])
GO
GRANT DELETE ON  [dbo].[TMSLineOfBusinessDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSLineOfBusinessDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSLineOfBusinessDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSLineOfBusinessDetails] TO [public]
GO
