CREATE TABLE [dbo].[ETABranchSettingValues]
(
[ebsv_id] [int] NOT NULL IDENTITY(1, 1),
[esbs_name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ebsv_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ebsv_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ETABranchSettingValues] ADD CONSTRAINT [pk_esbv_id] PRIMARY KEY CLUSTERED ([ebsv_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_eb_name_branch] ON [dbo].[ETABranchSettingValues] ([esbs_name], [ebsv_branch]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ETABranchSettingValues] ADD CONSTRAINT [fk_ebsv_esbs_name] FOREIGN KEY ([esbs_name]) REFERENCES [dbo].[ETASupportedBranchSettings] ([esbs_name])
GO
GRANT DELETE ON  [dbo].[ETABranchSettingValues] TO [public]
GO
GRANT INSERT ON  [dbo].[ETABranchSettingValues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ETABranchSettingValues] TO [public]
GO
GRANT SELECT ON  [dbo].[ETABranchSettingValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[ETABranchSettingValues] TO [public]
GO
