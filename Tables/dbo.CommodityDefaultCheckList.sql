CREATE TABLE [dbo].[CommodityDefaultCheckList]
(
[cdcl_id] [int] NOT NULL IDENTITY(1, 1),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdcl_origin_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdcl_dest_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdcl_checklisttype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommodityDefaultCheckList] ADD CONSTRAINT [pk_CommodityDefaultCheckList] PRIMARY KEY CLUSTERED ([cdcl_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_CommodityDefaultCheckList_cmd_code_origin_dest] ON [dbo].[CommodityDefaultCheckList] ([cmd_code], [cdcl_origin_country], [cdcl_dest_country]) INCLUDE ([cdcl_checklisttype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CommodityDefaultCheckList] TO [public]
GO
GRANT INSERT ON  [dbo].[CommodityDefaultCheckList] TO [public]
GO
GRANT SELECT ON  [dbo].[CommodityDefaultCheckList] TO [public]
GO
GRANT UPDATE ON  [dbo].[CommodityDefaultCheckList] TO [public]
GO
