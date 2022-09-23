CREATE TABLE [dbo].[TableVarDriverList]
(
[driverId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TableVarDriverList] ADD CONSTRAINT [PK__TableVar__F1532DF20D83712E] PRIMARY KEY CLUSTERED ([driverId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TableVarDriverList] TO [public]
GO
GRANT INSERT ON  [dbo].[TableVarDriverList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TableVarDriverList] TO [public]
GO
GRANT SELECT ON  [dbo].[TableVarDriverList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TableVarDriverList] TO [public]
GO
