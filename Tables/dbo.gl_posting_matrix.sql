CREATE TABLE [dbo].[gl_posting_matrix]
(
[glpm_booked_terminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_glpm_booked_terminal] DEFAULT ('UNK'),
[glpm_executing_terminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_glpm_executing_terminal] DEFAULT ('UNK'),
[glpm_revenue_gl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glpm_cost_gl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gl_posting_matrix] TO [public]
GO
GRANT INSERT ON  [dbo].[gl_posting_matrix] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gl_posting_matrix] TO [public]
GO
GRANT SELECT ON  [dbo].[gl_posting_matrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[gl_posting_matrix] TO [public]
GO
