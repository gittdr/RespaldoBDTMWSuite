CREATE TABLE [dbo].[commodity_xref]
(
[cmd_xref_id] [int] NOT NULL IDENTITY(1, 1),
[cmd_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crt_date] [datetime] NULL,
[src_system] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_date] [datetime] NULL,
[upd_count] [int] NULL,
[upd_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_tradingpartner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_xref] ADD CONSTRAINT [PK__commodit__D437563942CC2180] PRIMARY KEY CLUSTERED ([cmd_xref_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_xref] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_xref] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_xref] TO [public]
GO
