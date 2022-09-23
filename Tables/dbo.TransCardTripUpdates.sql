CREATE TABLE [dbo].[TransCardTripUpdates]
(
[tctu_id] [int] NOT NULL IDENTITY(1, 1),
[tctu_asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tctu_asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tctu_updatedon] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TransCardTripUpdates] TO [public]
GO
GRANT INSERT ON  [dbo].[TransCardTripUpdates] TO [public]
GO
GRANT SELECT ON  [dbo].[TransCardTripUpdates] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransCardTripUpdates] TO [public]
GO
