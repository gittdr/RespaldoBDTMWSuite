CREATE TABLE [dbo].[gp_trcrental]
(
[trcr_id] [int] NOT NULL IDENTITY(1, 1),
[trcr_loan_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trcr_borrow_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trcr_loan_term] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trcr_borrow_term] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trcr_min_age] [int] NULL,
[trcr_max_age] [int] NULL,
[trcr_rent_var] [money] NULL,
[trcr_rent_fix] [money] NULL,
[trcr_CompTerm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trcr_CompTerm] DEFAULT ('C')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gp_trcrental] TO [public]
GO
GRANT INSERT ON  [dbo].[gp_trcrental] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gp_trcrental] TO [public]
GO
GRANT SELECT ON  [dbo].[gp_trcrental] TO [public]
GO
GRANT UPDATE ON  [dbo].[gp_trcrental] TO [public]
GO
