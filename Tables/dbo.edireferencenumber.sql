CREATE TABLE [dbo].[edireferencenumber]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ref_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_ref_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edireferencenumber] TO [public]
GO
GRANT INSERT ON  [dbo].[edireferencenumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edireferencenumber] TO [public]
GO
GRANT SELECT ON  [dbo].[edireferencenumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[edireferencenumber] TO [public]
GO
