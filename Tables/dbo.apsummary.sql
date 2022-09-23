CREATE TABLE [dbo].[apsummary]
(
[stlmnt] [int] NOT NULL,
[type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[docno] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [datetime] NOT NULL,
[status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[netamt] [money] NOT NULL,
[remaining] [money] NOT NULL,
[gpcurtrxam] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apsummary] ADD CONSTRAINT [pk_apsummary2] PRIMARY KEY CLUSTERED ([stlmnt]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_apsummary_id_period] ON [dbo].[apsummary] ([type], [id], [period]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[apsummary] TO [public]
GO
GRANT INSERT ON  [dbo].[apsummary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[apsummary] TO [public]
GO
GRANT SELECT ON  [dbo].[apsummary] TO [public]
GO
GRANT UPDATE ON  [dbo].[apsummary] TO [public]
GO
