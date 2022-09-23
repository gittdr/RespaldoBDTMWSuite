CREATE TABLE [dbo].[TIActionMap]
(
[am_id] [int] NOT NULL IDENTITY(1, 1),
[am_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[am_action] [int] NULL,
[am_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TIActionMap_am_createdby] DEFAULT (suser_name()),
[am_createdon] [datetime] NULL CONSTRAINT [DF_TIActionMap_am_createdon] DEFAULT (getdate()),
[am_lasteupdatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[am_lastupdatedon] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TIActionMap] ADD CONSTRAINT [PK__TIAction__B95A8ED029AB2172] PRIMARY KEY CLUSTERED ([am_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TIActionMap] TO [public]
GO
GRANT INSERT ON  [dbo].[TIActionMap] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TIActionMap] TO [public]
GO
GRANT SELECT ON  [dbo].[TIActionMap] TO [public]
GO
GRANT UPDATE ON  [dbo].[TIActionMap] TO [public]
GO
