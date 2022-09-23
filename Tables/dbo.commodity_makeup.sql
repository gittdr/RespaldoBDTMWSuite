CREATE TABLE [dbo].[commodity_makeup]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmk_sequence] [int] NOT NULL IDENTITY(1, 1),
[cmk_description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmk_percentage] [money] NULL,
[cmk_child_ccl_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmk_child_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmk_pickup_sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_makeup] ADD CONSTRAINT [pk_commodity_makeup] PRIMARY KEY CLUSTERED ([cmk_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_commodity_makeup_cmd_code] ON [dbo].[commodity_makeup] ([cmd_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_makeup] ADD CONSTRAINT [fk_commodity_makeup] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
GRANT DELETE ON  [dbo].[commodity_makeup] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_makeup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity_makeup] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_makeup] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_makeup] TO [public]
GO
