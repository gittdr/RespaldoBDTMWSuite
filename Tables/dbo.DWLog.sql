CREATE TABLE [dbo].[DWLog]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[log_date] [datetime] NOT NULL CONSTRAINT [DF__DWLog__log_date__01741A25] DEFAULT (getdate()),
[log_comment] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DWLog] ADD CONSTRAINT [PK__DWLog__007FF5EC] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DWLog] TO [public]
GO
GRANT INSERT ON  [dbo].[DWLog] TO [public]
GO
GRANT SELECT ON  [dbo].[DWLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[DWLog] TO [public]
GO
