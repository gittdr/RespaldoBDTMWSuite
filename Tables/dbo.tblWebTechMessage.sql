CREATE TABLE [dbo].[tblWebTechMessage]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[wt_vehicle_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message_type] [int] NOT NULL,
[create_time] [datetime] NULL,
[receive_time] [datetime] NOT NULL,
[post_time] [datetime] NULL,
[post_result] [int] NULL,
[xml_data] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblWebTechMessage] ADD CONSTRAINT [pk_wtm_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tblWebTechMessage_receiveTime] ON [dbo].[tblWebTechMessage] ([receive_time]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblWebTechMessage] TO [public]
GO
GRANT INSERT ON  [dbo].[tblWebTechMessage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblWebTechMessage] TO [public]
GO
GRANT SELECT ON  [dbo].[tblWebTechMessage] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblWebTechMessage] TO [public]
GO
