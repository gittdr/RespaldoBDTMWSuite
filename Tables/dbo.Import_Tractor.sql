CREATE TABLE [dbo].[Import_Tractor]
(
[trc_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_avl_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_avl_cmp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_avl_date] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_require_drvtrl] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_make] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_model] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_year] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_owner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_company] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_fleet] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_division] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_terminal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_serial] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_licstate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_licnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_tareweight] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isloaded] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Import_Tr__isloa__656AA819] DEFAULT ('N'),
[err_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Tractor] ADD CONSTRAINT [PK__Import_T__6B54B9AB962F9475] PRIMARY KEY CLUSTERED ([trc_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Import_Tractor] TO [public]
GO
GRANT INSERT ON  [dbo].[Import_Tractor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Import_Tractor] TO [public]
GO
GRANT SELECT ON  [dbo].[Import_Tractor] TO [public]
GO
GRANT UPDATE ON  [dbo].[Import_Tractor] TO [public]
GO
