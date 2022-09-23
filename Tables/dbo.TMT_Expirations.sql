CREATE TABLE [dbo].[TMT_Expirations]
(
[texp_id] [int] NOT NULL IDENTITY(1, 1),
[EXP_KEY] [int] NULL,
[EXP_IDTYPE] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_ID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_CODE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_EXPIRATIONDATE] [datetime] NULL,
[EXP_ROUTETO] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_PRIORITY] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_COMPLDATE] [datetime] NULL,
[EXP_COMPCODE] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_CODEKEY] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_MILESTOEXP] [int] NULL,
[EXP_DESCRIPTION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_STATUS] [smallint] NULL,
[EXP_OUTKEY] [int] NULL,
[EXP_DAYSINSHOP] [int] NULL,
[EXP_PERCENT] [int] NULL,
[EXP_ORDERID] [int] NULL,
[EXP_SECTION] [int] NULL,
[EXP_COMPLETED] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXP_TRANSFER_STATUS] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tex_idtype_id_compcode_comp] ON [dbo].[TMT_Expirations] ([EXP_IDTYPE], [EXP_ID], [EXP_COMPCODE], [EXP_COMPLETED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TMT_Expirations_texp_id] ON [dbo].[TMT_Expirations] ([texp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMT_Expirations] TO [public]
GO
GRANT INSERT ON  [dbo].[TMT_Expirations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMT_Expirations] TO [public]
GO
GRANT SELECT ON  [dbo].[TMT_Expirations] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMT_Expirations] TO [public]
GO
