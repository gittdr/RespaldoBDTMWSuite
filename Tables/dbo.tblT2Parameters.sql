CREATE TABLE [dbo].[tblT2Parameters]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TrailerSN] [int] NOT NULL,
[Code] [int] NOT NULL,
[ReceivedOn] [datetime] NOT NULL,
[Value] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PendingValue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblT2Parameters] ADD CONSTRAINT [PK_tblT2Parameters] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblT2Parameters] ON [dbo].[tblT2Parameters] ([TrailerSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblT2Parameters] TO [public]
GO
GRANT INSERT ON  [dbo].[tblT2Parameters] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblT2Parameters] TO [public]
GO
GRANT SELECT ON  [dbo].[tblT2Parameters] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblT2Parameters] TO [public]
GO
