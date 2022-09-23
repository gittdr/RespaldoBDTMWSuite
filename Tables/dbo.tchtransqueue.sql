CREATE TABLE [dbo].[tchtransqueue]
(
[ttq_id] [int] NOT NULL IDENTITY(1, 1),
[ttq_mov_number] [int] NULL,
[ttq_userid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttq_issuedon] [datetime] NULL,
[ttq_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttq_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttq_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttq_trailer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttq_tripnum] [int] NULL,
[ttq_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tchtransqueue] ADD CONSTRAINT [pk_tchtransqueue] PRIMARY KEY CLUSTERED ([ttq_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tchtransqueue] TO [public]
GO
GRANT INSERT ON  [dbo].[tchtransqueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tchtransqueue] TO [public]
GO
GRANT SELECT ON  [dbo].[tchtransqueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[tchtransqueue] TO [public]
GO
