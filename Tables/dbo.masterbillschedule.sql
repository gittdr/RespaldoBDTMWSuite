CREATE TABLE [dbo].[masterbillschedule]
(
[mbs_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mbs_date] [datetime] NOT NULL,
[mbs_mbnumber] [int] NOT NULL,
[mbs_printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mbs_beg_dtm] [datetime] NULL,
[mbs_end_dtm] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [i_mbs_1] ON [dbo].[masterbillschedule] ([mbs_billto], [mbs_date], [mbs_mbnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[masterbillschedule] TO [public]
GO
GRANT INSERT ON  [dbo].[masterbillschedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[masterbillschedule] TO [public]
GO
GRANT SELECT ON  [dbo].[masterbillschedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[masterbillschedule] TO [public]
GO
