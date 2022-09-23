CREATE TABLE [dbo].[paperworkMisc]
(
[pms_ident] [int] NOT NULL IDENTITY(1, 1),
[pw_ident] [int] NOT NULL,
[Driver_ppw_date] [datetime] NULL,
[PPW_ShipMethod] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPW_EnvelopColor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paperworkMisc] ADD CONSTRAINT [pk_pms_ident] PRIMARY KEY CLUSTERED ([pms_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_paperworkMisc_pw_ident] ON [dbo].[paperworkMisc] ([pw_ident]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paperworkMisc] ADD CONSTRAINT [FK_paperworkMisc_Paperwork] FOREIGN KEY ([pw_ident]) REFERENCES [dbo].[paperwork] ([pw_ident]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[paperworkMisc] TO [public]
GO
GRANT INSERT ON  [dbo].[paperworkMisc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paperworkMisc] TO [public]
GO
GRANT SELECT ON  [dbo].[paperworkMisc] TO [public]
GO
GRANT UPDATE ON  [dbo].[paperworkMisc] TO [public]
GO
