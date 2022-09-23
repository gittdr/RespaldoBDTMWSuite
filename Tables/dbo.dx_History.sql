CREATE TABLE [dbo].[dx_History]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcedate] [datetime] NOT NULL,
[dx_actiondate] [datetime] NOT NULL,
[dx_hist_seq] [bigint] NOT NULL,
[dx_origin] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_command] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_commandstring] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_returncode] [int] NULL,
[dx_orderhdrnumber] [int] NULL,
[dx_ordernumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_docnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_controlnumber] [int] NULL,
[dx_spid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_History] ADD CONSTRAINT [uk_dx_History_Ident] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_history_dx_actiondate] ON [dbo].[dx_History] ([dx_actiondate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_history_dx_docnumber] ON [dbo].[dx_History] ([dx_docnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_dx_History] ON [dbo].[dx_History] ([dx_importid], [dx_sourcename], [dx_sourcedate], [dx_actiondate], [dx_hist_seq]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_history_dx_orderhdrnumber] ON [dbo].[dx_History] ([dx_orderhdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_history_dx_ordernumber] ON [dbo].[dx_History] ([dx_ordernumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_History] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_History] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_History] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_History] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_History] TO [public]
GO
