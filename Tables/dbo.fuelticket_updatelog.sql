CREATE TABLE [dbo].[fuelticket_updatelog]
(
[ftk_ticket_number] [int] NOT NULL,
[ftk_updated_on] [datetime] NOT NULL,
[ftk_updated_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftk_old_ord_hdrnumber] [int] NOT NULL,
[ftk_old_mov_number] [int] NULL,
[ftk_old_lgh_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelticket_updatelog] ADD CONSTRAINT [PK__fuelticket_updat__547F7DDB] PRIMARY KEY CLUSTERED ([ftk_ticket_number], [ftk_updated_on]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelticket_updatelog] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelticket_updatelog] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelticket_updatelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelticket_updatelog] TO [public]
GO
