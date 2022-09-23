CREATE TABLE [dbo].[gp_trlrental]
(
[trlr_id] [int] NOT NULL IDENTITY(1, 1),
[trlr_loan_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlr_borrow_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlr_loan_term] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlr_borrow_term] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlr_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlr_axel_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_rent_var] [money] NULL,
[trl_rent_fix] [money] NULL,
[trlr_CompTerm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trlr_CompTerm] DEFAULT ('C')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gp_trlrental] TO [public]
GO
GRANT INSERT ON  [dbo].[gp_trlrental] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gp_trlrental] TO [public]
GO
GRANT SELECT ON  [dbo].[gp_trlrental] TO [public]
GO
GRANT UPDATE ON  [dbo].[gp_trlrental] TO [public]
GO
