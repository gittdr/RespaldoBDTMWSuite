CREATE TABLE [dbo].[WatchDogParameter]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Heading] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubHeading] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParameterName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParameterValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParameterDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParameterSort] [int] NULL,
[DisplayOnEmail] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogParameter] ADD CONSTRAINT [PK_WatchDogParameter] PRIMARY KEY CLUSTERED ([SubHeading], [Heading], [ParameterName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogParameter] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogParameter] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogParameter] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogParameter] TO [public]
GO
