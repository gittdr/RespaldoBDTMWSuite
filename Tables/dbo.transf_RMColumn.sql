CREATE TABLE [dbo].[transf_RMColumn]
(
[transf_user_id] [int] NOT NULL,
[rmc_rm_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rmc_col_name] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rmc_seq] [int] NOT NULL,
[rmc_header_text] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_dt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_RMColumn] ADD CONSTRAINT [PK_transf_RMColumn] PRIMARY KEY CLUSTERED ([transf_user_id], [rmc_rm_name], [rmc_col_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_RMColumn] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_RMColumn] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_RMColumn] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_RMColumn] TO [public]
GO
