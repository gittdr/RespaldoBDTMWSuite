CREATE TABLE [dbo].[StopTimeWindows]
(
[RecId] [int] NOT NULL IDENTITY(1, 1),
[Terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NOT NULL,
[EndTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopTimeWindows] ADD CONSTRAINT [PK__StopTimeWindows__2CB3E5A8] PRIMARY KEY CLUSTERED ([RecId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [StopTimeWindow_Terminal] ON [dbo].[StopTimeWindows] ([Terminal]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StopTimeWindows] TO [public]
GO
GRANT INSERT ON  [dbo].[StopTimeWindows] TO [public]
GO
GRANT SELECT ON  [dbo].[StopTimeWindows] TO [public]
GO
GRANT UPDATE ON  [dbo].[StopTimeWindows] TO [public]
GO
