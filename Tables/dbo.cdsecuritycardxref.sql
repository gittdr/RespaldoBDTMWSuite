CREATE TABLE [dbo].[cdsecuritycardxref]
(
[scx_id] [int] NOT NULL IDENTITY(1, 1),
[scx_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scx_vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdsecuritycardxref] ADD CONSTRAINT [pk_cdsecuritycardxref_scx_id] PRIMARY KEY CLUSTERED ([scx_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdsecuritycardxref] TO [public]
GO
GRANT INSERT ON  [dbo].[cdsecuritycardxref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdsecuritycardxref] TO [public]
GO
GRANT SELECT ON  [dbo].[cdsecuritycardxref] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdsecuritycardxref] TO [public]
GO
