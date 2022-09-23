CREATE TABLE [dbo].[Permit_Requirements]
(
[PR_ID] [int] NOT NULL IDENTITY(1, 1),
[PM_ID] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PR_Default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PR_Escort_Required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PR_Escort_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PR_Escort_Qty] [smallint] NULL,
[pr_comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Requirements] ADD CONSTRAINT [PK_Permit_Requirements_1] PRIMARY KEY CLUSTERED ([PR_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_permit_requirements_lgh_number] ON [dbo].[Permit_Requirements] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_permit_requirements_mov_number] ON [dbo].[Permit_Requirements] ([mov_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Requirements] ADD CONSTRAINT [FK_Permit_Requirements_Permit_Master] FOREIGN KEY ([PM_ID]) REFERENCES [dbo].[Permit_Master] ([PM_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Requirements] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Requirements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Requirements] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Requirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Requirements] TO [public]
GO
