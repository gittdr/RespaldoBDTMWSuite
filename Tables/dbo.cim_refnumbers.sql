CREATE TABLE [dbo].[cim_refnumbers]
(
[rfr_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rfr_datein] [datetime] NOT NULL,
[rfr_ref_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfr_transaction] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfr_ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfr_required] [tinyint] NULL,
[rfr_sid] [tinyint] NULL,
[rfr_edi_level_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfr_edi_level_seq] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rfr_cmp_datein] ON [dbo].[cim_refnumbers] ([rfr_cmp_id], [rfr_datein]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cim_refnumbers] TO [public]
GO
GRANT INSERT ON  [dbo].[cim_refnumbers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cim_refnumbers] TO [public]
GO
GRANT SELECT ON  [dbo].[cim_refnumbers] TO [public]
GO
GRANT UPDATE ON  [dbo].[cim_refnumbers] TO [public]
GO
