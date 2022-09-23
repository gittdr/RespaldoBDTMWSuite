CREATE TABLE [dbo].[ordertimetable]
(
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ott_pickuptime] [datetime] NOT NULL,
[ott_minimumtime] [datetime] NOT NULL,
[ott_speed] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordertimetable] ADD CONSTRAINT [PK__ordertimetable__7D1D0E7B] PRIMARY KEY CLUSTERED ([ord_revtype1], [ord_revtype2]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordertimetable] TO [public]
GO
GRANT INSERT ON  [dbo].[ordertimetable] TO [public]
GO
GRANT SELECT ON  [dbo].[ordertimetable] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordertimetable] TO [public]
GO
