CREATE TABLE [dbo].[temp_report_arguments]
(
[current_session_id] [int] NOT NULL CONSTRAINT [DF__temp_repo__curre__1368413C] DEFAULT (@@spid),
[temp_report_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[temp_report_argument_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[temp_report_argument_value] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_id] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_report_arguments] ADD CONSTRAINT [PK__temp_rep__9E078C13DA520F4C] PRIMARY KEY CLUSTERED ([tra_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[temp_report_arguments] TO [public]
GO
GRANT INSERT ON  [dbo].[temp_report_arguments] TO [public]
GO
GRANT SELECT ON  [dbo].[temp_report_arguments] TO [public]
GO
GRANT UPDATE ON  [dbo].[temp_report_arguments] TO [public]
GO
