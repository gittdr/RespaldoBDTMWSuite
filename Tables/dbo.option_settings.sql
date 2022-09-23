CREATE TABLE [dbo].[option_settings]
(
[option_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_expiration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_check] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_menulist] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_option_settings] ON [dbo].[option_settings] ([option_name], [option_value], [option_expiration], [option_check]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[option_settings] TO [public]
GO
GRANT INSERT ON  [dbo].[option_settings] TO [public]
GO
GRANT SELECT ON  [dbo].[option_settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[option_settings] TO [public]
GO
