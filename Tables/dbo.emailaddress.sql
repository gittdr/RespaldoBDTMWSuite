CREATE TABLE [dbo].[emailaddress]
(
[em_id] [int] NOT NULL,
[em_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[em_valid_time_begin] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[em_valid_time_end] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[em_occurrence_level] [smallint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_emailaddress] ON [dbo].[emailaddress] ([em_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[emailaddress] TO [public]
GO
GRANT INSERT ON  [dbo].[emailaddress] TO [public]
GO
GRANT REFERENCES ON  [dbo].[emailaddress] TO [public]
GO
GRANT SELECT ON  [dbo].[emailaddress] TO [public]
GO
GRANT UPDATE ON  [dbo].[emailaddress] TO [public]
GO
