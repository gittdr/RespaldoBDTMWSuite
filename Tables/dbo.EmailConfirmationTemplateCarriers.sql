CREATE TABLE [dbo].[EmailConfirmationTemplateCarriers]
(
[ectc_id] [int] NOT NULL IDENTITY(1, 1),
[ect_id] [int] NOT NULL,
[carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmailConfirmationTemplateCarriers] ADD CONSTRAINT [pk_ectc_id] PRIMARY KEY CLUSTERED ([ectc_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmailConfirmationTemplateCarriers] ADD CONSTRAINT [fk_ect_id] FOREIGN KEY ([ect_id]) REFERENCES [dbo].[EmailConfirmationTemplates] ([ect_id])
GO
GRANT DELETE ON  [dbo].[EmailConfirmationTemplateCarriers] TO [public]
GO
GRANT INSERT ON  [dbo].[EmailConfirmationTemplateCarriers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EmailConfirmationTemplateCarriers] TO [public]
GO
GRANT SELECT ON  [dbo].[EmailConfirmationTemplateCarriers] TO [public]
GO
GRANT UPDATE ON  [dbo].[EmailConfirmationTemplateCarriers] TO [public]
GO
