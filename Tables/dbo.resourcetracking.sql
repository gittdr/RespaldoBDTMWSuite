CREATE TABLE [dbo].[resourcetracking]
(
[res_number] [int] NOT NULL IDENTITY(1, 1),
[res_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_classificationtype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_classification] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_effdatetime] [datetime] NOT NULL,
[res_editid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[res_editdatetime] [datetime] NULL,
[res_createid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[res_createdatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[resourcetracking] ADD CONSTRAINT [uk_resourcetracking_res_number] PRIMARY KEY CLUSTERED ([res_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_resourcetracking_res_classification] ON [dbo].[resourcetracking] ([res_classification]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_resourcetracking_res_id] ON [dbo].[resourcetracking] ([res_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_resourcetracking_res_type] ON [dbo].[resourcetracking] ([res_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[resourcetracking] TO [public]
GO
GRANT INSERT ON  [dbo].[resourcetracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[resourcetracking] TO [public]
GO
GRANT SELECT ON  [dbo].[resourcetracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[resourcetracking] TO [public]
GO
