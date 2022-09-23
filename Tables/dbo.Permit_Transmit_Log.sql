CREATE TABLE [dbo].[Permit_Transmit_Log]
(
[PTL_ID] [int] NOT NULL IDENTITY(1, 1),
[P_ID] [int] NOT NULL,
[PTL_Transmit_Date] [datetime] NOT NULL,
[PTL_Transmit_By] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PTL_Comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Transmit_Log] ADD CONSTRAINT [PK_Permit_Transmit_Log] PRIMARY KEY CLUSTERED ([PTL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Transmit_Log] ADD CONSTRAINT [FK_Permit_Transmit_Log_Permits] FOREIGN KEY ([P_ID]) REFERENCES [dbo].[Permits] ([P_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Transmit_Log] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Transmit_Log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Transmit_Log] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Transmit_Log] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Transmit_Log] TO [public]
GO
