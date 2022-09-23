CREATE TABLE [dbo].[dx_Archive_72183]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcedate] [datetime] NOT NULL,
[dx_seq] [int] NOT NULL,
[dx_updated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_accepted] [bit] NULL,
[dx_ordernumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_orderhdrnumber] [int] NULL,
[dx_movenumber] [int] NULL,
[dx_stopnumber] [int] NULL,
[dx_freightnumber] [int] NULL,
[dx_docnumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_manifestnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_manifeststop] [int] NULL,
[dx_batchref] [int] NULL,
[dx_field001] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field002] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field003] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field004] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field005] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field006] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field007] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field008] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field009] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field010] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field011] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field012] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field013] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field014] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field015] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field016] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field017] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field018] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field019] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field020] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field021] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field022] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field023] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field024] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field025] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field026] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field027] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field028] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field029] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field030] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field031] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field032] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field033] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field034] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field035] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_doctype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_createdate] [datetime] NULL,
[dx_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_updatedate] [datetime] NULL,
[dx_processed] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_trpid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_sourcedate_reference] [datetime] NULL,
[dx_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Archive_72183] ADD CONSTRAINT [pkey_dx_archive_72183] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_dx_Archive_72183] ON [dbo].[dx_Archive_72183] ([dx_importid], [dx_sourcename], [dx_sourcedate], [dx_seq]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2ArchiveOrderHeaderNumber_72183] ON [dbo].[dx_Archive_72183] ([dx_orderhdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2ArchiveOrderNumber_72183] ON [dbo].[dx_Archive_72183] ([dx_ordernumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_dx_archive_72183_processed] ON [dbo].[dx_Archive_72183] ([dx_processed]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2ArchiveSourceDate_72183] ON [dbo].[dx_Archive_72183] ([dx_sourcedate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Archive_72183] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Archive_72183] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Archive_72183] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Archive_72183] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Archive_72183] TO [public]
GO
