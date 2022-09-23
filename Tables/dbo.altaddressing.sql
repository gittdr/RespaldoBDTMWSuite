CREATE TABLE [dbo].[altaddressing]
(
[alta_number] [int] NOT NULL IDENTITY(1, 1),
[alta_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alta_type] [int] NOT NULL,
[alta_value] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alta_scheme] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[altaddressing] ADD CONSTRAINT [PK__altaddressing__7DDD8D6E] PRIMARY KEY CLUSTERED ([alta_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[altaddressing] TO [public]
GO
GRANT INSERT ON  [dbo].[altaddressing] TO [public]
GO
GRANT REFERENCES ON  [dbo].[altaddressing] TO [public]
GO
GRANT SELECT ON  [dbo].[altaddressing] TO [public]
GO
GRANT UPDATE ON  [dbo].[altaddressing] TO [public]
GO
