CREATE TABLE [dbo].[tblQCModem]
(
[CommPort] [smallint] NULL,
[DTREnable] [smallint] NULL,
[Handshaking] [smallint] NULL,
[InBufferSize] [smallint] NULL,
[InputLen] [smallint] NULL,
[NullDiscard] [smallint] NULL,
[OutBufferSize] [smallint] NULL,
[ParityReplace] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RThreshold] [smallint] NULL,
[RTSEnable] [smallint] NULL,
[SThreshold] [smallint] NULL,
[Baud] [int] NULL,
[Parity] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataBits] [smallint] NULL,
[StopBits] [real] NULL,
[ModemInit] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InitPause] [real] NULL,
[DialType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QualCommPhone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNum] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConversationDisplay] [smallint] NULL,
[ConversationDetailed] [smallint] NULL,
[PacketDisplay] [smallint] NULL,
[PacketDetailed] [smallint] NULL,
[CommunicationDetailed] [smallint] NULL,
[PollingRate] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AccountNum] ON [dbo].[tblQCModem] ([AccountNum]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[CommPort]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[DTREnable]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[Handshaking]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[InBufferSize]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[InputLen]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[NullDiscard]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[OutBufferSize]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_ParityReplace_D]', N'[dbo].[tblQCModem].[ParityReplace]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[RThreshold]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[RTSEnable]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[SThreshold]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[Baud]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_Parity_D]', N'[dbo].[tblQCModem].[Parity]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[DataBits]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[StopBits]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[InitPause]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_DialType_D]', N'[dbo].[tblQCModem].[DialType]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_QualCommPhone_D]', N'[dbo].[tblQCModem].[QualCommPhone]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_AccountNum_D]', N'[dbo].[tblQCModem].[AccountNum]'
GO
EXEC sp_bindefault N'[dbo].[tblQCModem_Password_D]', N'[dbo].[tblQCModem].[Password]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[ConversationDisplay]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[ConversationDetailed]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[PacketDisplay]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[PacketDetailed]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[CommunicationDetailed]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblQCModem].[PollingRate]'
GO
GRANT DELETE ON  [dbo].[tblQCModem] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQCModem] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQCModem] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQCModem] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQCModem] TO [public]
GO
