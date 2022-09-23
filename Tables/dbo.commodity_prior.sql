CREATE TABLE [dbo].[commodity_prior]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpr_sequence] [int] NOT NULL IDENTITY(1, 1),
[cpr_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpr_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpr_goodorbad] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_prior] ADD CONSTRAINT [pk_commodity_prior] PRIMARY KEY CLUSTERED ([cmd_code], [cpr_sequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_prior] ADD CONSTRAINT [fk_commodity_prior] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
GRANT DELETE ON  [dbo].[commodity_prior] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_prior] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity_prior] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_prior] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_prior] TO [public]
GO
