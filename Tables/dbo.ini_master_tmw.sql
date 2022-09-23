CREATE TABLE [dbo].[ini_master_tmw]
(
[ini_filename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ini_section] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ini_item] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ini_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ini_description] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ini_customer_description] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unpublished_setting] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptsnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_master_tmw] ADD CONSTRAINT [pk_ini_master_tmw] PRIMARY KEY CLUSTERED ([ini_filename], [ini_section], [ini_item]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[ini_master_tmw] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_master_tmw] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_master_tmw] TO [public]
GO
