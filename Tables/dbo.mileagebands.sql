CREATE TABLE [dbo].[mileagebands]
(
[mb_id] [int] NOT NULL IDENTITY(1, 1),
[labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mb_min_miles] [int] NULL,
[mb_max_miles] [int] NULL,
[mb_time] [decimal] (6, 2) NULL,
[mb_additional_time] [decimal] (6, 2) NULL,
[mb_multiple_of_time] [decimal] (11, 4) NULL,
[mb_mph] [decimal] (11, 2) NULL,
[mb_created_date] [datetime] NOT NULL,
[mb_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mb_modified_date] [datetime] NOT NULL,
[mb_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mileagebands] ADD CONSTRAINT [PK_mileagebands] PRIMARY KEY NONCLUSTERED ([mb_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mileagebands] TO [public]
GO
GRANT INSERT ON  [dbo].[mileagebands] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mileagebands] TO [public]
GO
GRANT SELECT ON  [dbo].[mileagebands] TO [public]
GO
GRANT UPDATE ON  [dbo].[mileagebands] TO [public]
GO
