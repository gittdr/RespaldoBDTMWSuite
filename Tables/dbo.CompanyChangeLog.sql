CREATE TABLE [dbo].[CompanyChangeLog]
(
[clg_number] [int] NOT NULL IDENTITY(1, 1),
[clg_ord_hdrnumber] [int] NOT NULL,
[clg_old_supplier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[clg_new_supplier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[clg_reason_label] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clg_reason_desc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clg_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clg_misc_tripinfo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clg_datetime] [datetime] NOT NULL CONSTRAINT [DF__CompanyCh__clg_d__3731741B] DEFAULT ('01/01/50'),
[clg_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyCh__clg_u__38259854] DEFAULT (''),
[clg_cmptype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyCh__clg_c__3919BC8D] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyChangeLog] ADD CONSTRAINT [pk_companychangelog_scl_number] PRIMARY KEY CLUSTERED ([clg_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyChangeLog] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyChangeLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyChangeLog] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyChangeLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyChangeLog] TO [public]
GO
