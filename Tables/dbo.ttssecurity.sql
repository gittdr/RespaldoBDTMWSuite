CREATE TABLE [dbo].[ttssecurity]
(
[sec_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sec_idtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sec_id] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttssecurity] TO [public]
GO
GRANT INSERT ON  [dbo].[ttssecurity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttssecurity] TO [public]
GO
GRANT SELECT ON  [dbo].[ttssecurity] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttssecurity] TO [public]
GO
