CREATE TABLE [dbo].[edi_reason_codes]
(
[rsn_id] [int] NOT NULL IDENTITY(1, 1),
[rsn_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rsn_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rsn_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [inx_edireason] ON [dbo].[edi_reason_codes] ([rsn_id], [rsn_cmp_id], [rsn_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_reason_codes] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_reason_codes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_reason_codes] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_reason_codes] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_reason_codes] TO [public]
GO
