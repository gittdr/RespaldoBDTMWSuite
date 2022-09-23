CREATE TABLE [dbo].[carrierremovedreason]
(
[crr_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[crr_prevcarrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crr_newcarrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crr_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crr_note] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crr_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crr_lastupdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierremovedreason] ADD CONSTRAINT [PK_carrierremovedreason] PRIMARY KEY CLUSTERED ([crr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierremovedreason] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierremovedreason] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierremovedreason] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierremovedreason] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierremovedreason] TO [public]
GO
