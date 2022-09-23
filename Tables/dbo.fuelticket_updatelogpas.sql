CREATE TABLE [dbo].[fuelticket_updatelogpas]
(
[ftk_ticket_number] [int] NOT NULL,
[ftk_updated_on] [datetime] NOT NULL,
[ftk_updated_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftk_old_ord_hdrnumber] [int] NOT NULL,
[ftk_old_mov_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelticket_updatelogpas] ADD CONSTRAINT [PK__fuelticket_updat__74610A6E] PRIMARY KEY CLUSTERED ([ftk_ticket_number], [ftk_updated_on]) ON [PRIMARY]
GO
