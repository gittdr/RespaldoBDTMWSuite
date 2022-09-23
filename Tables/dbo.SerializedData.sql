CREATE TABLE [dbo].[SerializedData]
(
[sd_id] [int] NOT NULL IDENTITY(1, 1),
[sd_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sd_user_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sd_date] [datetime] NULL,
[sd_serialized] [xml] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SerializedData] ADD CONSTRAINT [prkey_SerializedData] PRIMARY KEY CLUSTERED ([sd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SerializedData] TO [public]
GO
GRANT INSERT ON  [dbo].[SerializedData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SerializedData] TO [public]
GO
GRANT SELECT ON  [dbo].[SerializedData] TO [public]
GO
GRANT UPDATE ON  [dbo].[SerializedData] TO [public]
GO
