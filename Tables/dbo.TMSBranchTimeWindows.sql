CREATE TABLE [dbo].[TMSBranchTimeWindows]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HoursBack] [int] NOT NULL,
[HoursOut] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranchTimeWindows] ADD CONSTRAINT [pk_TMSBranchTimeWindows] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranchTimeWindows] ADD CONSTRAINT [fk_tmsbranchtimewindows_billto] FOREIGN KEY ([billto]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSBranchTimeWindows] ADD CONSTRAINT [fk_tmsbranchtimewindows_branch] FOREIGN KEY ([brn_id]) REFERENCES [dbo].[branch] ([brn_id])
GO
ALTER TABLE [dbo].[TMSBranchTimeWindows] ADD CONSTRAINT [fk_tmsbranchtimewindows_consignee] FOREIGN KEY ([consignee]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TMSBranchTimeWindows] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSBranchTimeWindows] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMSBranchTimeWindows] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSBranchTimeWindows] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSBranchTimeWindows] TO [public]
GO
