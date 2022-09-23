CREATE TABLE [dbo].[edi_214_locationtracking]
(
[ord_hdrnumber] [int] NULL,
[eloc_nextlocreport] [datetime] NULL,
[eloc_interval] [int] NULL,
[eloc_lastckcall] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_ordhdrnumber] ON [dbo].[edi_214_locationtracking] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_214_locationtracking] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214_locationtracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214_locationtracking] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214_locationtracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214_locationtracking] TO [public]
GO
