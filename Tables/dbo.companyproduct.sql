CREATE TABLE [dbo].[companyproduct]
(
[cpr_identity] [int] NOT NULL IDENTITY(1, 1),
[cmp_ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpr_pup_or_drp] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scm_subcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpr_StartMonth] [tinyint] NOT NULL,
[cpr_Startday] [tinyint] NOT NULL,
[cpr_EndMonth] [tinyint] NOT NULL,
[cpr_EndDay] [tinyint] NOT NULL,
[cpr_UpdateBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpr_UpdateDate] [datetime] NOT NULL,
[cpr_density] [decimal] (9, 4) NULL,
[fgt_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companyproduct] ADD CONSTRAINT [pk_cppidentity] PRIMARY KEY CLUSTERED ([cpr_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_cpcmdscm] ON [dbo].[companyproduct] ([cmd_code], [scm_subcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_cpcmpcmdscm] ON [dbo].[companyproduct] ([cmp_ID], [cmd_code], [cpr_pup_or_drp], [scm_subcode], [cpr_StartMonth]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companyproduct] TO [public]
GO
GRANT INSERT ON  [dbo].[companyproduct] TO [public]
GO
GRANT REFERENCES ON  [dbo].[companyproduct] TO [public]
GO
GRANT SELECT ON  [dbo].[companyproduct] TO [public]
GO
GRANT UPDATE ON  [dbo].[companyproduct] TO [public]
GO
