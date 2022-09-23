CREATE TABLE [dbo].[Permit_Requirements_Default]
(
[PRD_ID] [int] NOT NULL IDENTITY(1, 1),
[PM_ID] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRD_RequiredFrom] [datetime] NULL,
[PRD_RequiredTo] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Requirements_Default] ADD CONSTRAINT [PK_Permit_Requirements] PRIMARY KEY CLUSTERED ([PRD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Requirements_Default] ADD CONSTRAINT [FK_Permit_Requirements_Default_Permit_Master] FOREIGN KEY ([PM_ID]) REFERENCES [dbo].[Permit_Master] ([PM_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Requirements_Default] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Requirements_Default] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Requirements_Default] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Requirements_Default] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Requirements_Default] TO [public]
GO
