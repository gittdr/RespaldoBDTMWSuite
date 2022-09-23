CREATE TABLE [dbo].[req_code]
(
[req_number] [int] NOT NULL,
[req_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[req_syscode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[req_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[req_billable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[req_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[req_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[req_min] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[req_max] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[req_code] TO [public]
GO
GRANT INSERT ON  [dbo].[req_code] TO [public]
GO
GRANT REFERENCES ON  [dbo].[req_code] TO [public]
GO
GRANT SELECT ON  [dbo].[req_code] TO [public]
GO
GRANT UPDATE ON  [dbo].[req_code] TO [public]
GO
