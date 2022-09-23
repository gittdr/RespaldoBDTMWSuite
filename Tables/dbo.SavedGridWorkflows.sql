CREATE TABLE [dbo].[SavedGridWorkflows]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[LayoutObject] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkFlowID] [int] NOT NULL,
[WorkFlowUserFriendlyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDate] [datetime] NOT NULL,
[lastUpdatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedGridWorkflows] ADD CONSTRAINT [PK_SavedGridWorkflows] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedGridWorkflows] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedGridWorkflows] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedGridWorkflows] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedGridWorkflows] TO [public]
GO
