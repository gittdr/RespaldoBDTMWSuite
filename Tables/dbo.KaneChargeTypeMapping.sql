CREATE TABLE [dbo].[KaneChargeTypeMapping]
(
[kaneitemcode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneChargeTypeMapping] ADD CONSTRAINT [PK__KaneChargeTypeMa__1011E1A0] PRIMARY KEY CLUSTERED ([kaneitemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[KaneChargeTypeMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneChargeTypeMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneChargeTypeMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneChargeTypeMapping] TO [public]
GO
