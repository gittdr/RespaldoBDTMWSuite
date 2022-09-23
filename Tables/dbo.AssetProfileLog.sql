CREATE TABLE [dbo].[AssetProfileLog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[res_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_original_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_original_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[effective] [datetime] NOT NULL,
[lastmodifiedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdatedon] [datetime] NOT NULL,
[appliedbysqljob] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[appliedon] [datetime] NULL,
[createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssetProfileLog] ADD CONSTRAINT [PK_AssetProfileLog] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AssetProfileLog] TO [public]
GO
GRANT INSERT ON  [dbo].[AssetProfileLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AssetProfileLog] TO [public]
GO
GRANT SELECT ON  [dbo].[AssetProfileLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[AssetProfileLog] TO [public]
GO
