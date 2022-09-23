CREATE TABLE [dbo].[payrateadjustment]
(
[timestamp] [timestamp] NULL,
[prh_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prj_sequence] [smallint] NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prj_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prj_rate] [money] NULL,
[trl_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_number_sequence] ON [dbo].[payrateadjustment] ([prh_number], [prj_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payrateadjustment] TO [public]
GO
GRANT INSERT ON  [dbo].[payrateadjustment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payrateadjustment] TO [public]
GO
GRANT SELECT ON  [dbo].[payrateadjustment] TO [public]
GO
GRANT UPDATE ON  [dbo].[payrateadjustment] TO [public]
GO
