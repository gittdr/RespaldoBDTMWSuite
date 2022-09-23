CREATE TABLE [dbo].[fuelticket_printlog]
(
[ftk_ticket_number] [int] NOT NULL,
[ftk_printed_on] [datetime] NOT NULL,
[ftk_printed_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelticket_printlog] ADD CONSTRAINT [PK__fuelticket_print__52973569] PRIMARY KEY CLUSTERED ([ftk_ticket_number], [ftk_printed_on]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelticket_printlog] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelticket_printlog] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelticket_printlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelticket_printlog] TO [public]
GO
