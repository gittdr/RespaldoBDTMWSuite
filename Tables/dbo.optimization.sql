CREATE TABLE [dbo].[optimization]
(
[opt_id] [int] NOT NULL,
[opt_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opt_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opt_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opt_int_width] [int] NOT NULL,
[opt_int_length] [int] NOT NULL,
[opt_int_height] [int] NOT NULL,
[opt_max_weight] [float] NOT NULL,
[opt_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opt_grp_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[optimization] ADD CONSTRAINT [pk_opt_id] PRIMARY KEY NONCLUSTERED ([opt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_abbr] ON [dbo].[optimization] ([opt_abbr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[optimization] TO [public]
GO
GRANT INSERT ON  [dbo].[optimization] TO [public]
GO
GRANT REFERENCES ON  [dbo].[optimization] TO [public]
GO
GRANT SELECT ON  [dbo].[optimization] TO [public]
GO
GRANT UPDATE ON  [dbo].[optimization] TO [public]
GO
