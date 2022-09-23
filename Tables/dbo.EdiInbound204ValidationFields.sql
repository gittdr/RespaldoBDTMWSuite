CREATE TABLE [dbo].[EdiInbound204ValidationFields]
(
[evf_ident] [int] NOT NULL IDENTITY(1, 1),
[evf_key] [varchar] (203) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_section] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_fieldname] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_numeric] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_parentsections] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evf_dxarchivesequence] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_isdate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdiInbound204ValidationFields] ADD CONSTRAINT [PK_EdiInbound204ValidationFields] PRIMARY KEY CLUSTERED ([evf_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EdiInbound204ValidationFields] TO [public]
GO
GRANT INSERT ON  [dbo].[EdiInbound204ValidationFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EdiInbound204ValidationFields] TO [public]
GO
GRANT SELECT ON  [dbo].[EdiInbound204ValidationFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[EdiInbound204ValidationFields] TO [public]
GO
