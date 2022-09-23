CREATE TABLE [dbo].[Import_Trailer]
(
[trl_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_avail_city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_avail_cmp_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_avail_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_ht] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_len] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_wdth] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_make] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_model] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_year] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_owner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_fleet] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_division] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_terminal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_company] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_grosswgt] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_serial] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_licstate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_licnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_tareweight] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isloaded] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Trailer] ADD CONSTRAINT [PK__Import_T__F66E3AD9BF8CBE1A] PRIMARY KEY CLUSTERED ([trl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Import_Trailer] TO [public]
GO
GRANT INSERT ON  [dbo].[Import_Trailer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Import_Trailer] TO [public]
GO
GRANT SELECT ON  [dbo].[Import_Trailer] TO [public]
GO
GRANT UPDATE ON  [dbo].[Import_Trailer] TO [public]
GO
