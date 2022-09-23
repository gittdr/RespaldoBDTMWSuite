CREATE TABLE [dbo].[payrateaccessorial]
(
[timestamp] [timestamp] NULL,
[prh_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pra_sequence] [smallint] NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pra_rate] [money] NULL,
[pra_milesplit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pra_requirestop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_number_sequence] ON [dbo].[payrateaccessorial] ([prh_number], [pra_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payrateaccessorial] TO [public]
GO
GRANT INSERT ON  [dbo].[payrateaccessorial] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payrateaccessorial] TO [public]
GO
GRANT SELECT ON  [dbo].[payrateaccessorial] TO [public]
GO
GRANT UPDATE ON  [dbo].[payrateaccessorial] TO [public]
GO
