CREATE TABLE [dbo].[tariffkeyrevall_codes]
(
[tkc_id] [int] NOT NULL IDENTITY(1, 1),
[tkc_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tkr_id] [int] NOT NULL,
[tkc_created_date] [datetime] NOT NULL,
[tkc_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tkc_modified_date] [datetime] NOT NULL,
[tkc_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffkeyrevall_codes] ADD CONSTRAINT [PK__tariffkeyrevall___527A356A] PRIMARY KEY CLUSTERED ([tkc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffkeyrevall_codes] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffkeyrevall_codes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffkeyrevall_codes] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffkeyrevall_codes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffkeyrevall_codes] TO [public]
GO
