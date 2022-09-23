CREATE TABLE [dbo].[MR_GeneralInfoAdmin]
(
[gia_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gia_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_GeneralInfoAdmin] ADD CONSTRAINT [PK_MR_GeneralInfoAdmin] PRIMARY KEY CLUSTERED ([gia_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_GeneralInfoAdmin] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_GeneralInfoAdmin] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_GeneralInfoAdmin] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_GeneralInfoAdmin] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_GeneralInfoAdmin] TO [public]
GO
