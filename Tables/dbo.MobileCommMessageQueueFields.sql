CREATE TABLE [dbo].[MobileCommMessageQueueFields]
(
[msd_ID] [int] NOT NULL IDENTITY(1, 1),
[msg_ID] [int] NOT NULL,
[msd_Seq] [int] NOT NULL,
[msd_FieldName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msd_FieldValue] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageQueueFields] ADD CONSTRAINT [PK_MobileCommMessageQueueFields] PRIMARY KEY CLUSTERED ([msd_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommMessageQueueFields] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageQueueFields] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageQueueFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageQueueFields] TO [public]
GO
