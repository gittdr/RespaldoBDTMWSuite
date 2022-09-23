CREATE TABLE [dbo].[edi_outbound204_notes]
(
[ob_204id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[not_sentby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntb_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_sequence] [smallint] NULL,
[not_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eon_ob_204id] ON [dbo].[edi_outbound204_notes] ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eon_ord_hdrnumber] ON [dbo].[edi_outbound204_notes] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_notes] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_notes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound204_notes] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_notes] TO [public]
GO
