CREATE TABLE [dbo].[ETASupportedBranchSettings]
(
[esbs_id] [int] NOT NULL IDENTITY(1, 1),
[esbs_name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esbs_defaultvalue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esbs_requirenumericvalue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ETASupportedBranchSettings] ADD CONSTRAINT [pk_esbs_id] PRIMARY KEY CLUSTERED ([esbs_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_esbs_name] ON [dbo].[ETASupportedBranchSettings] ([esbs_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ETASupportedBranchSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[ETASupportedBranchSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ETASupportedBranchSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[ETASupportedBranchSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[ETASupportedBranchSettings] TO [public]
GO
