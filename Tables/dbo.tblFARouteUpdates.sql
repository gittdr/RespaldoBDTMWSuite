CREATE TABLE [dbo].[tblFARouteUpdates]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[RouteUpdateID] [int] NOT NULL,
[ActualRouteID] [int] NOT NULL,
[Action] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusDescr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL,
[UpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFARouteUpdates] ADD CONSTRAINT [PK_tblFARouteUpdates] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblFARouteUpdates] ON [dbo].[tblFARouteUpdates] ([ActualRouteID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblFARouteUpdates_1] ON [dbo].[tblFARouteUpdates] ([RouteUpdateID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFARouteUpdates] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFARouteUpdates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFARouteUpdates] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFARouteUpdates] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFARouteUpdates] TO [public]
GO
