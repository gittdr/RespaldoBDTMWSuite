CREATE TABLE [dbo].[edi_outbound204_refs]
(
[ob_204id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[ref_tablekey] [int] NULL,
[ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sequence] [smallint] NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_number] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eor_ob_204id] ON [dbo].[edi_outbound204_refs] ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eor_ord_hdrnumber] ON [dbo].[edi_outbound204_refs] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_refs] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_refs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound204_refs] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_refs] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_refs] TO [public]
GO
