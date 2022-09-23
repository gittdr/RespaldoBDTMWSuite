CREATE TABLE [dbo].[daconfig]
(
[dac_id] [int] NOT NULL IDENTITY(1, 1),
[dac_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_parent_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_parent_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_valueint] [int] NULL,
[dac_valuedec] [decimal] (12, 4) NULL,
[dac_option1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_option2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_option3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dac_option4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[daconfig] ADD CONSTRAINT [pk_daconfig_dac_id] PRIMARY KEY CLUSTERED ([dac_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[daconfig] TO [public]
GO
GRANT INSERT ON  [dbo].[daconfig] TO [public]
GO
GRANT SELECT ON  [dbo].[daconfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[daconfig] TO [public]
GO
