CREATE TABLE [dbo].[Permit_Satisfied_By]
(
[PSB_ID] [int] NOT NULL IDENTITY(1, 1),
[PM_ID] [int] NOT NULL,
[PM_ID_Satisfied_By] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Satisfied_By] ADD CONSTRAINT [PK_IE_Permit_Satisfies] PRIMARY KEY CLUSTERED ([PSB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Satisfied_By] ADD CONSTRAINT [FK_Permit_Satisfied_By_Permit_Master] FOREIGN KEY ([PM_ID]) REFERENCES [dbo].[Permit_Master] ([PM_ID])
GO
ALTER TABLE [dbo].[Permit_Satisfied_By] ADD CONSTRAINT [FK_Permit_Satisfied_By_Permit_Master1] FOREIGN KEY ([PM_ID_Satisfied_By]) REFERENCES [dbo].[Permit_Master] ([PM_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Satisfied_By] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Satisfied_By] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Satisfied_By] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Satisfied_By] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Satisfied_By] TO [public]
GO
