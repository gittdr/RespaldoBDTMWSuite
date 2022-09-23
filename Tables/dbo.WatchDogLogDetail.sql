CREATE TABLE [dbo].[WatchDogLogDetail]
(
[sn] [int] NOT NULL,
[FldName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FldValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogLogDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogLogDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WatchDogLogDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogLogDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogLogDetail] TO [public]
GO
