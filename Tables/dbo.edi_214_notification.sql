CREATE TABLE [dbo].[edi_214_notification]
(
[e214n_id] [int] NOT NULL IDENTITY(1, 1),
[e214n_ord_hdrnumber] [int] NULL,
[e214n_stp_number] [int] NULL,
[e214n_dttm] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_214_notification] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214_notification] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214_notification] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214_notification] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214_notification] TO [public]
GO
