CREATE TABLE [dbo].[moneycodecancellog]
(
[mcl_identity] [int] NOT NULL IDENTITY(1, 1),
[pyd_number] [int] NOT NULL,
[tmc_sequencenumber] [int] NOT NULL,
[mcl_reason] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcl_description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcl_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcl_datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[moneycodecancellog] ADD CONSTRAINT [pk_moneycodecancellog] PRIMARY KEY CLUSTERED ([mcl_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[moneycodecancellog] TO [public]
GO
GRANT INSERT ON  [dbo].[moneycodecancellog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[moneycodecancellog] TO [public]
GO
GRANT SELECT ON  [dbo].[moneycodecancellog] TO [public]
GO
GRANT UPDATE ON  [dbo].[moneycodecancellog] TO [public]
GO
