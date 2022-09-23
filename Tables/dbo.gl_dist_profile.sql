CREATE TABLE [dbo].[gl_dist_profile]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[pro_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pro_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_pos] [int] NULL,
[new_value] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gl_dist_profile] ADD CONSTRAINT [PK__gl_dist___3213E83F81BD6837] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gl_dist_profile] TO [public]
GO
GRANT INSERT ON  [dbo].[gl_dist_profile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gl_dist_profile] TO [public]
GO
GRANT SELECT ON  [dbo].[gl_dist_profile] TO [public]
GO
GRANT UPDATE ON  [dbo].[gl_dist_profile] TO [public]
GO
