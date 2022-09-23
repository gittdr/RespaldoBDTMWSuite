CREATE TABLE [dbo].[userobject_hyperlinks]
(
[uh_id] [int] NOT NULL IDENTITY(1, 1),
[uh_window] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uh_window_datawindow_control] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uh_datawindow_object] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uh_datawindow_control] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uh_datawindow_embedded_report_id] [int] NULL,
[uh_command_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uh_command_line] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_hyperlinks] ADD CONSTRAINT [PK__userobject_hyper__67F93947] PRIMARY KEY CLUSTERED ([uh_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivd_uh_datawindow_embedded_report_id] ON [dbo].[userobject_hyperlinks] ([uh_datawindow_embedded_report_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivd_uh_datawindow] ON [dbo].[userobject_hyperlinks] ([uh_window], [uh_window_datawindow_control], [uh_datawindow_object]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userobject_hyperlinks] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject_hyperlinks] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject_hyperlinks] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject_hyperlinks] TO [public]
GO
