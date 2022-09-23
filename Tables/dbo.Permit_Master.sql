CREATE TABLE [dbo].[Permit_Master]
(
[PM_ID] [int] NOT NULL IDENTITY(1, 1),
[PIA_ID] [int] NULL,
[PM_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PM_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Permit_Cost] [money] NULL,
[PM_Contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact_Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact_Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact_Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact2_Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact2_Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Contact2_Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Comment1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_Comment2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PM_timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Master] ADD CONSTRAINT [PK_IE_Permit_Master] PRIMARY KEY CLUSTERED ([PM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Master] ADD CONSTRAINT [IX_Permit_Master_PM_Name] UNIQUE NONCLUSTERED ([PM_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Master] ADD CONSTRAINT [FK_Permit_Master_Permit_Issuing_Authority] FOREIGN KEY ([PIA_ID]) REFERENCES [dbo].[Permit_Issuing_Authority] ([PIA_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Master] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Master] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Master] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Master] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Master] TO [public]
GO
