CREATE TABLE [dbo].[MR_GeneralInfo]
(
[gi_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gi_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_GeneralInfo] ADD CONSTRAINT [PK_MR_GeneralInfo] PRIMARY KEY CLUSTERED ([gi_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_GeneralInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_GeneralInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_GeneralInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_GeneralInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_GeneralInfo] TO [public]
GO
