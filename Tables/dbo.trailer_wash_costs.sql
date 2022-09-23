CREATE TABLE [dbo].[trailer_wash_costs]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[twc_wash_count] [smallint] NULL,
[twc_total_wash_cost] [money] NULL,
[twc_create_date] [datetime] NULL CONSTRAINT [DF_trailer_wash_costs_twc_create_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_wash_costs] ADD CONSTRAINT [PK_trailer_wash_costs] PRIMARY KEY CLUSTERED ([cmp_id], [cmd_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_trailer_wash_costs_cmd_code] ON [dbo].[trailer_wash_costs] ([cmd_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_wash_costs] ADD CONSTRAINT [FK_trailer_wash_costs_commodity] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
ALTER TABLE [dbo].[trailer_wash_costs] ADD CONSTRAINT [FK_trailer_wash_costs_company] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
