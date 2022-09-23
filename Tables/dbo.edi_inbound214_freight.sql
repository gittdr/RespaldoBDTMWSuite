CREATE TABLE [dbo].[edi_inbound214_freight]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NULL,
[fgt_sequence] [smallint] NULL,
[cmd_code] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_weight] [float] NULL,
[fgt_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_count] [decimal] (10, 2) NULL,
[fgt_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume] [float] NULL,
[fgt_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rejection_error_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_inbound214_freight] ADD CONSTRAINT [PK_edi_inbound214_freight] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_inbound214_freight] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_inbound214_freight] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_inbound214_freight] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_inbound214_freight] TO [public]
GO
