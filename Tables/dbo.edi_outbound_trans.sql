CREATE TABLE [dbo].[edi_outbound_trans]
(
[etn_id] [int] NOT NULL IDENTITY(1, 1),
[etn_number] [int] NOT NULL,
[etn_integer] [int] NOT NULL,
[etn_string] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etn_created] [datetime] NOT NULL,
[etn_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etn_integer2] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_outbound_trans] ADD CONSTRAINT [pk_edi_outbound_trans] PRIMARY KEY CLUSTERED ([etn_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_edi_outbound_trans_etn_integer] ON [dbo].[edi_outbound_trans] ([etn_integer]) INCLUDE ([etn_number], [etn_created], [etn_integer2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_edi_outbound_trans_etn_integer2] ON [dbo].[edi_outbound_trans] ([etn_integer2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_edi_outbound_trans] ON [dbo].[edi_outbound_trans] ([etn_number], [etn_integer]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound_trans] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound_trans] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound_trans] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound_trans] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound_trans] TO [public]
GO
