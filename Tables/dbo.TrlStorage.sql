CREATE TABLE [dbo].[TrlStorage]
(
[tstg_id] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NULL,
[tstg_startdate] [datetime] NULL,
[tstg_billable] [bit] NOT NULL CONSTRAINT [DF__TrlStorag__tstg___7908539A] DEFAULT ((0)),
[tstg_bill_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tstg_enddate] [datetime] NULL,
[TrlStorageStatusId] [int] NOT NULL,
[tstg_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tstg_lastbilldate] [datetime] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDate] [datetime] NOT NULL,
[StorageCompanyId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToFreeDays] [int] NULL,
[Rate] [money] NULL,
[ivh_hdrnumber] [int] NULL,
[FreeDaysUsed] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorage] ADD CONSTRAINT [PK_TrlStorage] PRIMARY KEY CLUSTERED ([tstg_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrlStorage_stp_number] ON [dbo].[TrlStorage] ([stp_number]) INCLUDE ([ord_hdrnumber], [tstg_startdate], [tstg_enddate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorage] ADD CONSTRAINT [FK_TrlStorage_Stops] FOREIGN KEY ([stp_number]) REFERENCES [dbo].[stops] ([stp_number])
GO
ALTER TABLE [dbo].[TrlStorage] ADD CONSTRAINT [FK_TrlStorage_TrailerProfile] FOREIGN KEY ([trl_id]) REFERENCES [dbo].[trailerprofile] ([trl_id])
GO
ALTER TABLE [dbo].[TrlStorage] ADD CONSTRAINT [FK_TrlStorage_TrlStorageStatus] FOREIGN KEY ([TrlStorageStatusId]) REFERENCES [dbo].[TrlStorageStatus] ([TrlStorageStatusId])
GO
GRANT DELETE ON  [dbo].[TrlStorage] TO [public]
GO
GRANT INSERT ON  [dbo].[TrlStorage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrlStorage] TO [public]
GO
GRANT SELECT ON  [dbo].[TrlStorage] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrlStorage] TO [public]
GO
