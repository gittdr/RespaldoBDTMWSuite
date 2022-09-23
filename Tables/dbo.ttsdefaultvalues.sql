CREATE TABLE [dbo].[ttsdefaultvalues]
(
[dft_objectname] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dft_columnname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dft_expression] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ttsdefaultvalues] ADD CONSTRAINT [PK_ttsdefaultvalues] PRIMARY KEY CLUSTERED ([dft_objectname], [dft_columnname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsdefaultvalues] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsdefaultvalues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsdefaultvalues] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsdefaultvalues] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsdefaultvalues] TO [public]
GO
