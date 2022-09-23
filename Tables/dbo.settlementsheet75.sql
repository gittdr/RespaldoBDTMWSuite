CREATE TABLE [dbo].[settlementsheet75]
(
[section_header] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settlementsheet75] ADD CONSTRAINT [pk_sts_type] PRIMARY KEY CLUSTERED ([section_header], [paytype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[settlementsheet75] TO [public]
GO
GRANT INSERT ON  [dbo].[settlementsheet75] TO [public]
GO
GRANT REFERENCES ON  [dbo].[settlementsheet75] TO [public]
GO
GRANT SELECT ON  [dbo].[settlementsheet75] TO [public]
GO
GRANT UPDATE ON  [dbo].[settlementsheet75] TO [public]
GO
