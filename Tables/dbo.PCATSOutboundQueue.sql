CREATE TABLE [dbo].[PCATSOutboundQueue]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL CONSTRAINT [DF_PCATSOutboundQueue_stp_number] DEFAULT ((0)),
[poq_deliverto] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poq_msgtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poq_shiftdate] [datetime] NOT NULL,
[poq_dateinserted] [datetime] NOT NULL,
[poq_waitseconds] [int] NOT NULL,
[poq_filterdata] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCATSOutboundQueue] ADD CONSTRAINT [PK_PCATSOutboundQueue] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCATSOutboundQueue_msg_leg] ON [dbo].[PCATSOutboundQueue] ([poq_msgtype], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCATSOutboundQueue_msg_mov] ON [dbo].[PCATSOutboundQueue] ([poq_msgtype], [mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCATSOutboundQueue_msg_ord] ON [dbo].[PCATSOutboundQueue] ([poq_msgtype], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PCATSOutboundQueue_msgtype_filterdata] ON [dbo].[PCATSOutboundQueue] ([poq_msgtype], [poq_filterdata], [SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCATSOutboundQueue_msg_stp] ON [dbo].[PCATSOutboundQueue] ([poq_msgtype], [stp_number]) ON [PRIMARY]
GO
