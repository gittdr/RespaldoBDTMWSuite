CREATE TABLE [dbo].[trlwsh_selection_audit]
(
[tsa_id] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NOT NULL,
[tsa_sel_datetime] [datetime] NOT NULL,
[tsa_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_prior_location] [int] NOT NULL,
[tsa_next_location] [int] NOT NULL,
[tsa_sel_trlwsh] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_sel_rank] [int] NOT NULL,
[tsa_sel_miles_to_trlwash] [int] NOT NULL,
[tsa_sel_miles_from_trlwash] [int] NOT NULL,
[tsa_sel_mileage_cost] [money] NOT NULL,
[tsa_sel_trlwsh_cost] [money] NOT NULL,
[tsa_sel_trlwsh_cost_basis] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_sel_trlwsh_qual_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_rec_trlwsh] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_rec_miles_to_trlwash] [int] NOT NULL,
[tsa_rec_miles_from_trlwash] [int] NOT NULL,
[tsa_rec_mileage_cost] [money] NOT NULL,
[tsa_rec_trlwsh_cost] [money] NOT NULL,
[tsa_rec_trlwsh_cost_basis] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsa_rec_trlwsh_qual_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trlwsh_selection_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[trlwsh_selection_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trlwsh_selection_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[trlwsh_selection_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[trlwsh_selection_audit] TO [public]
GO
