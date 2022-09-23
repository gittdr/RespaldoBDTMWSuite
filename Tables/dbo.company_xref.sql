CREATE TABLE [dbo].[company_xref]
(
[cmp_xref_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_synonym] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cln_addr_city_state] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crt_date] [datetime] NULL,
[src_system] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_date] [datetime] NULL,
[upd_count] [int] NULL,
[upd_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[src_tradingpartner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_xref] ADD CONSTRAINT [PK__company_xref__4AC698D8] PRIMARY KEY CLUSTERED ([cmp_xref_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_xref] TO [public]
GO
GRANT INSERT ON  [dbo].[company_xref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_xref] TO [public]
GO
GRANT SELECT ON  [dbo].[company_xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_xref] TO [public]
GO
