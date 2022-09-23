CREATE TABLE [dbo].[scmaster]
(
[scm_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scm_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scm_manager] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scm_numcode] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [scm_codeix] ON [dbo].[scmaster] ([scm_code]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [scm_numix] ON [dbo].[scmaster] ([scm_numcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[scmaster] TO [public]
GO
GRANT INSERT ON  [dbo].[scmaster] TO [public]
GO
GRANT REFERENCES ON  [dbo].[scmaster] TO [public]
GO
GRANT SELECT ON  [dbo].[scmaster] TO [public]
GO
GRANT UPDATE ON  [dbo].[scmaster] TO [public]
GO
