CREATE TABLE [dbo].[dx_Wizard]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_wiz_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_prompt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_prompt_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_answer_abbr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_answer_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_prompt_back] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_prompt_next] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_prompt_loop] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_prompt_list] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_set_variable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_set_value] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Wizard] ADD CONSTRAINT [pk_dx_ident] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Wizard] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Wizard] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Wizard] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Wizard] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Wizard] TO [public]
GO
