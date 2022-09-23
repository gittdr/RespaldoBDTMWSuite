CREATE TABLE [dbo].[tblFormViewFields]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FormFieldSN] [int] NULL,
[SelectedViewsSN] [int] NULL,
[ViewFieldSN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFormViewFields] ADD CONSTRAINT [PK_tblFormViewFields_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblFormFieldstblFormViewFields] ON [dbo].[tblFormViewFields] ([FormFieldSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFormViewFields] ADD CONSTRAINT [FK__Temporary__FormF__5C81C570] FOREIGN KEY ([FormFieldSN]) REFERENCES [dbo].[tblFormFields] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormViewFields].[FormFieldSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormViewFields].[SelectedViewsSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormViewFields].[ViewFieldSN]'
GO
GRANT DELETE ON  [dbo].[tblFormViewFields] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFormViewFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFormViewFields] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFormViewFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFormViewFields] TO [public]
GO
