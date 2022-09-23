CREATE TABLE [dbo].[tchtransqhist]
(
[ttqh_id] [int] NOT NULL IDENTITY(1, 1),
[ttq_id] [int] NULL,
[ttqh_mov_number] [int] NULL,
[ttqh_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttqh_issuedon] [datetime] NULL,
[ttqh_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttqh_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttqh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttqh_trailer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttqh_tripnum] [int] NULL,
[ttqh_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tchtransqhist] ADD CONSTRAINT [PK_tchtransqhist] PRIMARY KEY CLUSTERED ([ttqh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tchtransqhist] TO [public]
GO
GRANT INSERT ON  [dbo].[tchtransqhist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tchtransqhist] TO [public]
GO
GRANT SELECT ON  [dbo].[tchtransqhist] TO [public]
GO
GRANT UPDATE ON  [dbo].[tchtransqhist] TO [public]
GO
