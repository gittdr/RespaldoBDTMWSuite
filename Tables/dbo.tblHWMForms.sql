CREATE TABLE [dbo].[tblHWMForms]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FormSN] [int] NULL,
[Version] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHWMForms] ADD CONSTRAINT [PK_tblHWMForms_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FomrID] ON [dbo].[tblHWMForms] ([FormSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMForms].[FormSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMForms].[Version]'
GO
GRANT DELETE ON  [dbo].[tblHWMForms] TO [public]
GO
GRANT INSERT ON  [dbo].[tblHWMForms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblHWMForms] TO [public]
GO
GRANT SELECT ON  [dbo].[tblHWMForms] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblHWMForms] TO [public]
GO
