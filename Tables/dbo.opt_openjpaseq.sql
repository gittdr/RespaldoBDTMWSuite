CREATE TABLE [dbo].[opt_openjpaseq]
(
[id] [tinyint] NOT NULL,
[sequence_value] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_openjpaseq] ADD CONSTRAINT [pk_opt_openjpaseq] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_openjpaseq] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_openjpaseq] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_openjpaseq] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_openjpaseq] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_openjpaseq] TO [public]
GO
