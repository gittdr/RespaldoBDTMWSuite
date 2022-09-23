CREATE TABLE [dbo].[commodity_equivalentdetails]
(
[EqId] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartMonth] [int] NOT NULL,
[StartDay] [int] NOT NULL,
[EndMonth] [int] NOT NULL,
[EndDay] [int] NOT NULL,
[Priority] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_equivalentdetails] ADD CONSTRAINT [PK_CommodityEquivalentDetails] PRIMARY KEY CLUSTERED ([EqId], [cmd_code], [StartMonth], [StartDay]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_equivalentdetails] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_equivalentdetails] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_equivalentdetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_equivalentdetails] TO [public]
GO
