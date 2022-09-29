CREATE TABLE [dbo].[dw_install_log]
(
[entry_no] [int] NOT NULL,
[log_message] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sys_timestamp] [datetime] NOT NULL CONSTRAINT [DF__dw_instal__sys_t__4EC8649F] DEFAULT (getdate())
) ON [PRIMARY]
GO
