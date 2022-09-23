CREATE TABLE [dbo].[WatchDogColumn]
(
[WatchName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AliasColumnName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogColumn] ADD CONSTRAINT [PK_WatchDogColumns] PRIMARY KEY CLUSTERED ([WatchName], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogColumn] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogColumn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WatchDogColumn] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogColumn] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogColumn] TO [public]
GO
