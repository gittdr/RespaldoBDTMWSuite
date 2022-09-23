CREATE TABLE [dbo].[tankdiphistory_deletelog]
(
[tdl_identity] [int] NOT NULL IDENTITY(1, 1),
[tank_nbr] [int] NULL,
[tank_dip_date] [datetime] NULL,
[tank_dip_shift] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_dip] [smallint] NULL,
[tank_inventoryqty] [int] NULL,
[tank_ullageqty] [int] NULL,
[tank_deliveredqty] [int] NULL,
[ord_hdrnumber] [int] NULL,
[tank_sales] [int] NULL,
[tdl_appname] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tdl_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tdl_datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tankdiphistory_deletelog] ADD CONSTRAINT [pk_tankdiphistory_deletelog] PRIMARY KEY CLUSTERED ([tdl_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tankdiphistory_deletelog] TO [public]
GO
GRANT INSERT ON  [dbo].[tankdiphistory_deletelog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tankdiphistory_deletelog] TO [public]
GO
GRANT SELECT ON  [dbo].[tankdiphistory_deletelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tankdiphistory_deletelog] TO [public]
GO
