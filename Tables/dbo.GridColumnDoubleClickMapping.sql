CREATE TABLE [dbo].[GridColumnDoubleClickMapping]
(
[ColumnMappingId] [int] NOT NULL IDENTITY(1, 1),
[GridLayoutID] [int] NOT NULL,
[ColumnName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActionType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TabDefault] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[CreatedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GridColumnDoubleClickMapping] ADD CONSTRAINT [PK_GridColumnDoubleClickMapping] PRIMARY KEY CLUSTERED ([ColumnMappingId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridAndColumnAndLayoutIdIndex] ON [dbo].[GridColumnDoubleClickMapping] ([GridLayoutID], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GridColumnDoubleClickMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[GridColumnDoubleClickMapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GridColumnDoubleClickMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[GridColumnDoubleClickMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[GridColumnDoubleClickMapping] TO [public]
GO
