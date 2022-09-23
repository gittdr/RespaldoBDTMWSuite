CREATE TABLE [dbo].[dx_Archive_detail]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_Archive_header_id] [bigint] NOT NULL,
[dx_seq] [smallint] NOT NULL,
[dx_stopnumber] [int] NULL,
[dx_freightnumber] [int] NULL,
[dx_manifeststop] [int] NULL,
[dx_field001] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field002] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field003] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field004] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field005] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field006] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field007] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field008] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field009] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field010] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field011] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field012] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field013] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field014] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field015] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field016] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field017] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field018] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field019] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field020] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field021] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field022] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field023] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field024] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field025] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field026] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field027] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field028] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field029] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field030] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field031] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field032] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field033] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field034] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field035] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Archive_detail] ADD CONSTRAINT [pk_dx_Archive_detail] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_dx_Archive_detail] ON [dbo].[dx_Archive_detail] ([dx_Archive_header_id], [dx_seq]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Archive_detail] ADD CONSTRAINT [FK_dx_Archive_detail_dx_Archive_header] FOREIGN KEY ([dx_Archive_header_id]) REFERENCES [dbo].[dx_Archive_header] ([dx_Archive_header_id])
GO
GRANT DELETE ON  [dbo].[dx_Archive_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Archive_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Archive_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Archive_detail] TO [public]
GO
