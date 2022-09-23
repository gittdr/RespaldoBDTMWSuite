CREATE TABLE [dbo].[DeliveryRpt_TerminalTranslation]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rev_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[translation] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_billto_revtype] ON [dbo].[DeliveryRpt_TerminalTranslation] ([billto], [rev_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DeliveryRpt_TerminalTranslation] TO [public]
GO
GRANT INSERT ON  [dbo].[DeliveryRpt_TerminalTranslation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DeliveryRpt_TerminalTranslation] TO [public]
GO
GRANT SELECT ON  [dbo].[DeliveryRpt_TerminalTranslation] TO [public]
GO
GRANT UPDATE ON  [dbo].[DeliveryRpt_TerminalTranslation] TO [public]
GO
