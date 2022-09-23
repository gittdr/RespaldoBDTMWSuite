CREATE TABLE [dbo].[tblFormDef]
(
[FormID] [smallint] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Direction] [smallint] NULL,
[DateModified] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionID] [smallint] NULL,
[Activate] [bit] NOT NULL,
[LastActivatedDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowUpdate] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFormDef] ADD CONSTRAINT [PK_tblFormDef_FormID] PRIMARY KEY CLUSTERED ([FormID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFormDef] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFormDef] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFormDef] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFormDef] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFormDef] TO [public]
GO
