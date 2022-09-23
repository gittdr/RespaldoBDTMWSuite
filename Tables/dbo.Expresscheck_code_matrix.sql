CREATE TABLE [dbo].[Expresscheck_code_matrix]
(
[ecm_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_ecm_code] DEFAULT ('UNK'),
[ecm_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_ecm_paytype] DEFAULT ('EXPCHK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Expresscheck_code_matrix] ADD CONSTRAINT [pk_Expresscheck_code_matrix] PRIMARY KEY CLUSTERED ([ecm_code], [ecm_paytype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Expresscheck_code_matrix] TO [public]
GO
GRANT INSERT ON  [dbo].[Expresscheck_code_matrix] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Expresscheck_code_matrix] TO [public]
GO
GRANT SELECT ON  [dbo].[Expresscheck_code_matrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[Expresscheck_code_matrix] TO [public]
GO
