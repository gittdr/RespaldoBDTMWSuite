CREATE TABLE [dbo].[edi_Inbound214_Misc]
(
[mdt_id] [int] NOT NULL IDENTITY(1, 1),
[mdt_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_tablekey] [int] NOT NULL,
[mdt_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_process_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mdt_updatedate] [datetime] NULL,
[mdt_timestamp] [timestamp] NULL,
[mdt_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mdt_ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_Inbound214_Misc] ADD CONSTRAINT [pk_edi_inbound214_misc] PRIMARY KEY CLUSTERED ([mdt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_Inbound214_Misc] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_Inbound214_Misc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_Inbound214_Misc] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_Inbound214_Misc] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_Inbound214_Misc] TO [public]
GO
