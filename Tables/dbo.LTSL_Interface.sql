CREATE TABLE [dbo].[LTSL_Interface]
(
[batch] [int] NOT NULL,
[progress_percent] [int] NOT NULL,
[halt] [int] NOT NULL,
[progress_message] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTSL_Interface] TO [public]
GO
GRANT INSERT ON  [dbo].[LTSL_Interface] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTSL_Interface] TO [public]
GO
GRANT SELECT ON  [dbo].[LTSL_Interface] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTSL_Interface] TO [public]
GO
