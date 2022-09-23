CREATE TABLE [dbo].[tblSettings]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IDType] [int] NOT NULL,
[SetName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Machine] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Instance] [int] NULL,
[Settings] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSettings] ADD CONSTRAINT [PK_tblSettings] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSettings] TO [public]
GO
